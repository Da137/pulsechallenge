//
//  UINavigationController+animationExtensions.m
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import "UINavigationController+animationExtensions.h"

@implementation UINavigationController (animationExtensions)



- (void)pushViewControllerCurlUp:(UIViewController*)viewController
{
    [self pushViewController:viewController animated:NO];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{}
                    completion:nil];
}

- (void)popViewControllerCurlDown
{
    [self popViewControllerAnimated:NO];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:nil
                    completion:nil];
}


@end
