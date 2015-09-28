//
//  QuizViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 9/21/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "QuizViewController.h"
#import "WordBankController.h"
#import "QuizObject.h"
#import "QuizCoverViewController.h"
#import "QuestionViewController.h"
#import "QuizSubmitViewController.h"
#import "QuestionObject.h"
#import "WordObject.h"
#import "RRVConstants.txt"

@implementation QuizViewController

#pragma mark Synthesizers

//Data
@synthesize quizObject; 
//Views
@synthesize wordBankButton, quizCurrentPageLabel, quizTotalPagesLabel;
@synthesize quizHeaderView, quizDateLabel, quizNameLabel, quizAreaScrollView;
//Controllers
@synthesize quizAreaViewControllers, activeController;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.quizAreaScrollView.delegate = nil;
    
    //Data
    [quizObject release];
    
    //Views
    [wordBankButton release];
    [quizCurrentPageLabel release];
    [quizTotalPagesLabel release];
    [quizHeaderView release];
    [quizDateLabel release];
    [quizNameLabel release];
    [quizAreaScrollView release];
    
    //Controllers
    [quizAreaViewControllers release];
    [activeController release];
    
    [super dealloc];
}//End dealloc

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.quizObject = nil;
    
        //Views
        self.wordBankButton = nil;
        self.quizCurrentPageLabel = nil;
        self.quizTotalPagesLabel = nil;
        self.quizHeaderView = nil;
        self.quizDateLabel = nil;
        self.quizNameLabel = nil;
        self.quizAreaScrollView = nil;
    
        //Controllers
        self.quizAreaViewControllers = nil;
        self.activeController = nil;
        
    }
    
}//End didReceiveMemoryWarning

- (void) viewDidDisappear:(BOOL)animated {
    
    //Notify observers of quiz state
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizClosedNotification object:self];
    
}//End viewDidDisappear:

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    //Return YES from this method for supported orientations 
    
    //Detect device
    NSString* detectedDevice = [[UIDevice currentDevice] model];
    NSRange textRange = [[detectedDevice lowercaseString] rangeOfString:@"ipad"];
    
    if(textRange.location != NSNotFound){ //Device is an iPad
        //Support landscape orientations
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    else{ //Device not an iPad
        //Restrict to portrait orientation
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

//Custom initialization includes lessonNumberToLoad
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad embedded:(BOOL)partOfLesson preQuiz:(BOOL)precursor {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Assemble a unique quiz
        self.quizObject = [[[QuizObject alloc] initForLessonNumber:lessonNumberToLoad] autorelease];
        self.quizObject.quizIsEmbedded = partOfLesson;
        self.quizObject.quizIsPrecursor = precursor;
    }
    return self;
}//End initWithNibName: bundle: forLesson:

- (void)viewDidLoad{
    [super viewDidLoad];
    //Do any additional setup after loading the view from its nib.
    
    //Notify observers of quiz state
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizOpenedNotification object:self];
    
    //Set dateLabel
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    [self.quizDateLabel setText:[dateFormatter stringFromDate:self.quizObject.dateStarted]];
    [dateFormatter release];
    
    //Draw quiz to quizAreaScrollView
    [self displayQuiz:self.quizObject];
    
    //Pre-quiz conditions
    if (self.quizObject.quizIsPrecursor) {
        
        //Disable scrolling
        [self.quizAreaScrollView setScrollEnabled:NO];
        
    }
    
    //Scroll to first question
    [self performSelector:@selector(scrollPage) withObject:nil afterDelay:0.5];
    
    NSLog(@"Finished Drawing Quiz.");
}//End viewDidLoad:

#pragma mark - Delegates -

#pragma mark UIScrollView

-(void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView {
    
    //Set current page
    [self updatePageControlLabels];
    
    //Update observations
    [self setAppropriateObservers];
    
}//End scrollViewDidEndDecelerating:

#pragma mark - Actions -

-(IBAction) viewWordBank: (id) sender{//User pressed Word Bank button
    
    //Load a word bank
    WordBankController* wordBankViewController = [[WordBankController alloc] initWithNibName:@"WordBankController" bundle:NULL];
    [wordBankViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:wordBankViewController animated:YES completion:^{
        //Afterwards...
    }];
    
}//End viewWordBank:

#pragma mark - Utility -

#pragma mark Quiz Drawing

-(void) configureQuizArea {
    
    //Configure the quizAreaScrollView
    self.quizAreaScrollView.contentSize = CGSizeMake(self.quizAreaScrollView.bounds.size.width*(1+[self.quizObject.questionObjects count]+1), 393);//Height of QuestionView
    [self.quizAreaScrollView scrollRectToVisible:CGRectMake(0, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height) animated:NO];
    
    //Configure the pageControlLabel variables
    self.quizObject.currentPage = 0;
    self.quizObject.numberOfPages = 1+[self.quizObject.questionObjects count]+1;
    [self.quizCurrentPageLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.currentPage]];
    [self.quizTotalPagesLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.numberOfPages-1]];
    
}//End configureQuizArea

-(void) displayQuiz: (QuizObject*)quiz {
    
    //Configure the quiz area
    [self configureQuizArea]; 
    
    //Keep an array of View Controllers used
    NSMutableArray* VCs = [NSMutableArray arrayWithCapacity:(1+[quiz.questionObjects count]+1)];
    
    //Cover Page
    QuizCoverViewController* newCoverVC = [[QuizCoverViewController alloc] initWithNibName:@"QuizCoverViewController" bundle:NULL quizInfoDictionary:[quiz collapseToDictionary]];
    [newCoverVC.view setFrame:CGRectMake(0, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height)];
    [VCs addObject:newCoverVC];//Add to array
    [self.quizAreaScrollView addSubview:newCoverVC.view];//Add view to quizArea
    [newCoverVC release];
    
    //Questions
    for (int questionIndex = 0; questionIndex < [quiz.questionObjects count]; questionIndex++) {//For each QuestionObject in Quiz
        
        //Create current question view controller (temp)
        QuestionViewController* newQuestionVC = [[QuestionViewController alloc] initWithNibName:@"QuestionViewController" bundle:NULL forQuestion:[quiz.questionObjects objectAtIndex:questionIndex]];
        [newQuestionVC.view setFrame:CGRectMake((questionIndex+1)*self.quizAreaScrollView.bounds.size.width, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.contentSize.height)];
        [VCs addObject:newQuestionVC];//Add to array
        [self.quizAreaScrollView addSubview:newQuestionVC.view];//Add view to quizArea
        [newQuestionVC release];//Release temp VC (retained by array)
        
    }//End for{} (each QuestionObject in Quiz)
    
    //Submit Page
    QuizSubmitViewController* newSubmitVC = [[QuizSubmitViewController alloc] initWithNibName:@"QuizSubmitViewController" bundle:NULL];
    [newSubmitVC.view setFrame:CGRectMake([VCs count]*self.quizAreaScrollView.bounds.size.width, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.contentSize.height)];
    if (self.quizObject.quizIsPrecursor) {
        [newSubmitVC.submitButton setHidden:YES];
        [newSubmitVC.instructionTextView setText:@"You are finished!"];
    }
    [newSubmitVC.view setUserInteractionEnabled:NO];
    [VCs addObject:newSubmitVC];
    [self.quizAreaScrollView addSubview:newSubmitVC.view];
    [newSubmitVC release];
    
    //Retain view controllers used
    self.quizAreaViewControllers = [NSArray arrayWithArray:VCs];
    
    //Redraw if necessary
    [self.quizAreaScrollView setNeedsLayout];
    
    //Set active controller
    self.activeController = [self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage];
    
}//End displayQuiz:

-(void) showGradedQuiz: (QuizObject*) quiz {
    
    //Update cover
    [(QuizCoverViewController*)[self.quizAreaViewControllers objectAtIndex:0] setCoverWithQuiz:quiz];
    
    //Update Question Views
    for (NSInteger questionIndex = 1; questionIndex < ([self.quizAreaViewControllers count]-1); questionIndex++) {//For each questionView in viewControllers
        [(QuestionViewController*)[self.quizAreaViewControllers objectAtIndex:questionIndex] showGradedQuestion];
    }
    
}//End showGradedQuiz:

#pragma mark Quiz Events

-(void) doneWithQuiz {//User wishes to move on
    
    //Post completion notification with metrics
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizFinishedNotification object:self userInfo:[self.quizObject collapseToDictionary]];
    
    NSLog(@"Posted QuizFinished Notification");
}//End doneWithQuiz:

-(void) submitQuiz{//User has pushed "Turn In Quiz" button
    
    self.quizObject.dateSubmitted = [NSDate date];//Set submit date
    [self.quizObject grade];//Grade Quiz
    //TO DO: Save Quiz somewhere
    
    if (!self.quizObject.quizIsPrecursor) { //If NOT pre-quiz
        
        //Update Views if NOT Pre-Quiz
        [self showGradedQuiz:self.quizObject]; 
    
        //Scroll to cover
        [self.quizAreaScrollView scrollRectToVisible:CGRectMake(0, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height) animated:YES];
        [self performSelector:@selector(updatePageControlLabels) withObject:nil afterDelay:0.9];
        [self performSelector:@selector(setAppropriateObservers) withObject:nil  afterDelay:1.0];
        
    }//End if{} (not pre-quiz)
    
}//End submitQuiz:

-(void) choseAnswer{
    NSLog(@"QuestionAnsweredNotification Observed.");
    
    [self performSelector:@selector(scrollPage) withObject:nil afterDelay:0.2];
    
}//End choseAnswer:

-(void) scrollPage{
    
    [self.quizAreaScrollView scrollRectToVisible:CGRectMake(((self.quizObject.currentPage+1)*self.quizAreaScrollView.bounds.size.width), 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height) animated:YES];
    
    [self performSelector:@selector(updatePageControlLabels) withObject:self.quizAreaScrollView afterDelay:0.6];
    [self performSelector:@selector(setAppropriateObservers) withObject:nil  afterDelay:0.6];
    
}//End scrollPage

-(void) updatePageControlLabels {
    
    //Calculate page after scrolling ends, set that page
	self.quizObject.currentPage = self.quizAreaScrollView.contentOffset.x/self.quizAreaScrollView.bounds.size.width;
    [self.quizCurrentPageLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.currentPage]];
    [self.quizTotalPagesLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.numberOfPages-1]];
    
}//End setPageControlLabels

-(void) setAppropriateObservers {
    
    //Remove observation
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Catch Pre-Quiz submission
    if (self.quizObject.currentPage == (self.quizObject.numberOfPages - 1) && self.quizObject.quizIsPrecursor) { //Submit Page of Pre-Quiz
        [self submitQuiz];
        [self performSelector:@selector(doneWithQuiz) withObject:nil afterDelay:2.0];
    }
    
    //Decide observer
    else if (self.quizObject.currentPage == 0) {//Cover Page
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneWithQuiz) name:QuizFinishedNotification object:[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage]];
        NSLog(@"Added Cover Observer");
    }
    else if (self.quizObject.currentPage == (self.quizObject.numberOfPages - 1)) {//Submit Page
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitQuiz) name:QuizSubmittedNotification object:[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage]];
        NSLog(@"Added Submit Observer");
        
        [[[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage] view] setUserInteractionEnabled:YES];
    }
    else {//Question Page
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choseAnswer) name:QuestionAnsweredNotification object:[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage]];
        NSLog(@"Added Question Observer");
    }
}//End setAppropriateObservers

@end
