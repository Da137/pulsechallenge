//
//  ARSPCViewController.m
//  PulseChallenge
//
//  Created by David Attaie on 22/02/2013.
//  Copyright (c) 2013 Angry Rocket Studios. All rights reserved.
//

#import "ARSPCMainScreenViewController.h"
#import "JSONKit.h"
#import "ARSPCNewsObject.h"
#import "ARSPCNewsDisplayItemViewController.h"
#import "UINavigationController+animationExtensions.h"

@interface ARSPCMainScreenViewController ()

@end

@implementation ARSPCMainScreenViewController

//--------------------------------------------------------------------------------------------

#pragma mark - View Lifecycle

//--------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.newsObjects = [[NSMutableArray alloc] init];
	[self.navigationItem setTitle:@"GigaOm"];
	[self.navigationItem setLeftBarButtonItem:self.refreshButton];
	[self fetchAll];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)displayNetworkFail
{
	//TODO: add delegate call and tie to refresh
	UIAlertView *networkFailView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to fetch news items please try again later" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
	[networkFailView show];
}

- (IBAction)refreshButtonClicked:(id)sender {
	
	//clear up array of news objects
	if (self.newsObjects) {
		[self.newsObjects removeAllObjects];
	}else{
		self.newsObjects = [[NSMutableArray alloc] init];
	}
	
	
	//clear up subviews on scroll view and set back to 0
	for (UIView *subview in self.newsScrollView.subviews) {
		[subview removeFromSuperview];
	}
	[self.newsScrollView setContentOffset:CGPointMake(0, 0)];
	
	
	//clean the hot load arrays
	if (viewsThatHaveLoaded) {
		[viewsThatHaveLoaded removeAllObjects];
	}
	
	if (viewsWithNumbersThatHaveLoaded) {
		[viewsWithNumbersThatHaveLoaded removeAllObjects];
	}
	
	//fetch the data again
	[self fetchAll];
}

//--------------------------------------------------------------------------------------------

#pragma mark - JSON Parsing and Management

//--------------------------------------------------------------------------------------------

-(void)fetchAll
{
	//add an activity indicator view to the superview and begin loading
	__block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator setCenter:self.view.center];
	[activityIndicator startAnimating];
	[self.view addSubview:activityIndicator];
	
	//dispatch our request to get the JSON data from the server
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//create and set up the network request
		NSURL *requestURL = [NSURL URLWithString:kFeedRequestURL];
		NSHTTPURLResponse *response = nil;
		NSError *error = nil;
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL
																	cachePolicy:NSURLRequestUseProtocolCachePolicy
																timeoutInterval:kDefaultTimeout];
		[request addValue:@"0" forHTTPHeaderField:@"Content-Length"];
		[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		
		//perform the network request synchronously (since we're already in another thread)
		NSData *result = [NSURLConnection sendSynchronousRequest:request
											   returningResponse:&response error:&error];
		
		if (error) {
			//update the UI on the main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[activityIndicator removeFromSuperview];
				[self displayNetworkFail];
			});
			return;
		}
		
		//setup a JSON decoder
		JSONDecoder *decoder = [[JSONDecoder alloc] init];
		
		//parse the JSON data
		NSDictionary *outputFromDecoder = [decoder objectWithData:result];
		if (!outputFromDecoder || [[outputFromDecoder objectForKey:@"responseStatus"] intValue] < 200) {
			//update the UI on the main thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[activityIndicator removeFromSuperview];
				[self displayNetworkFail];
			});
			return;
		}
		
		//begin parsing the json data to get the requirements for displaying the news objects
		NSDictionary *responseDataFromDecoder = [outputFromDecoder objectForKey:@"responseData"];
		NSDictionary *feedFromResponseData = [responseDataFromDecoder objectForKey:@"feed"];
		NSArray *entriesFromFeed = [feedFromResponseData objectForKey:@"entries"];
		
		//for every news entry we find, we add them to our news objects array
		for (NSDictionary *contentItem in entriesFromFeed) {
			ARSPCNewsObject	*newsObject = [[ARSPCNewsObject alloc] initWithDictionaryToParse:contentItem];
			[self.newsObjects addObject:newsObject];
		}
		
		//update the UI on the main thread
		dispatch_async(dispatch_get_main_queue(), ^{
			[activityIndicator removeFromSuperview];
			[self updateScrollView];
		});
		
	});

}

//--------------------------------------------------------------------------------------------

#pragma mark - Scroll View Management and Delegate Functions

//--------------------------------------------------------------------------------------------

-(void)updateScrollView
{
	
	//setup content view and add to scroll
	contentView = [[UIView alloc] initWithFrame:CGRectMake(0,
														   0,
														   [self.newsObjects count] * self.newsScrollView.frame.size.width,
														   self.newsScrollView.frame.size.height)];
	currentActiveItem = 0;
	[self.newsScrollView setContentSize:contentView.frame.size];
	[self.newsScrollView addSubview:contentView];
	
	//hot load the first and next page
	[self loadCurrentPage];
	[self loadNextPage];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int previousPage = currentActiveItem;
    currentActiveItem = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	
	//if we havent moved page, or we havent changed items then dont do any loading
    if (currentActiveItem == previousPage ||
        currentActiveItem < 0 ||
        previousPage < 0 ||
        currentActiveItem >= [self.newsObjects count] ||
        previousPage >= [self.newsObjects count]) {
        return;
    }
	
    [self loadNextPage];
    [self loadPrevPage];
}


//--------------------------------------------------------------------------------------------

#pragma mark - Hot Load Pages

//--------------------------------------------------------------------------------------------

-(void)loadNextPage
{
    //we load the images from the server
    int nextPage = currentActiveItem + 1;
    if (nextPage >= [self.newsObjects count]) {
        return;
    }
    
    for (NSNumber *number in viewsThatHaveLoaded) {
        if ([number intValue] == nextPage) {
            return;//we've already loaded that page dont load it again
        }
    }
    [viewsThatHaveLoaded addObject:[NSNumber numberWithInt:nextPage]];
    
	
	//we use a container view to control the size of the objects we're displaying
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(nextPage * self.newsScrollView.frame.size.width,
                                                                     0,
                                                                     self.newsScrollView.frame.size.width,
                                                                     contentView.frame.size.height)];
    [contentView addSubview:containerView];
	
	//set up the preview view and set the delegate
    ARSPCPreviewView *nextPreviewView = [[ARSPCPreviewView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               self.newsScrollView.frame.size.width,
                                                                               contentView.frame.size.height)];
	[nextPreviewView setDelegate:self];
    [nextPreviewView setContentMode:UIViewContentModeScaleAspectFill];
    [nextPreviewView setClipsToBounds:YES];

    //set the image and title data for the preview view
    ARSPCNewsObject *newsObject = [self.newsObjects objectAtIndex:nextPage];
    [[nextPreviewView previewTitle] setText:newsObject.title];
	
	//download and set the image up
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	NSData *previewImageData = [NSData dataWithContentsOfURL:[[newsObject arrayOfMediaURLs] objectAtIndex:0]];
	__block UIImage *previewImage = [UIImage imageWithData:previewImageData];
		dispatch_async(dispatch_get_main_queue(), ^{
			[[nextPreviewView previewImageView] setImage:previewImage];
		});
	});
	
	
	//add to content view
	[containerView addSubview:nextPreviewView];
	
	//set the hot load values so that we know what views are loaded activley
    NSDictionary *dic = @{@"number" : [NSNumber numberWithInt:nextPage], @"imageview" : containerView};
    [viewsWithNumbersThatHaveLoaded addObject:dic];
    
    [self clearup];
	
}

-(void)loadPrevPage
{
    //we load the images from the server
    int prevPage = currentActiveItem - 1;
    if (prevPage < 0 || prevPage > [self.newsObjects count]-1) {
        return;
    }
    
    for (NSNumber *number in viewsThatHaveLoaded) {
        if ([number intValue] == prevPage) {
            return;//we've already loaded that page dont load it again
        }
    }
    [viewsThatHaveLoaded addObject:[NSNumber numberWithInt:prevPage]];
	
	//we use a container view to control the size of the objects we're displaying
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(prevPage * self.newsScrollView.frame.size.width,
                                                                     0,
                                                                     self.newsScrollView.frame.size.width,
                                                                     contentView.frame.size.height)];
    [contentView addSubview:containerView];
    
	//setup the preview view and set the delegate
    ARSPCPreviewView *prevPreviewView = [[ARSPCPreviewView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               self.newsScrollView.frame.size.width,
                                                                               contentView.frame.size.height)];
	[prevPreviewView setDelegate:self];
    [prevPreviewView setContentMode:UIViewContentModeScaleAspectFill];
    [prevPreviewView setClipsToBounds:YES];
	
    //set the image and title data for the preview view
	ARSPCNewsObject *newsObject = [self.newsObjects objectAtIndex:prevPage];
    [[prevPreviewView previewTitle] setText:newsObject.title];
	
	//download and set the image up
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *previewImageData = [NSData dataWithContentsOfURL:[[newsObject arrayOfMediaURLs] objectAtIndex:0]];
		__block UIImage *previewImage = [UIImage imageWithData:previewImageData];
		dispatch_async(dispatch_get_main_queue(), ^{
			[[prevPreviewView previewImageView] setImage:previewImage];
		});
	});
	
	//add to content view
	[containerView addSubview:prevPreviewView];
    
	//set the hot load values so that we know what views are loaded activley
    NSDictionary *dic = @{@"number" : [NSNumber numberWithInt:prevPage], @"imageview" : containerView};
    [viewsWithNumbersThatHaveLoaded addObject:dic];
	
    
    [self clearup];
	
}

-(void)loadCurrentPage
{
    //we load the images from the server
    for (NSNumber *number in viewsThatHaveLoaded) {
        if ([number intValue] == currentActiveItem) {
            return;//we've already loaded that page dont load it again
        }
    }
    [viewsThatHaveLoaded addObject:[NSNumber numberWithInt:currentActiveItem]];
    
	//we use a container view to control the size of the objects we're displaying
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(currentActiveItem * self.newsScrollView.frame.size.width,
                                                                     0,
                                                                     self.newsScrollView.frame.size.width,
                                                                     contentView.frame.size.height)];
    [contentView addSubview:containerView];
	
	//set up the preview view and set the delegate
    ARSPCPreviewView *currentPreviewView = [[ARSPCPreviewView alloc] initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  self.newsScrollView.frame.size.width,
                                                                                  contentView.frame.size.height)];
	[currentPreviewView setDelegate:self];
    [currentPreviewView setContentMode:UIViewContentModeScaleAspectFill];
    [currentPreviewView setClipsToBounds:YES];
	
	//set the image and title data for the preview view
	ARSPCNewsObject *newsObject = [self.newsObjects objectAtIndex:currentActiveItem];
    [[currentPreviewView previewTitle] setText:newsObject.title];
	
	//download and set the image up
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSData *previewImageData = [NSData dataWithContentsOfURL:[[newsObject arrayOfMediaURLs] objectAtIndex:0]];
		__block UIImage *previewImage = [UIImage imageWithData:previewImageData];
		dispatch_async(dispatch_get_main_queue(), ^{
			[[currentPreviewView previewImageView] setImage:previewImage];
		});
	});
    
	//add to content view
	[containerView addSubview:currentPreviewView];
	
    //set the hot load values so that we know what views are loaded activley
    NSDictionary *dic = @{@"number" : [NSNumber numberWithInt:currentActiveItem], @"imageview" : containerView};
    [viewsWithNumbersThatHaveLoaded addObject:dic];
    
    [self clearup];
}

-(void)clearup
{
    NSMutableArray *newViewsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in viewsWithNumbersThatHaveLoaded) {
        NSNumber *num = [dic objectForKey:@"number"];
        int pageNumber = [num intValue];
        if (pageNumber  < currentActiveItem - 3 || pageNumber > currentActiveItem + 3) {
            UIView *imgView = [dic objectForKey:@"imageview"];
            [imgView removeFromSuperview];
            [self removeNumber:num];
        }else{
            [newViewsArray addObject:dic];
            
        }
    }
    [viewsWithNumbersThatHaveLoaded removeAllObjects];
    [viewsWithNumbersThatHaveLoaded setArray:newViewsArray];
}


-(void)removeNumber:(NSNumber *)numberToRemove
{
    NSMutableArray *newViewsArray = [[NSMutableArray alloc] init];
    int intToRemove = [numberToRemove intValue];
    for (NSNumber *subArrayNumber in viewsThatHaveLoaded) {
        int subPageNumber = [subArrayNumber intValue];
        if (intToRemove != subPageNumber) {
            [newViewsArray addObject:subArrayNumber];
        }
    }
    [viewsThatHaveLoaded removeAllObjects];
    [viewsThatHaveLoaded setArray:newViewsArray];
}

//--------------------------------------------------------------------------------------------

#pragma mark - Preview View Delegate Methods

//--------------------------------------------------------------------------------------------

-(void)previewViewUserSelectedTitle
{
	//instantiate the view controller
	ARSPCNewsDisplayItemViewController *newsDisplayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsDisplayViewController"];
	
	//setup with the news object we have active at the moment
	ARSPCNewsObject *newsObject = [self.newsObjects objectAtIndex:currentActiveItem];
	[newsDisplayViewController setNewsObject:newsObject];
	
	//push the view controller with an animation
//	[self.navigationController pushViewControllerCurlUp:newsDisplayViewController];
	[self.navigationController pushViewController:newsDisplayViewController animated:YES];
}


@end
