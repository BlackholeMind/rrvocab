//
//  WordBalloon.h
//  RRV101
//
//  Created by Brian C. Grant on 1/12/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface WordBalloon : CCSprite {
    NSString* word;
    NSInteger fontSize;
}
@property (nonatomic, retain) NSString* word;
@property NSInteger fontSize;
+ (id)balloonWithWord:(NSString*)wordForBalloon fontSize:(NSInteger)fontSizeForBalloon HD:(BOOL)at2x iPad:(BOOL)iPadDevice;
- (id)initWithWord: (NSString*)wordForBalloon fontSize: (NSInteger)fontSizeForBalloon HD:(BOOL)at2x iPad:(BOOL)iPadDevice;

@end
