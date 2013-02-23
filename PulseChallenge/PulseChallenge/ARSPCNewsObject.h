//
//  ARSPCNewsObject.h
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARSPCNewsObject : NSObject
{
	
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *publishDate;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *author;

//We store all the media URLs for the images
@property (nonatomic, strong) NSMutableArray *arrayOfMediaURLs;

-(id)initWithDictionaryToParse:(NSDictionary *)preparsedDictionary;

@end
