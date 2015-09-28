//
//  WordBalloon.m
//  RRV101
//
//  Created by Brian C. Grant on 1/12/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordBalloon.h"


@implementation WordBalloon

@synthesize word, fontSize;

+ (id)balloonWithWord:(NSString*)wordForBalloon fontSize:(NSInteger)fontSizeForBalloon HD:(BOOL)at2x iPad:(BOOL)iPadDevice {
	return [[[self alloc] initWithWord:wordForBalloon fontSize:fontSizeForBalloon HD:at2x iPad:iPadDevice] autorelease];
}

- (id)initWithWord: (NSString*)wordForBalloon fontSize:(NSInteger)fontSizeForBalloon HD:(BOOL)at2x iPad:(BOOL)iPadDevice {
    
    self.word = wordForBalloon;
    self.fontSize = fontSizeForBalloon;
        
    //Determine filename to use
    NSString* balloonSpriteFileName = [NSString stringWithFormat:@"balloon"];
        
    if (at2x && !iPadDevice) { //Note: Remove check for !iPadDevice when enabling Retina on iPad3
        balloonSpriteFileName = [balloonSpriteFileName stringByAppendingFormat:@"@2x"];
    }
    
    balloonSpriteFileName = [balloonSpriteFileName stringByAppendingFormat:@".png"];
    
    NSLog(@"%@", balloonSpriteFileName);
        
    //Determine graphic settings
    NSInteger balloonGraphicWidth = 128;
    NSInteger balloonGraphicHeight = 200;
    
    if ( self = [super initWithFile:balloonSpriteFileName]) {
        
        NSLog(@"Adding ballon: %@", wordForBalloon);
        NSLog(@"%.1fW x %.1fH", self.contentSize.width, self.contentSize.height );
        self.scaleX = balloonGraphicWidth / self.contentSize.width;
        self.scaleY = balloonGraphicHeight / self.contentSize.height;
        
        NSLog(@"%d", balloonGraphicHeight);
        
        [self runAction:[CCFadeTo actionWithDuration:0 opacity:204]]; //Set opacity
        
        //wordLabel
        CCLabelTTF* wordLabel = [CCLabelTTF labelWithString:self.word dimensions:CGSizeMake(balloonGraphicWidth, self.fontSize+10) alignment:NSTextAlignmentCenter lineBreakMode:UILineBreakModeClip fontName:@"Marker Felt" fontSize:self.fontSize];
        
        wordLabel.color = ccc3(0, 0, 0); //Set font color
        [wordLabel runAction:[CCFadeTo actionWithDuration:0 opacity:204]];//Set label opacity
        [self addChild:wordLabel]; //Add to balloon
        
        //Position on balloon (from bottom left of parent - anchor is in center)
        int label_x = (self.contentSize.width/2); // X = Middle of balloon (from left)
        int label_y = (self.contentSize.height/3)*2; // Y = Two thirds of the way up the balloon (from bottom)
        wordLabel.position = ccp(label_x, label_y); //Set position
        
        //Ensure label size
        [wordLabel setScale:1.0/self.scale];
        
    }
    
    return self;
    
}//End initWithWord: fontSize: HD: iPad:

@end
