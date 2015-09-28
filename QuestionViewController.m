//
//  QuestionViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 3/28/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "QuestionViewController.h"
#import "QuestionObject.h"
#import "RRVConstants.txt"

@implementation QuestionViewController

#pragma mark Synthesizers

@synthesize questionToDisplay;
@synthesize numberLabel, instructionTextView, pronunciationButton, wordLabel;
@synthesize indicatorA, indicatorB, indicatorC, indicatorD;
@synthesize labelA, labelB, labelC, labelD;
@synthesize buttonA, buttonB, buttonC, buttonD;


#pragma mark - VIEW LIFECYCLE -

#pragma mark Memory Management

- (void)dealloc {
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Data
    [questionToDisplay release];
    
    //Views
    [numberLabel release];
    [instructionTextView release];
    [pronunciationButton release];
    [wordLabel release];
    [indicatorA release];
    [indicatorB release];
    [indicatorC release];
    [indicatorD release];
    [labelA release];
    [labelB release];
    [labelC release];
    [labelD release];
    [buttonA release];
    [buttonB release];
    [buttonC release];
    [buttonD release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.questionToDisplay = nil;
    
        //Views
        self.numberLabel = nil;
        self.instructionTextView = nil;
        self.pronunciationButton = nil;
        self.wordLabel = nil;
        self.indicatorA = nil;
        self.indicatorB = nil;
        self.indicatorC = nil;
        self.indicatorD = nil;
        self.labelA = nil;
        self.labelB = nil;
        self.labelC = nil;
        self.labelD = nil;
        self.buttonA = nil;
        self.buttonB = nil;
        self.buttonC = nil;
        self.buttonD = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forQuestion:(QuestionObject*)question {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Retain question
        self.questionToDisplay = question;
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Set the question number and word labels
    [self.numberLabel setText:[NSString stringWithFormat:@"%@.", [self.questionToDisplay numberString]]];
    [self.wordLabel setText:self.questionToDisplay.wordForQuestion];
    
    //Set the answer choices. Based on how many there are, this will start with the highest number answer choice and count backwards - avoiding invalid indices.
    switch ([self.questionToDisplay.answerChoices count]-1) {
        case 3:
            [self.buttonD setTitle:[self.questionToDisplay.answerChoices objectAtIndex:3] forState:UIControlStateNormal];
            [self.buttonD setTitle:[self.questionToDisplay.answerChoices objectAtIndex:3] forState:UIControlStateHighlighted];
            [self.buttonD setTitle:[self.questionToDisplay.answerChoices objectAtIndex:3] forState:UIControlStateSelected];
            [self.buttonD setTitle:[self.questionToDisplay.answerChoices objectAtIndex:3] forState:UIControlStateDisabled];
            [self.buttonD setTag:104];
            [self.indicatorD setHidden:NO];
            [self.labelD setHidden:NO];
            [self.buttonD setHidden:NO];
        case 2:
            [self.buttonC setTitle:[self.questionToDisplay.answerChoices objectAtIndex:2] forState:UIControlStateNormal];
            [self.buttonC setTitle:[self.questionToDisplay.answerChoices objectAtIndex:2] forState:UIControlStateHighlighted];
            [self.buttonC setTitle:[self.questionToDisplay.answerChoices objectAtIndex:2] forState:UIControlStateSelected];
            [self.buttonC setTitle:[self.questionToDisplay.answerChoices objectAtIndex:2] forState:UIControlStateDisabled];
            [self.buttonC setTag:103];
            [self.indicatorC setHidden:NO];
            [self.labelC setHidden:NO];
            [self.buttonC setHidden:NO];
        case 1:
            [self.buttonB setTitle:[self.questionToDisplay.answerChoices objectAtIndex:1] forState:UIControlStateNormal];
            [self.buttonB setTitle:[self.questionToDisplay.answerChoices objectAtIndex:1] forState:UIControlStateHighlighted];
            [self.buttonB setTitle:[self.questionToDisplay.answerChoices objectAtIndex:1] forState:UIControlStateSelected];
            [self.buttonB setTitle:[self.questionToDisplay.answerChoices objectAtIndex:1] forState:UIControlStateDisabled];
            [self.buttonB setTag:102];
            [self.indicatorB setHidden:NO];
            [self.labelB setHidden:NO];
            [self.buttonB setHidden:NO];
        case 0:
            [self.buttonA setTitle:[self.questionToDisplay.answerChoices objectAtIndex:0] forState:UIControlStateNormal];
            [self.buttonA setTitle:[self.questionToDisplay.answerChoices objectAtIndex:0] forState:UIControlStateHighlighted];
            [self.buttonA setTitle:[self.questionToDisplay.answerChoices objectAtIndex:0] forState:UIControlStateSelected];
            [self.buttonA setTitle:[self.questionToDisplay.answerChoices objectAtIndex:0] forState:UIControlStateDisabled];
            [self.buttonA setTag:101];
            [self.indicatorA setHidden:NO];
            [self.labelA setHidden:NO];
            [self.buttonA setHidden:NO];
            break;
            
        default:
            //Code for an index (count) not supported above.
            break;
    }
}

#pragma mark - Delegates -

#pragma mark AVAudioPlayer

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully: (BOOL)flag{ //An AVAudioPlayer finished playing
    
    //Release any audio player after it finishes
    [player release];
    
}//End audioPlayerDidFinishPlaying: successfully:

#pragma mark - Actions -

-(IBAction) pronounceWord:(id)sender{//User pressed a pronunciationButton
    
    //Get the wordToPronounce
    NSString* wordToPronounce = self.questionToDisplay.wordForQuestion;
    
    //Play the audio file with the name of wordToPronounce
    AVAudioPlayer* wordAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:wordToPronounce ofType:@"mp3"]] error:NULL];
    [wordAudioPlayer setDelegate:self];
    
    [wordAudioPlayer play];
    
}//End pronounceWord:

-(IBAction) choseAnswer:(id)sender {//Delay for selection animations
    NSLog(@"choseAnswer:");
    [self performSelector:@selector(setAnswer:) withObject:sender afterDelay:0.3];
}//End choseAnswer:

#pragma mark - UTILITY METHODS -

-(void) setAnswer:(UIButton*)sender{//User chose an answer
    NSLog(@"setAnswer:");
    
    /// VIEWS
    
    [self clearAnswerSelections];
    
    //Select the chosen button
    [sender setHighlighted:YES];
    
    //Set indicator image
    switch ([sender tag]) {
        case 104:
            [self.indicatorD setImage:[UIImage imageNamed:@"circle_24blue.png"] forState:UIControlStateNormal];
            break;
        case 103:
            [self.indicatorC setImage:[UIImage imageNamed:@"circle_24blue.png"] forState:UIControlStateNormal];
            break;
        case 102:
            [self.indicatorB setImage:[UIImage imageNamed:@"circle_24blue.png"] forState:UIControlStateNormal];
            break;
        case 101:
            [self.indicatorA setImage:[UIImage imageNamed:@"circle_24blue.png"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    /// DATA
    
    //Set the answer choice to chosenAnswer
    self.questionToDisplay.chosenAnswer = sender.titleLabel.text;
    
    //Post notification: Question has been answered.
    [[NSNotificationCenter defaultCenter] postNotificationName:QuestionAnsweredNotification object:self userInfo:[NSDictionary dictionaryWithObject:self.questionToDisplay forKey:kQuestionObjectInDictionary]]; NSLog(@"QuestionAnsweredNotification Posted.");
    
}//End setAnswer:

-(void) showGradedQuestion {
    
    /// DATA
    
    //Grade question
    [self.questionToDisplay grade];
    
    /// VIEWS
    
    //Clear indicators and selectors
    [self clearAnswerSelections];
    
    //Disable answer buttons, already graded!
    [self disableAnswerChoices];
    
    //Set indicators
    if (self.questionToDisplay.answeredCorrectly) {//Question was answered correctly
        
        //Indicate correct choice
        if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonA.titleLabel text]]) {//Check mark on A
            [indicatorA setImage:[UIImage imageNamed:@"correct@2x.png"] forState:UIControlStateNormal];
            [self.buttonA setHighlighted:YES];
        }
        else if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonB.titleLabel text]]) {//Check mark on A
            [indicatorB setImage:[UIImage imageNamed:@"correct@2x.png"] forState:UIControlStateNormal];
            [self.buttonB setHighlighted:YES];
        }
        else if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonC.titleLabel text]]) {//Check mark on A
            [indicatorC setImage:[UIImage imageNamed:@"correct@2x.png"] forState:UIControlStateNormal];
            [self.buttonC setHighlighted:YES];
        }
        else if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonD.titleLabel text]]) {//Check mark on A
            [indicatorD setImage:[UIImage imageNamed:@"correct@2x.png"] forState:UIControlStateNormal];
            [self.buttonD setHighlighted:YES];
        }
        
    }
    else {//Question was answered incorrectly
        
        //Indicate wrong choice
        if ([self.questionToDisplay.chosenAnswer isEqualToString:[self.buttonA.titleLabel text]]) {//Check mark on A
            [indicatorA setImage:[UIImage imageNamed:@"incorrect@2x.png"] forState:UIControlStateNormal];
            [self.buttonA setHighlighted:YES];
        }
        else if ([self.questionToDisplay.chosenAnswer isEqualToString:[self.buttonB.titleLabel text]]) {//Check mark on A
            [indicatorB setImage:[UIImage imageNamed:@"incorrect@2x.png"] forState:UIControlStateNormal];
            [self.buttonB setHighlighted:YES];
        }
        else if ([self.questionToDisplay.chosenAnswer isEqualToString:[self.buttonC.titleLabel text]]) {//Check mark on A
            [indicatorC setImage:[UIImage imageNamed:@"incorrect@2x.png"] forState:UIControlStateNormal];
            [self.buttonC setHighlighted:YES];
        }
        else if ([self.questionToDisplay.chosenAnswer isEqualToString:[self.buttonD.titleLabel text]]) {//Check mark on A
            [indicatorD setImage:[UIImage imageNamed:@"incorrect@2x.png"] forState:UIControlStateNormal];
            [self.buttonD setHighlighted:YES];
        }
        
        //Indicate correct answer
        if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonA.titleLabel text]]) {//Check mark on A
            [indicatorA setImage:[UIImage imageNamed:@"next_24green.png"] forState:UIControlStateNormal];
        }
        else if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonB.titleLabel text]]) {//Check mark on A
            [indicatorB setImage:[UIImage imageNamed:@"next_24green.png"] forState:UIControlStateNormal];
        }
        else if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonC.titleLabel text]]) {//Check mark on A
            [indicatorC setImage:[UIImage imageNamed:@"next_24green.png"] forState:UIControlStateNormal];
        }
        else if ([self.questionToDisplay.correctAnswer isEqualToString:[self.buttonD.titleLabel text]]) {//Check mark on A
            [indicatorD setImage:[UIImage imageNamed:@"next_24green.png"] forState:UIControlStateNormal];
        }
        
    }
    
}//End showGradedQuestion

-(void) clearAnswerSelections {
    
    //Deselect all buttons and remove indicator images
    [self.buttonA setHighlighted:NO];
    [self.buttonB setHighlighted:NO];
    [self.buttonC setHighlighted:NO];
    [self.buttonD setHighlighted:NO];
    [self.indicatorA setImage:nil forState:UIControlStateNormal];
    [self.indicatorB setImage:nil forState:UIControlStateNormal];
    [self.indicatorC setImage:nil forState:UIControlStateNormal];
    [self.indicatorD setImage:nil forState:UIControlStateNormal];
    
}//End clearAnswerSelections

-(void) disableAnswerChoices {
    
    [self.buttonA setUserInteractionEnabled:NO];
    [self.buttonB setUserInteractionEnabled:NO];
    [self.buttonC setUserInteractionEnabled:NO];
    [self.buttonD setUserInteractionEnabled:NO];
    
}//End disableAnswerChoices

@end
