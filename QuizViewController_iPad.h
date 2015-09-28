//
//  QuizViewController_iPad.h
//  RRV101
//
//  Created by Brian C. Grant on 1/25/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved. 
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@class LandingPageViewController;
@class WordBankController;
@class QuestionObject;
@class QuizObject;

@interface QuizViewController_iPad : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate> {
    
    //Data
    QuizObject* quizObject;
    
    //Views
    UIView* wordBankView;
    UITableView* wordBankTableView;
    UIView* quizAreaView;
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
@property (nonatomic, retain) IBOutlet UIView* wordBankView;
@property (nonatomic, retain) IBOutlet UITableView* wordBankTableView;
@property (nonatomic, retain) IBOutlet UIView* quizAreaView;
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

//Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad embedded:(BOOL)partOfLesson preQuiz:(BOOL) precursor;

//Actions

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
-(void) pronounceWord:(NSString*)word;

@end
