//
//  StoryPageViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 11/8/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "StoryPageViewController.h"
#import "StoryTitlePage.h"
#import "StoryViewController.h"
#import "DefinitionView.h"
#import "WordObject.h"
#import "TheEndPage.h"
#import "RRVConstants.txt"

@implementation StoryPageViewController

#pragma mark Synthesizers

@synthesize lessonNumber, currentPage, storyAutoplayEnabled, definitionViewShowing, arrayOfPageTexts;
@synthesize autoplayButton;
@synthesize pageVC;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.pageVC.delegate = nil;
    self.pageVC.dataSource = nil;
    
    //Child VCs
    for (UIViewController* childViewController in [self childViewControllers]) {
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
    }
    
    //Data
    [arrayOfPageTexts release];
    
    //Views
    [autoplayButton release];
    
    //Controllers
    [pageVC release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning{// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
        
        //Data
        self.arrayOfPageTexts = nil;
    
        //Views
        self.autoplayButton = nil;
    
        //Controllers
        self.pageVC = nil;
        
    }
    
}

#pragma mark Setup

//Custom initializer includes lessonNumberToLoad
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.lessonNumber = lessonNumberToLoad;
        self.currentPage = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.arrayOfPageTexts = [self textArrayForLesson];
    
    //Starting page
    UIViewController *startingViewController = [self storyPageForPageNumber:0];
    [self attachObserversForStoryPage:startingViewController];
    [self.autoplayButton setHidden:YES]; //TitlePage - no autoplayButton
    
    // Configure the page view controller and add it as a child view controller.
    self.pageVC = [[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil] autorelease];
    self.pageVC.delegate = self;
    self.pageVC.dataSource = self;
    
    NSArray* viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    CGRect pageViewRect = self.view.bounds;
    self.pageVC.view.frame = pageViewRect;
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.view sendSubviewToBack:self.pageVC.view];
    [self.pageVC didMoveToParentViewController:self];
    
    // Disable the tap gestures for smart-turning - they interfere with our special text views!
    // Then, add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    for (UIGestureRecognizer *recognizer in self.pageVC.gestureRecognizers) {
        
        recognizer.delegate = self;
        
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
        
    }
    self.view.gestureRecognizers = self.pageVC.gestureRecognizers;
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Data Sources -

#pragma mark UIPageViewController

//Next view controller
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSLog(@"pageViewController: Next view controller...");
    
    UIViewController* nextViewController = nil;
    
    if  (self.currentPage + 1 > [self.arrayOfPageTexts count]) {//No next page
        //Leave nil
    }
    else {//There is a next page
        
        nextViewController = [self storyPageForPageNumber:self.currentPage+1];
    }
    
    return nextViewController;
    
}//End pageViewController: viewControllerAfterViewController:

//Previous view controller
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSLog(@"pageViewController: Previous view controller...");
    
    UIViewController* previousViewController = nil;
    
    if  (self.currentPage - 1 < 0) {//No previous page
        //Leave nil
    }
    else {//There is a previous page
        
        previousViewController = [self storyPageForPageNumber:self.currentPage-1];
        
    }
    
    return previousViewController;
    
}//End pageViewController: viewControllerBeforeViewController:

#pragma mark - Delegates -

#pragma makr UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer //Manually deny gestures because UIPageViewController is broken =P
{
    
    //Deny gestures if definition view is showing
    if (self.definitionViewShowing && [gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]]) { //Unless it is a tap to exit
        return YES;
    }
    else if (self.definitionViewShowing) {
        return NO;
    }
    
    
    //Make sure we're not trying to turn backward past the first page:
    if (self.currentPage == 0) { //Beginning page?
        
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
    NSInteger maxPageNumber = [self.arrayOfPageTexts count]; // +Integer <-- trailing blank pages
    
    if (self.currentPage + 1 > maxPageNumber) { //Either page is invalid
        
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

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    NSLog(@"didFinishAnimating!!!!!!");
    
    
    if (self.currentPage == 0 || self.currentPage >= [self.arrayOfPageTexts count]) { //Non-ContentPage
        //Leave hidden
    }
    else {
        [self.autoplayButton setHidden:NO];
    }
    
    if (finished) {
        
        //Resume autoplay?
        if (self.storyAutoplayEnabled && [[[self.pageVC viewControllers] objectAtIndex:0] respondsToSelector:@selector(autoplay)])
            [self performSelector:@selector(autoplay) withObject:nil afterDelay:0.0];
        
    }
    
    if (completed) {
        
        //Replace observers
        UIViewController* prevPageVC = [previousViewControllers objectAtIndex:0];
        UIViewController* newPageVC = [[pageViewController viewControllers] objectAtIndex:0];
        [self removeObserversForStoryPage:prevPageVC];
        [self attachObserversForStoryPage:newPageVC];
        
        //Get the pageNumber from the currently held page
        if ([newPageVC respondsToSelector:@selector(pageNumberForView)]) {
            
            self.currentPage = [(StoryViewController*)newPageVC pageNumberForView];
            
        }
        
    }
    
}//End pageViewController: didFinishAnimating: previousViewControllers: transitionCompleted:

#pragma mark - Actions -

- (IBAction) toggleAutoplay:(id)sender {
    
    if (self.storyAutoplayEnabled) { [self pauseStoryPlayback]; }
    else { [self autoplay]; }
    
}//End toggleAutoplay:

#pragma mark - Callbacks -

-(void) openWordView: (NSNotification*)notification {
    
    self.definitionViewShowing = YES;
    
    //Pause page playback
    [self pauseStoryPlayback];
    
    //Catch word
    NSString* wordToOpen = [[notification userInfo] objectForKey:key_WordToLoadDictionaryKey];
    NSLog(@"openWordView: %@", wordToOpen);
    
    //Open wordView
    DefinitionView* definitionVC = [[[DefinitionView alloc] initWithNibName:@"DefinitionView" bundle:NULL forWordObject:[WordObject loadWord:wordToOpen fromLesson:self.lessonNumber]] autorelease];
        //MountView
    UIView* definitionMountView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
    [definitionMountView setBackgroundColor:[UIColor clearColor]];
    [definitionMountView setAlpha:0.0];
        //Touch Swallowing (Button w/ Exclusive Touch)
    /*
    UIButton* touchSwallowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [touchSwallowButton setExclusiveTouch:YES];
    touchSwallowButton.frame = definitionMountView.frame;
    [definitionMountView addSubview:touchSwallowButton];
    */
        //Shadow
    UIImageView* shadowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Shadow_portrait.png"]] autorelease];
    shadowImageView.contentMode = UIViewContentModeScaleToFill;
    shadowImageView.frame = CGRectMake(0.0, 130.0, 320.0, 220.0);
    [definitionMountView addSubview:shadowImageView];
        //View
    definitionVC.view.frame = CGRectMake(10.0, 140.0, 300.0, 200.0);
    [self addChildViewController:definitionVC];
    [definitionMountView addSubview:definitionVC.view];
    [self.view addSubview:definitionMountView];
    [definitionVC didMoveToParentViewController:self];
    
    //Animate into view
    //iOS 4.0+
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                     animations:^{
                         //Animations...
                         definitionMountView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         //Afterwards...
                     }];
    
    //Add Gesture recognizer to exit on tap outside definitionVC.view
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapExitDefinitionView:)];
    [definitionMountView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    
    //Observe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWordView:) name:WordViewFinishedNotification object:definitionMountView];

}

- (void)tapExitDefinitionView:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:recognizer.view];

    self.definitionViewShowing = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WordViewFinishedNotification object:recognizer.view];
    
    [recognizer.view removeFromSuperview];
    
}

-(void) dismissWordView: (NSNotification*)notification {
    
    NSLog(@"dismissWordView:");
    
    DefinitionView* wordViewToDismiss = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordViewFinishedNotification object:wordViewToDismiss];
    
    //Controller
    for (UIViewController* childVC in [self childViewControllers]) { //Only child should be a definitionVC
        [childVC willMoveToParentViewController:nil];
        [childVC removeFromParentViewController];
    }
    
    //Resume playback on first visible page
    [self resumeStoryPlaybackOnPage:[[self.pageVC viewControllers] objectAtIndex:0]];
    
}

- (void) autoplayFirstPageComplete: (NSNotification *)notification {
    //Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:StoryPageAutoplayCompleteNotification object:[notification object]];
    
    NSLog(@"StoryAutoplay: Left hand page complete.");
    
    if ([[self.pageVC viewControllers] count] == 1) { // One page to play
        
        NSLog(@"StoryAutoplay: Single page controller, turning page...");
        [self turnPagesForward];
        /*
        CGFloat delayForTurn = 0.0; //Delay causes crash in current config?
        if (self.currentPage == 0) delayForTurn = 0.0; //No delay on title page
        [self performSelector:@selector(turnPagesForward) withObject:nil afterDelay:delayForTurn];
        */
        
    }
    else { // Empty or Unsupported pageViewController configuration
        
    }
    
}//End autoplayFirstPageComplete

-(void) storyFinished:(NSNotification*)notification {//Fired when User presses continueButton on TheEndPage
    
    //Echo notification to whatever is holding this contatiner
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryFinishedNotification object:self];
    
}//End storyFinished

#pragma mark - Utility -

#pragma mark Story Page Assembly

-(void) attachObserversForStoryPage: (UIViewController*)viewController {
    
    NSLog(@"attached Page Observer");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openWordView:) name:WordViewBeginNotification object:viewController];
    
}

-(void) removeObserversForStoryPage: (UIViewController*)viewController {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordViewBeginNotification object:viewController];
    
}

- (void) autoplay {
    
    NSLog(@"StoryAutoplay: Commence");
    
    [self setStoryAutoplayEnabled:YES];
    
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
        [self.view addSubview:button];
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
        UIViewController* firstPage = [[self.pageVC viewControllers] objectAtIndex:0];
        if ([firstPage respondsToSelector:@selector(autoplay)]) [firstPage performSelector:@selector(autoplay) withObject:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoplayFirstPageComplete:) name:StoryPageAutoplayCompleteNotification object:firstPage];
    }
    
}//End autoplay

- (void) pauseStoryPlayback {
    
    NSLog(@"StoryAutoplay: Pause");
    
    [self setStoryAutoplayEnabled:NO];
    
    //VIEWS
    
    //Change autoplayButton graphic
    [self.autoplayButton setImage:[UIImage imageNamed:@"black32_pauseCircled.png"] forState:UIControlStateNormal];
    
    
    //Animate status toggle (button)
    //Create a doppleganger button to animate
    UIButton* button = [[UIButton buttonWithType:self.autoplayButton.buttonType] retain]; //RELEASED AFTER ANIMATIONS
    button.contentMode = self.autoplayButton.contentMode;
    [button setImage:[UIImage imageNamed:@"black32_pauseCircled.png"] forState:UIControlStateNormal];
    button.imageEdgeInsets = self.autoplayButton.imageEdgeInsets;
    [self.view addSubview:button];
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
        [self.view addSubview:button];
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

- (void) turnPagesForward {
    NSLog(@"StoryAutoplay: Turning pages forward...");
    
    [self.autoplayButton setHidden:YES];
    
    if ([[self.pageVC viewControllers] count] == 1 && self.currentPage < [self.arrayOfPageTexts count]) { // One page to turn & not on end page
        
        UIViewController* currentPageController = [[self.pageVC viewControllers] objectAtIndex:0];
        UIViewController* nextPageController = [self storyPageForPageNumber:self.currentPage+1];
        if (nextPageController) {
            
            [self removeObserversForStoryPage:currentPageController];
            [self attachObserversForStoryPage:nextPageController];
            
            //Turn the page (by passing new view controllers)
            [self.pageVC setViewControllers:[NSArray arrayWithObjects:nextPageController, nil]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished){ //Equivalent to didFinishAnimating
                                         
                                         //Update currentPage (we only have 1 here)
                                         self.currentPage = [(StoryViewController*)nextPageController pageNumberForView];
                                     
                                         //Handle Auto-play Button
                                         if (self.currentPage == 0 || self.currentPage >= [self.arrayOfPageTexts count]) { //Non-ContentPage
                                             //Leave hidden
                                         }
                                         else {
                                             [self.autoplayButton setHidden:NO];
                                         }
                                     
                                         //Observer
                                         
                                         //Autoplay?
                                        StoryViewController* nextPageController_forBlock = [[self.pageVC viewControllers] objectAtIndex:0];
                                         if (self.storyAutoplayEnabled && !nextPageController_forBlock.pageAutoplayEnabled) [self performSelector:@selector(autoplay) withObject:nil afterDelay:0.0];
                                     
                                 }];
        }//End if{} (pages are not nil)
        else { //End of story
            
            self.storyAutoplayEnabled = NO;
            
        }//End else{} (end of story)
        
    }
    else { // Unrecognized pageViewController configuration
        
        NSLog(@"(StoryAutoplay) ALERT: Cannot Turn Page. It is either null or 'Out of Bounds'.");
        
    }
    
}//End turnPagesForward

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
    NSString* lessonStoryFileName = [[[NSString stringWithFormat:@"rrv"] stringByAppendingFormat:@"%i", self.lessonNumber] stringByAppendingFormat:@"s"];
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
            NSLog(@"%i is ZERO OR EVEN, omitted.", i);
            //Index 0 is empty (file starts with separator)
            //ODD indices are labels
        }//End else{} (number is even)
        else{//if number is odd
            NSLog(@"%i is ODD, trimmed and added.", i);
            //It is story text - trim it and add to lessonStoryText array
            NSString* trimmedChunkOfText = [[textChunksFromFile objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lessonStoryText addObject:trimmedChunkOfText];
        }//End else{} (number is odd)
    }//End for{} (each of chunk of text)
    
    return lessonStoryText;
    
}//End textArrayForLesson

- (UIViewController*) storyPageForPageNumber: (NSInteger)pageNumberToBuild {
    
    NSLog(@"storyPageForPageNumber: %i", pageNumberToBuild);
    
    UIViewController* newStoryPage;
    
    if (pageNumberToBuild == 0) { //Title page
        newStoryPage = [[[StoryTitlePage alloc] initWithNibName:@"StoryTitlePage" bundle:NULL lessonNumber:self.lessonNumber] autorelease];
    }
    else if (pageNumberToBuild > 0 && pageNumberToBuild < [self.arrayOfPageTexts count] ) { //Title Page or Content Page
        
        newStoryPage = [[[StoryViewController alloc] initWithNibName:@"StoryViewController" bundle:NULL forTextWithTags:[self.arrayOfPageTexts objectAtIndex:pageNumberToBuild] lessonNumber:self.lessonNumber pageNumber:pageNumberToBuild pageCount:[self.arrayOfPageTexts count]-1] autorelease];
        
    } //End if{} (title or content page)
    else if (pageNumberToBuild == [self.arrayOfPageTexts count]) { //The End page
        
        newStoryPage = [[[TheEndPage alloc] initWithNibName:@"TheEndPage" bundle:NULL pageNumber:pageNumberToBuild] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyFinished:) name:StoryFinishedNotification object:newStoryPage];
        
    }//End else if{} (the end page)
    else if (pageNumberToBuild == [self.arrayOfPageTexts count] + 1 ) { //Blank page
        
        NSLog(@"Assign blank page.");
        
        //Send blankPage YES
        newStoryPage = [[[UIViewController alloc] init] autorelease];
        newStoryPage.view.backgroundColor = [UIColor whiteColor];
        newStoryPage.view.frame = self.view.bounds;
        
    }//End else{} (blank page)
    else {
        
        newStoryPage = nil;
        
    }//End else{} (no page)
    
    return newStoryPage;
    
}//End storyPageForPageNumber:

@end
