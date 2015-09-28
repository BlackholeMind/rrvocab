//
//  StoryViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 9/27/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StoryViewController.h"
#import "StoryTextView.h"
#import "VideoPlayerViewController.h"
#import "WordObject.h"
#import "WordView.h"
#import "RRVConstants.txt"


@implementation StoryViewController

#pragma mark Synthesizers

//Data
@synthesize textWithTags, textWithAttributes, lessonNumberForView, pageNumberForView, pageCountForStory, pageAutoplayEnabled;

//Views
@synthesize videoView, imageView, textView, readStoryButton, replayButton, pageNumberLabel, textDrawnView, movieIndicator, movieLoadingLabel, audioIndicator;

//Controllers
@synthesize videoController, storyReader;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Remove observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.storyReader.delegate = nil;
    
    //Data
    [textWithTags release];
    [textWithAttributes release];
    
    //Views
        //wrappers
    [videoView release];
    [imageView release];
    [textView release];
        //indicators
    [movieIndicator release];
    [movieLoadingLabel release];
    [audioIndicator release];
        //buttons
    [readStoryButton release];
    [replayButton release];
        //misc
    [pageNumberLabel release];
    [textDrawnView release];
    
    //Controllers & Media
    [videoController release];
    [storyReader release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use
    
    //Data
    self.textWithTags = nil;
    self.textWithAttributes = nil;
    
    //Views
    //wrappers
    self.videoView = nil;
    self.imageView = nil;
    self.textView = nil;
    //indicators
    self.movieIndicator = nil;
    self.movieLoadingLabel = nil;
    self.audioIndicator = nil;
    //buttons
    self.readStoryButton = nil;
    self.replayButton = nil;
    //misc
    self.pageNumberLabel = nil;
    self.textDrawnView = nil;
    
    //Controllers & Media
    self.videoController = nil;
    self.storyReader = nil;
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    
    BOOL shouldRotate = NO;
    
    //Detect device
    NSString* detectedDevice = [[UIDevice currentDevice] model];
    NSRange textRange = [[detectedDevice lowercaseString] rangeOfString:@"ipad"];
    
    if(textRange.location != NSNotFound){ //Device is an iPad
        //Restrict to portrait only
        
        shouldRotate = (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        
    }//End if{} (device is iPad)
    else{ //Device not an iPad
        //Support all rotations
        
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait);
        
    }//End else{} (device not iPad)
    
    return shouldRotate;
    
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

//Custom init method includes text (with Tags), lessonNumber and pageNumber (for audio/video etc)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forTextWithTags:(NSString*)taggedText lessonNumber:(NSInteger)lessonNumber pageNumber:(NSInteger)pageNumber pageCount:(NSInteger)pageCount {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Sync passed values
        self.textWithTags = taggedText;
        self.lessonNumberForView = lessonNumber;
        self.pageNumberForView = pageNumber;
        self.pageCountForStory = pageCount;
    }
    return self;
    
}//End initWithNibName: bundle: withMovie: andTextView:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Set PageNumber to label
    [self.pageNumberLabel setText:[NSString stringWithFormat:@"%i / %i", self.pageNumberForView, self.pageCountForStory]];
    
    //Pass text to textDrawnView for drawing
    self.textDrawnView = [[[StoryTextView alloc] initWithFrame:self.textView.bounds andText:textWithTags] autorelease];
    [self.textView addSubview:self.textDrawnView];//Add to area
    [self.textView sendSubviewToBack:self.textDrawnView];
    [self.textDrawnView setNeedsDisplay];//Update display
    self.textWithAttributes = (NSAttributedString*)self.textDrawnView.attributedText;//Retain attributes
    
    //Add gesture recognizer
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedStoryText:)];
    //[tapGesture setDelegate:self];
    [self.textDrawnView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    //Configure media
    [self configureVideo];
    [self configureAudio];
    
}//End viewDidLoad

- (void)viewDidAppear:(BOOL)animated {
    
    self.videoController.view.frame = self.videoView.bounds;
    
    [self configureAudio];
    
}//End viewDidAppear:

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //Dismantle Audio Session
    [self.videoController.player pause];
    [self.storyReader stop];
    [self setStoryReader:nil];
    NSError* activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
    
}

#pragma mark - Delegates -

#pragma mark AVAudioPlayer

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self.textView setBackgroundColor:[UIColor clearColor]];
    
    if (self.pageAutoplayEnabled) {
        NSLog(@"StoryPageAutoplayComplete.");
        [self autoplayEnd];
    }
    
}//End audioPlayerDidFinishPlaying: successfully:

#pragma mark - Callbacks -

#pragma mark VideoPlayerViewController

-(void) videoReadyToPlay: (NSNotification*)notification {
    
    NSLog(@"videoReadyToPlay:");
    
    [self.videoView addSubview:self.videoController.view];
    [self.videoView sendSubviewToBack:self.videoController.view];
    [self.videoView setBackgroundColor:[UIColor clearColor]];
    
    [self.movieIndicator stopAnimating];
    [self.movieIndicator setHidden:YES];
    [self.movieLoadingLabel setHidden:YES];
    
    //[self.videoController.player play];
    
}//End videoReadyToPlay:


-(void) videoDidFinishPlaying: (NSNotification*)notification {
    
    if (self.pageAutoplayEnabled && ![self.storyReader isPlaying]) [self performSelector:@selector(readPage:) withObject:self.readStoryButton afterDelay:0.5];
    
}//End videoDidFinishPlaying:

#pragma mark - IBActions -

-(IBAction) readPage:(id)sender{
    
    [self.textView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.6 alpha:0.4]];
    
    if ([self.storyReader isPlaying]) [self.storyReader stop];
    [self.storyReader prepareToPlay];
    [self.storyReader play];
    
}//End readPage:

-(IBAction) replay:(id)sender{
    
    self.pageAutoplayEnabled = YES;
    
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
    
}//End replay:

#pragma mark - Utility -

- (void) configureVideo {
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Load graphic media for page (.mp4 video, or .png image)
    NSString* movieName = [[[@"rrv" stringByAppendingFormat:@"%d", self.lessonNumberForView] stringByAppendingFormat:@"pg"] stringByAppendingFormat:@"%d", self.pageNumberForView];
    NSString* moviePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"mp4"];
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"png"];
    if ([fileManager fileExistsAtPath:moviePath]) { // Movie file exists
        
        NSLog(@"Loading video for page %d", self.pageNumberForView);
        
        //Load and configure player
        NSLog(@"%@.mp4", movieName);
        NSLog(@"At path: %@", moviePath);
        NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
        
        VideoPlayerViewController* player = [[VideoPlayerViewController alloc] init];
        player.URL = movieURL;
        player.view.frame = self.videoView.bounds;
        self.videoController = player;
        [player release];
        
        //Observe player
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReadyToPlay:) name:MyVideoPlayerReadyToPlayNotification object:self.videoController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying:) name:MyVideoPlayerPlaybackCompleteNotification object:self.videoController];
        
    }//End if {} (Movie for page exists)
    else if ([fileManager fileExistsAtPath:imagePath]) { //Image file exists (no movie)
        
        NSLog(@"%@.png", movieName);
        self.imageView = [[[UIImageView alloc] initWithFrame:self.videoView.bounds] autorelease];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self.videoView addSubview:self.imageView];
        [self.videoView sendSubviewToBack:self.imageView];
        
    }//End else if {} (Image for page exists)
    else { //No movie or image exists
        //Present error to user
        
        UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"A video or image file seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [movieNotFoundAlert show];
        [movieNotFoundAlert release];
        
    }//End else {} (No movie or image found)
    
}//End configureVideo

- (void) configureAudio {
    
    //Begin Audio Session
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* audioName = [[[@"rrv" stringByAppendingFormat:@"%d", self.lessonNumberForView] stringByAppendingFormat:@"pg"] stringByAppendingFormat:@"%d", self.pageNumberForView];
    NSString* audioPath = [[NSBundle mainBundle] pathForResource:audioName ofType:@"mp3"];
    if ([fileManager fileExistsAtPath:audioPath]) { //Audio file exists
        
        //Load and configure player
        NSLog(@"%@.mp3", audioName);
        NSLog(@"At path: %@", audioPath);
        self.storyReader = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:NULL] autorelease];
        self.storyReader.delegate = self;
        
        [self.audioIndicator stopAnimating];
        [self.audioIndicator setHidden:YES];
        
    }//End if{} (Audio file exists)
    else { //No audio exists
        
        UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"An audio file seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [movieNotFoundAlert show];
        [movieNotFoundAlert release];
        
    }//End else{} (No audio file exists)
    
}//End configureAudio

-(void) tappedStoryText: (UITapGestureRecognizer*)tapGesture {//Called when user clicks storyTextView
    NSLog(@"storyTextView tapped!");
    if(self.textDrawnView.textCTFrame == NULL || self.textDrawnView.textCTFrame == nil){NSLog(@"***Frame is nil***");}
    
    CGPoint point = [tapGesture locationInView:self.textDrawnView];
    NSLog(@"Tap occured: %.0f, %.0f", point.x, point.y);
    
    point.y -= self.textDrawnView.bounds.size.height; if(point.y < 0){point.y *= -1;}
    NSLog(@"Converted to: %.0f, %.0f", point.x, point.y);
    
    //Get the lines of the frame in self.storyTextView.CTFrame
    CFArrayRef lines = CTFrameGetLines(self.textDrawnView.textCTFrame);
    NSLog(@"Got array of lines from desired CTFrame");
    if(!lines) NSLog(@"Array of lines is nil...");
    
    CFIndex lineCount = CFArrayGetCount(lines); NSLog(@"Frame has %ld lines", lineCount);
    CGPoint origins[lineCount];
    CTFrameGetLineOrigins(self.textDrawnView.textCTFrame, CFRangeMake(0, 0), origins);
    
    for(CFIndex idx = 0; idx < lineCount; idx++) {//For each line
        
        NSLog(@"Checking line %ld", idx);
        CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
        CGRect lineBounds = CTLineGetImageBounds(line, self.textDrawnView.contextForFrame);
        lineBounds.origin.y += origins[idx].y;//Set line origin to location on Y-axis
        
        //Check if the tap was on current line
        if(CGRectContainsPoint(lineBounds, point)) {//Tap was on this line
            NSLog(@"The tap was on line %ld!", idx);
            
            //Get the line's glyph runs
            CFArrayRef runs = CTLineGetGlyphRuns(line); NSLog(@"Line %ld has %ld runs", idx, CFArrayGetCount(runs));
            CFIndex runCount = CFArrayGetCount(runs);
            CGFloat runOriginCursorPosition;//Set run origin to location on X-axis
            
            for(CFIndex j = 0; j < runCount; j++) {//For each run
                CTRunRef run = CFArrayGetValueAtIndex(runs, j);
                CGRect runBounds = CTRunGetImageBounds(run, self.textDrawnView.contextForFrame, CFRangeMake(0, 0)); //Zero length range prompts full run continue to end
                
                //Add the origin offset, then set the true view origin
                runOriginCursorPosition += runBounds.origin.x;
                runBounds.origin.x = runOriginCursorPosition;
                
                //Conform the run to the line's true view Y-axis position and whole height
                runBounds.origin.y = lineBounds.origin.y;
                runBounds.size.height = lineBounds.size.height;
                NSLog(@"Run %ld's Origin: %.0f, %.0f", j, runBounds.origin.x, runBounds.origin.y);
                NSLog(@"Run %ld's Size: %.0f, %.0f", j, runBounds.size.width, runBounds.size.height);
                NSLog(@"X Between: %.0f and %.0f", runBounds.origin.x, runBounds.origin.x+runBounds.size.width);
                NSLog(@"Y Between: %.0f and %.0f", runBounds.origin.y, runBounds.origin.y+runBounds.size.height);
                
                //Check if the tap was on the current glyph run
                if(CGRectContainsPoint(runBounds, point)) {//Tap was on this run
                    NSLog(@"The tap was on run %ld!", j);
                    
                    //Load the attribute information
                    NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run); 
                    
                    //Check for the attribute in this run
                    NSString* wordToLoad = [attributes objectForKey:@"wordToLoad"];
                    if (wordToLoad && ![wordToLoad isEqualToString:@""]) { //Has a word to load attribute
                        
                        //Try to open a wordView for this run's text
                        NSLog(@"Word to load!");
                        
                        //Get string range from glyph run
                        //CFRange stringRangeForRun = CTRunGetStringRange(run);
                        //NSRange stringRange = NSMakeRange(stringRangeForRun.location, stringRangeForRun.length);
                        
                        //Check wordToLoad attribute for an NSString* of the word to load a view for
                        NSString* stringToLoad = [attributes objectForKey:@"wordToLoad"];
                        NSLog(@"%@ was clicked!", stringToLoad);
                        
                        //Notify that a word view needs to be opened
                        [[NSNotificationCenter defaultCenter] postNotificationName:WordViewBeginNotification object:self userInfo:[NSDictionary dictionaryWithObject:stringToLoad forKey:key_WordToLoadDictionaryKey]];
                        
                        return;//Stop looking for the touch (We found it)
                        
                    }//End if{} (Run has wordToLearn font)
                    else{//Attribute not found
                        
                        NSLog(@"Regular word...");
                        
                        //Stop looking for the touch (We found it)
                        
                    }//End else{} (Run has normal font
                    
                }//End if{} (Is tapped run)
                else{//Tap was not on this run
                    
                    NSLog(@"Run not tapped");
                    
                }//End else{} (Not tapped run)
                
                //Update runOriginCursorPosition with the width of this run
                runOriginCursorPosition += runBounds.size.width;
                
            }//End for{} (Each run)
            
        }//End if{} (Is tapped line)
        else{//Line not tapped
            
            NSLog(@"Line not tapped");
            
        }//End else{} (Not tapped line)
        
    }//End for{} (Each line)
    
    //If you get to here, nothing important happened
    [self readPage:nil];
    
}//End tappedStoryText:

- (void) autoplay {
    
    self.pageAutoplayEnabled = YES;
    
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
    [self readPage:self.readStoryButton];
    
}

- (void) pausePlayback {
    
    self.pageAutoplayEnabled = NO;
    [self.videoController.player pause];
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.storyReader stop];
    [self.storyReader setCurrentTime:0.0];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    
}

- (void) resumePlayback {
    
    self.pageAutoplayEnabled = YES;
    [self.videoController.player play];
}

- (void) autoplayEnd {
    
    self.pageAutoplayEnabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryPageAutoplayCompleteNotification object:self];
}

@end
