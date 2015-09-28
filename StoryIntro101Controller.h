//
//  StoryIntro101Controller.h
//  RRV101
//
//  Created by Brian C. Grant on 3/31/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class WordListObject;
@class QuizObject;
@class WordIntroController;
@class StoryIntro101Layer;

@interface StoryIntro101Controller : UIViewController {
    
    //Data
    BOOL runningOniPad;
    BOOL runningOnRetina;
    NSInteger lessonNumber;
    WordListObject* wordList;
    QuizObject* preQuiz;
    
    //Views & Layers
    StoryIntro101Layer* introLayer;
    
    //Controllers & Media
}

////PROPERTIES////

//Data
@property BOOL runningOniPad;
@property BOOL runningOnRetina;
@property NSInteger lessonNumber;
@property (nonatomic, retain) QuizObject* preQuiz;
@property (nonatomic, retain) WordListObject* wordList;

//Views & Layers
@property (nonatomic, retain) StoryIntro101Layer* introLayer;

//Controllers & Media

////METHODS////
//PUBLIC

//PRIVATE
//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lessonNumber:(NSInteger)lessonNumberToLoad iPad:(BOOL)isOniPad retina:(BOOL)isOnRetina;
//Callbacks
-(void) beginWordIntro: (NSNotification*) notification;
-(void) dismissWordIntro: (NSNotification*) notification;
-(void) dismissWordIntroModal: (NSNotification*) notification;
-(void) userFinishedWithStoryIntro;
//Utility
-(void) changeToBounds: (CGRect)bounds;
//Support
-(void) cocos2DSetup;

@end
