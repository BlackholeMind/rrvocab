//
//  StoryViewController_iPad.m
//  RRV101
//
//  Created by Brian C. Grant on 1/23/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import "StoryViewController_iPad.h"
#import "StoryTextView.h"
#import "WordView.h"
#import "WordObject.h"
#import "RRVConstants.txt"

#import "VideoPlayerViewController.h"

@implementation StoryViewController_iPad

#pragma mark Synthesizers

//Data
@synthesize pageIsBlank, pageIsTheEnd, pageAutoplayEnabled, lessonNumberForView, pageNumberForView, textWithTags, textWithAttributes;

//Views
@synthesize imageView, titleVideoView, titleReplayButton, videoView, textView, textDrawnView, movieIndicator, movieLoadingLabel, audioIndicator, readStoryButton, replayButton, pageNumberLabel, pageEdgeMarginView, pageContentWrapperView, pageGradientFillImageView, pageSpineImageView, titleLabel, lessonLabel, theEndLabel, theEndButton;

//Controllers & Media
@synthesize videoController, storyReader;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
     NSLog(@"StoryVC_iPad dealloc");
    
    //Remove observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.storyReader.delegate = nil;
    
    //Dismantle Audio Session
    [self.videoController.player pause];
    [self.storyReader stop];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
    
    //Data
    [textWithTags release];
    [textWithAttributes release];
    
    //Views
    [imageView release];
    [titleVideoView release];
    [titleReplayButton release];
    [videoView release];
    [textView release];
    [textDrawnView release];
    [movieIndicator release];
    [movieLoadingLabel release];
    [audioIndicator release];
    [readStoryButton release];
    [replayButton release];
    [pageNumberLabel release];
    [pageEdgeMarginView release];
    [pageContentWrapperView release];
    [pageGradientFillImageView release];
    [pageSpineImageView release];
    [titleLabel release];
    [lessonLabel release];
    [theEndLabel release];
    [theEndButton release];
    
    //Controllers & Media
    [videoController release];
    [storyReader release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.textWithTags = nil;
        self.textWithAttributes = nil;
    
        //Views
        self.imageView = nil;
        self.titleVideoView = nil;
        self.titleReplayButton = nil;
        self.videoView = nil;
        self.textView = nil;
        self.textDrawnView = nil;
        self.movieIndicator = nil;
        self.movieLoadingLabel = nil;
        self.audioIndicator = nil;
        self.readStoryButton = nil;
        self.replayButton = nil;
        self.pageNumberLabel = nil;
        self.pageEdgeMarginView = nil;
        self.pageContentWrapperView = nil;
        self.pageGradientFillImageView = nil;
        self.pageSpineImageView = nil;
        self.titleLabel = nil;
        self.lessonLabel = nil;
        self.theEndLabel = nil;
        self.theEndButton = nil;
    
        //Controllers
        self.videoController = nil;
        self.storyReader = nil;
        
    }
}

#pragma mark Setup

//Custom init method includes text (with Tags), lessonNumber and pageNumber (for audio/video etc)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forTextWithTags:(NSString*)taggedText lessonNumber:(NSInteger)lessonNumber pageNumber:(NSInteger)pageNumber blankPage:(BOOL)blank {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Sync passed values
        self.pageIsBlank = blank;
        self.textWithTags = taggedText;
        self.lessonNumberForView = lessonNumber;
        if (pageNumber < 0) self.pageIsTheEnd = YES; else self.pageIsTheEnd = NO;
        self.pageNumberForView = (int)fabs(pageNumber);
        
        NSLog(@"StoryVC_iPad init: pg#%d", self.pageNumberForView);
    }
    
    return self;
    
}//End initWithNibName: bundle: withMovie: andTextView:

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pageAutoplayEnabled = NO; //Only set to yes by calling [self autoplay];
    
    // IMPORTANT:
    // If pageNumber is 0, displays Title page - expects self.textWithTags to contain non-tagged Title string
    // If pageNumber is negative, displays "The End" page - BUT keep page number accurate for numbering (example: "The End" falls on page 14, pass pageNumber as -14)
    
    NSLog(@"StoryVC_iPad viewDidLoad: pg#%d", self.pageNumberForView);
    
}//End viewDidLoad

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configurePage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Dismantle Audio Session
    [self.videoController.player pause];
    [self.storyReader stop];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
    
    [self setVideoController:nil];
    [self setStoryReader:nil];
    
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    //iPad specific class - All orientations supported
    return YES;
    
}//End shouldAutorotateToInterfaceOrientation:

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
    
    if (self.pageNumberForView == 0) { //Title video
        
        [self.titleVideoView addSubview:self.videoController.view];
        [self.titleVideoView sendSubviewToBack:self.videoController.view];
        
    }
    else { //Content video
        
        [self.videoView addSubview:self.videoController.view];
        [self.videoView sendSubviewToBack:self.videoController.view];
        [self.videoView setBackgroundColor:[UIColor clearColor]];
        
        [self.movieIndicator stopAnimating];
        [self.movieIndicator setHidden:YES];
        [self.movieLoadingLabel setHidden:YES];
    }
    
}//End videoReadyToPlay:


-(void) videoDidFinishPlaying: (NSNotification*)notification {
    
    if (self.pageAutoplayEnabled) {
        
        if (self.pageNumberForView == 0) { //Title page
            [self performSelector:@selector(autoplayEnd) withObject:nil afterDelay:1.0];
        }
        else { //Content page
            if (![self.storyReader isPlaying]) [self performSelector:@selector(readPage:) withObject:self.readStoryButton afterDelay:0.5];
        }
        
    }//End if{} (Autoplay not complete)
    
}//End videoDidFinishPlaying:

#pragma mark StoryTextView

-(void) tappedStoryText: (UITapGestureRecognizer*)tapGesture {//Called when user clicks storyTextView
    NSLog(@"storyTextView tapped!"); if(self.textDrawnView.textCTFrame == NULL || self.textDrawnView.textCTFrame == nil){NSLog(@"***Frame is nil***");}
    
    CGPoint point = [tapGesture locationInView:self.textDrawnView]; NSLog(@"Tap occured: %.0f, %.0f", point.x, point.y);
    point.y -= self.textDrawnView.bounds.size.height; if(point.y < 0){point.y *= -1;} NSLog(@"Converted to: %.0f, %.0f", point.x, point.y);
    
    //Get the lines of the frame in self.storyTextView.CTFrame
    CFArrayRef lines = CTFrameGetLines(self.textDrawnView.textCTFrame); NSLog(@"Got lines in desired CTFrame"); if(!lines){NSLog(@"It is nil...");}
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
                    NSLog(@"The tap was on line %ld!", idx);
                    
                    //Load the attribute information
                    NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
                    
                    //Check for the attribute in this run
                    NSString* wordToLoad = [attributes objectForKey:@"wordToLoad"];
                    if (wordToLoad && ![wordToLoad isEqualToString:@""]) { //Has a word to load attribute
                        
                        //Open a wordView for this run's text
                        NSLog(@"Word to learn!");
                        
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
    
    //If you have reached here, then nothing important has happened
    [self readPage:nil];
    
}//End tappedStoryText:

#pragma mark - Actions -

-(IBAction) readPage:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryPageReadInfoBeginNotification object:self];
    
    [self.textView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.6 alpha:0.4]];
    
    if ([self.storyReader isPlaying])
        [self.storyReader stop];
    
    [self.storyReader setCurrentTime:0.0];
    
    if ([self.storyReader prepareToPlay])
        [self.storyReader play];
    
}//End readPage:

-(IBAction) replay:(id)sender{
    
    self.pageAutoplayEnabled = YES;

    //Seek to start & play
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
    
}//End replay:

- (IBAction) theEndButtonPressed:(id)sender {//Fired when user presses continueButton
    
    NSLog(@"The End Button pressed.");
    
    //Post notification that the story is finished
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryFinishedNotification object:self];
    
}//End theEndButtonPressed:

#pragma mark - Utility -

- (void) configurePage {
    
    //Configure page content
    
    //Determine page orientational graphics
    if ((int)fabs(self.pageNumberForView) % 2) { //Page number is odd - right side, move graphics
        
        //Move page edge margin to right side
        [self.pageEdgeMarginView setFrame:CGRectMake(self.view.frame.size.width - self.pageEdgeMarginView.frame.size.width, 0, self.pageEdgeMarginView.frame.size.width, self.pageEdgeMarginView.frame.size.height)];
        
        //Move content view to flush with margin above
        [self.pageContentWrapperView setFrame:CGRectMake(self.pageEdgeMarginView.frame.origin.x - self.pageContentWrapperView.frame.size.width, 0, self.pageContentWrapperView.frame.size.width, self.pageContentWrapperView.frame.size.height)];
        
        //Move spine image view to origin, flip image (pre-rendered)
        [self.pageSpineImageView setFrame:CGRectMake(0, 0, self.pageSpineImageView.frame.size.width, self.pageSpineImageView.frame.size.height)];
        [self.pageSpineImageView setImage:[UIImage imageNamed:@"BookSpine_leftSideOfPage.png"]];
        
        //Reverse gradient fill direction
        UIImage* newGradientFillImage = [UIImage imageNamed:@"Gradient_whiteToGrayFromLeft_640x4.png"];
        [self.pageGradientFillImageView setImage:newGradientFillImage];
        [self.pageGradientFillImageView setContentMode:UIViewContentModeScaleToFill];
        
        //Flip pageNumberLabel position & alignment
        CGFloat xPositionRightSide = self.pageContentWrapperView.bounds.size.width - self.pageNumberLabel.frame.size.width;
        [self.pageNumberLabel setFrame:CGRectMake(xPositionRightSide, self.pageNumberLabel.frame.origin.y, self.pageNumberLabel.frame.size.width, self.pageNumberLabel.frame.size.height)];
        [self.pageNumberLabel setTextAlignment:NSTextAlignmentRight];
        
        
    }
    else { //Page number is odd - left side, default graphic locations
        
    }//End else{} (pageNumber odd)
    
    //Determine page Content
    if (self.pageIsBlank) { //Blank Page
        
        //Ensure disabled
        [self.pageContentWrapperView setUserInteractionEnabled:NO];
        
    }
    else if (self.pageIsTheEnd) { //pageIsTheEnd - The End Page
        
        //Set & show theEnd views
        [self.theEndLabel setHidden:NO];
        [self.theEndButton setHidden:NO];
        [self.theEndButton setUserInteractionEnabled:YES];
        
    }
    else if (self.pageNumberForView == 0) { // pageNumber is 0 - Title Page
        
        //Set & show title views
        [self.titleLabel setText:self.textWithTags];
        if (self.lessonNumberForView == 0)
            [self.lessonLabel setText:@"Story 101 (Lite)"];
        else
            [self.lessonLabel setText:[NSString stringWithFormat:@"Story %i", self.lessonNumberForView]];
        [self.titleLabel setHidden:NO];
        [self.lessonLabel setHidden:NO];
        [self.titleVideoView setHidden:NO];
        
        //Load title video (.mp4)
        [self configureVideo];
        
    }
    else { //pageNumber is positive - Content Page
        
        //Show content views
        [self.videoView setHidden:NO];
        [self.textView setHidden:NO];
        [self.movieIndicator setHidden:NO];
        [self.movieIndicator startAnimating];
        [self.movieLoadingLabel setHidden:NO];
        [self.audioIndicator setHidden:NO];
        [self.audioIndicator startAnimating];
        [self.pageNumberLabel setHidden:NO];
        
        //Set PageNumber to label
        [self.pageNumberLabel setText:[NSString stringWithFormat:@"%d", self.pageNumberForView]];
        
        //Pass text to textDrawnView
        self.textDrawnView = [[[StoryTextView alloc] initWithFrame:self.textView.bounds andText:self.textWithTags] autorelease];
        [self.textView addSubview:self.textDrawnView];
        [self.textView sendSubviewToBack:self.textDrawnView];
        [self.textDrawnView setNeedsDisplay];
        self.textWithAttributes = (NSAttributedString*)self.textDrawnView.attributedText;
        
        //Load video (.mp4)
        [self configureVideo];
        
        //Load audio (.mp3)
        [self configureAudio];
        
        //Add gesture recognizer
        UITapGestureRecognizer* tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedStoryText:)] autorelease];
        //[tapGesture setDelegate:self];
        [self.textDrawnView addGestureRecognizer:tapGesture];
        
    }//End else{} (Content Page)
    
}//End configurePage

- (void) configureVideo {
    
    NSLog(@"Configuring video for page: %d", self.pageNumberForView);
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Load graphic media for page (.mp4 video, or .png image)
    NSString* movieName;
    CGRect movieBounds;
    
    if (self.pageIsTheEnd || self.pageIsBlank) { //The End or Blank (no video)
        movieName = nil;
        movieBounds = CGRectZero;
    } else if (self.pageNumberForView == 0) { //Title page video
        movieName = [NSString stringWithFormat:@"rrv%dcover", self.lessonNumberForView];
        movieBounds = self.titleVideoView.bounds;
    } else { //Content Page
        movieName = [NSString stringWithFormat:@"rrv%dpg%d", self.lessonNumberForView, self.pageNumberForView];
        movieBounds = self.videoView.bounds;
    }
    
    if (movieName) { //Movie name not nil
        
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
            player.view.frame = movieBounds;
            self.videoController = player;
            [player release];
        
            //Observe player
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReadyToPlay:) name:MyVideoPlayerReadyToPlayNotification object:self.videoController];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying:) name:MyVideoPlayerPlaybackCompleteNotification object:self.videoController];
            
            //NOTE: The controller's view is added in videoReadyToPlay:
        
        }//End if {} (Movie for page exists)
        else if ([fileManager fileExistsAtPath:imagePath]) { //Image file exists (no movie)
        
            NSLog(@"%@.png", movieName);
            self.imageView = [[[UIImageView alloc] initWithFrame:self.videoView.bounds] autorelease];
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
            [self.videoView addSubview:self.imageView];
            [self.videoView sendSubviewToBack:self.imageView];
            
            
            [self.movieIndicator stopAnimating];
            [self.movieIndicator setHidden:YES];
            [self.movieLoadingLabel setHidden:YES];
            [self.titleReplayButton setHidden:YES];
            [self.replayButton setHidden:YES];
        
        }//End else if {} (Image for page exists)
        else { //No movie or image exists
            //Present error to user
        
            UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"A video or image file seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [movieNotFoundAlert show];
            [movieNotFoundAlert release];
            
            [self.movieIndicator stopAnimating];
            [self.movieIndicator setHidden:YES];
            [self.movieLoadingLabel setHidden:YES];
            [self.titleReplayButton setHidden:YES];
            [self.replayButton setHidden:YES];
        
        }//End else {} (No movie or image found)
        
    }//End if{} (Movie name not nil)
    
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
        AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:NULL];
        audioPlayer.delegate = self;
        self.storyReader = audioPlayer;
        [audioPlayer release];
        
        
        [self.audioIndicator stopAnimating];
        [self.audioIndicator setHidden:YES];
        
    }//End if{} (Audio file exists)
    else { //No audio exists
        
        UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"An audio file seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [movieNotFoundAlert show];
        [movieNotFoundAlert release];
        
    }//End else{} (No audio file exists)
    
}//End configureAudio

- (void) autoplay {
    
    self.pageAutoplayEnabled = YES;
    
    if (self.pageNumberForView == 0) { //Title page
        
        //Wait, then end
        [self.videoController.player seekToTime:kCMTimeZero];
        [self.videoController.player play];
        
    }
    else if (self.pageIsTheEnd) { //The End page
        
        //Wait, then end
        [self performSelector:@selector(autoplayEnd) withObject:self afterDelay:1.0];
        
    }
    else if (self.pageIsBlank) { //Blank page
        
        //Wait, then end
        [self performSelector:@selector(autoplayEnd) withObject:self afterDelay:1.0];
        
    }
    else { //Content page
        
        [self.videoController.player seekToTime:kCMTimeZero];
        [self.videoController.player play];
        [self readPage:self.readStoryButton];
        
    }
    
}//End autoplay

- (void) pausePlayback {
    
    [self.videoController.player pause];
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.storyReader stop];
    [self.storyReader setCurrentTime:0.0];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    
}

- (void) resumePlayback {
    
    [self.videoController.player play];
}

- (void) autoplayEnd {
    
    self.pageAutoplayEnabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryPageAutoplayCompleteNotification object:self];
    
}

@end
