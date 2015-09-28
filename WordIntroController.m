//
//  WordIntroController.m
//  RRV101
//
//  Created by Brian C. Grant on 4/1/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordIntroController.h"
#import "WordObject.h"
#import "QuestionObject.h"
#import "QuestionViewController.h"
#import "WordView.h"
#import "RRVConstants.txt"

@implementation WordIntroController

#pragma mark Synthesizers

@synthesize runningOniPad, runningOnRetina, wordToIntroduce, questionObjectToReturn, presentedModally;
@synthesize mountingBackground, mountArea;

#pragma mark - Global Non-Properties

static const CGFloat kDuration_DelayPriorToWordView = 0.0;
static const CGFloat kDuration_TransitionToWordView = 1.5;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //ChildVCs
    for (UIViewController* childVC in self.childViewControllers) {
        [childVC.view removeFromSuperview];
        [childVC willMoveToParentViewController:nil];
        [childVC removeFromParentViewController];
    }
    
    //Data
    [wordToIntroduce release];
    [questionObjectToReturn release];
    
    //Views
    [mountingBackground release];
    [mountArea release];
    
    //Controllers
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not visible
    
        //Data
        self.wordToIntroduce = nil;
        self.questionObjectToReturn = nil;
    
        //Views
        self.mountingBackground = nil;
        self.mountArea = nil;
    
        //Controllers
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    BOOL shouldRotate;
    
    if (self.runningOniPad) {
        
        shouldRotate = YES;
        
    }
    else {
        
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait);
        
    }
    
    NSLog(@"WordIntro shouldRotate: %i", shouldRotate);
    
    return shouldRotate;
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forWordObject:(WordObject*)wordObjectToIntroduce presentedModally:(BOOL)shouldBePresentedModally iPad:(BOOL)isOniPad retina:(BOOL)isOnRetina {
    
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.wordToIntroduce = wordObjectToIntroduce;
        self.presentedModally = shouldBePresentedModally;
        self.runningOniPad = isOniPad;
        self.runningOnRetina = isOnRetina;
        
    }//End if{} (exists)
    
    return self;
    
}//End initWithNibName: bundle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Modal configuration
    if (self.presentedModally) {
        [self.mountingBackground setHidden:YES];
        
        [self.mountArea setFrame:self.view.bounds];
    }
    
    //QuestionView setup
    QuestionObject* questionObjectToLoad = [QuestionObject loadForWord:self.wordToIntroduce questionNumber:0];
    [questionObjectToLoad shuffleAnswerChoices];
    [questionObjectToLoad shuffleAnswerChoices];
    [questionObjectToLoad shuffleAnswerChoices];
    
    QuestionViewController* precursorQuestionVC = [[[QuestionViewController alloc] initWithNibName:@"QuestionViewController" bundle:NULL forQuestion:questionObjectToLoad] autorelease];
    [precursorQuestionVC.view setFrame:CGRectMake(0, 0, self.mountArea.bounds.size.width, self.mountArea.bounds.size.height)];
    [precursorQuestionVC.numberLabel setHidden:YES];
    
    //Mount QuestionView & observe
    [self addChildViewController:precursorQuestionVC];
    [precursorQuestionVC didMoveToParentViewController:self];
    [self.mountArea addSubview:precursorQuestionVC.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAnsweredQuestion:) name:QuestionAnsweredNotification object:precursorQuestionVC];
    
}//End viewDidLoad

#pragma mark - Callbacks -

#pragma mark Interaction

-(void) userAnsweredQuestion:(NSNotification *)notification {//QuestionView has posted a kQuestionAnsweredNotificationName notification
    
    QuestionViewController* precursorQuestionVC = [notification object];
    
    //Catch questionObject from notification
    self.questionObjectToReturn = [[notification userInfo] objectForKey:kQuestionObjectInDictionary];
    if (self.questionObjectToReturn == nil) NSLog(@"WordIntroController caught nil WordObject...");
    else NSLog(@"WordIntroController caught a QuestionObject for word: %@", self.questionObjectToReturn.wordForQuestion);
    
    //Show graded question for user
    [precursorQuestionVC showGradedQuestion];
    
    //After 3 seconds, move to wordView
    [self performSelector:@selector(moveToWordViewFromQuestionVC:) withObject:precursorQuestionVC afterDelay:kDuration_DelayPriorToWordView];
    
}//End userAnsweredQuestion:

-(void) userFinishedWithWordView:(NSNotification *)notification {//WordView has posted a kWordViewFinishedNotificationName notification
    NSLog(@"WordIntroController caught WordViewFinishedNotification.");
    
    WordView* wordVC = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordViewFinishedNotification object:wordVC];
    
    //Post notification of completion & embed (graded) questionObject from questionView in userInfo
    [[NSNotificationCenter defaultCenter] postNotificationName:WordIntroFinishedNotification object:self userInfo:[NSDictionary dictionaryWithObject:self.questionObjectToReturn forKey:kQuestionObjectInDictionary]];
    if (self.questionObjectToReturn == nil) NSLog(@"Posted nil WordObject...");
    else NSLog(@"Posted a WordObject for word: %@", self.questionObjectToReturn.wordForQuestion);
    
    [wordVC willMoveToParentViewController:nil];
    [wordVC removeFromParentViewController];
    
}//End userFinishedWithWordView:

#pragma mark Utility

-(void) moveToWordViewFromQuestionVC:(QuestionViewController*)precursorQuestionVC {
    
    //WordView setup
    WordView* wordVC = [[[WordView alloc] initWithNibName:@"WordView" bundle:NULL forWordObject:self.wordToIntroduce modalPresentation:NO] autorelease];
    [self addChildViewController:wordVC];
    [wordVC didMoveToParentViewController:self];
    [wordVC.view setFrame:CGRectMake(0, 0, self.mountArea.bounds.size.width, self.mountArea.bounds.size.height)];
    
    //Remove the questionView (and observation) & replace with wordView
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [precursorQuestionVC.view removeFromSuperview];
    [precursorQuestionVC willMoveToParentViewController:nil];
    [precursorQuestionVC removeFromParentViewController];
    [wordVC.view setFrame:self.mountArea.bounds];
    [self.mountArea addSubview:wordVC.view];
    
    //Set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:kDuration_TransitionToWordView];
    [animation setType:kCATransitionFade];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.mountArea layer] addAnimation:animation forKey:@"SwitchToView"];
    
    //Observe wordView
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFinishedWithWordView:) name:WordViewFinishedNotification object:wordVC];
    
}//End moveToWordView

@end
