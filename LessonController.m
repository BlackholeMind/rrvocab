//
//  LessonController.m
//  RRV101
//
//  Created by Brian C. Grant on 3/17/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//
//

#import <QuartzCore/QuartzCore.h>
#import "LessonController.h"
#import "RRVMessageViewController.h"
#import "RRVConstants.txt"

//Story Intros
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "StoryIntro101Controller.h"

//Story
    //iPhone
#import "StoryPageViewController.h"
#import "StoryTitlePage.h"
    //iPad
#import "StoryBookVC_iPad.h"
#import "StoryPageViewController_iPad.h"
#import "StoryViewController_iPad.h"

//Quiz
    //iPhone
#import "QuizViewController.h"
    //iPad
#import "QuizViewController_iPad.h"
    //Common
#import "QuizObject.h"
#import "QuestionObject.h"

//Games
#import "WordPopGameView.h"

//Media
#import "VideoPlayerViewController.h"

@implementation LessonController

#pragma mark Synthesizers

//Data
@synthesize runningOnIPad, runningOnRetina, orientationLockedToLandscape, lessonNumber, preQuiz, postQuiz;
//Views
@synthesize coverView, lessonBeginButton, titleLabel, lessonNumberLabel, activeView;
//Controllers

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc {
    
    //Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Child VCs
    for (UIViewController* childViewController in [self childViewControllers]) {
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
    }
    
    //Data
    [preQuiz release];
    [postQuiz release];
    
    
    //Views
    [coverView release];
    [lessonBeginButton release];
    [titleLabel release];
    [lessonNumberLabel release];
    [activeView release];
    
    //Controllers
    
    [super dealloc];
    
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not visible
   
        //Data
        self.preQuiz = nil;
        self.postQuiz = nil;
    
        //Views
        self.coverView = nil;
        self.lessonBeginButton = nil;
        self.titleLabel = nil;
        self.lessonNumberLabel = nil;
        self.activeView = nil;
    }
    
    //Controllers
}

#pragma mark Orientation

-(NSUInteger)supportedInterfaceOrientations {
    
    NSLog(@" LESSON CONTROLLER: supportedInterfaceOrietations{}");
    
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskPortrait;
    
    //Detect device
    if (self.runningOnIPad && !self.orientationLockedToLandscape) { //Device is an iPad & Orientation not locked
        
        NSLog(@"ALL ORIENTATIONS!!");
        mask = UIInterfaceOrientationMaskAll;
        
    }
    if (self.runningOnIPad) { //Device is an iPad & orientation is locked!!
        
        NSLog(@"LANSCAPE ONLY!!");
        mask = UIInterfaceOrientationMaskLandscape;
        
    }
    else { //Device is an iPhone/iPod
        
        mask = UIInterfaceOrientationMaskPortrait;
        
    }
    
    return mask;
    
}

-(BOOL)shouldAutorotate {
    
    return YES;
    
}

// DEPRECATED as of iOS 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    BOOL shouldRotate = NO;
    
    //Detect device
    if (self.runningOnIPad && !self.orientationLockedToLandscape) { //Device is an iPad & Orientation not locked
        shouldRotate = YES;
    }
    if (self.runningOnIPad) { //Device is an iPad & orientation is locked!!
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    else { //Device is an iPhone/iPod
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait) ;
    }
    
    return shouldRotate;
    
}//End shouldAutorotateToInterfaceOrientation:

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    for (StoryBookVC_iPad* storyBookVC_iPad in [self childViewControllers]) {
    
        if (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            
            storyBookVC_iPad.view.transform = CGAffineTransformMakeRotation(0.0);
            storyBookVC_iPad.view.center = self.view.center;
        }
        
    }
    
}//End didRotateFromInterfaceOrientation:


#pragma mark Setup

//Custom initalizer
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lessonNumber:(NSInteger)lessonNumberToLoad iPad:(BOOL)isOniPad retina:(BOOL)isOnRetina {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Sync passed parameters
        self.lessonNumber = lessonNumberToLoad;
        self.runningOnIPad = isOniPad;
        self.runningOnRetina = isOnRetina;
        
    }
    
    return self;
    
}//End initWithNibName: bundle: lessonNumber:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Lesson Titles
    [self.titleLabel setText:[self titleFromLessonNumber:self.lessonNumber]];

    if (self.lessonNumber == 0)
        [self.lessonNumberLabel setText:@"Story 101 (Lite)"];
    else
        [self.lessonNumberLabel setText:[NSString stringWithFormat:@"Story %d", self.lessonNumber]];
    
    self.coverView.bounds = self.view.bounds;
    [self configureImage];
    
}//End viewDidLoad

#pragma mark - Actions -

-(IBAction) beginLesson:(id)sender {
    
    //Hide native views
    [self.titleLabel setHidden:YES];
    [self.lessonNumberLabel setHidden:YES]; 
    [self.lessonBeginButton setHidden:YES];
    [self.coverView setHidden:YES];
    
    //Move to Pre Quiz module
    [self switchToModule:kModuleIdentifierPreQuiz];
    
}//End beginLesson

#pragma mark - Callbacks -

-(void) introFinished: (NSNotification*)notification {//Fired when storyIntroController posts its completion notification
    
    //Receive quiz metrics from the notification by accessing the attached userInfo dictionary
    if (notification) {//If notification not nil
        if ([notification userInfo]) {//If userInfo dictionary not nil
            self.preQuiz = [QuizObject  loadQuizFromDictionary:[notification userInfo]];
        }
    }
    
    //Remove intro module from childViewControllers
    UIViewController* introModuleController = [notification object];
    [self removeChildModuleController:introModuleController];
    
    //Move to Story module
    [self switchToModule:kModuleIdentifierStory];
    
    [[CCDirector sharedDirector] end];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    if ([[self completedLessonsList] count] > 0)
        [self showMessageWithTitle:@"Read To You?" text:@""]; //Skip Instructions
    else
        [self showStoryInstructions]; //Don't skip instructions
    
    self.orientationLockedToLandscape = YES;
    
}//End preQuizFinished

-(void) storyFinished: (NSNotification*)notification {//Fired when storyPageViewController posts its completion notification
    
    [self saveCompletionOfLessonNumber:self.lessonNumber];
    
    //Remove story module from childViewControllers
    for (UIViewController* childViewController in [self childViewControllers]) {
        
        if ([childViewController respondsToSelector:@selector(storyPageViewArea)] || [childViewController respondsToSelector:@selector(pageVC)]) {
            //Either iPad or iPhone storyModuleController
            
            [self removeChildModuleController:childViewController];
        }
        
    }
    
    //Move to Post Quiz module
    [self switchToModule:kModuleIdentifierGame];
    
    self.orientationLockedToLandscape = NO;
    
}//End storyFinished

-(void) postQuizFinished: (NSNotification*)notification {//Fired when postQuizViewController posts its completion notification
    
    //Receive quiz metrics from the notification by accessing the attached userInfo dictionary
    if (notification) {//If notification not nil
        if ([notification userInfo]) {//If userInfo dictionary not nil
            self.postQuiz = [QuizObject  loadQuizFromDictionary:[notification userInfo]];
        }
    }
    
    //Remove intro module from childViewControllers
    UIViewController* quizModuleController = [notification object];
    [self removeChildModuleController:quizModuleController];
    
    //Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //QUIT LESSON CONTROLLER
    [[NSNotificationCenter defaultCenter] postNotificationName:LessonCompleteNotification object:self userInfo:nil]; //Use userInfo to send grades somewhere
    
}//postQuizFinished

-(void) gameFinished: (NSNotification*)notification {
    
    //Remove intro module from childViewControllers
    UIViewController* gameModuleController = [notification object];
    [self removeChildModuleController:gameModuleController];
    
    //Stop observing
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //QUIT LESSON CONTROLLER
    [[NSNotificationCenter defaultCenter] postNotificationName:LessonCompleteNotification object:self userInfo:nil]; //Use userInfo to send grades somewhere
    
}//End gameFinished:

-(void) userFinishedWithMessage:(NSNotification *)notification {
    
    RRVMessageViewController* messageVC = [notification object];
    
    //Animate message away from viewable area (iOS 4.0 and later)
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^{messageVC.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);}//Reset to offscreen
                     completion:^(BOOL finished) {//Code to perform after animation completes
                         
                         //Remove observer
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:RRVMessageQuitNotification object:messageVC];
                         
                         //Remove view
                         [messageVC.view removeFromSuperview];
                         [messageVC willMoveToParentViewController:nil];
                         [messageVC removeFromParentViewController];
                         [messageVC release];
                         
                         //Re-enable disabled touches
                         [self.activeView setUserInteractionEnabled:YES];
                         
                         //If story is showing, update autoplay
                         BOOL shouldAutoplayStory = [[NSUserDefaults standardUserDefaults] boolForKey:key_StoryAutoplayUserDefaultsKey];
                            //iPad Story
                         for (UIViewController* childViewController in [self childViewControllers]) {
                             
                             if ([childViewController respondsToSelector:@selector(storyPageViewArea)]) { //iPad (StoryBookVC_iPad)
                             
                                 StoryBookVC_iPad* storyBookVC_iPad = (StoryBookVC_iPad*)childViewController;
                                 
                                 for (UIViewController* childViewController in [storyBookVC_iPad childViewControllers]) { //Find the pageVC as a child VC
                                     
                                     if ([childViewController respondsToSelector:@selector(pageVC)]) { //Found the the pageVC
                                         
                                         NSLog(@"Found an iPad Story controller, set autoplay?");
                                         
                                         StoryPageViewController_iPad* storyPageVC = (StoryPageViewController_iPad*)childViewController;
                                         
                                         StoryViewController_iPad* titlePageController = (StoryViewController_iPad*)[[storyPageVC.pageVC viewControllers] objectAtIndex:0];
                                         [titlePageController.videoController.player play];
                                         if (shouldAutoplayStory) [storyPageVC autoplay];
                                         
                                     }
                                     
                                 }
                             
                             }
                             else if ([childViewController respondsToSelector:@selector(pageVC)]) { //iPhone
                                 
                                 NSLog(@"Found an iPhone Story controller, set autoplay?");
                                 
                                 StoryPageViewController* storyPageViewController = (StoryPageViewController*)childViewController;
                                 
                                 StoryTitlePage* titlePageController = (StoryTitlePage*)[[storyPageViewController.pageVC viewControllers] objectAtIndex:0];
                                 [titlePageController.videoController.player play];
                                 if (shouldAutoplayStory) [storyPageViewController autoplay];
                                 
                             }
                             
                         }
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
}

#pragma mark - Utility -

-(void) switchToModule: (NSInteger)moduleIdentifier {
    
    //Remove previous observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIViewController* moduleController;
    
    if (moduleIdentifier == kModuleIdentifierPreQuiz) { //-----{ PreQuiz Module }-----
        
        //Intros are universal
        moduleController = [[[StoryIntro101Controller alloc] initWithNibName:@"StoryIntro101Controller" bundle:NULL lessonNumber:self.lessonNumber iPad:self.runningOnIPad retina:self.runningOnRetina] autorelease];
        [moduleController.view setFrame:self.view.bounds];
        [self addChildViewController:moduleController];
        [moduleController didMoveToParentViewController:self];
        [self switchToView:moduleController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(introFinished:) name:StoryIntroFinishedNotification object:moduleController];
        
    }//End if{} (preQuiz module)
    else if (moduleIdentifier == kModuleIdentifierStory) { //-----{ Story Module }-----
        
        [[NSNotificationCenter defaultCenter] postNotificationName:StoryBeginNotification object:self];
        
        if (self.runningOnIPad) { //iPad
            
            moduleController = [[[StoryBookVC_iPad alloc] initWithNibName:@"StoryBookVC_iPad" bundle:NULL forLesson:self.lessonNumber] autorelease];
            moduleController.wantsFullScreenLayout = YES;
            
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) { //Story is being started in portrait
                
                //Load to landscape
                moduleController.view.bounds = CGRectMake(0.0, 0.0, 1024, 768);
                CGFloat turnDegree = 90.0;
                if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationMaskPortraitUpsideDown)
                    turnDegree *= -1;
                moduleController.view.transform = CGAffineTransformMakeRotation(turnDegree/57.2958); //(Radian = Degree/57.2958....)
                moduleController.view.center = CGPointMake(self.view.center.x+([UIApplication sharedApplication].statusBarFrame.size.height/2), self.view.center.y);
                moduleController.view.center = self.view.center;
            }
            
            [self addChildViewController:moduleController];
            [moduleController didMoveToParentViewController:self];
            
            //TRANSITION (View)
            //Get the view that's currently showing
            UIView *currentView = self.activeView;
            UIView *superView = self.view;
            
            //Add the loginPageView as a subview, after removing currentView from superView (if one exists)
            if (currentView != nil) [currentView removeFromSuperview];
            [superView addSubview:moduleController.view];
            [superView sendSubviewToBack:moduleController.view];
            self.activeView = moduleController.view;
            
            //Set up an animation for the transition between the views
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.5];
            [animation setType:kCATransitionFade];
            [animation setSubtype:kCATransitionFromRight];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            [[superView layer] addAnimation:animation forKey:@"SwitchToView"];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyFinished:) name:StoryFinishedNotification object:nil];
            
        }
        else { //iPhone
            
            moduleController = [[[StoryPageViewController alloc] initWithNibName:@"StoryPageViewController" bundle:NULL forLesson:self.lessonNumber] autorelease];
            [self addChildViewController:moduleController];
            [moduleController didMoveToParentViewController:self];
            [self switchToView:moduleController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storyFinished:) name:StoryFinishedNotification object:nil];
            
        }
        
    }//End else if{} (story module)
    else if (moduleIdentifier == kModuleIdentifierGame) { //-----{ Game Module }-----
        
        //Load
        WordPopGameView* wordPopGameController = [[[WordPopGameView alloc] initWithNibName:@"WordPopGameView" bundle:NULL forLessonNumber:self.lessonNumber] autorelease];
        [wordPopGameController setWantsFullScreenLayout:YES];
        
        //Observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameFinished:) name:GameQuitNotification object:wordPopGameController];
        
        //Transition
        [self addChildViewController:wordPopGameController];
        [wordPopGameController didMoveToParentViewController:self];
        [self switchToView:wordPopGameController.view withTransition:kCATransitionFade andSubType:kCATransitionFromRight forDuration:0.5];
        
    }//End else if{} (postQuiz module)
    else { //Unrecognized module  identifier
        
        NSLog(@"Unrecognized module identifier.");
        
    }//End else{} (unrecognized identifier)
    
}//End switchToModule:

-(void) switchToView:(UIView*)view withTransition:(NSString*)transition andSubType:(NSString*)subtype forDuration:(CGFloat)durationForTransition{
    
    //Get the view that's currently showing
	UIView *currentView = self.activeView;
    UIView *superView = self.view;
    
    //Add the loginPageView as a subview, after removing currentView from superView (if one exists)
    if (currentView != nil) [currentView removeFromSuperview];
    [view setFrame:superView.bounds];
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

-(void) removeChildModuleController:(UIViewController*)moduleController {
    
    [moduleController willMoveToParentViewController:nil];
    [moduleController removeFromParentViewController];
    
}//End removeModuleController:

-(void) showMessageWithTitle:(NSString*)titleForMessage text:(NSString*)textForMessage {
      
    //Disable touches underneath
    [self.activeView setUserInteractionEnabled:NO];
    
    //Initialize
    RRVMessageViewController* messageVC = [[RRVMessageViewController alloc] initWithNibName:@"RRVMessageViewController" bundle:NULL iPad:self.runningOnIPad title:titleForMessage description:textForMessage];
        
    //Configure frame
    if (!self.runningOnIPad) { //iPhone/iPod
        [messageVC.view setFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)]; //Set Y to just below this VC.view's height (just off-screen, bottom)
    }
    else { //iPad
        [messageVC.view setFrame:CGRectMake((self.view.bounds.size.width-messageVC.view.bounds.size.width)/2, self.view.bounds.size.height, messageVC.view.bounds.size.width, messageVC.view.bounds.size.height)];
    }
    
    //Add to view
    [self addChildViewController:messageVC];
    [messageVC didMoveToParentViewController:self];
    [self.view addSubview:messageVC.view];
    
    //Animate into viewable area (iOS 4.0 and later)
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{ //Bring up from bottom
                             
                             if (!self.runningOnIPad) { //iPhone/iPod transition
                                 messageVC.view.transform = CGAffineTransformMakeTranslation(0.0, -self.view.bounds.size.height);
                             }
                             else { //iPad transition
                                 
                                 //Subtract (message view height + (empty space / 2) ) from y - this centers the view vertically on screen
                                 messageVC.view.transform = CGAffineTransformMakeTranslation(0.0, -(messageVC.view.bounds.size.height + ((self.view.bounds.size.height-messageVC.view.bounds.size.height)/2)));
                             }
                         
                         }
                         completion:^(BOOL finished){
                             
                         }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
    //Observe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFinishedWithMessage:) name:RRVMessageQuitNotification object:messageVC];
        
}

-(void) showStoryInstructions {
    
    //Disable touches underneath
    [self.activeView setUserInteractionEnabled:NO];
    
        //MountView
    UIView*  instructionsMountView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
    instructionsMountView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [instructionsMountView setBackgroundColor:[UIColor clearColor]];
    [instructionsMountView setAlpha:0.0];
    
        //Instructions
    NSString* deviceString = @""; if (self.runningOnIPad) deviceString = @"iPad"; else deviceString = @"iPhone";
    NSString* imageName = [NSString stringWithFormat:@"storyInstructions_%@", deviceString];
    UIImageView* instructionsImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
    instructionsImageView.frame = CGRectMake(0.0, 0.0, (instructionsImageView.frame.size.width/3)*2, (instructionsImageView.frame.size.height/3)*2); // Two thirds of imageSize (image is assumed to be altered screenshot - which would be full screen)
    instructionsImageView.contentMode = UIViewContentModeScaleAspectFit;
    instructionsImageView.center = instructionsMountView.center;
    
        //Shadow
    UIImageView* shadowImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Shadow_portrait.png"]] autorelease];
    shadowImageView.contentMode = UIViewContentModeScaleToFill;
    CGFloat shadowSpread = 20.0;
    shadowImageView.frame = CGRectMake(instructionsImageView.frame.origin.x-shadowSpread, instructionsImageView.frame.origin.y-shadowSpread, instructionsImageView.frame.size.width+(shadowSpread*2), instructionsImageView.frame.size.height+(shadowSpread*2));
    
        //Add
    [instructionsMountView addSubview:shadowImageView];
    [instructionsMountView addSubview:instructionsImageView];
    [self.view addSubview:instructionsMountView];
    
    if (!self.runningOnIPad) {
        instructionsMountView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    }
    
    //Animate into view
    //iOS 4.0+
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                     animations:^{
                         //Animations...
                          instructionsMountView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         //Afterwards...
                     }];
    
    //Add Gesture recognizer to exit on tap
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapExitStoryInstructions:)];
    [instructionsMountView addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
}//End showStoryInstructions

- (void)tapExitStoryInstructions:(UITapGestureRecognizer *)recognizer {
    
    //Re-enable touches underneath
    [self.activeView setUserInteractionEnabled:YES];
    
    [recognizer.view removeFromSuperview];
    
    [self showMessageWithTitle:@"Read To You?" text:@""];
    
}//End tapExitStoryInstructions

/***
 - Method Name -
 titleForLessonNumber:
 
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
 Returns an NSString* that contains the title of the story (described above),
 which has been aggregated from the valid (content) text parts from the .txt file.
 ***/
- (NSString*) titleFromLessonNumber:(NSInteger)lessonNumberInt {
    
    //Get text from file
    NSString* storyFilename = [NSString stringWithFormat:@"rrv%ds", lessonNumberInt];
    NSString* lessonStoryFilePath = [[NSBundle mainBundle] pathForResource:storyFilename ofType:@"txt"];
    NSURL* lessonStoryURL = [NSURL fileURLWithPath:lessonStoryFilePath];
    NSString* lessonTextFromFile = [NSString stringWithContentsOfURL:lessonStoryURL encoding:NSUTF8StringEncoding error:nil];
    
    //Break apart into array of strings
    NSArray* textChunksFromFile = [lessonTextFromFile componentsSeparatedByString:@"#"];
    NSMutableArray* lessonStoryText = [[[NSMutableArray alloc] init] autorelease]; //make mutable array to aggregate story text - starts empty
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
    
    return [lessonStoryText objectAtIndex:0];
}//End textArrayForLesson

-(void) configureImage {
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Load graphic media for page (.mp4 video, or .png image)
    NSString* movieName = [NSString stringWithFormat:@"rrv%dlessonCover", self.lessonNumber];
    NSString* moviePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"mp4"];
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"png"];
    
    if ([fileManager fileExistsAtPath:moviePath]) { //Video file exists
    
        //To enable video, create a VideoPlayerViewController property (self.videoController) and use code below.
        /*
        NSLog(@"Loading video for page %d", self.pageNumberForView);
        
        //Load and configure player
        NSLog(@"%@.mp4", movieName);
        NSLog(@"At path: %@", moviePath);
        NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
        
        VideoPlayerViewController* player = [[VideoPlayerViewController alloc] init];
        player.URL = movieURL;
        player.view.frame = self.videoView.bounds;
        self.videoController = player;
        [player release];
        
        //Observe player
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReadyToPlay:) name:MyVideoPlayerReadyToPlayNotification object:self.videoController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying:) name:MyVideoPlayerPlaybackCompleteNotification object:self.videoController];
        */
        
    }
    else if ([fileManager fileExistsAtPath:imagePath]) { //Image file exists (no movie)
        
        NSLog(@"%@.png", movieName);
        
        [self.coverView setBounds:self.view.bounds];
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.coverView.bounds] autorelease];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imageView setBounds:self.coverView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self.coverView addSubview:imageView];
        [self.coverView sendSubviewToBack:imageView];
        
    }//End else if {} (Image for page exists)
    else { //No video or image
        
        NSLog(@"Did not find lesson cover visual media for lesson: %d", self.lessonNumber);
        
        [self.coverView setBackgroundColor:[UIColor whiteColor]];
        [self.titleLabel setTextColor:[UIColor darkGrayColor]];
        [self.lessonNumberLabel setTextColor:[UIColor darkGrayColor]];
        
    }
    
}

-(void) saveCompletionOfLessonNumber: (NSInteger)lessonNumberToSave {
    
    // *** RRVLocalAuthority ***
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RRVLocalAuthority.plist"];
    
    //THIS FILE SHOULD BE GARUNTEED TO EXIST.
        //App delegate: if not found at path, it is copied from mainBundle to Documents.
    if([fileManager fileExistsAtPath:plistPath]){ //File found. Update for content.
        
        //Load verified lessons dictionary from locally stored reference
        NSMutableDictionary* localAuthorityDict = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] retain];
        NSDictionary* purchasedLessonsDict = [[NSDictionary dictionaryWithDictionary:[localAuthorityDict objectForKey:@"PurchasedLessons"]] retain]; //Ensure retain
        NSMutableDictionary* completedLessonsDict = [[NSMutableDictionary dictionaryWithDictionary:[localAuthorityDict objectForKey:@"CompletedLessons"]] retain];
        
        //Set flag for lesson
        [completedLessonsDict setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", lessonNumberToSave]];
        
        //Update the RRVLocalAuthority (Overwrite file)
        NSMutableDictionary* localAuthorityUpdateDict = [NSMutableDictionary dictionaryWithDictionary:localAuthorityDict];
        [localAuthorityUpdateDict setObject:completedLessonsDict forKey:@"CompletedLessons"];
        [localAuthorityUpdateDict setObject:purchasedLessonsDict forKey:@"PurchasedLessons"];
        [localAuthorityUpdateDict writeToFile:plistPath atomically:YES];
        
        //Release retained dictionaries
        [localAuthorityDict release];
        [purchasedLessonsDict release];
        [completedLessonsDict release];
        
    }
    
}//End saveCompletionOfLessonNumber:

- (NSArray*)completedLessonsList {
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
    if([fileManager fileExistsAtPath:plistPath]) { //File found.
        
        NSDictionary* verifiedLessonsDict = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"CompletedLessons"] retain]; //Ensure retain
        
        //SPECIAL CASE - (Lite) Story
        if ( ![[verifiedLessonsDict objectForKey:@"101"] boolValue] && [[verifiedLessonsDict objectForKey:@"0"] boolValue] ) { //If Story 101 NOT complete && Story 101 (Lite) IS complete
            
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
                BOOL lessonVerified = [[verifiedLessonsDict objectForKey:[NSString stringWithFormat:@"%d", lessonNumberProper]] boolValue];
                if (lessonVerified) { //BOOL value from dictionary is YES
                    NSLog(@"Lesson %d purchased.", lessonNumberProper);
                    //Lesson is verified
                    
                    //Add lesson number to verified array - must wrap in NSNumber
                    [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                    
                }//End if{} (lesson purchased)
                else { //BOOL value for lesson is NO, invalid, or does not exist
                    NSLog(@"Lesson %d NOT PURCHASED.", lessonNumberProper);
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
    
}//End verifiedLessonsList

@end
