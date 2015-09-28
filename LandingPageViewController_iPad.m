//
//  LandingPageViewController_iPad.m
//  RRV101
//
//  Created by Brian C. Grant on 1/22/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LandingPageViewController_iPad.h"
#import "LessonSelect.h"
#import "LessonController.h"
#import "QuizViewController_iPad.h"
#import "ThesaurusVC_iPad.h"
#import "WordPopGameView.h"
#import "RRVConstants.txt"

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@implementation LandingPageViewController_iPad

#pragma mark Synthesizers

//Data
@synthesize runningOnRetina, menuViewIsRaised, orientationLockedToLandscape, homeButtonVisible, activeView;
//Views
@synthesize bannerImageView, menuView, menuButtonAreaView, menuTabButton, homeBtn, lessonsBtn, quizzesBtn, thesaurusBtn, gamesBtn, gradesBtn, settingsBtn, crossOutImageViews, comingSoonLabels;
//Controllers & Media

#pragma mark - Global Non-Properies -

CGFloat menuBounceMargin = 50.0;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void) dealloc{
    
    //Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Remove all child VCs
    for (UIViewController* childViewController in self.childViewControllers) {
        
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
        
    }
    
    //Data
    [activeView release];
    
    //Views
    [bannerImageView release];
    [menuView release];
    [menuTabButton release];
    [homeBtn release];
    [lessonsBtn release];
    [quizzesBtn release];
    [thesaurusBtn release];
    [gamesBtn release];
    [gradesBtn release];
    [settingsBtn release];
    [crossOutImageViews release];
    [comingSoonLabels release];
    
    //Controllers &  Media
    
    [super dealloc];
    
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.activeView = nil;
    
        //Views 
        self.bannerImageView = nil;
        self.menuView = nil;
        self.menuTabButton = nil;
        self.homeBtn = nil;
        self.lessonsBtn = nil;
        self.quizzesBtn = nil;
        self.thesaurusBtn = nil;
        self.gamesBtn = nil;
        self.gradesBtn = nil;
        self.settingsBtn = nil;
        self.crossOutImageViews = nil;
        self.comingSoonLabels = nil;
        
    }
}

#pragma mark Orientation

//// iOS 6.0+
-(NSUInteger)supportedInterfaceOrientations {
    
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskPortrait;
    
    if (self.orientationLockedToLandscape) { //Device is an iPad & orientation is locked!!
        
        mask = UIInterfaceOrientationMaskLandscape;
        
    }
    else {
        
        mask = UIInterfaceOrientationMaskAll;
        
    }
    
    return mask;
    
}

-(BOOL)shouldAutorotate {
    
    return YES;
    
}

//// iOS 5.1-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    
    BOOL shouldRotate;
    
    if (self.orientationLockedToLandscape) {
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    else shouldRotate = YES;
    
    return shouldRotate;
    
}//End shouldAutorotateToInterfaceOrientation:

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    for (UIViewController* childViewController in [self childViewControllers]) {
        
        if ([childViewController respondsToSelector:@selector(doneWithThesaurus:)]) {
        
            ThesaurusVC_iPad* thesaurusViewController = (ThesaurusVC_iPad*)childViewController;
            
            //Ensure Thesaurus visual configuration
            if (thesaurusViewController.view && (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ) {
        
                //Reset transform - x transition only
                thesaurusViewController.view.center = CGPointMake(-(thesaurusViewController.view.bounds.size.width/2), thesaurusViewController.view.bounds.size.height/2);
                thesaurusViewController.view.transform = CGAffineTransformMakeTranslation(thesaurusViewController.view.frame.size.height, 0);
        
            }//End if{} (view exists and orientation is portrait)
            
        }//End if{} (responds to unique thesaurusViewController selector
        
    }//End for{} (each childViewController)
    
}//End didRotateFromInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //This is an iPad specific class, assume device is iPad
        
        //Detect retina display
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
            NSLog(@"Retina Display detected.");
        
            self.runningOnRetina = YES;
        
        }
        else {
            NSLog(@"Standard Definition Display detected.");
        
            self.runningOnRetina = NO;
        
        }
        
        self.menuViewIsRaised = YES;
        
    }
    
    return self;
    
}//End initWithNibName: bundle:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Hide menu
    [self hideMenuView];
    
    //Observe quiz state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableThesaurus:) name:QuizOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableThesaurus:) name:QuizFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableThesaurus:) name:QuizClosedNotification object:nil];
    
    if ( [[self completedLessonsList] count] <= 0 ) {
        NSLog(@"No lesson has been completed!");
        
        //Open lesson select
        [self performSelector:@selector(goLessons:) withObject:nil afterDelay:0.0];
    }
    else {
        NSLog(@"User has completed a lesson.");
        
        //Menu view
        [self unhideMenuView];
    }
    
    self.menuViewIsRaised = YES;
    
}//End viewDidLoad

#pragma mark - Actions -

-(IBAction)menuButtonPushed:(id)sender {
    
    //Toggle menu position
    if (self.menuViewIsRaised) [self lowerMenuView];
    else [self raiseMenuView];
     
}//End menuButtonPushed:

-(IBAction)goHome:(id)sender {
    
    //Reset landing page
    [self reset];
    
    [self unhideMenuView];
    
    if (!self.menuViewIsRaised) {
        [self raiseMenuView];
    }
    if (self.homeButtonVisible)
        [self hideHomeButtonOnMenuButtonAreaViewWithinDuration:0.5];
    
    [self bounceMenuViewScale];
    
    [self.bannerImageView setHidden:NO];
    
}

-(IBAction)goLessons:(id)sender{

    [self reset];
    
    NSLog(@"goLessons:");
    
    //Display modal lesson selection - single lesson - and observe
    
    LessonSelect* lessonSelectVC;
    
    if (sender) { //Sender not nil
        NSLog(@"sender exists");
        
        [self goHome:sender];
        lessonSelectVC = [[[LessonSelect alloc] initWithNibName:@"LessonSelect" bundle:NULL multipleLessons:NO backButton:YES] autorelease];
    }
    else { //Nil sender
        NSLog(@"nil sender");
        
        //Don't go home, remove back button
        lessonSelectVC = [[[LessonSelect alloc] initWithNibName:@"LessonSelect" bundle:NULL multipleLessons:NO backButton:NO] autorelease];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchLesson:) name:LessonSelectionCompleteNotification object:lessonSelectVC];
    [lessonSelectVC setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:lessonSelectVC animated:YES completion:^{
        //Afterwards...
    }];
    
}//End goLessons:

-(IBAction)goQuizzes:(id)sender{
    
    [self reset];
    
    if (![self hasCompletedLessonNumber:101]) { //Hasn't completed first lesson
        //Load demo quiz
        
        NSNotification* liteQuizNotification = [NSNotification notificationWithName:LessonCompleteNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[NSNumber numberWithInt:0]] forKey:kLessonSelectionArrayInDictionary]];
        
        [self launchQuiz:liteQuizNotification];
        [self unhideMenuView];
        
    }
    else {
    
        //Display modal lesson selection - single lesson - and observe
        LessonSelect* lessonSelectVC = [[[LessonSelect alloc] initWithNibName:@"LessonSelect" bundle:NULL multipleLessons:NO backButton:YES] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchQuiz:) name:LessonSelectionCompleteNotification object:lessonSelectVC];
        [lessonSelectVC setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:lessonSelectVC animated:YES completion:^{
            //Afterwards...
        }];
        
    }
    
}//End goQuizzes:

-(IBAction)goThesaurus:(id)sender{
    
    //Disable touches in menu
    [self.menuView setUserInteractionEnabled:NO];
    
    //Lock orientation to landscape
    self.orientationLockedToLandscape = YES;
    
    //Initialize & observe
    ThesaurusVC_iPad* thesaurusViewController = [[[ThesaurusVC_iPad alloc] initWithNibName:@"ThesaurusVC_iPad" bundle:NULL] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitThesaurus:) name:ThesaurusQuitNotification object:thesaurusViewController];
    
    //Transition
    [self addChildViewController:thesaurusViewController];
    [thesaurusViewController didMoveToParentViewController:self];
    [thesaurusViewController.view setFrame:CGRectMake(-thesaurusViewController.view.frame.size.width, 0, thesaurusViewController.view.frame.size.width, thesaurusViewController.view.frame.size.height)]; NSLog(@"THEVIEW CENTER: (%.1f, %.1f)", thesaurusViewController.view.center.x, thesaurusViewController.view.center.y);
    [self.view addSubview:thesaurusViewController.view];
    
    //Handle orientation
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) { //Landscape animation - bring in from left
        
        //Animate into view
            //iOS 4.0 and later...
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             thesaurusViewController.view.transform = CGAffineTransformMakeTranslation(thesaurusViewController.view.frame.size.width, 0);
                         } 
                         completion:^(BOOL finished){
                             //Afterwards...
                         
                         }];
    }
    else { //Portrait animation - rotate and bring in from top
        
        //Rotate
        CGAffineTransform rotation = CGAffineTransformMakeRotation(90.0/57.2958);
        thesaurusViewController.view.transform = rotation; NSLog(@"THEVIEW BOUNDS: (%.1f, %.1f) %.1f x %.1f", thesaurusViewController.view.frame.origin.x, thesaurusViewController.view.frame.origin.y, thesaurusViewController.view.frame.size.width, thesaurusViewController.view.frame.size.height);
        thesaurusViewController.view.center = CGPointMake(self.view.center.x, -thesaurusViewController.view.bounds.size.width);
        
        //Animate into view
            //iOS 4.0 and later...
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             thesaurusViewController.view.center = CGPointMake(self.view.center.x, thesaurusViewController.view.bounds.size.width/2);
                         }
                         completion:^(BOOL finished){
                             //Afterwards...
                             
                             NSLog(@"THEVIEW BOUNDS: (%.1f, %.1f) %.1f x %.1f", thesaurusViewController.view.frame.origin.x, thesaurusViewController.view.frame.origin.y, thesaurusViewController.view.frame.size.width, thesaurusViewController.view.frame.size.height);
                             
                         }];
        
    }
    
}//End goThesaurus:

-(IBAction)goGames:(id)sender{
    
    [self reset];
    
    [self.gamesBtn setEnabled:NO];
    
    if (self.menuViewIsRaised)[self lowerMenuView];
    [self hideMenuView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideMenuView) name:WordBurstReadyToPlayNotification object:nil];
    
    NSInteger lessonNumberToPlay = 0;
    if ([self hasPurchasedLessonNumber:101] && [self hasCompletedLessonNumber:101]) lessonNumberToPlay = 101;
    
    //Launch
    WordPopGameView* wordBurstGameController = [[[WordPopGameView alloc] initWithNibName:@"WordPopGameView" bundle:NULL forLessonNumber:lessonNumberToPlay] autorelease];
    wordBurstGameController.wantsFullScreenLayout = YES;
    
    //Observe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome:) name:GameQuitNotification object:wordBurstGameController];
    
    //Transition
    [self addChildViewController:wordBurstGameController];
    [wordBurstGameController didMoveToParentViewController:self];
    [self switchToView:wordBurstGameController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:1.0];
    
    //Leaving landing - show home button
    if (self.homeButtonVisible == NO) {
        [self showHomeButtonOnMenuButtonAreaViewWithinDuration:0.0];
    }
    
}//End goGames:

-(IBAction)goGrades:(id)sender{
    
    
}//End goGrades:

-(IBAction)goSettings:(id)sender{
    
    
}//End goSettings:

#pragma mark - Callbacks -

#pragma mark Custom

- (void)launchLesson:(NSNotification *)notification {
    NSLog(@"LessonSelect successful!");
    
    //Leaving landing - show home button
    if ([notification userInfo] && self.homeButtonVisible == NO) {
        [self showHomeButtonOnMenuButtonAreaViewWithinDuration:0.0];
        if (self.menuViewIsRaised)[self lowerMenuView];
    }
    
    //Remove observation & dismiss Lesson Select
    LessonSelect* lessonSelectVC = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LessonSelectionCompleteNotification object:lessonSelectVC];
    [lessonSelectVC dismissViewControllerAnimated:YES completion:^{}];
    
    //Catch lesson selection array from userInfo
    NSArray* lessons = [[notification userInfo] objectForKey:kLessonSelectionArrayInDictionary];
    if (lessons) { //If successful
        
        //Load first lesson in array
        NSInteger lessonNumber = [[lessons objectAtIndex:0] intValue];
        LessonController* lessonController = [[[LessonController alloc] initWithNibName:@"LessonController" bundle:NULL lessonNumber:lessonNumber iPad:YES retina:self.runningOnRetina] autorelease];
        
        //Observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome:) name:LessonCompleteNotification object:lessonController];
            //Orientation lock (when Story Begins & Ends)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockOrientationToLandscape:) name:StoryBeginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockOrientation:) name:StoryFinishedNotification object:nil];
        
        //Transition
        [self addChildViewController:lessonController];
        [lessonController didMoveToParentViewController:self];
        [lessonController.view setFrame:self.view.bounds];
        [self switchToView:lessonController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
        
        //Disable games while in lesson
        [self.gamesBtn setEnabled:NO];
        
    }//End if{} (lessons array exists)
    
    //Menu handling during game...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenuView) name:StoryFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhideMenuView) name:WordBurstReadyToPlayNotification object:nil];
    
}//End launchLesson:

- (void)launchQuiz:(NSNotification *)notification {
    NSLog(@"LessonSelect successful!");
    
    //Leaving landing - show home button
    if ([notification userInfo] && self.homeButtonVisible == NO) {
        [self showHomeButtonOnMenuButtonAreaViewWithinDuration:0.0];
        if (self.menuViewIsRaised)[self lowerMenuView];
    }
    
    //Remove observation & dismiss Lesson Select
    LessonSelect* lessonSelectVC = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LessonSelectionCompleteNotification object:lessonSelectVC];
    if (lessonSelectVC) [lessonSelectVC dismissViewControllerAnimated:YES completion:^{}];
    
    //Catch lesson selection array from userInfo
    NSArray* lessons = [[notification userInfo] objectForKey:kLessonSelectionArrayInDictionary];
    if (lessons) { //If successful
        
        //Take first lesson and launch
        NSInteger lessonNumber = [[lessons objectAtIndex:0] intValue];
        QuizViewController_iPad* quizViewController = [[[QuizViewController_iPad alloc] initWithNibName:@"QuizViewController_iPad" bundle:NULL forLesson:lessonNumber embedded:NO preQuiz:NO] autorelease];
        
        //Observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome:) name:QuizFinishedNotification object:quizViewController];
        
        //Transition
        [self addChildViewController:quizViewController];
        [quizViewController didMoveToParentViewController:self];
        [quizViewController.view setFrame:self.view.bounds];
        [self switchToView:quizViewController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
        
    }//End if{} (lessons array exists)
    
    
    
}//End launchQuiz:

- (void)launchGame:(NSNotification *)notification {
    
    
}//End launchGame:

-(void) exitThesaurus:(NSNotification *)notification {
    
    ThesaurusVC_iPad* thesaurusViewController = [notification object];
    
    //Stop audio
    [thesaurusViewController stopAllAudioPlayers];
    
    //Unlock orientations
    self.orientationLockedToLandscape = NO;
    
    //Re-enable menu touches
    [self.menuView setUserInteractionEnabled:YES];
    
    
    [thesaurusViewController willMoveToParentViewController:nil];
    //Animate out of view
    //iOS 4.0 and later...
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         thesaurusViewController.view.transform = CGAffineTransformMakeTranslation(0, 0);
                     } 
                     completion:^(BOOL finished){
                         //Afterwards...
                         
                         //Remove
                         [thesaurusViewController.view removeFromSuperview];
                         [thesaurusViewController removeFromParentViewController];
                     }]; 
    
}//End exitThesaurus:

-(void) disableThesaurus:(NSNotification *)notification {
    
    [self.thesaurusBtn setEnabled:NO];
    
}//End disableThesaurus:

-(void) enableThesaurus:(NSNotification *)notification {
    
    [self.thesaurusBtn setEnabled:YES];
    
}//End enableThesaurus:

-(void) lockOrientationToLandscape: (NSNotification*)notification {
    
    self.orientationLockedToLandscape = YES;
    
}

-(void) unlockOrientation: (NSNotification*)notification {
    
    self.orientationLockedToLandscape = NO;
    
}

#pragma mark - Utility -

-(void) reset {
    
    [self.gamesBtn setEnabled:YES];
    
    //Remove Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Remove all child VCs
    for (UIViewController* childViewController in self.childViewControllers) {
        
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
        
    }
    
    if (self.activeView != nil)
        [self.activeView removeFromSuperview];
    
    //Trash (Reset)
    self.activeView = nil;
    //[[CCDirector sharedDirector] end];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    //Reset Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableThesaurus:) name:QuizOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableThesaurus:) name:QuizFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableThesaurus:) name:QuizClosedNotification object:nil];
    
}//End reset

-(void) hideMenuView {
    
    //Disable user interaction
    [self.menuView setUserInteractionEnabled:NO];
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         self.menuView.alpha = 0;
                         self.bannerImageView.alpha = 0;
                     
                     }
                     completion:^(BOOL finished){
                     
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
}//End hideMenuView

-(void) unhideMenuView {
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^{
                     
                         self.menuView.alpha = 1.0;
                         self.bannerImageView.alpha = 1.0;
                     
                     }//Send to original position (down state)
                     completion:^(BOOL finished){[self.menuView setUserInteractionEnabled:YES];}];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
}//End unhideMenuView

-(void) lowerMenuView {
    
    //Disable user interaction
    [self.menuView setUserInteractionEnabled:NO];
    
    //Determine lowered position
    CGFloat loweredPositionY = self.menuView.frame.size.height+20-45; //Height + Margin - TabHeight
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{self.menuView.transform = CGAffineTransformMakeTranslation(0.0, loweredPositionY+menuBounceMargin/2);}
                     completion:^(BOOL finished){ //Afterwards...
                         
                         //Ease down to original position
                         [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn
                                          animations:^{self.menuView.transform = CGAffineTransformMakeTranslation(0.0, loweredPositionY);}
                                          completion:^(BOOL finished){ //Afterwards...
                                              
                                              //Re-enable user interaction & update flag
                                              [self.menuView setUserInteractionEnabled:YES];
                                              
                                          }];//End animation block
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
    self.menuViewIsRaised = NO;
    
}//End lowerMenuView

-(void) raiseMenuView {
    
    //Disable user interaction
    [self.menuView setUserInteractionEnabled:NO];
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{self.menuView.transform = CGAffineTransformMakeTranslation(0.0, -menuBounceMargin);}//Bring up - just above original position
                     completion:^(BOOL finished){ //Afterwards...
                         
                         //Ease down to original position
                         [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn
                                          animations:^{self.menuView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);}//Bring up - above position
                                          completion:^(BOOL finished){ //Afterwards...
                                              
                                              //Re-enable user interaction & update flag
                                              [self.menuView setUserInteractionEnabled:YES];
                                              
                                          }];//End animation block
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
    self.menuViewIsRaised = YES;
    
}//End raiseMenuView

-(void) bounceMenuViewScale {
    
    //Disable user interaction
    [self.menuView setUserInteractionEnabled:NO];
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear
                     animations:^{self.menuView.transform = CGAffineTransformMakeScale(1.1, 1.1);}
                     completion:^(BOOL finished){ //Afterwards...
                         
                         //Ease down to original position
                         [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear
                                          animations:^{self.menuView.transform = CGAffineTransformMakeScale(1.0, 1.0);}
                                          completion:^(BOOL finished){ //Afterwards...
                                              
                                              //Re-enable user interaction & update flag
                                              [self.menuView setUserInteractionEnabled:YES];
                                              
                                          }];//End animation block
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
}//End raiseMenuView

-(void) showHomeButtonOnMenuButtonAreaViewWithinDuration:(CGFloat)duration {
    
    //Disable user interaction
    [self.menuView setUserInteractionEnabled:NO];
    
    [self.homeBtn setAlpha:0.0];
    [self.menuButtonAreaView addSubview:self.homeBtn];
    [self.homeBtn setCenter:CGPointMake(self.homeBtn.bounds.size.width/2, self.menuButtonAreaView.bounds.size.height/4)];
    [self.homeBtn setHidden:NO];
    
    //iOS 4.0 and later
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{ //Animations...
                         
                         CGFloat numberOfColumns = 4.0; //Number of button spaces per row
                         CGFloat numberOfRows = 3.0;    //Number of rows
                    
                         [self.homeBtn setAlpha:1.0];
                         
                         //First Row
                         self.homeBtn.center = [self centerPointForMenuButtonOnRow:1.0 column:1.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         self.lessonsBtn.center = [self centerPointForMenuButtonOnRow:1.0 column:2.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         self.thesaurusBtn.center = [self centerPointForMenuButtonOnRow:1.0 column:3.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         
                         //Second Row
                         self.quizzesBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:2.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         self.gamesBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:3.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         
                         /* NOT IMPLEMENTED
                          self.gradesBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:2.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                          self.settingsBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:3.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                          */
                         
                         //Hide Cross-Outs & Coming Soons
                         for (UIImageView* crossOutView in self.crossOutImageViews) {
                             [crossOutView setHidden:YES];
                         }
                         for (UILabel* comingSoonLabel in self.comingSoonLabels) {
                             [comingSoonLabel setHidden:YES];
                         }
                         
                     }
                     completion:^(BOOL finished){ //Afterwards...
                         
                         
                         
                         //Ease down to original position
                        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn
                                          animations:^{self.menuView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);}//Bring up - above position
                                          completion:^(BOOL finished){ //Afterwards...
                                              
                                              //Re-enable user interaction & update flag
                                              [self.menuView setUserInteractionEnabled:YES];
                                              
                                          }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
    self.homeButtonVisible = YES;
    
}//End showHomeButtonOnMenuButtonAreaView

-(void) hideHomeButtonOnMenuButtonAreaViewWithinDuration:(CGFloat)duration {
    
    //Disable user interaction
    [self.menuView setUserInteractionEnabled:NO];
    
    //iOS 4.0 and later
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationCurveEaseOut
                     animations:^{ //Animations...
                         
                         CGFloat numberOfColumns = 4.0; //Number of button spaces per row
                         CGFloat numberOfRows = 3.0;    //Number of rows
                         
                         //Fade the transient homeBtn
                         [self.homeBtn setAlpha:0.0];
                         [self.homeBtn setCenter:CGPointMake(self.homeBtn.bounds.size.width/2, self.menuButtonAreaView.bounds.size.height/4)]; //Left edge
                         
                         //First Row
                         self.lessonsBtn.center = [self centerPointForMenuButtonOnRow:1.0 column:2.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         self.thesaurusBtn.center = [self centerPointForMenuButtonOnRow:1.0 column:3.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         
                         //Second Row
                         self.quizzesBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:2.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         self.gamesBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:3.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         
                         /* NOT IMPLEMENTED
                         self.gradesBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:2.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                         self.settingsBtn.center = [self centerPointForMenuButtonOnRow:3.0 column:3.0 numberOfRows:numberOfRows numberOfColumns:numberOfColumns];
                          */
                         
                     }
                     completion:^(BOOL finished){ //Afterwards...
                         
                         
                         
                         //Ease down to original position
                         [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseIn
                                          animations:^{self.menuView.transform = CGAffineTransformMakeTranslation(0.0, 0.0);}//Bring up - above position
                                          completion:^(BOOL finished){ //Afterwards...
                                              
                                              //Remove homeButton
                                              [self.homeBtn removeFromSuperview];
                                              [self.homeBtn setHidden:YES];
                                              
                                              //Show Cross-Outs & Coming Soons
                                              for (UIImageView* crossOutView in self.crossOutImageViews) {
                                                  [crossOutView setHidden:NO];
                                              }
                                              for (UILabel* comingSoonLabel in self.comingSoonLabels) {
                                                  [comingSoonLabel setHidden:NO];
                                              }
                                              
                                              //Re-enable user interaction & update flag
                                              [self.menuView setUserInteractionEnabled:YES];
                                              
                                          }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
    self.homeButtonVisible = NO;
    
}//End hideHomeButtonOnMenuButtonAreaView

-(CGPoint) centerPointForMenuButtonOnRow:(CGFloat)rowWholeNumber column:(CGFloat)columnWholeNumber numberOfRows:(CGFloat)numberOfRowsWholeNumber numberOfColumns:(CGFloat)numberOfColumnsWholeNumber {
    
    //Y position coefficient (multiply this number by the row number the button is in to get center.y)
    //Example: I want buttonX in row 2, so buttonX.center.y = rowYCenterPositionCoefficient*2;
    CGFloat rowYCenterPositionCoefficient = self.menuButtonAreaView.bounds.size.height/(numberOfRowsWholeNumber+1.0);
    
    //X position coefficient (same as above for center.x)
    CGFloat columnXCenterPositionCoefficient = self.menuButtonAreaView.bounds.size.width/(numberOfColumnsWholeNumber+1.0);
    
    return CGPointMake(columnXCenterPositionCoefficient * columnWholeNumber, rowYCenterPositionCoefficient * rowWholeNumber);
    
}

/***
 - Method Name -
 switchToView: withTransition: andSubtype: forDuration:
 
 @param view                                 | The UIView* to be displayed.
 @param transition                        | The style of the transition animation
 @param subtype                            | The subtype of of the transition; the direction of the animation
 @param durationForTransition   | The duration in seconds of the animation
 
 - Description -
 This method disposes of the current view from its superview, and adds the passed UIView* to that superview using the transition animation below.
 
 @return is void.
 ***/
-(void) switchToView:(UIView*)view withTransition:(NSString*)transition andSubType:(NSString*)subtype forDuration:(CGFloat)durationForTransition{
    
    //Hide the banner and animate the menuView
    [self.bannerImageView setHidden:YES];
    
    //Get the view that's currently showing
	UIView *currentView = self.activeView;
    UIView *superView = self.view;
    
    //Add the passed view as a subview, after removing currentView from superView (if one exists)
    if (currentView != nil) [currentView removeFromSuperview];
	[superView addSubview:view];
    [superView sendSubviewToBack:view];
    self.activeView = view;
	
	//Set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:durationForTransition];
	[animation setType:transition];
	[animation setSubtype:subtype];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[superView layer] addAnimation:animation forKey:@"SwitchToView"];
    
}//End switchToView withTransition: andSubType: forDuration:

#pragma mark Data

- (BOOL) hasCompletedLessonNumber:(NSInteger)lessonNumberToVerify {
    NSLog(@"hasCompletedLessonNumber:%d ???", lessonNumberToVerify);
    
    BOOL isComplete = NO;
    NSArray* lessonsCompleted = [self completedLessonsList];
    
    for (NSInteger verifiedLessonIndex = 0; verifiedLessonIndex < [lessonsCompleted count]; verifiedLessonIndex++) { //For each verified lesson
        
        NSInteger lessonNumberBeingChecked = [[lessonsCompleted objectAtIndex:verifiedLessonIndex] intValue];
        
        if (lessonNumberBeingChecked == lessonNumberToVerify) { //If lesson number matches
            isComplete = YES;
        }
        
    }
    
    return isComplete;
    
}//End isPurchased

- (NSArray*)completedLessonsList {
    //Returns an array of verified lesson numbers (NSNumber integers)
    
    //Buildable array of lesson numbers to display - will be synced to self.lessonsTableCellMap
    NSMutableArray* lessonsList = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    //Load verified lessons dictionary from locally stored reference
    // *** RRVLocalAuthority ***
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RRVLocalAuthority.plist"];
    
    if ([fileManager fileExistsAtPath:plistPath]) { //File found.
        
        NSDictionary* completedLessonsDict = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"CompletedLessons"] retain]; //Ensure retain
        
        //SPECIAL CASE - Lite Story
        if ( ![[completedLessonsDict objectForKey:@"101"] boolValue] && [[completedLessonsDict objectForKey:@"0"] boolValue] ) { //If Story 101 NOT complete && Story 101 (Lite) IS complete
            
            //Add Story 101 (Lite)
            [lessonsList addObject:[NSNumber numberWithInt:0]];
            
        }
        
        //Lesson numbers increment by 100, from 100 - 900
        for (NSInteger level = 100; level <= 900; level += 100) { //Each level
            
            //Lesson subnumber (added to level) 1-20
            for (NSInteger lessonSubnumber = 1; lessonSubnumber <= 20; lessonSubnumber++) { //Each lesson in level
                
                //Assemble correct lesson number
                NSInteger lessonNumberProper = level+lessonSubnumber;
                
                //Check BOOL value for lesson, key = lesson number as NSString
                BOOL lessonVerified = [[completedLessonsDict objectForKey:[NSString stringWithFormat:@"%d", lessonNumberProper]] boolValue];
                
                if (lessonVerified) { //BOOL value from dictionary is YES
                    NSLog(@"Lesson %d completed.", lessonNumberProper);
                    //Lesson is verified
                    
                    //Add lesson number to verified array - must wrap in NSNumber
                    [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                    
                }//End if{} (lesson purchased)
                else { //BOOL value for lesson is NO, invalid, or does not exist
                    NSLog(@"Lesson %d incomplete.", lessonNumberProper);
                    //Lesson not verified, omit from list
                    
                }//End else{} (lesson not purchased)
            }//End for{} (each lesson in level)
        }//End for{} (each level)
        
        //Release retained dictionary
        [completedLessonsDict release];
        
    }//End if{} (RRVLocalAuthority.plist exists)
    else {
        
        NSLog(@"RRVLocalAuthority not found!");
        
    }
    
    //Return verified lesson numbers
    return [NSArray arrayWithArray:lessonsList];
    
}//End completedLessonsList

- (BOOL) hasPurchasedLessonNumber:(NSInteger)lessonNumberToVerify {
    NSLog(@"hasPurchasedLessonNumber:%d ???", lessonNumberToVerify);
    
    BOOL isPurchased = NO;
    NSArray* lessonsPurchased = [self purchasedLessonsList];
    
    for (NSInteger verifiedLessonIndex = 0; verifiedLessonIndex < [lessonsPurchased count]; verifiedLessonIndex++) { //For each verified lesson
        
        NSInteger lessonNumberBeingChecked = [[lessonsPurchased objectAtIndex:verifiedLessonIndex] intValue];
        
        if (lessonNumberBeingChecked == lessonNumberToVerify) { //If lesson number matches
            isPurchased = YES;
        }
        
    }
    
    return isPurchased;
    
}//End isPurchased

- (NSArray*)purchasedLessonsList {
    //Returns an array of verified lesson numbers (NSNumber integers)
    
    //Buildable array of lesson numbers to display - will be synced to self.lessonsTableCellMap
    NSMutableArray* lessonsList = [[[NSMutableArray alloc] init] autorelease];
    
    //Load verified lessons dictionary from locally stored reference
    // *** RRVLocalAuthority ***
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RRVLocalAuthority.plist"];
    
    //THIS FILE SHOULD BE GARUNTEED TO EXIST.
    //App delegate: if not found at path, it is copied from mainBundle to Documents.
    if([fileManager fileExistsAtPath:plistPath]){ //File found.
        NSDictionary* verifiedLessonsDict = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"PurchasedLessons"] retain]; //Ensure retain
        
        //Lesson numbers increment by 100, from 100 - 900
        for (NSInteger level = 100; level <= 900; level += 100) { //Each level
            
            //Lesson subnumber (added to level) 1-20
            for (NSInteger lessonSubnumber = 1; lessonSubnumber <= 20; lessonSubnumber++) { //Each lesson in level
                
                //Assemble correct lesson number
                NSInteger lessonNumberProper = level+lessonSubnumber;
                
                //Check BOOL value for lesson, key = lesson number as NSString
                BOOL lessonVerified = [[verifiedLessonsDict objectForKey:[NSString stringWithFormat:@"%d", lessonNumberProper]] boolValue];
                
                if (lessonVerified) { //BOOL value from dictionary is YES
                    NSLog(@"Lesson %d PURCHASED.", lessonNumberProper);
                    //Lesson is verified
                    
                    //Add lesson number to verified array - must wrap in NSNumber
                    [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                    
                }//End if{} (lesson purchased)
                else { //BOOL value for lesson is NO, invalid, or does not exist
                    NSLog(@"Lesson %d not purchased.", lessonNumberProper);
                    //Lesson not verified, omit from list
                    
                }//End else{} (lesson not purchased)
            }//End for{} (each lesson in level)
        }//End for{} (each level)
        
        //Release retained dictionary
        [verifiedLessonsDict release];
        
    }//End if{} (RRVLocalAuthority.plist exists)
    else {
        
        NSLog(@"RRVLocalAuthority not found!");
        
    }
    
    //Return verified lesson numbers
    return [NSArray arrayWithArray:lessonsList];
    
}//End purchasedLessonsList



@end
