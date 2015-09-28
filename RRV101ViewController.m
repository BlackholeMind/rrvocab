//
//  RRV101ViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 9/16/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "RRV101ViewController.h"
#import "SimpleAudioEngine.h"
#import "cocos2d.h"
#import "LandingPageViewController_iPad.h"
#import "LessonSelect.h"
#import "LessonController.h"
#import "QuizViewController.h"
#import "ThesaurusViewController.h"
#import "WordPopGameView.h"
#import <QuartzCore/QuartzCore.h>
#import "TheEndPage.h"
#import "RRVConstants.txt"

#import "StoryIntro101Controller.h"

@implementation RRV101ViewController

#pragma mark Synthesizers

//Data
@synthesize runningOnRetina, menuEnabled, menuHidden, menuRaised, activeView;

//Views
@synthesize landingView, lessonsBtn, quizzesBtn, thesaurusBtn, gamesBtn, gradesBtn, settingsBtn;
@synthesize toolbarView, toolbarTabButton, toolbarHomeButton, toolbarLessonsButton, toolbarQuizzesButton, toolbarGamesButton, toolbarThesaurusButton;

//Controllers & Media

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Remove any observation
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Child VCs
    for (UIViewController* childViewController in [self childViewControllers]) {
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
    }
    
    //Data
    [activeView release];
    
    //Views
        //Landing View
    [landingView release];
    [lessonsBtn release];
    [quizzesBtn release];
    [thesaurusBtn release];
    [gamesBtn release];
    [gradesBtn release];
    [settingsBtn release];
        //Menu Toolbar
    [toolbarView release];
    [toolbarTabButton release];
    [toolbarHomeButton release];
    [toolbarLessonsButton release];
    [toolbarQuizzesButton release];
    [toolbarGamesButton release];
    [toolbarThesaurusButton release];
    
    //Controllers & Media
    
    [super dealloc];
    
} //End dealloc

- (void)didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ![[self view] window]) {
    
        //Data
        self.activeView = nil;
    
        //Views
            //Landing Vew
        self.landingView = nil;
        self.lessonsBtn = nil;
        self.quizzesBtn = nil;
        self.thesaurusBtn = nil;
        self.gamesBtn = nil;
        self.gradesBtn = nil;
        self.settingsBtn = nil;
            //Menu Toolbar
        self.toolbarView = nil;
        self.toolbarTabButton = nil;
        self.toolbarHomeButton = nil;
        self.toolbarLessonsButton = nil;
        self.toolbarQuizzesButton = nil;
        self.toolbarGamesButton = nil;
        self.toolbarThesaurusButton = nil;
    
        //Controllers & Media
        
    }
    
}

#pragma mark Orientation

//// iOS 6.0+
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}//End supportedInterfaceOrientations

- (BOOL) shouldAutorotate {
    
    return YES;
    
}

//// iOS 5.1-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}//End shouldAutorotateToInterfaceOrientation

#pragma mark Setup

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"iPhone/iPod detected, root controller is this view controller.");
        
    //This is an iPhone/iPod specific class, assume device is NOT iPad
        
    //Detect retina display
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
            NSLog(@"Retina Display detected.");
            
        self.runningOnRetina = YES;
            
    }
    else {
            NSLog(@"Standard Definition Display detected.");
            
            self.runningOnRetina = NO;
            
    }
        
    //Place menuView
    CGFloat menuViewY_down = self.view.bounds.size.height - kMenuTabDeltaY;
    self.toolbarView.frame = CGRectMake(self.toolbarView.frame.origin.x, menuViewY_down, self.toolbarView.frame.size.width, self.toolbarView.frame.size.height);
    
    //Initial navigation
    if ( [[self completedLessonsList] count] <= 0 ) {
        NSLog(@"No lessons have been completed!");
        
        //Go to lesson select
        [self hideMenuView];
        [self hideLandingView:0.0];
        [self performSelector:@selector(goLessons:) withObject:nil afterDelay:0.0];
        
    }
    else {
        NSLog(@"User has completed a lesson.");
        
        //Menu view
        [self unhideMenuView];
        [self changeToLandingView:0.5];
        
    }
    
}//End viewDidLoad

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.view.window) {
    
        //Ensure frame for 4" screen
        [UIView animateWithDuration:0.0
                         animations:^{
                         
                             UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
                             CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
                         
                             CGFloat rootViewHeight = keyWindow.bounds.size.height - statusBarFrame.size.height;
                         
                             self.view.frame = CGRectMake(0.0, statusBarFrame.size.height, keyWindow.bounds.size.width, rootViewHeight);
                         }
                         completion:^(BOOL finished){
                             //Afterwards...
                         }];
    }
    
    if ([[self completedLessonsList] count] > 0 && self.activeView) {
        //User has completed a lesson & there is an activeView
        
        [self unhideMenuView];
        
    }
    
}

#pragma mark - Actions -

#pragma mark Landing View

-(IBAction)goLessons:(id)sender{
    
    NSLog(@"goLessons:");
    
    [self reset];
    
    //Display modal lesson selection - single lesson - and observe
    BOOL backButtonEnabled = NO;
    
    if (sender) //Enable back button
        backButtonEnabled = YES;
    else //Nil sender - Remove back button
        backButtonEnabled = NO;
    
    LessonSelect* lessonSelectVC = [[[LessonSelect alloc] initWithNibName:@"LessonSelect" bundle:NULL multipleLessons:NO backButton:backButtonEnabled] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchLesson:) name:LessonSelectionCompleteNotification object:lessonSelectVC];
    [lessonSelectVC setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:lessonSelectVC animated:YES completion:^{
        //Afterwards...
    }];

}

-(IBAction)goQuizzes:(id)sender{
    
    [self reset];
    
    if (![self hasCompletedLessonNumber:101]) { //Hasn't completed first lesson
        //Load Quiz 101 (Lite)
        
        NSNotification* liteQuizNotification = [NSNotification notificationWithName:LessonCompleteNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[NSNumber numberWithInt:0]] forKey:kLessonSelectionArrayInDictionary]];
        
        [self launchQuiz:liteQuizNotification];
        [self unhideMenuView];
        
    }
    else {
    
        //Display modal lesson selection - single lesson - and observe
        LessonSelect* lessonSelectVC = [[[LessonSelect alloc] initWithNibName:@"LessonSelect" bundle:NULL multipleLessons:NO backButton:YES] autorelease];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchQuiz:) name:LessonSelectionCompleteNotification object:lessonSelectVC];
        [self presentViewController:lessonSelectVC animated:YES completion:nil];
        
    }
    
}

-(IBAction)goThesaurus:(id)sender{
    
    ThesaurusViewController* thesaurusViewController = [[[ThesaurusViewController alloc] initWithNibName:@"ThesaurusViewController" bundle:NULL] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissThesaurus:) name:ThesaurusQuitNotification object:thesaurusViewController];
    [self presentViewController:thesaurusViewController animated:YES completion:nil];
    
}

-(IBAction)goGames:(id)sender{
    
    [self reset];
    
    [self.toolbarGamesButton setEnabled:NO];
    
    NSInteger lessonNumberToPlay = 0;
    if ([self hasPurchasedLessonNumber:101] && [self hasCompletedLessonNumber:101]) lessonNumberToPlay = 101;
    
    //Load
    WordPopGameView* wordPopGameController = [[[WordPopGameView alloc] initWithNibName:@"WordPopGameView" bundle:NULL forLessonNumber:lessonNumberToPlay] autorelease];
    [wordPopGameController setWantsFullScreenLayout:YES];
    
    //Observe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome:) name:GameQuitNotification object:wordPopGameController];
    
    //Transition
    [self addChildViewController:wordPopGameController];
    [wordPopGameController didMoveToParentViewController:self];
    [self switchToView:wordPopGameController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
    
    [self unhideMenuView];
    
}

-(IBAction)goGrades:(id)sender{
    //COMING SOON!
}

-(IBAction)goSettings:(id)sender{
    //COMING SOON!
}

#pragma mark Menu Toolbar

-(IBAction) toggleMenuView: (id)sender {
    
    CGFloat menuViewY_up = self.view.bounds.size.height - self.toolbarView.bounds.size.height;
    CGFloat menuViewY_down = self.view.bounds.size.height - kMenuTabDeltaY;
    
        //iOS 4.0 and later...
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         
                         if (self.menuRaised) { // If raised
                             
                             self.toolbarView.frame = CGRectMake(self.toolbarView.frame.origin.x, menuViewY_down, self.toolbarView.frame.size.width, self.toolbarView.frame.size.height);
                             self.menuRaised = NO;
                             
                             
                         }
                         else { // If lowered (showing)
                             
                             self.toolbarView.frame = CGRectMake(self.toolbarView.frame.origin.x, menuViewY_up, self.toolbarView.frame.size.width, self.toolbarView.frame.size.height);
                             self.menuRaised = YES;
                         }
                         
                     } 
                     completion:^(BOOL finished){
                         //Afterwards...
                         
                     }];

}//End toggleMenuView:

-(IBAction) goHome:(id)sender {
    
    //Return user to landing/home view
    [self changeToLandingView:0.5];
    
}//End goHome:

#pragma mark - Callbacks -

#pragma mark Custom

- (void)launchLesson:(NSNotification *)notification {
    NSLog(@"LessonSelect successful!");
    
    //Remove observation & select
    LessonSelect* lessonSelectVC = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LessonSelectionCompleteNotification object:lessonSelectVC];
    [lessonSelectVC dismissViewControllerAnimated:YES completion:^{}];
    
    //Catch lesson selection array from userInfo
    NSArray* lessons = [[notification userInfo] objectForKey:kLessonSelectionArrayInDictionary];
    if (lessons) { //If successful
        
        //Load first lesson in array
        NSInteger lessonNumber = [[lessons objectAtIndex:0] intValue];
        LessonController* lessonController = [[[LessonController alloc] initWithNibName:@"LessonController" bundle:NULL lessonNumber:lessonNumber iPad:NO retina:self.runningOnRetina] autorelease];
        
        //Observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome:) name:LessonCompleteNotification object:lessonController];
        
        //Transition
        [self addChildViewController:lessonController];
        [lessonController didMoveToParentViewController:self];
        [self switchToView:lessonController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
        
        //Disable games while in lesson
        [self.toolbarGamesButton setEnabled:NO];
    
    }//End if{} (lessons array exists)
   
}//End launchLesson:

- (void)launchQuiz:(NSNotification *)notification {
    NSLog(@"LessonSelect successful!");
    
    if ( ![self hasCompletedLessonNumber:101] ) { //If we haven't finished the first lesson...
        //Open the Quiz for lesson 0;
        
    }
    
    //Remove observation
    LessonSelect* lessonSelectVC = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LessonSelectionCompleteNotification object:lessonSelectVC];
    if (lessonSelectVC) [lessonSelectVC dismissViewControllerAnimated:YES completion:^{}];
    
    //Catch lesson selection array from userInfo
    NSArray* lessons = [[notification userInfo] objectForKey:kLessonSelectionArrayInDictionary];
    if (lessons) { //If successful
        
        //Load first lesson in array
        NSInteger lessonNumber = [[lessons objectAtIndex:0] intValue];
        QuizViewController* quizViewController = [[[QuizViewController alloc] initWithNibName:@"QuizViewController" bundle:NULL forLesson:lessonNumber embedded:NO preQuiz:NO] autorelease];
        
        //Observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome:) name:QuizFinishedNotification object:quizViewController];
        
        //Transition
        [self addChildViewController:quizViewController];
        [quizViewController didMoveToParentViewController:self];
        [self switchToView:quizViewController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
        
    }//End if{} (lessons array exists)
    
}//End launchQuiz:

- (void)launchGame:(NSNotification *)notification {
    
    
    
}//End launchGame:

-(void) dismissThesaurus:(NSNotification*)notification {
    
    ThesaurusViewController* thesaurusViewController = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ThesaurusQuitNotification object:thesaurusViewController];
    [thesaurusViewController dismissViewControllerAnimated:YES completion:nil];
    
}//End dismissThesaurs:

-(void) disableThesaurus:(NSNotification*)notification {
    
    [self.toolbarThesaurusButton setEnabled:NO];
    
}//End disableThesaurus:

-(void) enableThesaurus:(NSNotification*)notification {
    
    [self.toolbarThesaurusButton setEnabled:YES];
    
}//End enableThesaurus:

#pragma mark - Utility -

-(void) reset {
    
    [self.toolbarGamesButton setEnabled:YES];
    
    //Remove notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Remove all child VCs
    for (UIViewController* childViewController in self.childViewControllers) {
        
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
        
    }
    
    //Trash (Reset)
    //[[CCDirector sharedDirector] end];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    if (self.activeView) [self.activeView removeFromSuperview];
    self.activeView = nil;
    
    //Observe quiz state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableThesaurus:) name:QuizOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableThesaurus:) name:QuizFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableThesaurus:) name:QuizClosedNotification object:nil];
    
}

-(void) setMenuViewEnabled:(BOOL)menuViewEnabledOrNot {
    
    self.menuEnabled = menuViewEnabledOrNot;
    [self.toolbarView setUserInteractionEnabled:self.menuEnabled];

}//End setMenuViewEnabled:

-(void) hideMenuView {
     NSLog(@"hideMenuView");
    
    //Disable user interaction & flags
    [self setMenuViewEnabled:NO];
    self.menuHidden = YES;
    
    CGFloat menuViewY_hidden = self.view.bounds.size.height;
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         self.toolbarView.frame = CGRectMake(self.toolbarView.frame.origin.x, menuViewY_hidden, self.toolbarView.frame.size.width, self.toolbarView.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         //Afterwards...
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
}//End hideMenuView

-(void) unhideMenuView {
    NSLog(@"unhideMenuView");
    
    self.menuHidden = NO;
    
    CGFloat menuViewY_down = self.view.bounds.size.height - kMenuTabDeltaY;
    
    //iOS 4.0 and later
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         
                         self.toolbarView.frame = CGRectMake(self.toolbarView.frame.origin.x, menuViewY_down, self.toolbarView.frame.size.width, self.toolbarView.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         //Afterwards...
                         
                         [self setMenuViewEnabled:YES];
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
}//End unhideMenuView

-(void) hideLandingView:(CGFloat)duration {
    
    //Disable user interaction
    [self.landingView setUserInteractionEnabled:NO];
    
    //iOS 4.0 and later
        //Bring to hidden
    [UIView animateWithDuration:duration animations:^{ self.landingView.alpha = 0;} completion:^(BOOL finished){
        //Afterwards...
    }];
    
}//End hideLandingView

-(void) unhideLandingView:(CGFloat)duration {
    
    //iOS 4.0 and later
        //Bring to visible, enable user interaction
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         self.landingView.alpha = 100;
                         
                     }
                     completion:^(BOOL finished){
                         //Afterwards...
        
                         [self.landingView setUserInteractionEnabled:YES];
        
                     }];
    
}//End unhideLandingView

-(void) changeToLandingView:(CGFloat)duration{
    
    [self reset];
    
    //Device is iPhone/iPodTouch
    [self hideMenuView];
    [self unhideLandingView:duration];
    
}//End changeToLoginView{}

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
    
    //Hide the landing view
    [self hideLandingView:0.0];
    
    //Get the view that's currently showing
	UIView *currentView = self.activeView;
    UIView *superView = self.view;
    
    //Add the loginPageView as a subview, after removing currentView from superView (if one exists)
    if (currentView != nil) [currentView removeFromSuperview];
    view.frame = superView.bounds;
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
                    NSLog(@"Lesson %d COMPLETED.", lessonNumberProper);
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
