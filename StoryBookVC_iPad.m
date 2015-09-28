//
//  StoryBookVC_iPad.m
//  RRV101
//
//  Created by Brian C. Grant on 6/29/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "StoryBookVC_iPad.h"
#import "StoryPageViewController_iPad.h"

@implementation StoryBookVC_iPad

#pragma mark Synthesizers

//Data
@synthesize lessonNumber;
//Views
@synthesize storyPageViewArea;
//Controllers

#pragma mark - View Lifecycle -

#pragma mark Memory Management

-(void) dealloc {
    
    //Remove child VCs
    for (UIViewController* childViewController in [self childViewControllers]){
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
    }

    //Properties
    [storyPageViewArea release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
        
        self.storyPageViewArea = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.lessonNumber = lessonNumberToLoad;
        
    }
    return self;
    
}//End initWithNibName: bundle:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    StoryPageViewController_iPad* storyPageVC = [[[StoryPageViewController_iPad alloc] initWithNibName:@"StoryPageViewController_iPad" bundle:NULL forLesson:self.lessonNumber] autorelease];
    self.view.gestureRecognizers = storyPageVC.view.gestureRecognizers;

    [self addChildViewController:storyPageVC];
    [storyPageVC didMoveToParentViewController:self];
    [self.storyPageViewArea addSubview:storyPageVC.view];

}//End viewDidLoad

@end
