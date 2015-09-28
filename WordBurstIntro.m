//
//  WordBurstIntro.m
//  RRV101
//
//  Created by Brian C. Grant on 5/14/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordBurstIntro.h"

@implementation WordBurstIntro

@synthesize wordListCount, gameCondition, victoryNumber, reuseWords, minScore, maxScore;
@synthesize victoryNumberLabel, victoryNumberDescription, victoryNumberSlider;
@synthesize gameModeSegmentedControl;
@synthesize reuseWordsButton, endlessButton, quitGameButton, playGameButton;

#pragma mark Global Non-Properties
static NSInteger const minWords = 3;
static NSInteger const maxWords = 40;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void) dealloc {
    // Release any retained subviews before deallocating
    // e.g. [self.myOutlet release];
    
    [victoryNumberLabel release];
    [victoryNumberDescription release];
    [victoryNumberSlider release];
    [gameModeSegmentedControl release];
    [reuseWordsButton release];
    [endlessButton release];
    [quitGameButton release];
    [playGameButton release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        self.victoryNumberLabel = nil;
        self.victoryNumberDescription = nil;
        self.victoryNumberSlider = nil;
        self.gameModeSegmentedControl = nil;
        self.reuseWordsButton = nil;
        self.endlessButton = nil;
        self.quitGameButton = nil;
        self.playGameButton = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
    
}//End shouldAutorotateToInterfaceOrientation

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil wordListCount:(NSInteger)listCount{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.wordListCount = listCount;
        self.minScore = minWords*3;
        self.maxScore = maxWords*3;
        
    }
    return self;
    
}//End initWithNibName: bundle:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.gameCondition = kGameConditionWords;
    [self.reuseWordsButton setSelected:NO];
    [self.victoryNumberSlider setMinimumValue:minWords];
    [self.victoryNumberSlider setMaximumValue:maxWords];
    if (wordListCount <= maxWords) [self.victoryNumberSlider setValue:wordListCount animated:YES];
    else [self.victoryNumberSlider setValue:maxWords animated:YES];
    [self.victoryNumberLabel setText:[NSString stringWithFormat:@"%.0f", [self.victoryNumberSlider value]]];
    [self.victoryNumberDescription setText:@"correct."];
    
}//End viewDidLoad

#pragma mark - IBActions -

- (IBAction) gameModeChanged:(id)sender {
    
    switch (self.gameModeSegmentedControl.selectedSegmentIndex) {
            
        case 0: //Words
            //Set default word settings - play the game list (up to 100 words)
            self.gameCondition = kGameConditionWords;
            if (!self.endlessButton.isSelected)[self.reuseWordsButton setSelected:NO];
            [self.victoryNumberSlider setMinimumValue:minWords];
            [self.victoryNumberSlider setMaximumValue:maxWords];
            if (wordListCount <= maxWords) [self.victoryNumberSlider setValue:wordListCount animated:YES];
            else [self.victoryNumberSlider setValue:maxWords animated:YES];
            [self.victoryNumberLabel setText:[NSString stringWithFormat:@"%.0f", [self.victoryNumberSlider value]]];
            [self.victoryNumberDescription setText:@"correct."];
            
            break;
            
        case 1: //Score
            //Set default word settings - play the game list (up to 100 words)
            self.gameCondition = kGameConditionScore;
            [self.reuseWordsButton setSelected:YES];
            [self.victoryNumberSlider setMinimumValue:minScore];
            [self.victoryNumberSlider setMaximumValue:maxScore];
            if (wordListCount <= maxWords) [self.victoryNumberSlider setValue:wordListCount*3];
            else [self.victoryNumberSlider setValue:maxScore animated:YES];
            [self.victoryNumberLabel setText:[NSString stringWithFormat:@"%.0f", [self.victoryNumberSlider value]]];
            [self.victoryNumberDescription setText:@"points."];
            
            break;
            
        default:
            break;
    }//End switch{} (selectected index of victorySegmentedControl)
    
}//End gameModeChanged:

- (IBAction) reuseWordsChanged:(id)sender {
    
    //Only deselect if selected, and if we are counting words, that are less than the count (and not infinite)
    if (self.reuseWordsButton.isSelected && self.gameCondition == kGameConditionWords && [self.victoryNumberSlider value] <= wordListCount && !self.endlessButton.isSelected) {
        [self.reuseWordsButton setSelected:NO];
    }
    else if (self.reuseWordsButton.isSelected == NO) {
        [self.reuseWordsButton setSelected:YES];
    }
    
}//End reuseWordsChanged:

- (IBAction) victorySliderChanged:(id)sender {
    
    //User wants a finite number, if endless button is selected - unselect it
    if ([self.endlessButton isSelected]) [self.endlessButton setSelected:NO];
    
    //If the current value exceeds the wordList count, you must reuse words
    if ([self.victoryNumberSlider value] > wordListCount) [self.reuseWordsButton setSelected:YES];
    
    //If the current value does not exceed the count and we are counting words, unselect re-use words to promote variety
    if ([self.victoryNumberSlider value] <= wordListCount && self.gameCondition == kGameConditionWords) [self.reuseWordsButton setSelected:NO];
    
    //Set number to label
    [self.victoryNumberLabel setText:[NSString stringWithFormat:@"%.0f", [self.victoryNumberSlider value]]];
    
}//End victorySliderChanged:

- (IBAction) endlessButtonChanged:(id)sender {
    
    if (self.endlessButton.isSelected) {
        [self.endlessButton setSelected:NO];
        //User wants finite play, show the slider & set defaults
        [self.victoryNumberLabel setHidden:NO];
        [self.victoryNumberDescription setHidden:NO];
        [self.victoryNumberSlider setHidden:NO];
        if (self.gameCondition == kGameConditionWords) {
            [self.reuseWordsButton setSelected:NO];
            [self.victoryNumberSlider setMinimumValue:minWords];
            [self.victoryNumberSlider setMaximumValue:maxWords];
            if (wordListCount <= maxWords) [self.victoryNumberSlider setValue:wordListCount animated:YES];
            else [self.victoryNumberSlider setValue:maxWords animated:YES];
        } 
        [self.victoryNumberLabel setText:[NSString stringWithFormat:@"%.0f", [self.victoryNumberSlider value]]];
    }
    else if (self.endlessButton.isSelected == NO) {
        [self.endlessButton setSelected:YES];
        //User wants infinite play. Hide the victory labels, slider & select re-use words
        [self.victoryNumberLabel setHidden:YES];
        [self.victoryNumberDescription setHidden:YES];
        [self.victoryNumberSlider setHidden:YES];
        [self.reuseWordsButton setSelected:YES];
    }
}//End endlessButtonChanged:

- (IBAction) playGameButtonPushed:(id)sender {
    
    //self.gameCondition already set
    
    //Victory Number
    if (self.endlessButton.isSelected) self.victoryNumber = -1;
    else self.victoryNumber = [self.victoryNumberSlider value];
    
    //Reuse Words
    if (self.reuseWordsButton.isSelected) self.reuseWords = YES; else self.reuseWords = NO;
    
    //Post conditions
    NSArray* gameConditions = [NSArray arrayWithObjects: [NSNumber numberWithInt:self.gameCondition], [NSNumber numberWithFloat:self.victoryNumber], [NSNumber numberWithBool:self.reuseWords], nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WordBurstReadyToPlayNotification object:self userInfo:[NSDictionary dictionaryWithObject:gameConditions forKey:@"GameConditions"]];
    
}//End playGameButtonPushed:

- (IBAction) quitGameButtonPushed:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GameQuitNotification object:self];
    
}//End quitGameButtonPushed:

@end
