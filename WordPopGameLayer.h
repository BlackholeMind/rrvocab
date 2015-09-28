//
//  WordPopGameLayer.h
//  RRV101
//
//  Created by Brian C. Grant on 1/7/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class WordListObject;
@class WordObject;
@class WordBalloon;

@interface WordPopGameLayer : CCLayerGradient {
    
    //Data
    BOOL runningOniPad;
    BOOL runningOnRetina;
    NSInteger lessonNumber;
    WordListObject* wordListComprehensive;
    WordListObject* wordListEliminator;
    WordObject* currentWord;
    NSInteger currentWordListPosition;
    NSInteger previousWordIndex;
    NSInteger correctWordIntervalRegulator;
    NSInteger gameCondition;
    NSInteger targetWordNumber;
    NSInteger targetScore;
    BOOL reuseWords;
    BOOL endlessPlay;
    NSInteger wordsCorrectCount;
    NSInteger wordsIncorrectCount;
    NSInteger score;
    BOOL gameOver;
    
    //Views & Nodes
    CCLayerColor* conditionsLayer;
    CCSprite* scoreCloud;
    CCLabelTTF* scoreDumbLabel;
    CCLabelTTF* scoreLabel;
    CCSprite* victoryConditionsCloud; //Used to display victory conditions (wordsLeft, targetScore, etc..)
    CCLabelTTF* victoryConditionsDumbLabel;
    CCLabelTTF* victoryConditionsNumberLabel;
    CCLayerGradient* definitionLayer;
    CCLayerGradient* currentDefinitionLabelLayer;
    CCLabelTTF* currentDefinitionLabel;
    CCSpriteBatchNode* biplaneBatchNode;
    CCSprite* currentBiplane;
    
    //Controllers & Media
    UIViewController* tempChildVC;
    
}

////PROPERTIES////

//Data
@property BOOL runningOniPad;
@property BOOL runningOnRetina;
@property NSInteger lessonNumber;
@property (nonatomic, retain) WordListObject* wordListComprehensive;
@property (nonatomic, retain) WordListObject* wordListEliminator;
@property (nonatomic, retain) WordObject* currentWord;
@property NSInteger currentWordListPosition;
@property NSInteger previousWordIndex;
@property NSInteger correctWordIntervalRegulator;
@property NSInteger gameCondition;
@property NSInteger targetWordNumber;
@property NSInteger targetScore;
@property BOOL reuseWords;
@property BOOL endlessPlay;
@property NSInteger wordsCorrectCount;
@property NSInteger wordsIncorrectCount;
@property NSInteger score;
@property BOOL gameOver;

//Views & Nodes
@property (nonatomic, retain) CCLayerColor* conditionsLayer;
@property (nonatomic, retain) CCSprite* scoreCloud;
@property (nonatomic, retain) CCLabelTTF* scoreDumbLabel;
@property (nonatomic, retain) CCLabelTTF* scoreLabel;
@property (nonatomic, retain) CCSprite* victoryConditionsCloud;
@property (nonatomic, retain) CCLabelTTF* victoryConditionsDumbLabel;
@property (nonatomic, retain) CCLabelTTF* victoryConditionsNumberLabel;
@property (nonatomic, retain) CCLayerGradient* definitionLayer;
@property (nonatomic, retain) CCLayerGradient* currentDefinitionLabelLayer;
@property (nonatomic, retain) CCLabelTTF* currentDefinitionLabel;
@property (nonatomic, retain) CCSpriteBatchNode* biplaneBatchNode;
@property (nonatomic, retain) CCSprite* currentBiplane;

//Controllers & Media
@property (nonatomic, retain) UIViewController* tempChildVC;

////METHODS////

//PUBLIC
+ (id)nodeWithLessonNumber:(NSInteger)lessonNumber;

//PRIVATE
//Constructors
-(id) initWithLessonNumber: (NSInteger)lessonNumberToPlay;
//Orientation
- (void) willChangeBounds: (CGRect) bounds;
//Game Logic
    //Systemic Mechanics
- (void) startPlaying:(NSNotification*)notification;
- (void) cyclePlay:(NSNotification*)notification;
- (void) quitPlaying:(NSNotification*)notification; 
- (void) syncInfoFromArray:(NSArray*)gameConditionsArray;
- (void) gameLogic: (ccTime)dt;
- (void) requestNewBalloon;
- (void) chooseNewWord;
- (void) findWordForBalloon;
- (BOOL) checkVictoryState;
- (void) gameOverVictory;
    //Sprite Management
        //CREATION
- (void) addBalloon:(NSNotification*)notification;
- (void) addBalloonWithWord:(NSNotification*)notification;
        //DESTRUCTION
- (void) popBalloon: (WordBalloon*)balloon;
- (void) balloonReachedTop: (id) sender;
    //Touch Management
- (void) startTrackingBalloon: (WordBalloon*)balloon;
- (void) stopTrackingBalloon: (WordBalloon*)balloon;
    //Preparations
- (void) prepareAnimations;
- (void) prepareDefinitionLayer;
- (void) prepareConditionsLayer;
- (void) prepareUserInterface;
    //UI Tasks
- (void) presentUserInterface: (NSNotification*)notification;
- (void) dismissUserInterface;
- (void) updateConditionLabels;
- (void) moveConditionLabelsOnscreen;
- (void) moveConditionLabelsOffscreen;
- (void) presentIntroVC;
- (void) dismissIntroVC:(NSNotification*)notification;
- (void) presentVictoryVC;
- (void) dismissVictoryVC:(NSNotification*)notification;
- (void) moveDefinitionLayerOffscreen;
- (void) moveDefinitionLayerRightOfScreen;
- (void) moveDefinitionLayerOnscreen;
    //Sound
- (void)playSound:(NSString *)fileName;
- (void)stopAllSounds;
- (void) playBGM;
- (void) resumeBGM;
- (void) pauseBGM;
- (void) stopBGM;
    //Notification Management
- (void) startObservingIntroVC:(UIViewController*)introVC;
- (void) stopObservingIntroVC:(UIViewController*)introVC;
- (void) startObservingVictoryVC:(UIViewController*)victoryVC;
- (void) stopObservingVictoryVC:(UIViewController*)victoryVC;
    //Randomizers
- (id) randomBalloonColor;
- (CGPoint) randomPositionForBalloon;
    //Programmatically Created Views
- (void) setupDefinitionLabelWithText: (NSString*) definitionText;
- (void) thumbSpriteAtLocation: (CGPoint)location upFacing: (BOOL)thumbsUp;
- (void) movingLabelForScoreChange: (NSInteger)scoreChange increment: (BOOL)isIncrement atLocation: (CGPoint)location;

@end
