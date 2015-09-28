//
//  RRVMessageViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 9/8/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All Right Reserved.
//

#import "RRVMessageViewController.h"
#import "RRVConstants.txt"

@interface RRVMessageViewController ()

@end

@implementation RRVMessageViewController

#pragma mark Synthesizers

//Data
@synthesize autoplayEnabled, runningOniPad, messageTitle, messageText;

//Views
@synthesize backgroundImageView, titleLabel, textView, yesButton, noButton;

//Controllers

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void) dealloc {
    
    //Data
    [messageTitle release];
    [messageText release];
    
    //Views
    [backgroundImageView release];
    [titleLabel release];
    [textView release];
    [yesButton release];
    [noButton release];
    
    [super dealloc];
}

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.messageTitle = nil;
        self.messageText = nil;
    
        //Views
        self.backgroundImageView = nil;
        self.titleLabel = nil;
        self.textView = nil;
        self.yesButton = nil;
        self.noButton = nil;
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    BOOL shouldRotate;
    
    if (self.runningOniPad) shouldRotate = YES; //iPad - All orientations
    else shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait); //iPhone/iPod - Portrait only
    
    return shouldRotate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil iPad:(BOOL)isOniPad title:(NSString*)titleOfMessage description:(NSString*)messageBody {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.runningOniPad = isOniPad;
        self.messageTitle = [titleOfMessage copy];
        self.messageText = [messageBody copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Text
    [self.titleLabel setText:messageTitle];
    [self.textView setText:messageText];
}

#pragma mark IBActions

- (IBAction)quitMessage:(id)sender {
    
    //Save switch value, if in use
    if (sender == self.yesButton) [self saveAutoplayFlagToSettings:YES];
    else /*(sender == self.noButton)*/ [self saveAutoplayFlagToSettings:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RRVMessageQuitNotification object:self];
    
}

#pragma mark Utility

-(void) saveAutoplayFlagToSettings:(BOOL)shouldAutoplay {
    
    [[NSUserDefaults standardUserDefaults] setBool:shouldAutoplay forKey:key_StoryAutoplayUserDefaultsKey];
    
}

@end
