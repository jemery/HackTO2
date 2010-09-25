//
//  ASIHTTPRequestWrapper.m
//  HackTO
//
//  Created by Jason Emery on 10-09-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ASIHTTPRequestWrapper.h"
#import "SynthesizeSingleton.h"

// ASIHTTPRequest lib includes
#import "ASIHTTPRequest.h"

// JSON lib includes
#import "JSON.h"


#define TRUSTED_HOSTS_ARRAY [NSArray arrayWithObjects:		\
@"graupel.oanda.com", nil]


@implementation ASIHTTPRequestWrapper

SYNTHESIZE_SINGLETON_FOR_CLASS(ASIHTTPRequestWrapper);

#pragma mark -
#pragma mark JSON decompression

- (NSDictionary *)parseJson:(NSString *)rspr
{
	//NSString *utf = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
	
	SBJsonParser* parser = [[SBJsonParser alloc] init];		
	id parsedData = [parser objectWithString:rspr];	
	[parser release];
	return (NSDictionary*) parsedData;
}


#pragma mark -
#pragma mark ASIHTTPRequestWrapper

- (void)createRequest:(NSString *)requestString target:(id)target action:(SEL)selector
{
	//NSString *apiKey = @"2b04a753-cd63-748b-fc39-832a184b4ff6";
	
	_target = target;
	_selector = selector;
	
	NSLog(@"createRequest");
	//NSURL *url = [NSURL URLWithString:@"https://graupel.oanda.com/v1/user/login.json?api_key=12345&username=jemery&password=foobar"];
	//NSURL *url = [NSURL URLWithString:@"https://fxgame-webapi.oanda.com/v1/user/login.json?api_key=0325ee6232373738&username=jemery&password=foobar"];
	NSURL *url = [NSURL URLWithString:requestString];

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setTimeOutSeconds:10];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSDictionary *d = [self parseJson:responseString];
	//NSLog(@"response: %@", d);
	[_target performSelector:_selector withObject:d];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"error: %@", error);
}


#pragma mark get posts

- (void)getTrendingPosts:(NSInteger)hours target:(id)target action:(SEL)selector
{
	NSString *requestString = [NSString stringWithFormat:@"http://thecadmus.com/api/posts/%d?key=2b04a753-cd63-748b-fc39-832a184b4ff6", hours];
	[self createRequest:requestString target:target action:selector];
}


#pragma mark -
#pragma mark Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"challenge.protectionSpace.host %@", challenge.protectionSpace.host);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		NSArray *trustedHosts = TRUSTED_HOSTS_ARRAY;
		if ([trustedHosts containsObject:challenge.protectionSpace.host]) {
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space
{
	if([[space authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		BOOL shouldAllowSelfSignedCert = YES;
		if(shouldAllowSelfSignedCert) {
			return YES; // Self-signed cert will be accepted
		} else {
			return NO;  // Self-signed cert will be rejected
		}
		// Note: it doesn't seem to matter what you return for a proper SSL cert
		//       only self-signed certs
	}
	// If no other authentication is required, return NO for everything else
	// Otherwise maybe YES for NSURLAuthenticationMethodDefault and etc.
	return NO;
}

@end
