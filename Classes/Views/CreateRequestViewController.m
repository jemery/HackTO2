//
//  CreateRequestViewController.m
//  HackTO
//
//  Created by Jason Emery on 10-09-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CreateRequestViewController.h"
#import "ASIHTTPRequestWrapper.h"

#import <MediaPlayer/MediaPlayer.h>

@implementation CreateRequestViewController

static double back = 168;

- (id)init
{
	if (self = [super initWithNibName:@"CreateRequestView" bundle:nil]) {
		finalDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark View lifecycle
- (void)viewDidLoad
{
	NSString *rootPath = [[NSBundle mainBundle] resourcePath];
	NSString *filePath = [rootPath stringByAppendingPathComponent:@"example.mov"];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
	MPMoviePlayerController *yourMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: fileURL];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)tappedLogin
{
	NSLog(@"tappedLogin");
	[[ASIHTTPRequestWrapper sharedASIHTTPRequestWrapper] getTrendingPosts:back target:self action:@selector(postsResponse:)];
}

- (void)related
{
}

- (void)getRelated:(NSDictionary *)related parent:(double)parent
{
	double i = 0;
	
	for (NSDictionary *post in related)
	{
		NSDictionary *user = [post objectForKey:@"user"];
		NSString *username = [user objectForKey:@"name"];
		
		double weight = back / (++i + parent);
		[finalDictionary setObject:[NSNumber numberWithDouble:weight] forKey:username];
	}
}

#pragma mark -
#pragma mark Responses
- (void)postsResponse:(NSDictionary *)response
{
	//NSLog(@"Response: %@", response);
	double i = 0;
	int totalcount = 0;
	for (NSDictionary *key in response)
	{
		NSDictionary *user = [key objectForKey:@"user"];
		NSString *username = [user objectForKey:@"name"];

		double weight = back / ++i;
		totalcount += i;
		[finalDictionary setObject:[NSNumber numberWithDouble:weight] forKey:username];
		
		NSDictionary *related = [key objectForKey:@"related"];
		if (related != nil) {
			[self getRelated:related parent:i];
		}
		
		//NSLog(@"username:%@ weight:%f", username, weight);
	}
	
	//NSLog(@"finalCount:%f finalDictionary:%@", i, finalDictionary);
	for (NSString *name in finalDictionary) {
		totalcount++;
		NSDecimalNumber *value = [finalDictionary objectForKey:name];
		//if ([value doubleValue] > 30) {
			NSLog(@"name:%@ weight:%f", name, [value doubleValue]);
		//}
	}
	
	NSLog(@"total count %d", totalcount);
}


#pragma mark -
#pragma mark Response

- (void)dealloc {
	[finalDictionary release];
    [super dealloc];
}


@end
