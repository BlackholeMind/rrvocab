//
//  WordBurstVictoryVC.m
//  RRV101
//
//  Created by Brian C. Grant on 5/17/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordBurstVictoryVC.h"
#import "RRVConstants.txt"

@implementation WordBurstVictoryVC

#pragma mark Synthesizers

//Data
@synthesize score, correctCount, incorrectCount, accuracy;

//Views
@synthesize scoreNumberLabel, correctCountLabel, incorrectCountLabel, accuracyLabel, commentLabel;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void) dealloc {
    
    [scoreNumberLabel release];
    [correctCountLabel release];
    [incorrectCountLabel release];
    [accuracyLabel release];
    [commentLabel release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
        
        self.scoreNumberLabel = nil;
        self.correctCountLabel = nil;
        self.incorrectCountLabel = nil;
        self.accuracyLabel = nil;
        self.commentLabel = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil gameVictoryInfo:(NSArray*)victoryInfoArray {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.score = [[victoryInfoArray objectAtIndex:0] intValue];
        self.correctCount = [[victoryInfoArray objectAtIndex:1] intValue];
        self.incorrectCount = [[victoryInfoArray objectAtIndex:2] intValue];
        self.accuracy = ( (CGFloat)self.correctCount / ( (CGFloat)self.correctCount + (CGFloat)self.incorrectCount ) ) * 100.0;
        NSLog(@"Accuracy: %i / (%i + %i) * 100.0 = %%%.2f", self.correctCount, self.correctCount, self.incorrectCount, self.accuracy);
    }
    return self;
    
}//End initWithNibName: bundle: gameVictoryInfo:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Verbatim Labels
    [self.scoreNumberLabel setText:[NSString stringWithFormat:@"%i", self.score]]; NSLog(@"%i Points", self.score);
    [self.correctCountLabel setText:[NSString stringWithFormat:@"%i", self.correctCount]]; NSLog(@"%i Correct", self.correctCount);
    [self.incorrectCountLabel setText:[NSString stringWithFormat:@"%i", self.incorrectCount]]; NSLog(@"%i Incorrect", self.incorrectCount);
    
    //Accuracy
    [self.accuracyLabel setText:[NSString stringWithFormat:@"%.2f%%", self.accuracy]]; NSLog(@"%%%.2f Accuracy", self.accuracy);
    
    //Feedback Comment
    NSString* stringComment = [NSString string];
    if (self.incorrectCount == 0) { stringComment = @"PERFECT"; }
    else if (self.accuracy < 100.0 && self.accuracy >= 95.0) { stringComment = @"Excellent!"; }
    else if (self.accuracy < 95.0 && self.accuracy >= 90.0) { stringComment = @"Great!"; }
    else if (self.accuracy < 90.0 && self.accuracy >= 80.0) { stringComment = @"Good!"; }
    else if (self.accuracy < 80.0 && self.accuracy >= 70.0) { stringComment = @"Keep Going!"; }
    else { stringComment = @"Keep Practicing"; }
    [self.commentLabel setText:stringComment]; 
    
}//End viewDidLoad

#pragma mark - Callbacks -

- (void) playAgain:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WordBurstReadyToPlayNotification object:self];
    
}//End playAgain:

- (void) quitGame:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GameQuitNotification object:self];
    
}//End quitGame:

@end
