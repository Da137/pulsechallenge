//
//  ARSPCNewsObject.m
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import "ARSPCNewsObject.h"

@implementation ARSPCNewsObject

-(id)initWithDictionaryToParse:(NSDictionary *)preparsedDictionary
{
	self = [super init];
	if (self) {
		[self setAuthor:[preparsedDictionary objectForKey:@"author"]];
		[self setContent:[preparsedDictionary objectForKey:@"content"]];
		[self setTitle:[preparsedDictionary objectForKey:@"title"]];
		
		//set up the URLS for the images this is a lower overhead than directly storing images
		self.arrayOfMediaURLs = [[NSMutableArray alloc] init];
		NSArray *mediaGroups = [preparsedDictionary objectForKey:@"mediaGroups"];
		NSArray *contentArray = [[mediaGroups objectAtIndex:0] objectForKey:@"contents"];
		
		//setup the dictionary of media URLS
		//Ideally we can use these for a slideshow of images later
		for (NSDictionary *contentDictionary in contentArray) {
			NSURL *urlOfImage = [NSURL URLWithString:[contentDictionary objectForKey:@"url"]];
			[self.arrayOfMediaURLs addObject:urlOfImage];
		}
	}
	return self;
}
@end
