//
//  ASIHTTPRequestWrapper.h
//  HackTO
//
//  Created by Jason Emery on 10-09-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequestDelegate.h"

@interface ASIHTTPRequestWrapper : NSObject <ASIHTTPRequestDelegate> {

	id _target;
	SEL _selector;
}

+ (ASIHTTPRequestWrapper *)sharedASIHTTPRequestWrapper;

- (NSDictionary *)parseJson:(NSString *)rspr;
- (void)createRequest:(NSString *)requestString target:(id)target action:(SEL)selector;
- (void)getTrendingPosts:(NSInteger)hours target:(id)target action:(SEL)selector;

@end
