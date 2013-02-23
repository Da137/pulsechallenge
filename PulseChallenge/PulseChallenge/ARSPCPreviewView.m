//
//  ARSPCPreviewView.m
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import "ARSPCPreviewView.h"

@implementation ARSPCPreviewView

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		[[NSBundle mainBundle] loadNibNamed:@"ARSPCPreviewView" owner:self options:nil];
        [self addSubview:self.view];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFrame:frame];
        [self.view setFrame:CGRectIntegral(CGRectMake(0, 0, frame.size.width, frame.size.height))];
	}
	return self;
}


- (IBAction)userClickedTitle:(id)sender {
	if ([self.delegate respondsToSelector:@selector(previewViewUserSelectedTitle)]) {
		[self.delegate previewViewUserSelectedTitle];
	}
}
@end
