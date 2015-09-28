//
//  QuizCoverViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 3/28/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "QuizCoverViewController.h"
#import "QuizObject.h"
#import "RRVConstants.txt"

@implementation QuizCoverViewController

//Data
@synthesize quiz;

//Views
@synthesize quizTitleLabel, classNameLabel, ratioLabel, letterButton, percentLabel, finishedButton;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc {
    
    //Data
    [quiz release];
    
    //Views
    [quizTitleLabel release];
    [classNameLabel release];
    [ratioLabel release];
    [letterButton release];
    [percentLabel release];
    [finishedButton release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.quiz = nil;
    
        //Views
        self.quizTitleLabel = nil;
        self.classNameLabel = nil;
        self.ratioLabel = nil;
        self.percentLabel = nil;
        self.finishedButton = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil quizInfoDictionary:(NSDictionary*)quizInfo {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Load Quiz
        self.quiz = [QuizObject loadQuizFromDictionary:quizInfo];
        
    }
    
    return self;
    
}//End initWithNibName: bundle: quizInfoDictionary:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Set views
    [self setCoverWithQuiz:self.quiz];    
    
}//End viewDidLoad

#pragma mark - Actions -

- (IBAction) doneWithQuiz:(id)sender {
    
    //Notify
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizFinishedNotification object:self];
    
}//End doneWithQuiz:

#pragma mark - Utility -

- (void) setCoverWithQuiz:(QuizObject*)quizToDisplay {
    
    //Set labels
    if (quizToDisplay.lessonNumber == 0) [self.quizTitleLabel setText:@"Quiz 101 (Lite)"];
    else [self.quizTitleLabel setText:[NSString stringWithFormat:@"Quiz %i", quizToDisplay.lessonNumber]];
    
    [self.classNameLabel setText:quizToDisplay.classOfUser];
    if (quizToDisplay.quizIsGraded) {
        [self.ratioLabel setText:[quizToDisplay ratioString]];
        [self.ratioLabel setHidden:NO];
        [self.letterButton setTitle:[quizToDisplay letterGradeString] forState:UIControlStateNormal];
        [self.letterButton setHidden:NO];
        [self.percentLabel setText:[quizToDisplay percentString]];
        [self.percentLabel setHidden:NO];
        [self.finishedButton setHidden:NO];
    }
    
}//End setCoverWithQuiz:

@end
