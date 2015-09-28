//
//  LessonController.h
//  RRV101
//
//  Created by Brian C. Grant on 3/17/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuizObject;
@class StoryIntro101Controller;
@class StoryPageViewController;
@class QuizViewController;
@class LessonReportController;
@class StoryBookVC_iPad;
@class QuizViewController_iPad;
@class RRVMessageViewController;

@interface LessonController : UIViewController {
    
    //Data
    BOOL runningOnIPad;
    BOOL runningOnRetina;
    BOOL orientationLockedToLandscape;
    NSInteger lessonNumber;
    QuizObject* preQuiz;
    QuizObject* postQuiz;
    
    //Views
    UIView* coverView;
    UIButton* lessonBeginButton;
    UILabel* titleLabel;
    UILabel* lessonNumberLabel;
    UIView* activeView;
    
    //Controllers
    
}
////PROPERTIES////

//Data
@property BOOL runningOnIPad;
@property BOOL runningOnRetina;
@property BOOL orientationLockedToLandscape;
@property NSInteger lessonNumber;
@property (nonatomic, retain) QuizObject* preQuiz;
@property (nonatomic, retain) QuizObject* postQuiz;

//Views
@property (nonatomic, retain) IBOutlet UIView* coverView;
@property (nonatomic, retain) IBOutlet UIButton* lessonBeginButton;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* lessonNumberLabel;
@property (nonatomic, retain) UIView* activeView;

//Controllers

////METHODS////
//PUBLIC
//Constructors

//PRIVATE
//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lessonNumber:(NSInteger)lessonNumberToLoad iPad:(BOOL)isOniPad retina:(BOOL)isOnRetina;
//IBActions
-(IBAction) beginLesson:(id)sender;
//Callbacks
-(void) introFinished: (NSNotification*)notification;
-(void) storyFinished: (NSNotification*)notification;
-(void) postQuizFinished: (NSNotification*)notification;
-(void) gameFinished: (NSNotification*)notification;
-(void) userFinishedWithMessage:(NSNotification *)notification;
//Utility
-(void) switchToModule: (NSInteger)moduleIdentifier;
-(void) removeChildModuleController:(UIViewController*)moduleController;
-(void) switchToView:(UIView*)view withTransition:(NSString*)transition andSubType:(NSString*)subtype forDuration:(CGFloat)durationForTransition;
-(void) showMessageWithTitle:(NSString*)titleForMessage text:(NSString*)textForMessage;
-(void) showStoryInstructions;
-(void)tapExitStoryInstructions:(UITapGestureRecognizer *)recognizer;
- (NSString*) titleFromLessonNumber:(NSInteger)lessonNumberInt;
-(void) configureImage;
-(void) saveCompletionOfLessonNumber: (NSInteger)lessonNumberToSave;
- (NSArray*)completedLessonsList;

@end
