//
//  RRV101ViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 9/16/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class LandingPageViewController_iPad;
@class LessonSelect;
@class LessonController;
@class QuizViewController; 
@class ThesaurusViewController;
@class WordPopGameView; 

@interface RRV101ViewController : UIViewController {
    
    //Data
    BOOL runningOnRetina;
    BOOL menuEnabled;
    BOOL menuHidden;
    BOOL menuRaised;
    UIView* activeView;
    
    //Views
       //Landing View
    UIView* landingView;
    UIButton* lessonsBtn;
    UIButton* quizzesBtn;
    UIButton* thesaurusBtn;
    UIButton* gamesBtn;
    UIButton* gradesBtn;
    UIButton* settingsBtn;
        //Menu Toolbar
    UIView* toolbarView;
    UIButton* toolbarTabButton;
    UIButton* toolbarHomeButton;
    UIButton* toolbarLessonsButton;
    UIButton* toolbarGamesButton;
    UIButton* toolbarQuizzesButton;
    UIButton* toolbarThesaurusButton;
    
    //Controllers & Media
    
}
////PROPERTIES////

//Data
@property BOOL runningOnRetina;
@property BOOL menuEnabled;
@property BOOL menuHidden;
@property BOOL menuRaised;
@property (nonatomic, retain) UIView* activeView;

//Views
    //Landing View
@property (nonatomic, retain) IBOutlet UIView* landingView;
@property (nonatomic, retain) IBOutlet UIButton* lessonsBtn;
@property (nonatomic, retain) IBOutlet UIButton* quizzesBtn;
@property (nonatomic, retain) IBOutlet UIButton* thesaurusBtn;
@property (nonatomic, retain) IBOutlet UIButton* gamesBtn;
@property (nonatomic, retain) IBOutlet UIButton* gradesBtn;
@property (nonatomic, retain) IBOutlet UIButton* settingsBtn;
    //Menu Toolbar
@property (nonatomic, retain) IBOutlet UIView* toolbarView;
@property (nonatomic, retain) IBOutlet UIButton* toolbarTabButton;
@property (nonatomic, retain) IBOutlet UIButton* toolbarHomeButton;
@property (nonatomic, retain) IBOutlet UIButton* toolbarLessonsButton;
@property (nonatomic, retain) IBOutlet UIButton* toolbarGamesButton;
@property (nonatomic, retain) IBOutlet UIButton* toolbarQuizzesButton;
@property (nonatomic, retain) IBOutlet UIButton* toolbarThesaurusButton;

//Controllers & Media



////METHODS////

//Actions
-(IBAction) toggleMenuView: (id)sender;
-(IBAction) goLessons:(id)sender;
-(IBAction) goQuizzes:(id)sender;
-(IBAction) goThesaurus:(id)sender;
-(IBAction) goGames:(id)sender;
-(IBAction) goGrades:(id)sender;
-(IBAction) goSettings:(id)sender;
-(IBAction) goHome:(id)sender;

//Callbacks
-(void) launchLesson:(NSNotification*)notification;
-(void) launchQuiz:(NSNotification*)notification;
-(void) launchGame:(NSNotification*)notification;
-(void) disableThesaurus:(NSNotification*)notification;
-(void) enableThesaurus:(NSNotification*)notification;

//Utility
-(void) reset;
-(void) hideMenuView;
-(void) unhideMenuView;
-(void) hideLandingView:(CGFloat)duration;
-(void) unhideLandingView:(CGFloat)duration;
-(void) changeToLandingView:(CGFloat)duration;
-(void) switchToView:(UIView*)view withTransition:(NSString*)transition andSubType:(NSString*)subtype forDuration:(CGFloat)durationForTransition;
    //Data
-(BOOL) hasCompletedLessonNumber:(NSInteger)lessonNumberToVerify;
-(NSArray*)completedLessonsList;
-(BOOL)hasPurchasedLessonNumber:(NSInteger)lessonNumberToVerify;
-(NSArray*)purchasedLessonsList;

@end
