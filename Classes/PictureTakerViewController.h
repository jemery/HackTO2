//
//  PictureTakerViewController.h
//  HackTO
//
//  Created by Jason Emery on 10-09-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PictureTakerViewController : UIViewController <UIImagePickerControllerDelegate> {

	IBOutlet UIButton *buttonTakeAPicture;
	IBOutlet UIImageView *imageView;
	UIImagePickerController *imagePickerController;
	NSData *imageData;
}

@property (nonatomic, retain) IBOutlet UIButton *buttonTakeAPicture;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) NSData *imageData;

- (IBAction)tappedTakeAPicture;

- (void)exifDataFromImage:(UIImage *)anImage;

@end
