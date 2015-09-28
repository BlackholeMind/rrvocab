//
//  StoryPageViewController_iPad.m
//  RRV101
//
//  Created by Brian C. Grant on 1/22/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "StoryPageViewController_iPad.h"
#import "StoryViewController_iPad.h"
#import "DefinitionView.h"
#import "WordObject.h"
#import "RRVConstants.txt"

@implementation StoryPageViewController_iPad

#pragma mark Synthesizers

//Data
@synthesize storyAutoplayEnabled, lessonNumber, currentPage, arrayOfPageTexts;

//Views
@synthesize autoplayMountView, autoplayButton;

//Controllers
@synthesize pageVC;
@synthesize definitionPopover;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Children
    for (UIViewController* childVC in [pageVC viewControllers]) {
        [childVC willMoveToParentViewController:nil];
        [childVC removeFromParentViewController];
    }
    
    //Delegation
    self.pageVC.delegate = nil;
    self.pageVC.dataSource = nil;
    self.definitionPopover.delegate = nil;
    
    //Data
    [arrayOfPageTexts release];
    
    //Views
    [autoplayMountView release];
    [autoplayButton release];
    
    //Controllers
    [pageVC release];
    [definitionPopover release];
    
    [super dealloc];
}

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.arrayOfPageTexts = nil;
    
        //Views
        self.autoplayMountView = nil;
        self.autoplayButton = nil;
    
        //Controllers
        self.pageVC = nil;
        self.definitionPopover = nil;
    
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    // Return YES for supported orientations
    return YES;
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}

#pragma mark Setup

//Custom initializer includes lessonNumberToLoad
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.lessonNumber = lessonNumberToLoad;
        self.currentPage = 0;
        self.arrayOfPageTexts = [self textArrayForLesson];
        self.storyAutoplayEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Configure the page view controller and add it as a child view controller.
    NSDictionary* pageViewControllerOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid] forKey:UIPageViewControllerOptionSpineLocationKey]; //options dictionary sets spine location
    self.pageVC = [[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:pageViewControllerOptions] autorelease];
    self.pageVC.delegate = self;
    self.pageVC.dataSource = self;
    
    //Set intial view controllers & observers
    StoryViewController_iPad* titlePage = [self storyPageForPageNumber:0];
    StoryViewController_iPad* firstPage = [self storyPageForPageNumber:1];
    NSArray* viewControllers = [NSArray arrayWithObjects:titlePage, firstPage, nil];
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyPageBeginReadInfo:) name:StoryPageReadInfoBeginNotification object:titlePage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyPageBeginReadInfo:) name:StoryPageReadInfoBeginNotification object:firstPage];
    
    // Set the page view controller's bounds
    CGRect pageViewRect = self.view.bounds;
    self.pageVC.view.frame = pageViewRect;
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.view sendSubviewToBack:self.pageVC.view];
    [self.pageVC didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to this view controller's view so that the gestures are started more easily.
    for (UIGestureRecognizer* gestureRecognizer in self.pageVC.gestureRecognizers) {
        gestureRecognizer.delegate = self;
    }
    self.view.gestureRecognizers = self.pageVC.gestureRecognizers;
    
    //Check autoplay
    if (self.storyAutoplayEnabled) [self performSelector:@selector(autoplay) withObject:nil afterDelay:1.0];
}

#pragma mark - Data Sources -

#pragma mark UIPageViewController

//Next view controller
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    
    
    //Grab the reference viewController
    StoryViewController_iPad* viewControllerCasted = (StoryViewController_iPad*)viewController;
    NSLog(@"viewControllerAfterViewController: Page = %d", viewControllerCasted.pageNumberForView);
    
    //Conceptualize maxPageNumber
    //Title(0) + Content + TheEnd = (arrayOfPageTexts) + BlankPage(s) = (maxPageNumber)
    //Odd#: Last page is TheEnd :)
    //Even#: Last page is blank :)
    NSInteger maxPageNumber = [self.arrayOfPageTexts count] + 1; //integer represents # of trailing blank pages
    NSLog(@"%d", maxPageNumber);
    
    //Access the StoryViewController_iPad property: pageNumberForView
    if (viewControllerCasted.pageNumberForView + 1 <= maxPageNumber) { //Both page numbers valid
        return [self storyPageForPageNumber: viewControllerCasted.pageNumberForView + 1];
    }
    else {
        return nil;
    }
    
}//End pageViewController: viewControllerAfterViewController:

//Previous view controller
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    StoryViewController_iPad* viewControllerCasted = (StoryViewController_iPad*)viewController;
    NSLog(@"viewControllerBeforeViewController: Page = %d", viewControllerCasted.pageNumberForView);
    
    if (viewControllerCasted.pageNumberForView - 1 >= 0) {
        return [self storyPageForPageNumber: viewControllerCasted.pageNumberForView - 1];
    }
    else {
        return nil;
    }
    
}//End pageViewController: viewControllerBeforeViewController:

#pragma mark - Delegates -

#pragma makr UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer //Manually deny gestures because UIPageViewController is broken =P
{
    
    //Make sure we're not trying to turn backward past the first page:
    if ([(StoryViewController_iPad*)[self.pageVC.viewControllers objectAtIndex:0] pageNumberForView] == 0) { //Beginning page?
        
        if ([(UISwipeGestureRecognizer*)gestureRecognizer isMemberOfClass:[UISwipeGestureRecognizer class]] && [(UISwipeGestureRecognizer*)gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight) {
            //Trying to swipe to the right (turn page back/leftward)
            NSLog(@"DENIED SWIPE NEXT ON LAST PAGE");
            return NO;
            
        }
        
        if ([(UIPanGestureRecognizer*)gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
            [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].x > 0.0f) {
            NSLog(@"DENIED PAN PREVIOUS ON FIRST PAGE");
            return NO;
        }
        
        if ([(UITapGestureRecognizer*)gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
            [(UITapGestureRecognizer*)gestureRecognizer locationInView:gestureRecognizer.view].x < self.view.frame.size.width/2) {
            NSLog(@"DENIED TAP PREVIOUS ON FIRST PAGE");
            return NO;
        }
    }
    
    //Make sure we're not trying to turn forward past the last page:
    NSInteger maxPageNumber = [self.arrayOfPageTexts count]+1; // +Integer <-- trailing blank pages
    
    if (self.currentPage + 2 > maxPageNumber || self.currentPage + 3 > maxPageNumber) { //Either page is invalid
        
        if ([(UISwipeGestureRecognizer*)gestureRecognizer isMemberOfClass:[UISwipeGestureRecognizer class]] && [(UISwipeGestureRecognizer*)gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight) {
            //Trying to swipe to the left (turn page forward/rightward) past end
            NSLog(@"DENIED SWIPE NEXT ON LAST PAGE");
            return NO;
        }
        
        if ([(UIPanGestureRecognizer*)gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
            [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].x < 0.0f) {
            NSLog(@"DENIED PAN NEXT ON LAST PAGE");
            return NO;
        }
        
        if ([(UITapGestureRecognizer*)gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
            [(UITapGestureRecognizer*)gestureRecognizer locationInView:gestureRecognizer.view].x > self.view.frame.size.width/2) {
            NSLog(@"DENIED TAP NEXT ON LAST PAGE");
            return NO;
        }
    }
    
    return YES;
}

#pragma mark UIPageViewController

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    NSLog(@"willTransitionToViewControllers!!!!!");
    [self.autoplayButton setHidden:YES];
    
}

//Transition detection
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    NSLog(@"didFinishAnimating!!!!!");
    
    [self.autoplayButton setHidden:NO];
    
    if (finished) {
        
        //Resume autoplay?
        if (self.storyAutoplayEnabled) [self performSelector:@selector(autoplay) withObject:nil afterDelay:0.0];
        
    }
    
    if (completed) {
        
        //Set current page to left hand page of new position
        self.currentPage = [(StoryViewController_iPad*)[[pageViewController viewControllers] objectAtIndex:0] pageNumberForView];
        
        //Remove reader observers from previous page & add to new views
        if (previousViewControllers && [previousViewControllers count] > 0) { //If previous view controllers exists and not empty
            
            //Replace observers
            StoryViewController_iPad* prevFirstPageVC = [previousViewControllers objectAtIndex:0];
            StoryViewController_iPad* newFirstPageVC = [[pageViewController viewControllers] objectAtIndex:0];
            [self removeObserversForStoryPage:prevFirstPageVC];
            [self attachObserversForStoryPage:newFirstPageVC];
             
            //Then 2nd page, if exists
            if ([previousViewControllers count] == 2) {
                
                //Replace observers
                StoryViewController_iPad* prevSecondPageVC = [previousViewControllers objectAtIndex:1];
                StoryViewController_iPad* newSecondPageVC = [[pageViewController viewControllers] objectAtIndex:1];
                [self removeObserversForStoryPage:prevSecondPageVC];
                [self attachObserversForStoryPage:newSecondPageVC];
                
            }//End if{} (2nd page exists)
            
            
        }//End if{} (1st page exists)
        
         
        
    }//End if{} (User completed a transition)
     
}//End pageViewController: didFinishAnimating: previousViewControllers: transitionCompleted:

#pragma mark UIPopoverController

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    [self.view setUserInteractionEnabled:YES];
    
    //Resume playback on first visible page
    [self resumeStoryPlaybackOnPage:[[self.pageVC viewControllers] objectAtIndex:0]];
    
}//End popoverControllerDidDismissPopover:

#pragma mark - Actions -

- (IBAction) toggleAutoplay:(id)sender {
    
    if (self.storyAutoplayEnabled) { [self pauseStoryPlayback]; }
    else { [self autoplay]; }
    
}//End toggleAutoplay

#pragma mark - Callbacks -

-(void) storyPageBeginReadInfo: (NSNotification*)notification {
    
    //1. Ensure concurrent story page audio reader stopped
    StoryViewController_iPad* storyPage = [notification object];
    
    if ([[self.pageVC viewControllers] count] == 2) { //If 2 pages
    
        StoryViewController_iPad* leftHandPage = [[self.pageVC viewControllers] objectAtIndex:0];
        StoryViewController_iPad* rightHandPage = [[self.pageVC viewControllers] objectAtIndex:1];
    
        if (storyPage == leftHandPage) { //Left hand page
        
            //Ensure RIGHT side reader is stopped
            if ([rightHandPage.storyReader isPlaying]) {
                [rightHandPage.storyReader stop];
                [rightHandPage.storyReader prepareToPlay];
                
            }
            
            //Ensure textView not colored & autoplay off
            [rightHandPage.textView setBackgroundColor:[UIColor clearColor]];
            [rightHandPage setPageAutoplayEnabled:NO];
        
        }
        else if (storyPage == rightHandPage) { //Right hand page
    
            //Ensure LEFT side reader is stopped
            if ([leftHandPage.storyReader isPlaying]) {
                [leftHandPage.storyReader stop];
                [rightHandPage.storyReader prepareToPlay];
                
            }
            
            //Ensure textView not colored & autoplay off
            [leftHandPage.textView setBackgroundColor:[UIColor clearColor]];
            [leftHandPage setPageAutoplayEnabled:NO];
        
        }
        else {
            NSLog(@"Logic Error: storyPageBeginReadInfo (callback) - page pointer does not point to a pageVC view controller.");
        }
    
    }//End if{} (2 pages)
    
}//End storyPageBeginReadInfo:

-(void) openDefinitionPopover: (NSNotification*)notification {
    
    [self.view setUserInteractionEnabled:NO];
    
    //Pause page playback
    [self pauseStoryPlayback];
    
    //Catch word
    NSString* wordToOpen = [[notification userInfo] objectForKey:key_WordToLoadDictionaryKey];
    NSLog(@"openDefinitionPopover: %@", wordToOpen);
    
    //Open definition popover
        //ViewController
    CGSize popoverSize = CGSizeMake(350.0, 200.0);
    DefinitionView* wordViewModalViewController = [[[DefinitionView alloc] initWithNibName:@"DefinitionView" bundle:NULL forWordObject:[WordObject loadWord:wordToOpen fromLesson:self.lessonNumber]] autorelease];
    wordViewModalViewController.view.frame = CGRectMake(0.0, 0.0, popoverSize.width, popoverSize.height);
        //Popover
    self.definitionPopover = [[[UIPopoverController alloc] initWithContentViewController:wordViewModalViewController] autorelease];
    self.definitionPopover.delegate = self;
    self.definitionPopover.popoverContentSize = popoverSize;
    
    [self.definitionPopover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width/2-popoverSize.width/2, self.view.bounds.size.height/2-popoverSize.height/2, popoverSize.width, popoverSize.height) inView:self.view permittedArrowDirections:0 animated:YES];
    
}

- (void) autoplayFirstPageComplete: (NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:StoryPageAutoplayCompleteNotification object:[notification object]];
    
    NSLog(@"StoryAutoplay: Left hand page complete.");
    
    if ([[self.pageVC viewControllers] count] == 2) { // Two pages to play through
        
        NSLog(@"StoryAutoplay: Right hand page found. Playing...");
        
        StoryViewController_iPad* secondPage = [[self.pageVC viewControllers] objectAtIndex:1];
        [secondPage performSelector:@selector(autoplay) withObject:nil afterDelay:0.0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoplaySecondPageComplete:) name:StoryPageAutoplayCompleteNotification object:secondPage];
        
    }
    else if ([[self.pageVC viewControllers] count] == 1) { // One page to play
        
        NSLog(@"StoryAutoplay: Single page controller, turning page...");
        [self performSelector:@selector(turnPagesForward) withObject:nil afterDelay:0.0];
        
    }
    else { // Unrecognized pageViewController configuration
        
    }
    
}//End autoplayFirstPageComplete

- (void) autoplaySecondPageComplete: (NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:StoryPageAutoplayCompleteNotification object:[notification object]];
    
    NSLog(@"StoryAutoplay: Right hand page complete, turning page...");
    [self performSelector:@selector(turnPagesForward) withObject:nil afterDelay:0.0];
    
}//End autoplaySecondPageComplete

#pragma mark - Utility -

-(void) attachObserversForStoryPage: (StoryViewController_iPad*)pageController {
    
    NSLog(@"attached Page Observer");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openDefinitionPopover:) name:WordViewBeginNotification object:pageController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyPageBeginReadInfo:) name:StoryPageReadInfoBeginNotification object:pageController];
}

-(void) removeObserversForStoryPage: (StoryViewController_iPad*)pageController {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordViewBeginNotification object:pageController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:StoryPageReadInfoBeginNotification object:pageController];
    
}

- (StoryViewController_iPad*) storyPageForPageNumber: (NSInteger)pageNumberToBuild {
    
    NSLog(@"storyPageForPageNumber: %i", pageNumberToBuild);
    
    StoryViewController_iPad* newStoryPage;
    
    if ( pageNumberToBuild < [self.arrayOfPageTexts count] && pageNumberToBuild >= 0 ) { //Title Page or Content Page
        
        newStoryPage = [[[StoryViewController_iPad alloc] initWithNibName:@"StoryViewController_iPad" bundle:NULL forTextWithTags:[self.arrayOfPageTexts objectAtIndex:pageNumberToBuild] lessonNumber:self.lessonNumber pageNumber:pageNumberToBuild blankPage:NO] autorelease];
    
    } //End if{} (title or content page)
    else if (pageNumberToBuild == [self.arrayOfPageTexts count]) { //The End page
        
        NSLog(@"Assign The End page.");
        
        //Send negative pageNumber
        newStoryPage = [[[StoryViewController_iPad alloc] initWithNibName:@"StoryViewController_iPad" bundle:NULL forTextWithTags:@"" lessonNumber:self.lessonNumber pageNumber:-pageNumberToBuild blankPage:NO] autorelease];
        
    }//End else if{} (the end page)
    else if (pageNumberToBuild == [self.arrayOfPageTexts count] + 1 ) { //Blank page
        
        NSLog(@"Assign blank page.");
        
        //Send blankPage YES
        newStoryPage = [[[StoryViewController_iPad alloc] initWithNibName:@"StoryViewController_iPad" bundle:NULL forTextWithTags:@"" lessonNumber:self.lessonNumber pageNumber:pageNumberToBuild blankPage:YES] autorelease];
        
    }//End else{} (blank page)
    else {
        
        newStoryPage = nil;
    
    }//End else{} (no page)
        
    return newStoryPage;
    
}//End storyPageForPageNumber:

- (void) turnPagesForward {
    
    if ([[self.pageVC viewControllers] count] == 2) { // Two pages to turn
        
        NSLog(@"StoryAutoplay: Two page turn...");
        
        //Current pages
        StoryViewController_iPad* prevPageLeft = [[self.pageVC viewControllers] objectAtIndex:0];
        StoryViewController_iPad* prevPageRight =[[self.pageVC viewControllers] objectAtIndex:1];
        
        //Next pages
        StoryViewController_iPad* nextPageLeft = [self storyPageForPageNumber:self.currentPage+2];
        StoryViewController_iPad* nextPageRight =[self storyPageForPageNumber:self.currentPage+3];
        
        if (nextPageLeft && nextPageRight) {
            
            //Replace story reader observers
                //1st page
            [self removeObserversForStoryPage:prevPageLeft];
            [self attachObserversForStoryPage:nextPageLeft];
                //2nd page
            [self removeObserversForStoryPage:prevPageRight];
            [self attachObserversForStoryPage:nextPageRight];
            
            NSLog(@"StoryAutoplay: Page turn is possible, turning now.");
            //Turn the page (by passing new view controllers)
            [self.pageVC setViewControllers:[NSArray arrayWithObjects:nextPageLeft, nextPageRight, nil]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished){
                                     
                                        //Update currentPage
                                        self.currentPage = nextPageLeft.pageNumberForView;
                         
                                        //Autoplay?
                                        NSLog(@"StoryAutoplay: Turn completed.");
                                        if (self.storyAutoplayEnabled && !nextPageLeft.pageAutoplayEnabled) {
                                         
                                            NSLog(@"StoryAutoplay: Autoplay still enabled, continuing play...");
                                            [self performSelector:@selector(autoplay) withObject:nil afterDelay:1.0];
                                        }
                             
                                 }];
        }//End if{} (pages are not nil)
        else {//End of story
            
            NSLog(@"StoryAutoplay: Page turn was not possible (nil page encountered). Ending autoplay.");
            [self pauseStoryPlayback];
            
        }//End else{} (end of story)
        
    }//End if{} (2 pages to turn)
    else if ([[self.pageVC viewControllers] count] == 1) { // One page to turn
        
        StoryViewController_iPad* nextPage = [self storyPageForPageNumber:self.currentPage+1];
        if (nextPage) {
            
            //Turn the page (by passing new view controllers)
            [self.pageVC setViewControllers:[NSArray arrayWithObjects:nextPage, nil]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished){
                                     
                                     //Update currentPage
                                     self.currentPage = nextPage.pageNumberForView;
                                     
                                     //Repeat?
                                     if (self.storyAutoplayEnabled) [self performSelector:@selector(autoplay) withObject:nil afterDelay:1.0];
                                     
                                 }];
        }//End if{} (pages are not nil)
        else { //End of story
            
            self.storyAutoplayEnabled = NO;
            
        }//End else{} (end of story)
        
    }
    else { // Unrecognized pageViewController configuration
        
        NSLog(@"(StoryAutoplay) ALERT: Cannot Turn Page. Unrecognized pageViewController configuration. No viewControllers, or excess.");
        
    }
    
    
    
}//End turnPagesForward

- (void) autoplay {
    
    NSLog(@"StoryAutoplay: Commence");
    
    self.storyAutoplayEnabled = YES;
    
    //Ensure there is a page to play
    if ([[self.pageVC viewControllers] count] > 0) {
        
        NSLog(@"StoryAutoplay: There is a page to play! Playing...");
        
        //VIEWS
        
        //Change autoplayButton graphic
        [self.autoplayButton setImage:[UIImage imageNamed:@"black32_playCircled.png"] forState:UIControlStateNormal];
        
        
        //Animate status toggle (button)
            //Create a doppleganger button to animate
        UIButton* button = [[UIButton buttonWithType:self.autoplayButton.buttonType] retain]; //RELEASED AFTER ANIMATIONS
        button.contentMode = self.autoplayButton.contentMode;
        [button setImage:[UIImage imageNamed:@"black32_playCircled.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = self.autoplayButton.imageEdgeInsets;
        [self.autoplayMountView addSubview:button];
        button.frame = self.autoplayButton.frame;
        button.alpha = self.autoplayButton.alpha;
        button.userInteractionEnabled = NO;
        
        //Animate
            //iOS 4.0+
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                         animations:^{
                             //Animations...
                             
                             button.transform = CGAffineTransformMakeScale(3.0, 3.0);
                             button.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished){
                             //Afterwards...
                             
                             [button removeFromSuperview];
                             [button release];
                             
                         }];
        
        //DATA
        
        //Play first page & observe (test for 2nd page when this page is finished)
        StoryViewController_iPad* firstPage = [[self.pageVC viewControllers] objectAtIndex:0];
        [firstPage autoplay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoplayFirstPageComplete:) name:StoryPageAutoplayCompleteNotification object:firstPage];
    }
    
}//End autoplay

- (void) pauseStoryPlayback {
    
    self.storyAutoplayEnabled = NO;
    
    //VIEWS
    
    //Change autoplayButton graphic
    [self.autoplayButton setImage:[UIImage imageNamed:@"black32_pauseCircled.png"] forState:UIControlStateNormal];
    
    
    //Animate status toggle (button)
        //Create a doppleganger button to animate
    UIButton* button = [[UIButton buttonWithType:self.autoplayButton.buttonType] retain]; //RELEASED AFTER ANIMATIONS
    button.contentMode = self.autoplayButton.contentMode;
    [button setImage:[UIImage imageNamed:@"black32_pauseCircled.png"] forState:UIControlStateNormal];
    button.imageEdgeInsets = self.autoplayButton.imageEdgeInsets;
    [self.autoplayMountView addSubview:button];
    button.frame = self.autoplayButton.frame;
    button.alpha = self.autoplayButton.alpha;
    button.userInteractionEnabled = NO;
    
    
        //Animate
            //iOS 4.0+
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                     animations:^{
                         //Animations...
                         
                         button.transform = CGAffineTransformMakeScale(3.0, 3.0);
                         button.alpha = 0.0;
                     
                     }
                     completion:^(BOOL finished){
                         //Afterwards...
                         
                         [button removeFromSuperview];
                         [button release];
                         
                     }];
    
    
    //DATA
    
    //Access page controllers
    UIViewController* leftHandPage = nil;
    if ([[self.pageVC viewControllers] count] > 0) leftHandPage = [[self.pageVC viewControllers] objectAtIndex:0];
    UIViewController* rightHandPage = nil;
    if ([[self.pageVC viewControllers] count] == 2) rightHandPage = [[self.pageVC viewControllers] objectAtIndex:1];
    
    if (leftHandPage && [leftHandPage respondsToSelector:@selector(pausePlayback)]) {
        [leftHandPage performSelector:@selector(pausePlayback)];
    }
    if (rightHandPage && [rightHandPage respondsToSelector:@selector(pausePlayback)]) {
        [rightHandPage performSelector:@selector(pausePlayback)];
    }
    
}//End pauseStoryPlayback

- (void) resumeStoryPlaybackOnPage: (UIViewController*)pageController {
    
    if (self.storyAutoplayEnabled && pageController && [pageController respondsToSelector:@selector(resumePlayback)]) {
        
        //DATA
        [pageController performSelector:@selector(resumePlayback)];
        
        //VIEWS
        //Change autoplayButton graphic
        [self.autoplayButton setImage:[UIImage imageNamed:@"black32_playCircled.png"] forState:UIControlStateNormal];
        
        
        //Animate status toggle (button)
        //Create a doppleganger button to animate
        UIButton* button = [[UIButton buttonWithType:self.autoplayButton.buttonType] retain]; //RELEASED AFTER ANIMATIONS
        button.contentMode = self.autoplayButton.contentMode;
        [button setImage:[UIImage imageNamed:@"black32_playCircled.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = self.autoplayButton.imageEdgeInsets;
        [self.autoplayMountView addSubview:button];
        button.frame = self.autoplayButton.frame;
        button.alpha = self.autoplayButton.alpha;
        button.userInteractionEnabled = NO;
        
        //Animate
        //iOS 4.0+
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                         animations:^{
                             //Animations...
                             
                             button.transform = CGAffineTransformMakeScale(3.0, 3.0);
                             button.alpha = 0.0;
                             
                         }
                         completion:^(BOOL finished){
                             //Afterwards...
                             
                             [button removeFromSuperview];
                             [button release];
                             
                         }];
    }
    
}//End resumeStoryPlayback

/***
 - Method Name -
 textArrayForLesson
 
 - Description -
 This method opens a file named rrv?s.txt, where ? equals the lesson number requested.
 Assumed to be in proper (#Label#Text#Label#Text) format, the .txt file is separated into an array.
 That array is checked for validity - even numbers should be marked-up story content. (i.e. still with tags)
 These even indices of the array are added to a mutable array, which is what is returned.
 
 Thus, the format of the returned array is as follows:
 Index 0: Title for Story
 Index 1: Text for Page 1
 Index 2: Text for Page 2
 Index 3: Text for Page 3
 etc...
 
 - Return -
 Returns an NSArray* that contains the story content (described above),
 which has been aggregated from the valid (content) text parts from the .txt file.
 ***/
- (NSArray*) textArrayForLesson {
    
    //Get text from file
    NSString* lessonStoryFileName = [NSString stringWithFormat:@"rrv%ds", self.lessonNumber];
    NSString* lessonStoryFilePath = [[NSBundle mainBundle] pathForResource:lessonStoryFileName ofType:@"txt"];
    NSURL* lessonStoryURL = [NSURL fileURLWithPath:lessonStoryFilePath];
    NSString* lessonTextFromFile = [NSString stringWithContentsOfURL:lessonStoryURL encoding:NSUTF8StringEncoding error:nil];
    
    //Break apart into array of strings
    NSArray* textChunksFromFile = [lessonTextFromFile componentsSeparatedByString:@"#"];
    NSMutableArray* lessonStoryText = [NSMutableArray array]; //make mutable array to aggregate story text - starts empty
    NSLog(@"ARRAY LENGTH: %i", [textChunksFromFile count]);
    for (NSInteger i = 0; i < [textChunksFromFile count]; i++) {//for each chunk of text
        
        NSLog(@"Chunk %i is %@.", i, [textChunksFromFile objectAtIndex:i]);
        
        if (i == 0 || (i%2)) {//if number is zero or odd
            NSLog(@"%i is ZERO OR ODD, omitted.", i);
            
            //Index 0 is empty (file starts with separator)
            //ODD indices are labels
            
        }//End else{} (number is even)
        else{//if number is odd
            NSLog(@"%i is EVEN, trimmed and added.", i);
            
            //It is story text - trim it and add to lessonStoryText array
            NSString* trimmedChunkOfText = [[textChunksFromFile objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lessonStoryText addObject:trimmedChunkOfText];
            
        }//End else{} (number is odd)
    }//End for{} (each of chunk of text)
    
    return lessonStoryText;
}

@end
