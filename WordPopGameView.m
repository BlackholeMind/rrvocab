//
//  WordPopGameView.m
//  RRV101
//
//  Created by Brian C. Grant on 1/8/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "cocos2d.h"

#import "WordPopGameView.h"
#import "WordPopGameLayer.h"
#import "RRVConstants.txt"

@implementation WordPopGameView

@synthesize runningOniPad, runningOnRetina, lessonNumber;
@synthesize mainLayer;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void) dealloc {
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Retire the cocos2d director
    CCDirector *director = [CCDirector sharedDirector];
    [[director openGLView] removeFromSuperview];
    [director end];
    
    //Views
    [mainLayer release];
    
    [super dealloc];
    
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        self.mainLayer = nil;
        
    }
    
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
    return YES;
}

//
// The EAGLView MUST be resized manually!
//
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGRect rect;
	if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			rect = CGRectMake(0.0, 0.0, 768.0, 1024.0);
		else
			rect = CGRectMake(0.0, 0.0, 320.0, 480.0);
        
	} else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			rect = CGRectMake(0.0, 0.0, 1024.0, 768.0);
		else
			rect = CGRectMake(0.0, 0.0, 480.0, 320.0);
	}
    
    //Reset Transforms
        //iOS 4.0 and later
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         self.view.transform = CGAffineTransformMakeRotation([self radianFromDegree:0.0]);
                         self.view.bounds = CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
                         self.view.center = CGPointMake(rect.size.width/2, rect.size.height/2);
                         
                     }
                     completion:^(BOOL finished){
                         
                         self.view.frame = self.view.bounds;
                         
                     }];//End [animateWithDuration: delay: options: animations:^{} completion:^{}]
    
	EAGLView *glView = [[CCDirector sharedDirector] openGLView];
	glView.bounds = rect;
    
    //self.mainLayer resizing
    [self.mainLayer willChangeBounds:glView.bounds];
    
}//End willRotateToInterfaceOrientation: duration:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLessonNumber:(NSInteger)lessonNumberToPlay {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Sync Data
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
    }
        
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //Turn orientation to portrait
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        
        CGFloat turnDegree = 90.0; 
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) turnDegree *= -1;
        
        //iOS 4.0 and later
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             
                             self.view.transform = CGAffineTransformIdentity;
                             self.view.transform = CGAffineTransformMakeRotation([self radianFromDegree:turnDegree]);
                             self.view.bounds = CGRectMake(0.0f, 0.0f, self.view.bounds.size.height, self.view.bounds.size.width);
                             self.view.center = CGPointMake(self.view.bounds.size.height/2, self.view.bounds.size.width/2);
                         
                         }
                         completion:^(BOOL finished){
                         
                         }];//End [animateWithDuration: delay: options: animations:^{} completion:^{}]
    }
    
}//End viewWillAppear:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    if( ! [director enableRetinaDisplay:YES] ) {
        CCLOG(@"Retina Display Not supported");
    }
    
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
    
    // Run the game scene & observe
    self.mainLayer = [WordPopGameLayer nodeWithLessonNumber:self.lessonNumber];
    CCScene* mainScene = [CCScene node];
    [mainScene addChild:self.mainLayer];
    
	// Run or replace the game scene
    if ([director runningScene]) {
        [director replaceScene:mainScene];
    }
    else { //No scene running
        [director stopAnimation];
        [director runWithScene:mainScene];
    }
    
    //Observe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitPlaying:) name:GameQuitNotification object:self.mainLayer];
    
}//End viewDidLoad{}

#pragma mark - Callbacks -

- (void) quitPlaying: (NSNotification*) notification {
    
    //Post desire to quit
    [[NSNotificationCenter defaultCenter] postNotificationName:GameQuitNotification object:self];
    
    //Remove observation
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GameQuitNotification object:[notification object]];
    
}//End quitPlaying

#pragma mark - Math -

- (CGFloat) radianFromDegree: (CGFloat) degree {
    
    return (M_PI * (degree) / 180.0);
    
}//End radianFromDegree

@end
