//
//  StoryIntro101Controller.m
//  RRV101
//
//  Created by Brian C. Grant on 3/31/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved. 
//

#import "StoryIntro101Controller.h"
#import "WordListObject.h"
#import "QuizObject.h"
#import "QuestionObject.h"
#import "StoryIntro101Layer.h"
#import "WordIntroController.h"
#import "RRVConstants.txt"

@implementation StoryIntro101Controller

#pragma mark Synthesizers

@synthesize runningOniPad, runningOnRetina, lessonNumber, wordList, preQuiz;
@synthesize introLayer;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

-(void) dealloc {
    
    //Observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //Child VCs
    for (UIViewController* childViewController in [self childViewControllers]) {
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
    }
    
    //Retire the cocos2d director
    CCDirector *director = [CCDirector sharedDirector];
    [[director openGLView] removeFromSuperview];
    [director end];
    
    //Data
    [wordList release];
    [preQuiz release];
    
    //Views & Layers
    [introLayer release];
    
    //Controllers & Media
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.wordList = nil;
        self.preQuiz = nil;
    
        //Views & Layers
        self.introLayer = nil;
    
        //Controllers & Media
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    BOOL shouldRotate;
    
    if (self.runningOniPad) {
        
        shouldRotate = YES;
        
    }
    else {
        
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait);
        
    }
    return shouldRotate;
    
}//End shouldAutorotateToInterfaceOrientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    NSLog(@"StoryIntro101Controller willRotate");
    
    CGRect rect;
	if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			rect = CGRectMake(0, 0, 768, 1024);
		else
			rect = CGRectMake(0, 0, 320, 480);
        
	} else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			rect = CGRectMake(0, 0, 1024, 768);
		else
			rect = CGRectMake(0, 0, 480, 320);
	}
    
	[self changeToBounds:rect];
    [self.introLayer updateSpritePositions];
    
}

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lessonNumber:(NSInteger)lessonNumberToLoad iPad:(BOOL)isOniPad retina:(BOOL)isOnRetina {

    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        // Custom initialization
        
        self.lessonNumber = lessonNumberToLoad; //IMPORTANT: Lesson must have EXACTLY 12 words, needs tweaking to support dynamic wordList size.
        self.runningOniPad = isOniPad;
        self.runningOnRetina = isOnRetina;
        
    }
    return self;
    
}//End initWithNibName: bundle: lessonNumber:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Data Construction
    self.wordList = [WordListObject listForLessonNumber:self.lessonNumber];
    [self.wordList shuffle]; [self.wordList shuffle]; [self.wordList shuffle];
    [self.wordList ensureLastWord:@"horizon"];
    self.preQuiz = [[[QuizObject alloc] init] autorelease];
    [self.preQuiz setQuizIsPrecursor:YES];
    [self.preQuiz setLessonNumber:self.lessonNumber];
    
    //Setup cocos2D director, scene, etc...
    [self cocos2DSetup];

}//End viewDidLoad

- (void) viewWillAppear:(BOOL)animated{
        
    [self.introLayer changeWidth:self.view.bounds.size.width height:self.view.bounds.size.height];
    [self.introLayer updateSpritePositions];
        
}//End viewWillAppear:

#pragma mark - Callbacks - 

-(void) beginWordIntro: (NSNotification*)notification {
    
    //DEVELOPMENT SHORTCUT (Shortcut to story)
    //[[NSNotificationCenter defaultCenter] postNotificationName:StoryIntroFinishedNotification object:self userInfo:[self.preQuiz collapseToDictionary]];
    
    
    //Pop a wordObject, present a wordIntro, & add observer
    if (self.runningOniPad) { // iPad
        NSLog(@"WordIntro presentation (iPad): Modal");
        
        //Disable further touches
        self.view.userInteractionEnabled = NO;
        
        //Pop
        WordIntroController* wordIntroController = [[[WordIntroController alloc] initWithNibName:@"WordIntroController" bundle:NULL forWordObject:[self.wordList popWordObject] presentedModally:YES iPad:self.runningOniPad retina:self.runningOnRetina] autorelease];
        
        //Present
        [wordIntroController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentViewController:wordIntroController animated:YES completion:^{
                //Afterwards...
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWordIntroModal:) name:WordIntroFinishedNotification object:wordIntroController];
        
    }
    else { // iPhone/iPod
        NSLog(@"WordIntro presentation (iPhone/iPod): Mock PageView Modal");
        
        //Disable further touches
        self.introLayer.customTouchesDisabled = YES;
        
        //Pop
        WordIntroController* wordIntroController = [[[WordIntroController alloc] initWithNibName:@"WordIntroController" bundle:NULL forWordObject:[self.wordList popWordObject] presentedModally:NO iPad:self.runningOniPad retina:self.runningOnRetina] autorelease];
        
        //Transition
        [wordIntroController.view setFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)]; //Set Y to just below this VC.view's height (just off-screen, bottom)
        [self addChildViewController:wordIntroController];
        [wordIntroController didMoveToParentViewController:self];
        [self.view addSubview:wordIntroController.view];
            //Animate into viewable area (iOS 4.0 and later)
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut 
                     animations:^{wordIntroController.view.transform = CGAffineTransformMakeTranslation(0.0, -self.view.bounds.size.height);}//Bring up from bottom
                     completion:^(BOOL finished){
                     
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
        
        //Observe
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWordIntro:) name:WordIntroFinishedNotification object:wordIntroController];
    
    }// End else{} (iPhone/iPod)
    
    
    
}//End beginWordIntro

-(void) dismissWordIntro: (NSNotification*)notification {
    
    NSLog(@"dismissWordIntro:");
    
    //Catch wordIntroController
    WordIntroController* wordIntroController = (WordIntroController*)[notification object];
    
    //Catch QuestionObject
    QuestionObject* questionToAppend = [[notification userInfo] objectForKey:kQuestionObjectInDictionary];
    
    //Catch question info, add to quizObject
    [self.preQuiz appendQuestionObject:questionToAppend]; NSLog(@"Appended QuestionObject, New count: %d", [self.preQuiz.questionObjects count]);
    
    //Animate WordIntro away from viewable area (iOS 4.0 and later)
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^{wordIntroController.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);}//Bring up from bottom
                     completion:^(BOOL finished) {//Code to perform after animation completes
                         
                        //Remove observer
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:WordIntroFinishedNotification object:wordIntroController];
                         
                         //Remove view & release
                         [wordIntroController.view removeFromSuperview];
                         [wordIntroController willMoveToParentViewController:nil];
                         [wordIntroController removeFromParentViewController];
                         
                         //Re-enable disabled touches
                         self.introLayer.customTouchesDisabled = NO;
                         
                         //If out of words, report finished
                         if ([self.wordList.wordObjects count] == 0) [self performSelector:@selector(userFinishedWithStoryIntro) withObject:nil afterDelay:1.0];
                         
                     }];//End animateWithDuration: delay: options: animations:^{} completion:^{}
    
    
    
}//End userFinishedWithWordIntro:

-(void) dismissWordIntroModal: (NSNotification*)notification {
    
    WordView* wordViewModalViewController = (WordView*)[notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WordViewFinishedNotification object:wordViewModalViewController];
    
    //[wordViewModalViewController dismissModalViewControllerAnimated:YES];
    [wordViewModalViewController dismissViewControllerAnimated:YES completion:^{
        //Afterwards...
    }];
    
    self.view.userInteractionEnabled = YES;
    self.introLayer.customTouchesDisabled = NO;
    
    //If out of words, report finished
    if ([self.wordList.wordObjects count] == 0) [self performSelector:@selector(userFinishedWithStoryIntro) withObject:nil afterDelay:1.0];
    
}//End dismissWordIntroModal:

-(void) userFinishedWithStoryIntro {
    
    //Grade and post built quizObject
    [self.preQuiz grade];
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryIntroFinishedNotification object:self userInfo:[self.preQuiz collapseToDictionary]];
    
    NSLog(@"Story Intro finished, Quiz posted.");
}//End userFinishedWithStoryIntro:

#pragma mark - Utility -

-(void) changeToBounds: (CGRect)bounds {
    
    //Drawing view
    EAGLView *glView = [[CCDirector sharedDirector] openGLView];
	glView.frame = bounds;
    
    //Layer node
    [self.introLayer setContentSize:glView.bounds.size];
    
}//End changeLayerBounds:

#pragma mark - Support -

-(void) cocos2DSetup {
    // Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
    
    // Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
    CCDirector *director = [CCDirector sharedDirector];
    
    // Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
    EAGLView *glView = [EAGLView viewWithFrame:[self.view bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
    
    //Attach the openglView to the director
	[director setOpenGLView:glView];
    
    //Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    if( ! [director enableRetinaDisplay:YES] )
        CCLOG(@"Retina Display Not supported");
    
    // VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
    [director setDeviceOrientation:kCCDeviceOrientationPortrait];
    
    //Displays frames-per-second
    [director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
    
    //Make OpenGLView child of this view controller
    [self setView:glView];
    
    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    //Initialize the layer, add to a scene, and run
    self.introLayer = [StoryIntro101Layer node];
    CCScene* mainScene = [CCScene node];
    [mainScene addChild:self.introLayer];
    
    // Run or replace the game scene
    if ([director runningScene]) {
        [director replaceScene:mainScene];
    }
    else { //No scene running
        [director stopAnimation];
        [director runWithScene:mainScene];
    }
    
    //Observe
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginWordIntro:) name:WordIntroBeginNotification object:self.introLayer];
    
    // Set the layer bounds
    [self.introLayer changeWidth:glView.bounds.size.width height:glView.bounds.size.height];
    
}//End cocos2DSetup


@end
