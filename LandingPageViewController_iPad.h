//
//  LandingPageViewController_iPad.h
//  RRV101
//
//  Created by Brian C. Grant on 1/22/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LessonSelect;
@class LessonController;
@class QuizViewController_iPad;
@class ThesaurusVC_iPad;
@class WordPopGameView;

@interface LandingPageViewController_iPad : UIViewController {
    
    //Data
    BOOL runningOnRetina;
    BOOL orientationLockedToLandscape;
    BOOL menuViewIsRaised;
    BOOL homeButtonVisible;
    UIView* activeView;
    
    //Views
    UIImageView* bannerImageView;
    UIView* menuView;
    UIView* menuButtonAreaView;
    UIButton* menuTabButton;
    UIButton* homeBtn;
    UIButton* lessonsBtn;
    UIButton* quizzesBtn;
    UIButton* thesaurusBtn;
    UIButton* gamesBtn;
    UIButton* gradesBtn;
    UIButton* settingsBtn;
    NSArray* crossOutImageViews;
    NSArray* comingSoonLabels;
    
    //Controllers & Media
    
}
////PROPERTIES////

//Data
@property BOOL runningOnRetina;
@property BOOL orientationLockedToLandscape;
@property BOOL menuViewIsRaised;
@property BOOL homeButtonVisible;
@property (nonatomic, retain) UIView* activeView;

//Views
@property (nonatomic, retain) IBOutlet UIImageView* bannerImageView;
@property (nonatomic, retain) IBOutlet UIView* menuView;
@property (nonatomic, retain) IBOutlet UIView* menuButtonAreaView;
@property (nonatomic, retain) IBOutlet UIButton* menuTabButton;
@property (nonatomic, retain) IBOutlet UIButton* homeBtn;
@property (nonatomic, retain) IBOutlet UIButton* lessonsBtn;
@property (nonatomic, retain) IBOutlet UIButton* quizzesBtn;
@property (nonatomic, retain) IBOutlet UIButton* thesaurusBtn;
@property (nonatomic, retain) IBOutlet UIButton* gamesBtn;
@property (nonatomic, retain) IBOutlet UIButton* gradesBtn;
@property (nonatomic, retain) IBOutlet UIButton* settingsBtn;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray* crossOutImageViews;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray* comingSoonLabels;

//Controllers & Media

////METHODS////

//Actions
-(IBAction) menuButtonPushed:(id)sender;
-(IBAction) goLessons:(id)sender;
-(IBAction) goQuizzes:(id)sender;
-(IBAction) goThesaurus:(id)sender;
-(IBAction) goGames:(id)sender;
-(IBAction) goGrades:(id)sender;
-(IBAction) goSettings:(id)sender;

//Callbacks
-(void) launchLesson:(NSNotification*)notification;
-(void) launchQuiz:(NSNotification*)notification;
-(void) launchGame:(NSNotification*)notification;
-(void) exitThesaurus:(NSNotification*)notification;
-(void) disableThesaurus:(NSNotification*)notification;
-(void) enableThesaurus:(NSNotification*)notification;

//Utility
-(void) reset;
-(void) hideMenuView;
-(void) unhideMenuView;
-(void) lowerMenuView;
-(void) raiseMenuView;
-(void) bounceMenuViewScale;
-(void) showHomeButtonOnMenuButtonAreaViewWithinDuration:(CGFloat)duration;
-(void) hideHomeButtonOnMenuButtonAreaViewWithinDuration:(CGFloat)duration;
-(CGPoint) centerPointForMenuButtonOnRow:(CGFloat)rowWholeNumber column:(CGFloat)columnWholeNumber numberOfRows:(CGFloat)numberOfRowsWholeNumber numberOfColumns:(CGFloat)numberOfColumnsWholeNumber;
-(void) switchToView:(UIView*)view withTransition:(NSString*)transition andSubType:(NSString*)subtype forDuration:(CGFloat)durationForTransition;
    //Data
-(BOOL) hasCompletedLessonNumber:(NSInteger)lessonNumberToVerify;
-(NSArray*)completedLessonsList;
-(BOOL)hasPurchasedLessonNumber:(NSInteger)lessonNumberToVerify;
-(NSArray*)purchasedLessonsList;

@end
