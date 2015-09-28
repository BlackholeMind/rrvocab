//
//  StoryIntro101Layer.h
//  RRV101
//
//  Created by Brian C. Grant on 3/31/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class WordListObject;
@class QuizObject;


@interface StoryIntro101Layer : CCLayerColor {
    
    //Data
    //NSArray* starsArray;
    BOOL customTouchesDisabled;
    
    //Views
    CCSprite* backgroundBG;
    CCLabelTTF* instructionLabel;
    CCSpriteBatchNode* twinklingStarBatchNode;
    
    //Controllers & Media
}
////PROPERTIES////

//Data
//@property (nonatomic, retain) NSArray* starsArray;
@property BOOL customTouchesDisabled;

//Views
@property (nonatomic, retain) CCSprite* backgroundBG;
@property (nonatomic, retain) CCLabelTTF* instructionLabel;
@property (nonatomic, retain) CCSpriteBatchNode* twinklingStarBatchNode;

//Controllers & Media

////METHODS////
//PUBLIC


//PRIVATE
//Game Logic
  //Touch Management
- (void)startTrackingSprite: (CCSprite*) spriteToObserve;
- (void)destroySprite: (CCSprite*) spriteToIgnore;
//Sound
- (void)playSound:(NSString *)fileName;
- (void)stopAllSounds;
//Utility
-(void) prepareAnimations;
-(void) updateSpritePositions;
-(void) placeStarSprite:(CCSprite*)sprite atPositionByIndex:(NSInteger)spriteIndex;
-(void) sparkleExplosionAtLocation: (CGPoint)location sprite:(CCSprite*)sprite;
-(void) sparkleFizzleAtLocation: (CGPoint)location sprite:(CCSprite*)sprite;
-(void) starTakeOffAtLocation:(CGPoint)location sprite:(CCSprite*)sprite;
-(void) sparklerFountainAtLocation: (CGPoint)location sprite:(CCSprite*)sprite;

@end
