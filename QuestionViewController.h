//
//  QuestionViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 3/28/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@class QuestionObject;

@interface QuestionViewController : UIViewController <AVAudioPlayerDelegate> {
    
    //Data
    QuestionObject* questionToDisplay;
    
    //Views
    UILabel* numberLabel;
    UITextView* instructionTextView;
    UIButton* pronunciationButton;
    UILabel* wordLabel;
    UIButton* indicatorA;
    UIButton* indicatorB;
    UIButton* indicatorC;
    UIButton* indicatorD;
    UILabel* labelA;
    UILabel* labelB;
    UILabel* labelC;
    UILabel* labelD;
    UIButton* buttonA;
    UIButton* buttonB;
    UIButton* buttonC;
    UIButton* buttonD;
    
}
////PROPERTIES////

//Data
@property (nonatomic, retain) QuestionObject* questionToDisplay;

//Views
@property (nonatomic, retain) IBOutlet UILabel* numberLabel;
@property (nonatomic, retain) IBOutlet UITextView* instructionTextView;
@property (nonatomic, retain) IBOutlet UIButton* pronunciationButton;
@property (nonatomic, retain) IBOutlet UILabel* wordLabel;
@property (nonatomic, retain) IBOutlet UIButton* indicatorA;
@property (nonatomic, retain) IBOutlet UIButton* indicatorB;
@property (nonatomic, retain) IBOutlet UIButton* indicatorC;
@property (nonatomic, retain) IBOutlet UIButton* indicatorD;
@property (nonatomic, retain) IBOutlet UILabel* labelA;
@property (nonatomic, retain) IBOutlet UILabel* labelB;
@property (nonatomic, retain) IBOutlet UILabel* labelC;
@property (nonatomic, retain) IBOutlet UILabel* labelD;
@property (nonatomic, retain) IBOutlet UIButton* buttonA;
@property (nonatomic, retain) IBOutlet UIButton* buttonB;
@property (nonatomic, retain) IBOutlet UIButton* buttonC;
@property (nonatomic, retain) IBOutlet UIButton* buttonD;

////METHODS////
//PUBLIC
//Constructors

//PRIVATE

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forQuestion:(QuestionObject*)question;

//IBActions//
-(IBAction) pronounceWord:(id)sender;

//Utility Methods//
-(void) setAnswer:(UIButton*)sender;
-(void) showGradedQuestion;
-(void) clearAnswerSelections;
-(void) disableAnswerChoices;

@end
