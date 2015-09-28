//
//  QuizSubmitViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 3/29/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "QuizSubmitViewController.h"
#import "RRVConstants.txt"

@implementation QuizSubmitViewController

#pragma mark Synthesizers

@synthesize submitButton, instructionTextView;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc {
    
    //Views
    [submitButton release];
    [instructionTextView release];
    
    [super dealloc];
    
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Views
        self.submitButton = nil;
        self.instructionTextView = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
    
}//end initWithNibName: bundle:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}//End viewDidLoad

#pragma mark - Actions -

-(IBAction) submit:(id)sender {//User pressed submit button
    
    //Hide button & inform user
    [self.submitButton setHidden:YES];
    [self.instructionTextView setText:@"Your quiz has been submitted!"];
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizSubmittedNotification object:self];
    
}//End submit:

@end
