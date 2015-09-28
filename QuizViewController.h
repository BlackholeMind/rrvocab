//
//  QuizViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 9/21/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@class WordBankController;
@class QuizObject;
@class QuestionObject;

@interface QuizViewController : UIViewController <UIScrollViewDelegate> {
    
    //Data
    QuizObject* quizObject;
    
    //Views
    UIButton* wordBankButton;
    UILabel* quizCurrentPageLabel;
    UILabel* quizTotalPagesLabel;
    UIView* quizHeaderView;
    UILabel* quizDateLabel;
    UILabel* quizNameLabel;
    UIScrollView* quizAreaScrollView;
    
    //Controllers
    NSArray* quizAreaViewControllers;
    UIViewController* activeController;
}
////PROPERTIES////

//Data
@property (nonatomic, retain) QuizObject* quizObject;

//Views
@property (nonatomic, retain) IBOutlet UIButton* wordBankButton;
@property (nonatomic, retain) IBOutlet UILabel* quizCurrentPageLabel;
@property (nonatomic, retain) IBOutlet UILabel* quizTotalPagesLabel;
@property (nonatomic, retain) IBOutlet UIView* quizHeaderView;
@property (nonatomic, retain) IBOutlet UILabel* quizDateLabel;
@property (nonatomic, retain) IBOutlet UILabel* quizNameLabel;
@property (nonatomic, retain) IBOutlet UIScrollView* quizAreaScrollView;

//Controllers
@property (nonatomic, retain) NSArray* quizAreaViewControllers;
@property (nonatomic, retain) UIViewController* activeController;

////METHODS////
//PUBLIC
//Constructors

//PRIVATE
//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad embedded:(BOOL)partOfLesson preQuiz:(BOOL)precursor;
//Actions
-(IBAction) viewWordBank: (id)sender;
//Utility
  //Quiz Drawing
-(void) configureQuizArea;
-(void) displayQuiz: (QuizObject*)quiz;
-(void) showGradedQuiz:(QuizObject*)quiz;
  //Quiz Events
-(void) doneWithQuiz;
-(void) submitQuiz;
-(void) choseAnswer;
-(void) scrollPage;
-(void) updatePageControlLabels;
-(void) setAppropriateObservers;

@end
