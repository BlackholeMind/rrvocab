//
//  TheEndPage.m
//  RRV101
//
//  Created by Brian C. Grant on 3/20/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "TheEndPage.h"
#import "RRVConstants.txt"

@implementation TheEndPage

#pragma mark Synthesizers

@synthesize pageNumberForView, pageAutoplayEnabled;
@synthesize continueButton;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc {
    
    //Notifications
    
    //Delegation
    
    //Data
    
    //Views
    [continueButton release];
    
    [super dealloc];
}

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not visible
    
    //Release any cached data, views, etc that aren't in use.
    self.continueButton = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageNumber:(NSInteger)pageNum
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.pageNumberForView = pageNum;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pageAutoplayEnabled = NO; //Only set to YES in [self autoplay];
}

#pragma mark - Actions -

- (IBAction) continueButtonPressed:(id)sender  {//Fired when user presses continueButton
    
    //Post notification that the story is finished
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryFinishedNotification object:self];

}

#pragma mark - Utility -

- (void) autoplay {
    
    self.pageAutoplayEnabled = YES;
    
    //Wait, then end
    [self performSelector:@selector(autoplayEnd) withObject:self afterDelay:1.0];
    
}

- (void) autoplayEnd {
    
    self.pageAutoplayEnabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryPageAutoplayCompleteNotification object:self];
}



@end
