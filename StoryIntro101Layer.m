//
//  StoryIntro101Layer.m
//  RRV101
//
//  Created by Brian C. Grant on 3/31/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "StoryIntro101Layer.h"
#import "WordListObject.h"
#import "QuizObject.h"
#import "WordIntroController.h"
#import "RRVConstants.txt"

#import "SimpleAudioEngine.h"


@implementation StoryIntro101Layer

#pragma mark Synthesizers
@synthesize customTouchesDisabled, backgroundBG, instructionLabel, twinklingStarBatchNode;

#pragma mark Global Non-Properties
static NSMutableArray* starsArray;
static NSMutableArray* soundsIDArray;

#pragma mark - PUBLIC -

#pragma mark - PRIVATE -
#pragma mark Layer Lifecycle -

#pragma mark Memory Management

- (void) dealloc{
    
	//Note: Cocos2d will automatically release added children (that use [node] method)
    
    //Sounds
    [self stopAllSounds];
    
    //Release your retained properties or specifically allocated globals
    
    //Globals
    [starsArray release];
    [soundsIDArray release];
    
    //Views
    [backgroundBG release];
    [instructionLabel release];
    [twinklingStarBatchNode release];
    
	[super dealloc];
    
}//End dealloc


#pragma mark Setup

- (id) init {
    
    if( (self=[super initWithColor:ccc4(0, 0, 69, 255)]) ) {
		
        
        //Create background layer with image
        CGSize windowSize = [[CCDirector sharedDirector] winSize];
        self.backgroundBG = [CCSprite spriteWithFile:@"BlueGradient_vertical1024.png" rect: CGRectMake(0, 0, self.boundingBox.size.width, self.boundingBox.size.height)];
        self.backgroundBG.position = ccp( windowSize.width/2, windowSize.height/2 );
        [self addChild:self.backgroundBG];
        
        //Instruction Label
        self.instructionLabel = [CCLabelTTF labelWithString:@"(Press any twinkling star)" dimensions:CGSizeMake(self.boundingBox.size.width, 30.0) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:18.0];
        self.instructionLabel.position = ccp( self.boundingBox.size.width/2, self.boundingBox.size.height - self.instructionLabel.boundingBox.size.height);
        [self addChild:self.instructionLabel z:2];
        
        //Initialize the touch tracking array
        starsArray = [[NSMutableArray alloc] initWithCapacity:12]; //Released in dealloc
        soundsIDArray = [[NSMutableArray alloc] init];
        
        //Load spriteFrameCache
        [self prepareAnimations];
        
        //Enable touches
        self.isTouchEnabled = YES;
        
	}//End if{} (successful)
    
	return self;
    
}//End init

#pragma mark - Game Logic -

#pragma mark Touch Management

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (self.customTouchesDisabled) { //Touches disabled
        //Do nothing
        
        NSLog(@"Intro Layer touches are disabled. Doing nothing.");
        
    }
    else { //Touches being accepted
        
        NSLog(@"Intro Layer touches are enabled.");
        
        //Get touch location
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];//Convert into Cocos2D coords
    
        //Compare touch location to stars being tracked
        for (NSUInteger i = 0; i < [starsArray count]; i++) { //For each star being tracked
        
            //Grab a sprite
            CCSprite* starSpriteToCheck = (CCSprite*)[starsArray objectAtIndex:i];
        
            //Check the bounding box of the sprite to see if it contains the touch
            if (CGRectContainsPoint([starSpriteToCheck boundingBox], location)) {
                //The sprite contains the touch location
                
                //Disable touches on sprite touch
                self.customTouchesDisabled = YES;
            
                //Determine sprite center point
                CGFloat spriteCenterX = starSpriteToCheck.boundingBox.origin.x + starSpriteToCheck.boundingBox.size.width/2;
                CGFloat spriteCenterY = starSpriteToCheck.boundingBox.origin.y + starSpriteToCheck.boundingBox.size.height/2;
                CGPoint spriteCenterPoint = CGPointMake(spriteCenterX, spriteCenterY);
                
                //Sequence: Animate, Destroy, Post Notification
            
                //Animate Star being touched
                    //Pick a random animation
                NSInteger pickedNumber = (arc4random() % 4) + 1;
                switch (pickedNumber) {
                    case 1:
                        [self sparkleFizzleAtLocation:spriteCenterPoint sprite:starSpriteToCheck];
                        break;
                    case 2:
                        [self sparkleExplosionAtLocation:spriteCenterPoint sprite:starSpriteToCheck];
                        break;
                    case 3:
                        [self starTakeOffAtLocation:spriteCenterPoint sprite:starSpriteToCheck];
                        break;
                    case 4:
                        [self sparklerFountainAtLocation:spriteCenterPoint sprite:starSpriteToCheck];
                        break;
                    
                    default:
                        break;
                }
                
                //IMPORTANT: Make sure sprites are destroyed in their exit process!!!
                //NOTE: Destroying a sprite will cause a WordIntroBeginNotification
           
            }//End if{} (starSpriteToCheck was touched)
            
        }//End for{} (Each star sprite being tracked)
    }//End else{} (touches enabled)
    
}//End touchesBegan: withEvent:{}

- (void)startTrackingSprite: (CCSprite*) spriteToObserve {
    
    //Append to array
    [starsArray addObject:spriteToObserve]; NSLog(@"Sprite appended to tracking array. Count: %i", [starsArray count]);
    
}//End startTrackingBalloon:{}

- (void)destroySprite: (CCSprite*)spriteToDestroy {
    
    //Remove sprite & begin intro
    [starsArray removeObject:spriteToDestroy];
    [spriteToDestroy removeFromParentAndCleanup:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:WordIntroBeginNotification object:self];
  
}//End stopTrackingBalloon:{}

#pragma mark - Sound -

- (void)playSound:(NSString *)fileName {
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    
    ALuint soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
    
    [soundsIDArray addObject:[NSString stringWithFormat:@"%i", soundEffectID]];
}

- (void)stopAllSounds {
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    
    for (int i=0; i<[soundsIDArray count]; i++)
    {
        [[SimpleAudioEngine sharedEngine] stopEffect:[[soundsIDArray objectAtIndex:i] intValue]];
    }
    
    [soundsIDArray removeAllObjects];
}

#pragma mark - Utility -

-(void) prepareAnimations {
    
    //Create SpriteFrameCache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Tstar.plist" textureFile:@"Tstar.png.ccz"];
    
    //Create SpriteSheet, add to the layer
    self.twinklingStarBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Tstar.png.ccz"];
    [self addChild:self.twinklingStarBatchNode z:100];
    
    //Array to collect CCSpriteFrames
    NSMutableArray* framesOfAnimation =  [NSMutableArray array];
    
    //Build the animation from the cache
    for (NSInteger frameNumber = 1; frameNumber <= 24; frameNumber++) {//For each frame in spriteheet image atlas
        
        //String to build frameName
        NSString* frameName = [NSString string];
        
        //Pad a zero for single digit frames
        if ( frameNumber >= 1 && frameNumber < 10 ) { frameName = [NSString stringWithFormat:@"Tstar%02d.png", frameNumber]; }
        
        //Don't pad double digit frameNumbers
        else { frameName = [NSString stringWithFormat:@"Tstar%d.png", frameNumber]; }
        
        //Load the desired frame by its name - if succesful, add to collection
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]; if(frame) [framesOfAnimation addObject:frame];
        
    }//End for{} (each frame in spritesheet image)
    
    //Do this again in reverse to create looped animation
    for (NSInteger frameNumber = 23; frameNumber >= 1; frameNumber--) {//For each frame counting backwards from last
        
        //String to build frameName
        NSString* frameName = [NSString string];
        
        //Pad a zero for single digit frames
        if ( frameNumber >= 1 && frameNumber < 10 ) { frameName = [NSString stringWithFormat:@"Tstar%02d.png", frameNumber]; }
        
        //Don't pad double digit frameNumbers
        else { frameName = [NSString stringWithFormat:@"Tstar%d.png", frameNumber]; }
        
        //Load the desired frame by its name - if succesful, add to collection
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]; if(frame) [framesOfAnimation addObject:frame];
        
    }//End for{} (each frame counting backwards)
    
    //Animaton to contain the frames
    CCAnimation* twinklingStarAnimation = [CCAnimation animationWithFrames:[NSArray arrayWithArray:framesOfAnimation] delay:1.0f/24.0f];//Delay equals inverse FPS
    
    //Save animation to cache
    [[CCAnimationCache sharedAnimationCache] addAnimation:twinklingStarAnimation name:@"twinkleForever"]; 
    

    for (NSInteger spriteIndex = 0; spriteIndex < 12; spriteIndex++) {//For each spriteNumber
        
        //Create a sprite
        CCSprite* twinklingStarSprite = [CCSprite spriteWithSpriteFrameName:@"Tstar01.png"];
        
        //Run action animation on sprite - twinkle forever
        [twinklingStarSprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache]animationByName:@"twinkleForever"]restoreOriginalFrame:YES]]];
        
        //Child to the sprite sheet - aka batch node - that owns the animation
        [self.twinklingStarBatchNode addChild:twinklingStarSprite z:spriteIndex];
        
        //Add sprite to touch detection group array
        [self startTrackingSprite:twinklingStarSprite];
        
        [twinklingStarSprite setScale:0.8];
        
        //Position the sprite based on its number
        [self placeStarSprite:twinklingStarSprite atPositionByIndex:spriteIndex];
        
    }//End for{} (each word in wordList)
}//End prepareAnimations

-(void) updateSpritePositions {
    
    //BG
    [self.backgroundBG removeFromParentAndCleanup:YES];
    self.backgroundBG = [CCSprite spriteWithFile:@"BlueGradient_vertical1024.png" rect:self.boundingBox];
    [self.backgroundBG setPosition:ccp(self.boundingBox.size.width/2, self.boundingBox.size.height/2)];
    [self addChild:self.backgroundBG z:0];
    
    //Instruction Label
    self.instructionLabel.position = ccp(self.boundingBox.size.width/2, self.boundingBox.size.height - self.instructionLabel.boundingBox.size.height);
    
    //Stars
    for (NSInteger spriteIndex = 0; spriteIndex < [starsArray count]; spriteIndex++) {
        
        [self placeStarSprite:[starsArray objectAtIndex:spriteIndex] atPositionByIndex:spriteIndex];
        
    }
    
}//End updateSpritePostions

-(void) placeStarSprite:(CCSprite*)sprite atPositionByIndex:(NSInteger)spriteIndex {
    
    switch (spriteIndex) {
        case 0:
            sprite.position = ccp(0.14*self.boundingBox.size.width, 0.125*self.boundingBox.size.height);
            break;
        case 1:
            sprite.position = ccp(0.39*self.boundingBox.size.width, 0.677*self.boundingBox.size.height);
            break;
        case 2:
            sprite.position = ccp(0.735*self.boundingBox.size.width, 0.865*self.boundingBox.size.height);
            break;
        case 3:
            sprite.position = ccp(0.5*self.boundingBox.size.width, 0.5*self.boundingBox.size.height);
            break;
        case 4:
            sprite.position = ccp(0.125*self.boundingBox.size.width, 0.74*self.boundingBox.size.height);
            break;
        case 5:
            sprite.position = ccp(0.188*self.boundingBox.size.width, 0.47*self.boundingBox.size.height);
            break;
        case 6:
            sprite.position = ccp(0.875*self.boundingBox.size.width, 0.208*self.boundingBox.size.height);
            break;
        case 7:
            sprite.position = ccp(0.61*self.boundingBox.size.width, 0.125*self.boundingBox.size.height);
            break;
        case 8:
            sprite.position = ccp(0.813*self.boundingBox.size.width, 0.448*self.boundingBox.size.height);
            break;
        case 9:
            sprite.position = ccp(0.375*self.boundingBox.size.width, 0.875*self.boundingBox.size.height);
            break;
        case 10:
            sprite.position = ccp(0.406*self.boundingBox.size.width, 0.292*self.boundingBox.size.height);
            break;
        case 11:
            sprite.position = ccp(0.875*self.boundingBox.size.width, 0.688*self.boundingBox.size.height);
            break;
            
        default:
            break;
    }//End switch{} (spriteIndex) {aka spriteNumber}
    
}//End placeStarsRandomly

-(void) sparkleExplosionAtLocation: (CGPoint)location sprite:(CCSprite*)sprite {
    
    [sprite setVisible:NO];
    
    CCParticleSystem *emitter=[[[CCParticleSystemQuad alloc] initWithTotalParticles:100] autorelease];
    emitter.autoRemoveOnFinish = YES;
    
    CCTexture2D* texture=[[CCTextureCache sharedTextureCache] addImage:@"stars.png"];
    emitter.texture = texture;
    emitter.emissionRate=200.00;
    emitter.angle=90.0;
    emitter.angleVar=360.0;
    ccBlendFunc blendFunc={GL_SRC_ALPHA,GL_ONE};
    emitter.blendFunc=blendFunc;
    emitter.duration=0.15;
    emitter.emitterMode=kCCParticleModeGravity;
    ccColor4F startColor={0.56,0.86,0.85,1.00};
    emitter.startColor=startColor;
    ccColor4F startColorVar={0.00,0.00,0.00,0.00};
    emitter.startColorVar=startColorVar;
    ccColor4F endColor={0.10,0.19,0.24,1.00};
    emitter.endColor=endColor;
    ccColor4F endColorVar={0.00,0.00,0.00,0.00};
    emitter.endColorVar=endColorVar;
    emitter.startSize=100.00;
    emitter.startSizeVar=20.00;
    emitter.endSize=24.00;
    emitter.endSizeVar=12.00;
    emitter.gravity=ccp(0.00,0.00);
    emitter.radialAccel=100.00;
    emitter.radialAccelVar=10.00;
    emitter.speed=450;
    emitter.speedVar= 0;
    emitter.tangentialAccel=690;
    emitter.tangentialAccelVar=10;
    emitter.totalParticles=100;
    emitter.life=0.50;
    emitter.lifeVar=0.00;
    emitter.startSpin=350.00;
    emitter.startSpinVar=350.00;
    emitter.endSpin=0.00;
    emitter.endSpinVar=105.00;
    
    emitter.position = location;
    
    [self addChild:emitter];
    
    //Play SFX
    [self playSound:@"SparkleExplosion.mp3"];
    
    //Destroy sprite
    if (sprite) {
        CGFloat delayOfDestruction = 1.0;
        [self performSelector:@selector(destroySprite:) withObject:sprite afterDelay:delayOfDestruction*1.5];
    }
   
}//End sparkleEmitterAtLocation: sprite:

-(void)sparkleFizzleAtLocation: (CGPoint)location sprite:(CCSprite*)sprite {
    
    CGFloat durationOfFunction = 1.0;
    
    [sprite runAction:[CCSequence actions:[CCScaleTo actionWithDuration:durationOfFunction scale:0.1], [CCHide action], nil]];

    
    CCParticleSystem *emitter=[[[CCParticleSystemQuad alloc] initWithTotalParticles:100] autorelease];
    emitter.autoRemoveOnFinish = YES;
    CCTexture2D *texture=[[CCTextureCache sharedTextureCache] addImage:@"stars2_mini.png"];
    emitter.texture=texture;
    emitter.emissionRate=266.67;
    emitter.angle=90.0;
    emitter.angleVar=360.0;
    ccBlendFunc blendFunc={GL_SRC_ALPHA,GL_ONE};
    emitter.blendFunc=blendFunc;
    emitter.duration=0.40;
    emitter.emitterMode=kCCParticleModeGravity;
    ccColor4F startColor={0.57,0.93,1.00,0.90};
    emitter.startColor=startColor;
    ccColor4F startColorVar={0.00,0.00,0.00,0.00};
    emitter.startColorVar=startColorVar;
    ccColor4F endColor={1.00,0.94,0.37,0.30};
    emitter.endColor=endColor;
    ccColor4F endColorVar={0.00,0.00,0.00,0.00};
    emitter.endColorVar=endColorVar;
    emitter.startSize=16.00;
    emitter.startSizeVar=10.00;
    emitter.endSize=8.00;
    emitter.endSizeVar=10.00;
    emitter.gravity=ccp(0.00,0.00);
    emitter.radialAccel=-1000.00;
    emitter.radialAccelVar=300.00;
    emitter.speed=500;
    emitter.speedVar=100;
    emitter.tangentialAccel=450;
    emitter.tangentialAccelVar= 0;
    emitter.totalParticles=100;
    emitter.life=0.75;
    emitter.lifeVar=0.20;
    emitter.startSpin=0.00;
    emitter.startSpinVar=0.00;
    emitter.endSpin=0.00;
    emitter.endSpinVar=0.00;
    
    emitter.position = location;
    
    [self addChild:emitter];
    
    //Play SFX
    [self playSound:@"SparkleFizzle.mp3"];
    
    //Destroy sprite
    if (sprite) {
        [self performSelector:@selector(destroySprite:) withObject:sprite afterDelay:durationOfFunction*1.5];
    }
    
}//End sparkleFizzleAtLocation:

-(void) starTakeOffAtLocation:(CGPoint)location sprite:(CCSprite*)sprite {
    
    NSLog(@"Take Off!!!!");
    
    CGFloat durationOfFunction = 2.0;
    
    CGFloat starDestinationBufferDistance = 200.0;
    NSInteger xPick;
    NSInteger yPick;
    do {
        
        xPick = arc4random() % 3;
        yPick = arc4random() % 3;
        
    } while (xPick == 1 && yPick == 1);
    
    //Handle x value
    CGFloat xPosition;
    
    switch (xPick) {
        case 0: //Min
            xPosition = -starDestinationBufferDistance;
            break;
        case 1: //Random
            xPosition = (arc4random() % lrintf(self.boundingBox.size.width + (starDestinationBufferDistance * 2))) - starDestinationBufferDistance;
            break;
        case 2: //Max
            xPosition = self.boundingBox.size.width + starDestinationBufferDistance;
            
        default:
            break;
    }
    
    //Handle y value
    CGFloat yPosition;
    switch (xPick) {
        case 0: //Min
            yPosition = -starDestinationBufferDistance;
            break;
        case 1: //Random
            yPosition = (arc4random() % lrintf(self.boundingBox.size.height + (starDestinationBufferDistance * 2))) - starDestinationBufferDistance;
            break;
        case 2: //Max
            yPosition = self.boundingBox.size.height + starDestinationBufferDistance;
            
        default:
            break;
    }
    
    CGPoint offscreenLocation = CGPointMake(xPosition, yPosition);
    CCMoveTo* starTakeOffMotion = [CCMoveTo actionWithDuration:durationOfFunction position:offscreenLocation];
    CCScaleTo* starScaleMotion = [CCScaleTo actionWithDuration:durationOfFunction scale:0.7];
    CCSequence* starTakeOffSequence = [CCSequence actions:starTakeOffMotion, [CCHide action], nil];
    [sprite runAction:starScaleMotion];
    [sprite runAction:starTakeOffSequence];
    
    
    CCParticleSystem *emitter=[[[CCParticleSystemQuad alloc] initWithTotalParticles:100] autorelease];
    emitter.autoRemoveOnFinish = YES;
    CCTexture2D *texture=[[CCTextureCache sharedTextureCache] addImage:@"fire-grayscale.png"];
    emitter.texture=texture;
    emitter.emissionRate=333.33;
    emitter.angle=270.0;
    emitter.angleVar=10.0;
    ccBlendFunc blendFunc={GL_SRC_ALPHA,GL_ONE};
    emitter.blendFunc=blendFunc;
    emitter.duration=durationOfFunction;
    emitter.emitterMode=kCCParticleModeGravity;
    ccColor4F startColor={0.76,0.25,0.12,1.00};
    emitter.startColor=startColor;
    ccColor4F startColorVar={0.00,0.00,0.00,0.00};
    emitter.startColorVar=startColorVar;
    ccColor4F endColor={0.90,0.60,0.28,0.62};
    emitter.endColor=endColor;
    ccColor4F endColorVar={0.00,0.00,0.00,0.00};
    emitter.endColorVar=endColorVar;
    emitter.startSize=10.00;
    emitter.startSizeVar=10.00;
    emitter.endSize=70.00;
    emitter.endSizeVar=0.00;
    emitter.gravity=ccp(0.00, 0.00);
    emitter.radialAccel=0.00;
    emitter.radialAccelVar=0.00;
    emitter.speed=100;
    emitter.speedVar=20;
    emitter.tangentialAccel= 0;
    emitter.tangentialAccelVar= 0;
    emitter.totalParticles=100;
    emitter.life=0.30;
    emitter.lifeVar=0.20;
    emitter.startSpin=0.00;
    emitter.startSpinVar=0.00;
    emitter.endSpin=0.00;
    emitter.endSpinVar=0.00;
    
    emitter.position = location;
    
    [self addChild:emitter z:0];
    CCMoveTo* emitterTakeOffMotion = [CCMoveTo actionWithDuration:durationOfFunction position:offscreenLocation];
    CCSequence* emitterTakeOffSequence = [CCSequence actions:emitterTakeOffMotion, [CCHide action], nil];
    [emitter runAction:emitterTakeOffSequence];
    
    //Play SFX
    [self playSound:@"Spinner_Rocket_1s.mp3"];
    
    //Destroy sprite
    if (sprite) {
        [self performSelector:@selector(destroySprite:) withObject:sprite afterDelay:durationOfFunction*1.5];
    }
    
}//End starTakeOffAtLocation: sprite:

-(void) sparklerFountainAtLocation: (CGPoint)location sprite:(CCSprite*)sprite {
    
    CGFloat durationOfFunction = 1.0;
    
    [sprite runAction:[CCSequence actions:[CCScaleTo actionWithDuration:durationOfFunction scale:0.1], [CCHide action], nil]];
    
    CCParticleSystem *emitter=[[[CCParticleSystemQuad alloc] initWithTotalParticles:200] autorelease];
    emitter.autoRemoveOnFinish = YES;
    CCTexture2D *texture=[[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
    emitter.texture=texture;
    emitter.emissionRate=222.22;
    emitter.angle=90.0;
    emitter.angleVar=35.0;
    ccBlendFunc blendFunc={GL_ONE,GL_ONE_MINUS_SRC_ALPHA};
    emitter.blendFunc=blendFunc;
    emitter.duration=1.00;
    emitter.emitterMode=kCCParticleModeGravity;
    ccColor4F startColor={0.96,0.96,0.96,0.70};
    emitter.startColor=startColor;
    ccColor4F startColorVar={0.50,0.50,0.50,0.10};
    emitter.startColorVar=startColorVar;
    ccColor4F endColor={0.36,0.36,0.36,0.20};
    emitter.endColor=endColor;
    ccColor4F endColorVar={0.10,0.10,0.10,0.20};
    emitter.endColorVar=endColorVar;
    emitter.startSize=16.00;
    emitter.startSizeVar=2.00;
    emitter.endSize=-1.00;
    emitter.endSizeVar=0.00;
    emitter.gravity=ccp(0.00,-200.00);
    emitter.radialAccel=-400.00;
    emitter.radialAccelVar=0.00;
    emitter.speed=400;
    emitter.speedVar=50;
    emitter.tangentialAccel= 0;
    emitter.tangentialAccelVar= 0;
    emitter.totalParticles=200;
    emitter.life=0.90;
    emitter.lifeVar=0.30;
    emitter.startSpin=0.00;
    emitter.startSpinVar=0.00;
    emitter.endSpin=0.00;
    emitter.endSpinVar=0.00;
    emitter.position=ccp(161.00,185.00);
    emitter.posVar=ccp(0.00,0.00);
    
    emitter.position = location;
    
    [self addChild:emitter];
    
    //Play SFX
    [self playSound:@"SparkleFountain.mp3"];
    
    //Destroy sprite
    if (sprite) {
        [self performSelector:@selector(destroySprite:) withObject:sprite afterDelay:durationOfFunction*1.5];
    }
    
}//End sparklerFountainAtLocation: sprite:


@end
