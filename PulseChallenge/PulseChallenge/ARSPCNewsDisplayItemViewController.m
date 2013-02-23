//
//  ARSPCNewsDisplayItemViewController.m
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import "ARSPCNewsDisplayItemViewController.h"
#import "UINavigationController+animationExtensions.h"

@interface ARSPCNewsDisplayItemViewController ()

@end

@implementation ARSPCNewsDisplayItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.webView loadHTMLString:self.newsObject.content baseURL:nil];
	[self.titleLabel setText:self.newsObject.title];
	
	//download and set the image up asynchronously
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *previewImageData = [NSData dataWithContentsOfURL:[[self.newsObject arrayOfMediaURLs] objectAtIndex:0]];
		__block UIImage *previewImage = [UIImage imageWithData:previewImageData];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.previewImageView setImage:previewImage];
		});
	});
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
