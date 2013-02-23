//
//  ARSPCViewController.h
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSPCPreviewView.h"

#define kFeedRequestURL @"https://ajax.googleapis.com/ajax/services/feed/load?q=http://feeds.feedburner.com/ommalik&v=1.0"
#define kDefaultTimeout	30

@interface ARSPCMainScreenViewController : UIViewController <UIScrollViewDelegate, ARSPCPreviewViewDelegate>{
	int currentActiveItem;
	UIView *contentView;
	
	//used for hot loading
	NSMutableArray *viewsThatHaveLoaded;//store the number for what veiws are loaded
    NSMutableArray *viewsWithNumbersThatHaveLoaded;
}

@property (strong, nonatomic) IBOutlet UIScrollView *newsScrollView;
@property (strong, nonatomic) NSMutableArray *newsObjects;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;


- (IBAction)refreshButtonClicked:(id)sender;

@end
