//
//  ARSPCPreviewView.h
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import <UIKit/UIKit.h>


//delegate to inform delegate when the user selects the title
@protocol  ARSPCPreviewViewDelegate <NSObject>

@required
-(void)previewViewUserSelectedTitle;

@end



@interface ARSPCPreviewView : UIView
{
	
}


@property (strong, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet UILabel *previewTitle;
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) id<ARSPCPreviewViewDelegate> delegate;


- (IBAction)userClickedTitle:(id)sender;

@end
