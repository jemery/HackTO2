//
//  PictureTakerViewController.m
//  HackTO
//
//  Created by Jason Emery on 10-09-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PictureTakerViewController.h"

#import "libexif/exif-data.h"
#import "libexif/exif-content.h"

@implementation PictureTakerViewController

@synthesize buttonTakeAPicture;
@synthesize imageView;
@synthesize imagePickerController;
@synthesize imageData;


#pragma mark -
#pragma mark Initialization

- (id)init
{
	NSLog(@"initializing");
	if (self = [super initWithNibName:@"PictureTakerView" bundle:nil])
	{
		self.imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	buttonTakeAPicture.enabled = NO;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		NSArray *types = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
		NSLog(@"types %@", types);
		for (NSString *type in types) {
			if ([type isEqualToString:@"public.image"]) {
				buttonTakeAPicture.enabled = YES;
				//imagePickerController.mediaTypes = [NSArray arrayWithObjects:kUTTypeImage, nil];
			}
		}
	}
}


#pragma mark -
#pragma mark IBActions

- (IBAction)tappedTakeAPicture
{
	NSLog(@"tappedTakeAPicture imagePickerController %@", imagePickerController);
	[self presentModalViewController:imagePickerController animated:YES];
}


#pragma mark -
#pragma mark EXIF

/** Callback function handling an ExifEntry. */
void content_foreach_func(ExifEntry *entry, void *callback_data);
void content_foreach_func(ExifEntry *entry, void *callback_data)
{
	char buf[2000];
	exif_entry_get_value(entry, buf, sizeof(buf));
	printf("    Entry %p: %s (%s)\n"
		   "      Size, Comps: %d, %d\n"
		   "      Value: %s\n", 
		   entry,
		   exif_tag_get_name(entry->tag),
		   exif_format_get_name(entry->format),
		   entry->size,
		   (int)(entry->components),
		   exif_entry_get_value(entry, buf, sizeof(buf)));
}

/** Callback function handling an ExifContent (corresponds 1:1 to an IFD). */
void data_foreach_func(ExifContent *content, void *callback_data);
void data_foreach_func(ExifContent *content, void *callback_data)
{
	printf("  Content %p: ifd=%d\n", content, exif_content_get_ifd(content));
	exif_content_foreach_entry(content, content_foreach_func, callback_data);
}


/** Run EXIF parsing test on the given file. */
void test_parse(const char *filename, void *callback_data);
void test_parse(const char *filename, void *callback_data)
{
	ExifData *d;
	printf("File %s\n", filename);
	
	d = exif_data_new_from_file(filename);
	exif_data_foreach_content(d, data_foreach_func, callback_data);
	exif_data_unref(d);
}


/** Callback function prototype for string parsing. */
typedef void (*test_parse_func) (const char *filename, void *callback_data);


/** Split string at whitespace and call callback with each substring. */
void split_ws_string(const char *string, test_parse_func func, void *callback_data);
void split_ws_string(const char *string, test_parse_func func, void *callback_data)
{
	const char *start = string;
	const char *p = start;
	for (;;) {
		if (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r' || *p == '\0' ) {
			size_t len = p-start;
			if (len > 0) {
				/* emulate strndup */
				char *str = malloc(1+len);
				if (str) {
					memcpy(str, start, len);
					str[len] = '\0';
					func(str, callback_data);
					free(str);
					start = p+1;
				}
			} else {
				start = p+1;
			}
		}
		if (*p == '\0') {
			break;
		}
		p++;
	}  
}

- (void)exifDataFromImage:(UIImage *)anImage
{
	NSData *jpgData = UIImageJPEGRepresentation(anImage, 1.0);
	ExifData *data = exif_data_new_from_data((void *)jpgData, jpgData.length);
	
	//exif_data_foreach_content(data, data_foreach_func, callback_data);
	
	void *callback_data = NULL;
	test_parse("/private/var/mobile/Media/DCIM/100APPLE/*", callback_data);
	exif_data_unref(data);
	
	//	NSData *uiJpeg = UIImageJPEGRepresentation(anImage, 1.0);
	//	
	//	EXFJpeg* jpegScanner = [[EXFJpeg alloc] init];
	//	[jpegScanner scanImageData:uiJpeg];
	//	//self.imageData = jpegScanner;
	//	EXFMetaData* exifData = [jpegScanner exifMetaData];
	//	
	//	id longitude = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLongitude]];
	//	id longitudeRef = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLongitudeRef]];
	//	
	//	NSLog(@"Longitude: %@ %@", longitudeRef, longitude);
	//	
	//	[jpegScanner release];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	//
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSLog(@"didFinishPickingMediaWithInfo %@ info:%@", info);
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	//UIImage *image = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];

	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);

	[imagePickerController dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[imagePickerController dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	NSLog(@"didFinishSavingWithError context info %@", contextInfo);
	[self exifDataFromImage:image];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[imagePickerController release];
    [super dealloc];
}


@end
