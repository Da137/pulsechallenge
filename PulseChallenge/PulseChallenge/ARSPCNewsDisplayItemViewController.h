//
//  ARSPCNewsDisplayItemViewController.h
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSPCNewsObject.h"

@interface ARSPCNewsDisplayItemViewController : UIViewController
{
	
}

@property (strong, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) ARSPCNewsObject *newsObject; 

@end
