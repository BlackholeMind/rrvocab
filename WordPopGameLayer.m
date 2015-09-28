//
//  WordPopGameLayer.m
//  RRV101
//
//  Created by Brian C. Grant on 1/7/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordPopGameLayer.h"
#import "SimpleAudioEngine.h"
#import "WordListObject.h"
#import "WordObject.h"
#import "WordBurstIntro.h"
#import "WordBurstVictoryVC.h"
#import "WordBalloon.h"
#import "RRVConstants.txt"

@implementation WordPopGameLayer

#pragma mark Synthesizers

//Data
@synthesize runningOniPad, runningOnRetina, lessonNumber;
@synthesize wordListComprehensive, wordListEliminator, currentWord;
@synthesize currentWordListPosition, previousWordIndex, correctWordIntervalRegulator;
@synthesize gameCondition, targetWordNumber, targetScore, reuseWords, endlessPlay, wordsCorrectCount, wordsIncorrectCount, score, gameOver;

//Views & Nodes
@synthesize conditionsLayer, scoreCloud, scoreLabel, scoreDumbLabel, victoryConditionsCloud, victoryConditionsDumbLabel, victoryConditionsNumberLabel;
@synthesize definitionLayer, currentDefinitionLabelLayer, currentDefinitionLabel, biplaneBatchNode, currentBiplane;

//Controllers & Media
@synthesize tempChildVC;

#pragma mark Global Non-Properties
static NSMutableArray* balloonsArray = nil;
static NSMutableArray* soundsIDArray = nil;

#pragma mark - PUBLIC METHODS -

+ (id)nodeWithLessonNumber:(NSInteger)lessonNumber {
    return [[[self alloc] initWithLessonNumber:lessonNumber] autorelease];
}

#pragma mark - PRIVATE METHODS -
#pragma mark Layer Lifecycle -

#pragma mark Memory Management

- (void) dealloc{
    
	//Cocos2d will automatically release all children (It retains them upon adoption)
    
    //SimpleAudioEngine
    [self stopAllSounds];
    
    //Observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Balloons
    //Pop all balloons being tracked
    for (NSInteger balloons = [balloonsArray count]; balloons > 0; balloons--) {
        [self balloonReachedTop:[balloonsArray objectAtIndex:balloons-1]];
    }
    [balloonsArray release];
    [soundsIDArray release];
    
    //Data
    [wordListComprehensive release];
    [wordListEliminator release];
    [currentWord release];
    
    //Views & Nodes
    [conditionsLayer release];
    [scoreCloud release];
    [scoreDumbLabel release];
    [scoreLabel release];
    [victoryConditionsCloud release];
    [victoryConditionsDumbLabel release];
    [victoryConditionsNumberLabel release];
    [definitionLayer release];
    [currentDefinitionLabel release];
    [currentDefinitionLabelLayer release];
    [biplaneBatchNode release];
    [currentBiplane release];
    
    //Controllers
    [tempChildVC release];
	
	[super dealloc];
}

#pragma mark Orientation

- (void) willChangeBounds: (CGRect) bounds {
    NSLog(@"WordBurst main layer willChangeBounds!");    
    
    [self changeWidth:bounds.size.width height:bounds.size.height];
        // Conditions Layer
    [self.conditionsLayer changeWidth:self.boundingBox.size.width];
    [self.scoreCloud setPosition: ccp(self.boundingBox.size.width, 0.0)];
    [self.victoryConditionsCloud setPosition: ccp(0.0, 0.0)];
    [self.conditionsLayer setPosition: ccp(0.0, self.boundingBox.size.height - self.conditionsLayer.boundingBox.size.height)];
        //Definition Layer
    [self.currentDefinitionLabelLayer changeWidth: self.boundingBox.size.width];
    [self.currentDefinitionLabel setPosition: ccp( ((self.currentDefinitionLabelLayer.boundingBox.size.width/2) - (self.currentDefinitionLabel.boundingBox.size.width/2)), 0.0 ) ];
    [self.definitionLayer changeWidth: [self.currentBiplane boundingBox].size.width - kDefinitionLabelOverlapForBiplane + [self.currentDefinitionLabelLayer boundingBox].size.width];
    CGFloat definitionLayerPositionY = kDefinitionLayerPositionY;
    if (self.runningOniPad) definitionLayerPositionY += kDefintionLayerPositionY_iPadModifier;
    [self.definitionLayer setPosition: ccp(self.boundingBox.size.width - self.definitionLayer.boundingBox.size.width, definitionLayerPositionY)];
    
}//End willChangeBounds:

#pragma mark Initialization

- (id) init {
    
    if (self = [self initWithLessonNumber:0]) {
        
    }

    return self;
    
}//End init

-(id) initWithLessonNumber: (NSInteger)lessonNumberToPlay {
    
    if( (self=[super initWithColor:ccc4(59, 183, 254, 255) fadingTo:ccc4(47, 146, 203, 255) alongVector: ccp(0.0, -1.0)]) ) {
        
        self.lessonNumber = lessonNumberToPlay;
        
        //Detect environment
        NSString* detectedDevice = [[UIDevice currentDevice] model];
        NSRange textRange = [[detectedDevice lowercaseString] rangeOfString:@"ipad"];
        if(textRange.location != NSNotFound) {
            NSLog(@"Device identified as iPad.");
            
            self.runningOniPad = YES;
            
        }
        else {
            NSLog(@"Device identified as iPhone/iPod.");
            
            self.runningOniPad = NO;
            
        }
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
            NSLog(@"Retina Display detected.");
            
            self.runningOnRetina = YES;
            
        }
        else {
            NSLog(@"Standard Definition Display detected.");
            
            self.runningOnRetina = NO;
            
        }
        
		
        /*
         //Create background layer
         CGSize windowSize = [[CCDirector sharedDirector] winSize];
         CCSprite* backgroundImageSprite = [CCSprite spriteWithFile:@"wordBurstBackground@2x.png" rect:CGRectMake(0, 0, windowSize.width, windowSize.height)];
         [self addChild:backgroundImageSprite];
         */
        
        //Start BG Music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:kBGM_1 loop:YES];
        
        //Initialize touch tracking array
        balloonsArray = [[NSMutableArray alloc] init]; //Released in dealloc
        soundsIDArray = [[NSMutableArray alloc] init];
        
        //Load wordListArray
        self.wordListComprehensive = [WordListObject listForLessonNumber:self.lessonNumber]; //Used simply & ONLY for word-grabbing (is used with previousWordIndex, though, for same purpose)
        self.wordListEliminator = [WordListObject listFromList:self.wordListComprehensive]; //Used to track progress, effects game state (win/end/achievements/etc..)
        [self.wordListEliminator shuffle];
        
        //Pre-render animations & build resusables
        [self prepareAnimations]; //Adds animations to the sharedAnimationCache (Sets them up for use)
        [self prepareUserInterface]; //Creates and childs nodes to layer
        
        //Initialize index markers (word appearance regulators)
        self.previousWordIndex = -1;
        self.correctWordIntervalRegulator = 0;
        
        //Start the game logic interval
        self.score = 0;
        self.wordsCorrectCount = 0;
        self.wordsIncorrectCount = 0;
        self.endlessPlay = NO;
        self.reuseWords = NO;
        
        //Display the intro & observe
        [self presentIntroVC];
        
	}
    
	return self;
    
    
}//End initWithLessonNumber:

#pragma mark - Game Logic -
#pragma mark Systemic Mechanics

- (void) startPlaying:(NSNotification*)notification {
    
    self.gameOver = NO;
    
    //Present interface
    [self presentUserInterface:notification]; //Updates labels and moves them onscreen. DefinitionLayer readied to move onscreen.
    
    //Schedule the gameLogic loop
    [self schedule:@selector(gameLogic:) interval:kBalloonSpawnInterval];
    
    //Enable touches
    self.isTouchEnabled = YES;
    
    //Listen for balloons
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SpawnBalloonNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBalloon:) name:SpawnBalloonNotification object:nil];
    
}//End startPlaying

- (void) cyclePlay:(NSNotification*)notification {
    
    //Dismiss victoryVC
    [self dismissVictoryVC:notification];
    
    //Ensure touches
    self.isTouchEnabled = YES;
    
    //Reset conditions
    self.wordListEliminator = [WordListObject listFromList:self.wordListComprehensive];
    [self.wordListEliminator shuffle];
    self.score = 0;
    self.wordsCorrectCount = 0;
    self.wordsIncorrectCount = 0;
    
    //Present intro again
    [self presentIntroVC];
    
}//End cyclePlay

- (void) quitPlaying:(NSNotification*)notification {
    
    //Post notification of desire for removal
    [[NSNotificationCenter defaultCenter] postNotificationName:GameQuitNotification object:self];

}//End quitPlaying

- (void) syncInfoFromArray:(NSArray *)gameConditionsArray {
    //Array Format:
    //O: (NSInteger const) Game Condition 
    //1: (NSInteger) Victory Number
    //2: (BOOL) Reuse Words?
    
    self.gameCondition = [[gameConditionsArray objectAtIndex:0] intValue]; //Game Condition
    if (self.gameCondition == kGameConditionWords) { //Victory Number - Words
        self.targetScore = 0;
        self.targetWordNumber = [[gameConditionsArray objectAtIndex:1] intValue];
        if (self.targetWordNumber == kGameVictoryNumberEndless) self.endlessPlay = YES;
    }
    else if (self.gameCondition == kGameConditionScore) { //Victory Number - Score
        self.targetWordNumber = 0;
        self.targetScore = [[gameConditionsArray objectAtIndex:1] intValue];
        if (self.targetScore == kGameVictoryNumberEndless) self.endlessPlay = YES;
    }
    self.reuseWords = [[gameConditionsArray objectAtIndex:2] boolValue]; //Reuse Words
    
}//End syncInfoFromArray:

- (void) gameLogic:(ccTime)dt {
    NSLog(@"gameLogic loop.");
    
    [self requestNewBalloon];
    
}//End gameLogic:{}

- (void) requestNewBalloon {
    
    NSInvocationOperation* findWordOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(findWordForBalloon) object:nil];
    
    NSOperationQueue* opQueue = [NSOperationQueue new];
    [opQueue addOperation:findWordOperation];
    
    [findWordOperation release];
    
}

- (void) findWordForBalloon {
    
    //Increment correct word interval regulator (Ensures correct word appears frequently)
    self.correctWordIntervalRegulator++;
    NSString* wordForBalloon;
    if (self.correctWordIntervalRegulator < 5) {//Correct word has appeared recently
        
        do { //Obtain a random WRONG word
            NSLog(@"Finding new word...");
            wordForBalloon = [self.wordListComprehensive randomWordStringOnly];
            NSLog(@"Ensuring new word '%@' is not equal to current word '%@'. If so, repeat search.", wordForBalloon, self.currentWord.wordString);
        } while ( [wordForBalloon isEqualToString:self.currentWord.wordString] ) ;
        
    }
    else {//Correct word has not appeared recently
        wordForBalloon = self.currentWord.wordString;//Get correct word
        self.correctWordIntervalRegulator = (arc4random() % 3);//Reset interval regulator to random value (0 - 2)
    }
    
    //Post Notification of chosen word
    [[NSNotificationCenter defaultCenter] postNotificationName:SpawnBalloonNotification object:nil userInfo:[NSDictionary dictionaryWithObject:wordForBalloon forKey:@"wordForBalloon"]];
    
}

- (void) chooseNewWord {
    NSLog(@"Choosing new word...");
    
    //Move current lables offscreen
    [self moveDefinitionLayerOffscreen];
    
    //Stop gameLogic if gameOver
    if ([self checkVictoryState] && !self.gameOver) { //Victory only once
        
        NSLog(@"Victory!");
        self.isTouchEnabled = NO;
        [self unschedule:@selector(gameLogic:)];
        [self gameOverVictory];
        self.gameOver = YES;
        
    }
    else {
        
        if (self.reuseWords) {
            
            //Reusing words, do not destroy queried object
            self.currentWord = [self.wordListComprehensive randomWordObject];
            
        }//End if{} (NOT resuing words)
        else { //self.reuseWords == NO
            
            //If NOT resuing words, set currentWord by removing that word from list (popping acheives this)
            self.currentWord = [self.wordListEliminator popWordObject];
            
        }//End else{} (NOT reusing words)
        NSLog(@"New word is: %@, which means: %@", self.currentWord.wordString, self.currentWord.definitionString);
        
        NSLog(@"Collapsed to array: [%d; %@; %@; %@;]", [[[self.currentWord collapseToArray] objectAtIndex:kWordLessonNumber] intValue], [[self.currentWord collapseToArray] objectAtIndex:kWordString],  [[self.currentWord collapseToArray] objectAtIndex:kWordDefinition], [[self.currentWord collapseToArray] objectAtIndex:kWordSentence]);
        
        //Delay other actions until animation is complete
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (kDefinitionLayerAnimationInterval/2)*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
            
        
        
                    //Update definition label text
                    [self.currentDefinitionLabel setString:self.currentWord.definitionString];
            
                    //Transport definitionLayer to right side of screen
                    [self moveDefinitionLayerRightOfScreen];
            
                    //Move defintionLayer back onscreen
                    [self moveDefinitionLayerOnscreen];
        
        }); //End of delayed block
        
    }
    
}//End chooseNewWord{}

- (BOOL) checkVictoryState {
    
    BOOL victory = NO;
    
    if (self.endlessPlay) { //Endless Play!
        
        //Leave victory = NO;
        
    }
    else if (self.gameCondition == kGameConditionWords && self.targetWordNumber <= 0) { //Target Words has reached 0
        
        victory = YES;
        
    }
    else if (self.gameCondition == kGameConditionScore && self.score >= self.targetScore) { //Target Score reached
        
        victory = YES;
    }
    
    return victory;
    
}//End checkVictoryState

- (void) gameOverVictory {
    
    [self dismissUserInterface];
    [self performSelector:@selector(presentVictoryVC) withObject:nil afterDelay:kDefinitionLayerAnimationInterval/2];
    
}//End gameOverVictory

#pragma mark Sprite Management

#pragma mark CREATION

- (void) addBalloon:(NSNotification*)notification {
    
    //Ensure main thread
    [self performSelectorOnMainThread:@selector(addBalloonWithWord:) withObject:notification waitUntilDone:NO];
    
}

//This method creates a balloon of random color (1 of 7), with a random word (from list), in a random position (1 of 5)
//and tells it to move upward. A callback method is registered to be called when the balloon passes out of view.
- (void) addBalloonWithWord:(NSNotification*)notification {
    
    NSString* wordForBalloon = [[notification userInfo] objectForKey:@"wordForBalloon"];
    
    //Count characters (for font sizing)
    NSInteger fontSizeForBalloon;
    switch ([wordForBalloon length]) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
            fontSizeForBalloon = 36;
            break;
        case 8:
        case 9:
        case 10:
        case 11:
            fontSizeForBalloon = 28;
            break;
            
        default:
            fontSizeForBalloon = 22;
            break;
    }//End switch(word length){}
    
    //Make the balloon (CCSprite subclass), add to layer & track touches after setting a position
    WordBalloon* balloon = [WordBalloon balloonWithWord:wordForBalloon fontSize:fontSizeForBalloon HD:self.runningOnRetina iPad:self.runningOniPad];
    CGPoint positionForBalloon = [self randomPositionForBalloon];
    balloon.position = ccp(positionForBalloon.x, positionForBalloon.y);
    [self addChild:balloon z:1];
    [self startTrackingBalloon:balloon];
    
    //Random color (receives a CCTintTo action to run)
    [balloon runAction:[self randomBalloonColor]];
    
    //Number of balloons on screen at a time
    CGFloat spawnInterval = kBalloonSpawnInterval;
    CGFloat numberOfBalloonsOnScreen = 1.0;
    if (self.runningOniPad) {
        numberOfBalloonsOnScreen = kNumberOfBalloonsOnScreen_iPad;
    }
    else {
        numberOfBalloonsOnScreen = kNumberOfBalloonsOnScreen_iPhone;
        spawnInterval += 0.159;
    }
    
    //Set actions
        //Move upward
    int randomDriftCoefficient  = (arc4random() % 141) - 80;
    id driftUpwardAction = [CCMoveTo actionWithDuration:(spawnInterval*numberOfBalloonsOnScreen)*1.2 position:ccp(positionForBalloon.x + randomDriftCoefficient, [[CCDirector sharedDirector] winSize].height + [balloon boundingBox].size.width)];
        //Reached top (callback)
    id actionsDone = [CCCallFuncN actionWithTarget:self selector:@selector(balloonReachedTop:)];
    
    //~~~SCALE~~~
    balloon.scale *= 0.8;
    
    //Set to drift upwards
    [balloon runAction:[CCSequence actions:driftUpwardAction, actionsDone, nil]];

}//End addBalloon{}

#pragma mark DESTRUCTION

- (void) popBalloon:(WordBalloon *)balloon {
    
    //Stop tracking
    [self stopTrackingBalloon:balloon];
    
    //SFX
    [self playSound:kSFX_PopBalloon];
    
    //Emitter
    CCParticleSystem *particle=[[[CCParticleSystemQuad alloc] initWithTotalParticles:45] autorelease];
    particle.autoRemoveOnFinish = YES;
    CCTexture2D *texture=[[CCTextureCache sharedTextureCache] addImage:@"balloonShred.png"];
    particle.texture=texture;
    particle.emissionRate=450.00;
    particle.angle=90.0;
    particle.angleVar=360.0;
    ccBlendFunc blendFunc={GL_SRC_ALPHA,GL_ONE_MINUS_DST_COLOR};
    particle.blendFunc=blendFunc;
    particle.duration=0.08;
    particle.emitterMode=kCCParticleModeGravity;
    ccColor4F startColor={0.86,0.57,0.42,1.00};
    particle.startColor=startColor;
    ccColor4F startColorVar={0.50,0.50,0.50,0.00};
    particle.startColorVar=startColorVar;
    ccColor4F endColor={0.81,0.81,0.81,0.70};
    particle.endColor=endColor;
    ccColor4F endColorVar={0.50,0.50,0.50,0.00};
    particle.endColorVar=endColorVar;
    particle.startSize=16.00;
    particle.startSizeVar=0.00;
    particle.endSize=16.00;
    particle.endSizeVar=0.00;
    particle.gravity=ccp(0.00,30.00);
    particle.radialAccel=0.00;
    particle.radialAccelVar=10.00;
    particle.speed=400;
    particle.speedVar= 0;
    particle.tangentialAccel= 0;
    particle.tangentialAccelVar=10;
    particle.totalParticles=45;
    particle.life=0.20;
    particle.lifeVar=0.10;
    particle.startSpin=300.00;
    particle.startSpinVar=0.00;
    particle.endSpin=0.00;
    particle.endSpinVar=0.00;
    particle.position=ccp(balloon.boundingBox.origin.x+(balloon.boundingBox.size.width/2),balloon.boundingBox.origin.y+(balloon.boundingBox.size.height/2));
    particle.posVar=ccp(0.00,0.00);
    [self addChild:particle];
    
    //Animate & Remove
    [balloon runAction: [CCScaleTo actionWithDuration:0.1f scale:1.1f]];
    [balloon runAction: [CCSequence actions: 
                         [CCFadeOut actionWithDuration:0.1f], //Replace this & CCScaleTo above with pop animation
                         [CCCallFuncND actionWithTarget:balloon selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
                         nil]];
    
}//End popBalloon:{}

//This method is called when a balloon passes out of view and deletes that balloon.
- (void) balloonReachedTop: (id) sender {
    
    NSLog(@"balloonReachedTop:");
    
    //Remove from scene
    WordBalloon* balloon = (WordBalloon*)sender;
    [self stopTrackingBalloon:balloon];
    [self removeChild:balloon cleanup:YES];
    
}//End balloonReachedTop:{}

#pragma mark Touch Management

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {//Touch received
    
    if (!self.isTouchEnabled) { //NO TOUCHES!!
        //Ignore
    }
    else { //Touches are enabled
        
        //Get touch location
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];//Convert to Cocos2D coords
    
        //Compare touch location to balloons being tracked
        for (NSInteger i = [balloonsArray count]-1; i >= 0; i--) { //Each balloon being tracked
        
            WordBalloon* balloonToCheck = (WordBalloon *)[balloonsArray objectAtIndex:i]; //Current balloon being checked for touch (balloonToCheck)
        
            if (CGRectContainsPoint([balloonToCheck boundingBox], location)) { //balloonToCheck contains touch location 
                //A balloon has been touched
            
                NSLog(@"Clicked balloon: %@", balloonToCheck.word);
                NSLog(@"Current Word is: %@", self.currentWord.wordString);
            
                NSString* wordToCheck = balloonToCheck.word;
            
                [self popBalloon:balloonToCheck];
            
                if ([wordToCheck isEqualToString:self.currentWord.wordString]) { //Balloon's word matches currentWord
                    //User popped correct balloon!
                    NSLog(@"Correct Balloon.");
                
                    //Play SFX
                    [self playSound:kSFX_Correct];
                
                    // [-----Data-----]
                
                    //Tally
                    self.wordsCorrectCount++;
                    if (self.gameCondition == kGameConditionWords) self.targetWordNumber--;
                
                    //Score
                    self.score += kScoreIncrementAmount;
                
                    // [-----Visuals-----]
                
                    //Feedback
                    [self thumbSpriteAtLocation:location upFacing:YES];
                    [self movingLabelForScoreChange:kScoreIncrementAmount increment:YES atLocation:location];
                
                    //Update changeable labels
                    [self updateConditionLabels];
                
                    //Update game state
                    [self chooseNewWord];
                
                }//End if{} (Correct balloon)
                else { //Balloon's word does not match currentWord
                    //User popped wrong balloon!
                    NSLog(@"Wrong Balloon.");
                
                    //Play SFX
                    [self playSound:kSFX_Incorrect];
                
                    // [-----Data-----]
                
                    //Tally
                    self.wordsIncorrectCount++;
                
                    //Score, not negative!
                    if (self.score - kScoreDecrementAmount <= 0)
                        self.score = 0;
                    else 
                        self.score -= kScoreDecrementAmount;
                
                    // [-----Visuals-----]
                
                    //Feedback
                    [self thumbSpriteAtLocation:location upFacing:NO];
                    [self movingLabelForScoreChange:kScoreDecrementAmount increment:NO atLocation:location];
                
                    //Updates
                    [self updateConditionLabels];
                
                }//End else{} (Wrong balloon)
            
                //Balloon has been popped, swallow touch by breaking loop
                break;
            
            }//End if{} (balloonToCheck was touched)
        }//End for{} (Each balloon being tracked)
        
    }//End else{} (Touches enabled)
}//End touchesBegan: withEvent:{}

- (void)startTrackingBalloon: (WordBalloon*)balloon {
    
    if (balloonsArray) [balloonsArray addObject:balloon];
    else  balloonsArray = [NSMutableArray arrayWithObject:balloon];
    
}//End startTrackingBalloon:{}

- (void)stopTrackingBalloon: (WordBalloon*)balloon {
    
    if (balloonsArray) [balloonsArray removeObject:balloon];
    
}//End stopTrackingBalloon:{}

#pragma mark - Utility -

#pragma mark Preparations

-(void) prepareAnimations {
    
    //Create SpriteFrameCache
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Biplane@2x.plist" textureFile:@"Biplane@2x.png"]; 
    NSLog(@"Loaded Biplane files, result below...");
    
    /* - This was a check for the frames (and names) that were in the cache; The method used does not exist in cocos2d-iphone-1.1-rc0
     
    NSMutableDictionary* framesDict = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFramesToDict];
    for (NSString* frameKey in framesDict) {
        NSLog(@"Frame name: %@", frameKey);
    }
     */
    
    //Create SpriteSheet, add to the layer for definition (where it is used)
    self.biplaneBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Biplane@2x.png"];
    
    //Array to collect CCSpriteFrames
    NSMutableArray* framesOfAnimation =  [NSMutableArray array];
    
    //Build the animation from the cache
    for (NSInteger frameNumber = 1; frameNumber <= 2; frameNumber++) {//For each frame in spriteheet image atlas
        
        //String to build frameName
        NSString* frameName = [NSString string];
        
        //Set the frameName (to query cache) according to frameNumber
        frameName = [NSString stringWithFormat:@"Biplane%d@2x.png", frameNumber]; NSLog(@"Trying to add frame: %@", frameName);
        
        //Load the desired frame by its name - if succesful, add to collection
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]; 
        if( frame) {
            NSLog(@"Frame %d valid & added.", frameNumber);
            [framesOfAnimation addObject:frame];
            NSLog(@"Framecount: %d", [framesOfAnimation count]);
            
        }//End if{} (frame not nil)
        
    }//End for{} (each frame in spritesheet image)
    
    //Animaton to contain the frames
    CCAnimation* twinklingStarAnimation = [CCAnimation animationWithFrames:[NSArray arrayWithArray:framesOfAnimation] delay:1.0f/24.0f];//Delay equals inverse FPS
    
    //Save animation to cache
    [[CCAnimationCache sharedAnimationCache] addAnimation:twinklingStarAnimation name:@"flyForever"]; 
    
}//End prepareAnimations

-(void) prepareDefinitionLayer {
    
    //Biplane
    self.currentBiplane = [CCSprite spriteWithSpriteFrameName:@"Biplane2@2x.png"];
    if (!self.runningOnRetina) { //Standard definition
        self.currentBiplane.scale = 0.5;
    }
    else if (self.runningOniPad && self.runningOnRetina) { //Retina iPad, disabled Retina (Standard Def) -- Remove when enabling Retina for iPad
        self.currentBiplane.scale = 0.5;
    }
    [self.currentBiplane runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flyForever"]]]]; //Run animation action
    [self.biplaneBatchNode addChild:self.currentBiplane];
    
    //Add a label for the definition
    [self setupDefinitionLabelWithText:@" GET READY!!! "];
                            
     //Parent Layer
    CGFloat defLayer_width = [self.currentBiplane boundingBox].size.width - kDefinitionLabelOverlapForBiplane + [self.currentDefinitionLabelLayer boundingBox].size.width;
    CGFloat defLayer_height = [self.currentDefinitionLabelLayer boundingBox].size.height;
    self.definitionLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0) width:defLayer_width height:defLayer_height]; //Initialize
    [self.definitionLayer setIsRelativeAnchorPoint:YES]; //Necessary for position/movement
    self.definitionLayer.isRelativeAnchorPoint = YES;
    self.definitionLayer.anchorPoint =  ccp(0.0f, 0.0f);
    self.definitionLayer.position = ccp([CCDirector sharedDirector].winSize.width, kDefinitionLayerPositionY); //Start off-screen, right
        //Add children
    [self.definitionLayer addChild:self.biplaneBatchNode z:10]; //Use sprite's batchNode instead
    [self.definitionLayer addChild:self.currentDefinitionLabelLayer z:1];
        //Set children's positions
    [self.currentDefinitionLabelLayer setIsRelativeAnchorPoint:YES];
    [self.currentDefinitionLabelLayer setAnchorPoint: ccp(0.0f, 0.5f)];
    [self.currentDefinitionLabelLayer setPosition: ccp([self.currentBiplane boundingBox].size.width-kDefinitionLabelOverlapForBiplane, self.currentDefinitionLabelLayer.boundingBox.size.height/2)];
    [self.currentBiplane setAnchorPoint: ccp(0.0f, 0.5f)];
    [self.currentBiplane setPosition: ccp(0, self.currentDefinitionLabelLayer.position.y-5)];
    
    NSLog(@"currentDefinitionLabelLayer: Position(%.2f, %.2f) Size(%.2f, %.2f)", self.currentDefinitionLabelLayer.position.x, self.currentDefinitionLabelLayer.position.y, [self.currentDefinitionLabelLayer boundingBox].size.width, [self.currentDefinitionLabelLayer boundingBox].size.height);
    [self.currentDefinitionLabelLayer runAction:[CCShow action]];
    
    //iPad Y modification
    if (self.runningOniPad) { [self.definitionLayer setPosition:ccp(self.definitionLayer.position.x, self.definitionLayer.position.y+kDefintionLayerPositionY_iPadModifier)]; }
    
    //Add layer to self
    [self addChild:self.definitionLayer z:10];
    
}//End prepareReusableSprites

- (void) prepareConditionsLayer {
    
    //Create sprites - first, to calculate height
    self.scoreCloud = [CCSprite spriteWithFile:@"cloud.png"];
    self.victoryConditionsCloud = [CCSprite spriteWithFile:@"cloud.png"];
    
    //Parent Layer
    self.conditionsLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0) width:[CCDirector sharedDirector].winSize.width height:[self.scoreCloud boundingBox].size.height];
    
    //Position sprites & add
    
    [self.victoryConditionsCloud setAnchorPoint:CGPointMake(0.0, 0.0)];
    [self.victoryConditionsCloud setPosition:CGPointMake(0.0, 0.0)]; //Left-side left-aligned
    [self.victoryConditionsCloud setOpacity:0.0];
    [self.conditionsLayer addChild:self.victoryConditionsCloud];
    
    [self.scoreCloud setAnchorPoint:CGPointMake(1.0, 0.0)];
    [self.scoreCloud setPosition:CGPointMake([CCDirector sharedDirector].winSize.width, 0.0)]; //Right-side right-aligned
    [self.scoreCloud setOpacity:0.0];
    [self.conditionsLayer addChild:self.scoreCloud];
    
    //Score Labels
    self.scoreDumbLabel = [CCLabelTTF labelWithString:@"Error" dimensions:CGSizeMake([self.scoreCloud boundingBox].size.width, 20) alignment:UITextAlignmentCenter fontName:@"Georgia" fontSize:14.0]; //Create
    [self.scoreDumbLabel setColor:ccc3(55, 55, 55)]; //Color
    [self.scoreDumbLabel setOpacity:0.0];
    [self.scoreCloud addChild:self.scoreDumbLabel]; //Add
    [self.scoreDumbLabel setAnchorPoint:CGPointMake(0.0, 1.0)]; //Anchor
    [self.scoreDumbLabel setPosition:CGPointMake(0, [self.scoreCloud boundingBox].size.height - [scoreDumbLabel boundingBox].size.height)]; //Position
    
    self.scoreLabel = [CCLabelTTF labelWithString:@"error" dimensions:CGSizeMake([self.scoreCloud boundingBox].size.width, [self.scoreCloud boundingBox].size.height/2) alignment:UITextAlignmentCenter fontName:@"Didot" fontSize:24.0]; //Create
    [self.scoreLabel setColor:ccc3(55, 55, 125)]; //Color - 55, 55, 125 = Dark Gray-Blue
    [self.scoreLabel setOpacity:0.0];
    [self.scoreCloud addChild:self.scoreLabel]; //Add
    [self.scoreLabel setAnchorPoint:CGPointMake(0.0, 0.0)]; //Anchor
    [self.scoreLabel setPosition:CGPointMake(0, 0)]; //Position
    
    //Victory Conditions
    self.victoryConditionsDumbLabel = [CCLabelTTF labelWithString:@"Error" dimensions:CGSizeMake([self.scoreCloud boundingBox].size.width, 20) alignment:UITextAlignmentCenter fontName:@"Georgia" fontSize:14.0];
    [self.victoryConditionsDumbLabel setColor:ccc3(55, 55, 55)];
    [self.victoryConditionsDumbLabel setOpacity:0.0];
    [self.victoryConditionsCloud addChild:self.victoryConditionsDumbLabel];
    [self.victoryConditionsDumbLabel setAnchorPoint:CGPointMake(0, 1.0)];
    [self.victoryConditionsDumbLabel setPosition:CGPointMake(0, [self.victoryConditionsCloud boundingBox].size.height - [victoryConditionsDumbLabel boundingBox].size.height)];
    
    self.victoryConditionsNumberLabel = [CCLabelTTF labelWithString:@"error" dimensions:CGSizeMake([self.victoryConditionsCloud boundingBox].size.width, [self.victoryConditionsCloud boundingBox].size.height/2) alignment:UITextAlignmentCenter fontName:@"Didot" fontSize:24.0];
    [self.victoryConditionsNumberLabel setColor:ccc3(55, 55, 55)]; //55, 55, 55 - Dark Gray (match above)
    [self.victoryConditionsNumberLabel setOpacity:0.0];
    [self.victoryConditionsCloud addChild:self.victoryConditionsNumberLabel];
    [self.victoryConditionsNumberLabel setAnchorPoint:CGPointMake(0.0, 0.0)];
    [self.victoryConditionsNumberLabel setPosition:CGPointMake(0, 0)];
    
    //Add to main layer
    [self.conditionsLayer setPosition:CGPointMake(0.0, [CCDirector sharedDirector].winSize.height+1)]; //Set above screen
    [self addChild:self.conditionsLayer];
    
}//End prepareProgressLabels

- (void) prepareUserInterface { 
    //(NOTE: Must have self.currentWord set prior)
    
    [self prepareDefinitionLayer]; //Definition Label 
    [self prepareConditionsLayer]; //Progress Label(s)
    
}//End 

#pragma mark UI Tasks

- (void) presentUserInterface: (NSNotification*)notification {
    
    //Catch & sync info 
    [self syncInfoFromArray: [[notification userInfo] objectForKey:@"GameConditions"]  ];
    
    //Choose and update
    [self chooseNewWord];
    [self updateConditionLabels];
    [self moveConditionLabelsOnscreen];
    [self moveDefinitionLayerRightOfScreen];
    
}//End presentUserInterface

- (void) dismissUserInterface {
    
    [self moveConditionLabelsOffscreen];
    
}//End dismissUserInterface

- (void) updateConditionLabels {
    
    //Score
    [self.scoreDumbLabel setString:@"Score"];
    [self.scoreLabel setString:[NSString stringWithFormat:@"%i", self.score]];
    
    //Victory Conditions
    if (self.endlessPlay) {
        [self.victoryConditionsDumbLabel setString:@"Words Left"];
        [self.victoryConditionsNumberLabel setString:@"∞"];
    }
    else if (self.gameCondition == kGameConditionWords) {
        [self.victoryConditionsDumbLabel setString:@"Words Left"];
        [self.victoryConditionsNumberLabel setString:[NSString stringWithFormat:@"%i", self.targetWordNumber]]; 
    }   
    else if (self.gameCondition == kGameConditionScore) {
        [self.victoryConditionsDumbLabel setString:@"Target Score"];
        [self.victoryConditionsNumberLabel setString:[NSString stringWithFormat:@"%i", self.targetScore]];
    }
    
}//End updateLabels

- (void) moveConditionLabelsOnscreen {
    
    NSInteger transitionDuration = 1.0;
    [self.scoreCloud runAction:[CCFadeIn actionWithDuration:transitionDuration]];
    [self.scoreDumbLabel runAction:[CCFadeIn actionWithDuration:transitionDuration]];
    [self.scoreLabel runAction:[CCFadeIn actionWithDuration:transitionDuration]];
    [self.victoryConditionsCloud runAction:[CCFadeIn actionWithDuration:transitionDuration]];
    [self.victoryConditionsDumbLabel runAction:[CCFadeIn actionWithDuration:transitionDuration]];
    [self.victoryConditionsNumberLabel runAction:[CCFadeIn actionWithDuration:transitionDuration]];
    [self.conditionsLayer runAction:[CCMoveTo actionWithDuration:1.0 position:CGPointMake(0.0, [CCDirector sharedDirector].winSize.height-self.conditionsLayer.contentSize.height)]]; //Move down from above screen
    
} //End moveConditionLabelsOnscreen

- (void) moveConditionLabelsOffscreen {
    
    
    
}//End moveConditionLabelsOffscreen

- (void) presentIntroVC {
    
    //Display the intro & observe
    WordBurstIntro* introVC = [[[WordBurstIntro alloc] initWithNibName:@"WordBurstIntro" bundle:NULL wordListCount:[self.wordListComprehensive.wordObjects count]] autorelease];
    
        //Location
    if (self.runningOniPad) {
        introVC.view.center = CGPointMake(self.boundingBox.size.width/2, self.boundingBox.size.height/2);
        introVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    else //iPhone or iPod touch
        introVC.view.frame = self.boundingBox;
        
        //Observe
    [self startObservingIntroVC:introVC];
    
        //Add
    [[[CCDirector sharedDirector] openGLView] addSubview:introVC.view];
    
    self.tempChildVC = introVC;
    
}//End presentIntroVC

- (void) dismissIntroVC:(NSNotification*)notification {
    
    WordBurstIntro* introVC = [notification object];
    
    //Remove observations
    [self stopObservingIntroVC:introVC];
    
    //Remove intro view & destroy
    [introVC.view removeFromSuperview];
    
    [self startPlaying:notification];
    
}//End removeIntro

- (void) presentVictoryVC {
    
    [self pauseBGM];
    
        [self playSound:kSFX_Tada1];
    
    [self performSelector:@selector(resumeBGM) withObject:nil afterDelay:2.0];
    
    //Pop all balloons being tracked
    for (NSInteger balloons = [balloonsArray count]; balloons > 0; balloons--) {
        [self popBalloon:[balloonsArray objectAtIndex:balloons-1]];
    }
    
    //Collect stats for view: Score, Correct, Incorrect
    NSArray* victoryStats = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:self.score],
                             [NSNumber numberWithInt:self.wordsCorrectCount],
                             [NSNumber numberWithInt:self.wordsIncorrectCount],
                             nil];
    
    //Display victory view
    WordBurstVictoryVC* victoryVC = [[WordBurstVictoryVC alloc] initWithNibName:@"WordBurstVictoryVC" bundle:NULL gameVictoryInfo:victoryStats];
    
        //Location
    if (self.runningOniPad) {
        victoryVC.view.center = CGPointMake(self.boundingBox.size.width/2, self.boundingBox.size.height/2);
        victoryVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    else //iPhone or iPod touch
        victoryVC.view.frame = self.boundingBox;
    
        //Observe
    [self startObservingVictoryVC:victoryVC];
    
        //Add
    [[[CCDirector sharedDirector] openGLView] addSubview:victoryVC.view];
    
    self.tempChildVC = victoryVC;
    [victoryVC release];
    
}//End presentVictory

- (void) dismissVictoryVC:(NSNotification*)notification {
    
    WordBurstVictoryVC* victoryVC = [notification object];
    
    //Remove observations
    [self stopObservingVictoryVC:victoryVC];
    
    //Remove victory view & destroy
    [victoryVC.view removeFromSuperview];
    
}//End removeVictory

- (void) moveDefinitionLayerOffscreen {
    
    //Play biplane SFX
    [self playSound:kSFX_Airplane];
    
    //Move definitionLayer's right edge to just off left of screen
    CGFloat definitionLayerPositionY = kDefinitionLayerPositionY;
    if (self.runningOniPad) definitionLayerPositionY += kDefintionLayerPositionY_iPadModifier;
    [self.definitionLayer runAction:[CCMoveTo actionWithDuration:kDefinitionLayerAnimationInterval/2 position:ccp(-self.definitionLayer.contentSize.width*2, definitionLayerPositionY)]];
    
}//End moveDefinitionLayerOffscreen

- (void) moveDefinitionLayerRightOfScreen {
    
    //Move definitionLayer's left edge to just off right of screen
    CGFloat definitionLayerPositionY = kDefinitionLayerPositionY;
    if (self.runningOniPad) definitionLayerPositionY += kDefintionLayerPositionY_iPadModifier;
    [self.definitionLayer setPosition:ccp(self.definitionLayer.contentSize.width+1, definitionLayerPositionY)];
    
}//End moveDefinitionLayerRightOfScreen

- (void) moveDefinitionLayerOnscreen {
    
    //Ensure correct definition
    [self.currentDefinitionLabel setString:self.currentWord.definitionString];
    
    //Play biplane SFX
    [self playSound:kSFX_Airplane];
    [[SimpleAudioEngine sharedEngine] playEffect:kSFX_Airplane];
    
    //Move definitionLayer's right edge to the right edge of the screen
    CGFloat definitionLayerPositionY = kDefinitionLayerPositionY;
    if (self.runningOniPad) definitionLayerPositionY += kDefintionLayerPositionY_iPadModifier;
    [self.definitionLayer runAction:[CCMoveTo actionWithDuration:kDefinitionLayerAnimationInterval/2 position:ccp([CCDirector sharedDirector].winSize.width-self.definitionLayer.contentSize.width, definitionLayerPositionY)]];
    
}//End moveDefinitionLayerOffscreen

#pragma mark Sound

- (void)playSound:(NSString *)fileName {
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    
    ALuint soundEffectID = [[SimpleAudioEngine sharedEngine] playEffect:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
    
    [soundsIDArray addObject:[NSString stringWithFormat:@"%i", soundEffectID]];
}

- (void)stopAllSounds {
    
    [self stopBGM];
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    
    for (int i=0; i<[soundsIDArray count]; i++)
    {
        [[SimpleAudioEngine sharedEngine] stopEffect:[[soundsIDArray objectAtIndex:i] intValue]];
    }
    
    [soundsIDArray removeAllObjects];
}

- (void) playBGM {
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:kBGM_1 loop:YES];
}

- (void) resumeBGM {
    
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

- (void) pauseBGM {
    
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

- (void) stopBGM {
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

#pragma mark Notification Management

- (void) startObservingIntroVC:(UIViewController*)introVC {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissIntroVC:) name:WordBurstReadyToPlayNotification object:introVC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitPlaying:) name:GameQuitNotification object:introVC];
    
}//End startObservingIntroVC

- (void) stopObservingIntroVC:(UIViewController*)introVC {
    
    //Remove observations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordBurstReadyToPlayNotification object:introVC];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GameQuitNotification object:introVC];
    
}//End stopObservingIntroVC

- (void) startObservingVictoryVC:(UIViewController*)victoryVC {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cyclePlay:) name:WordBurstReadyToPlayNotification object:victoryVC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitPlaying:) name:GameQuitNotification object:victoryVC];
    
}//End startObservingVictoryVC

- (void) stopObservingVictoryVC:(UIViewController*)victoryVC {
    
    //Remove observations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordBurstReadyToPlayNotification object:victoryVC];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GameQuitNotification object:victoryVC];
    
}//End stopObservingVictoryVC

#pragma mark Randomizers

//Passes back a random color for a balloon:
// red, orange, yellow, green, blue, purple or pink.
- (id) randomBalloonColor {
    
    //Get a random number: 1 - 7
    int colorCoefficient = (arc4random() % 7) + 1;
    
    //Decide the color
    int red = 0;
    int green = 0;
    int blue = 0;
    switch (colorCoefficient) {
        case 1: 
            //Red
            red = 255;
            break;
        case 2:
            //Orange
            red = 255;
            green = 130;
            break;
        case 3:
            //Yellow
            red = 255;
            green = 255;
            break;
        case 4:
            //Green
            green = 255;
            break;
        case 5:
            //Blue
            red = 75;
            green = 75;
            blue = 255;
            break;
        case 6:
            //Purple
            red = 180;
            blue = 255;
            green = 50;
            break;
        case 7:
            //Pink
            red = 255;
            green = 125;
            blue = 255;
            break;
            
        default:
            //Black (signals error)
            break;
    }//End switch(colorCoefficient){}
    
    //Return a CCTintTo action with the random color, instant change (duration:0secs)
    return [CCTintTo actionWithDuration:0 red:red green:green blue:blue];
    
}//End randomBalloonColor

//This method randomly selects a position for a balloon to be added.
- (CGPoint) randomPositionForBalloon{
    
    //Decide number of "lanes" (columns) for balloon spawning. These will be dispersed equidistantly across x-axis
    int numberOfSpawnLanes = 5;
    if (!self.runningOniPad) {//iPhone or iPod touch
        numberOfSpawnLanes = 3;
    }
    
    //Randomly pick a lane
    int laneNumber = (arc4random() % numberOfSpawnLanes) + 1;
    
    //Decide x position: Multiply coefficent by column width
    int x = laneNumber * ( [CCDirector sharedDirector].winSize.width / (numberOfSpawnLanes + 1));
    
    //Set y position (below screen)
    int y = (-200);
    
    //Return the randomccp point
    return CGPointMake(x, y);
    
}//End randomPositionForBalloon

#pragma mark Programmatically Created Nodes

- (void) setupDefinitionLabelWithText: (NSString*) definitionText {
    
    //Create the standardized label for a definition using definitionText
    self.currentDefinitionLabel = [CCLabelTTF labelWithString:definitionText dimensions:CGSizeMake([CCDirector sharedDirector].winSize.width, kDefinitionLabelHeight) alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:@"Georgia" fontSize:18.0];
    self.currentDefinitionLabel.color = ccc3(55, 55, 55); //Set font color to black
    [self.currentDefinitionLabel setAnchorPoint: ccp(0.0, 0.0)];
    [self.currentDefinitionLabel setPosition: ccp(0.0, 0.0)];
    
    //Create a layer for the label
    self.currentDefinitionLabelLayer =  [CCLayerGradient layerWithColor:ccc4(155, 155, 155, 175) fadingTo:ccc4(200, 200, 200, 175) alongVector: ccp(-self.currentDefinitionLabel.boundingBox.size.width/2, self.currentDefinitionLabel.boundingBox.size.height/2)];
    [self.currentDefinitionLabelLayer changeWidth:self.currentDefinitionLabel.boundingBox.size.width height:self.currentDefinitionLabel.boundingBox.size.height];
    
    //Add label (child) to layer (parent)
    [self.currentDefinitionLabelLayer addChild:self.currentDefinitionLabel z:1];
    
}//End changeDefinitionLayerToText:

- (void) thumbSpriteAtLocation: (CGPoint) location upFacing: (BOOL) thumbsUp {
    
    //Determine correct sprite file
    NSString* spriteFile = [NSString stringWithFormat:@"thumbs"];
    
    //Direction
    if (thumbsUp)
        spriteFile = [spriteFile stringByAppendingFormat:@"Up"];
    else
        spriteFile = [spriteFile stringByAppendingFormat:@"Down"];

    //Resolution
    if (self.runningOnRetina) 
        spriteFile = [spriteFile stringByAppendingFormat:@"@2x"];
    
    //Enlarge
    
    //File extension
    spriteFile = [spriteFile stringByAppendingFormat:@".png"];
    
    //Spawn
    CCSprite* thumbSprite = [CCSprite spriteWithFile:spriteFile];
    CGFloat defaultThumbScale = 1.35;
    thumbSprite.scale = defaultThumbScale;
    [thumbSprite setPosition:location];
    [self addChild:thumbSprite];
    
    //Actions
    CGFloat showDuration = 0.5f;
    CGFloat fadeDuration = 0.5f;
    
    if (thumbsUp) {
        
        //Scale (Bounce)
        [thumbSprite runAction:[CCSequence actions:
                           [CCScaleTo actionWithDuration:showDuration/2 scale:defaultThumbScale+0.5],
                           [CCScaleTo actionWithDuration:showDuration/2 scale:defaultThumbScale],
                           [CCScaleTo actionWithDuration:fadeDuration scale:0.0],
                           nil]];
    }
    else { //thumbs down
        
        thumbSprite.anchorPoint = ccp(0.0, 0.5);
        [thumbSprite setIsRelativeAnchorPoint:YES];
        thumbSprite.position = ccp(thumbSprite.position.x-(thumbSprite.boundingBox.size.width/2), thumbSprite.position.y);
        
        //Rotation (Shake)
        [thumbSprite runAction:[CCSequence actions:
                                [CCRotateTo actionWithDuration:showDuration/2 angle:20.0],
                                [CCRotateTo actionWithDuration:showDuration/2 angle:0.0],
                                [CCRotateTo actionWithDuration:fadeDuration/2 angle:20.0],
                                [CCRotateTo actionWithDuration:fadeDuration/2 angle:0.0],
                                nil]];
    }
        
        //Alpha & Cleanup
    [thumbSprite runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:showDuration], //Show duration
                           [CCFadeOut actionWithDuration:fadeDuration], //Fade duration
                           [CCCallFuncND actionWithTarget:thumbSprite selector:@selector(removeFromParentAndCleanup:) data:(void*)YES], //Remove
                           nil]];
    
}//End thumbSpriteAtLocation: upFacing:

- (void) movingLabelForScoreChange: (NSInteger) scoreChange increment:(BOOL)isIncrement atLocation:(CGPoint)location{
   
    //String
    NSString* scoreChangeString = [NSString string];
    if (isIncrement)
        scoreChangeString = @"+"; //Start with sign
    else 
        scoreChangeString = @"-";
    scoreChangeString = [scoreChangeString stringByAppendingFormat:@"%i", scoreChange]; //Append abs value
    
    //Label
    CGFloat fontSizeForScoreIncrement;
    if (self.runningOniPad) 
        fontSizeForScoreIncrement = 40.0;
    else
        fontSizeForScoreIncrement = 46.0;
    
    CCLabelTTF* scoreChangeLabel = [CCLabelTTF labelWithString:scoreChangeString fontName:@"Marker Felt" fontSize:fontSizeForScoreIncrement]; //Create
    
    [scoreChangeLabel setPosition:location]; //Set position
    
    if (isIncrement) {
        [scoreChangeLabel setColor:ccc3(0, 0, 255)]; //Green if positive
        [scoreChangeLabel setPosition:ccp(scoreChangeLabel.position.x, scoreChangeLabel.position.y-30)];
    }
    else
        [scoreChangeLabel setColor:ccc3(255, 0, 0)]; //Red if negative
    
    [self addChild:scoreChangeLabel]; //Add to layer
    
    //Actions
    CGFloat scoreIncrementDisplayDuration = 1.5;
    [scoreChangeLabel runAction:[CCMoveTo actionWithDuration:scoreIncrementDisplayDuration position:CGPointMake(location.x, location.y+20.0f)]];
    [scoreChangeLabel runAction:[CCSequence actions:
                                 [CCFadeOut actionWithDuration:scoreIncrementDisplayDuration],
                                 [CCCallFuncND actionWithTarget:scoreChangeLabel selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
                                 nil]];
    
}//End movingLabelForScoreChange: increment:

@end
