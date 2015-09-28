//
//  QuizCoverViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 3/28/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuizObject;

@interface QuizCoverViewController : UIViewController {
    
    //Data
    QuizObject* quiz;
    
    //Views
    UILabel* quizTitleLabel;
    UILabel* classNameLabel;
    UILabel* ratioLabel;
    UIButton* letterButton;
    UILabel* percentLabel;
    UIButton* finishedButton;
}
////PROPERTIES////

//Data
@property (nonatomic, retain) QuizObject* quiz;

//Views
@property (nonatomic, retain) IBOutlet UILabel* quizTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel* classNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* ratioLabel;
@property (nonatomic, retain) IBOutlet UIButton* letterButton;
@property (nonatomic, retain) IBOutlet UILabel* percentLabel;
@property (nonatomic, retain) IBOutlet UIButton* finishedButton;

////METHODS////

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil quizInfoDictionary:(NSDictionary*)quizInfo;

//IBActions
- (IBAction) doneWithQuiz:(id)sender;

//Utility Methods
- (void) setCoverWithQuiz:(QuizObject*)quizToDisplay;

@end
