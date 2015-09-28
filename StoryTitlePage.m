//
//  StoryTitlePage.m
//  RRV101
//
//  Created by Brian C. Grant on 9/8/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All Right Reserved.
//

#import "StoryTitlePage.h"
#import "VideoPlayerViewController.h"
#import "RRVConstants.txt"

@implementation StoryTitlePage

#pragma mark Synthesizers

//Data
@synthesize lessonNumber, pageNumberForView, pageAutoplayEnabled;

//Views
@synthesize titleLabel, videoView, replayButton;

//Controllers & Media
@synthesize videoController;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc {
    [super dealloc];
    
    //Observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Data
    
    //Views
    [titleLabel release];
    [videoView release];
    [replayButton release];
    
    //Controllers & Media
    [videoController release];
}

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not visible
    
        //Data
    
        //Views
        self.titleLabel = nil;
        self.videoView = nil;
        self.replayButton = nil;
    
        //Controllers & Media
        self.videoController = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lessonNumber:(NSInteger)numberOfLesson {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.lessonNumber = numberOfLesson;
        self.pageNumberForView = 0; //Title page is 0 (first)
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.titleLabel setText:[self titleFromLessonNumber:self.lessonNumber]];
    
    [self configureVideo];
    
}//End viewDidLoad

#pragma mark - IBActions -

- (IBAction) replay:(id)sender {
    
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
    
}

#pragma mark - Callbacks -

#pragma mark VideoPlayerViewController

-(void) videoReadyToPlay: (NSNotification*)notification {
    
    NSLog(@"videoReadyToPlay:");
    
    [self.videoView addSubview:self.videoController.view];
    [self.videoView sendSubviewToBack:self.videoController.view];
    
}//End videoReadyToPlay:


-(void) videoDidFinishPlaying: (NSNotification*)notification {
    
    if (self.pageAutoplayEnabled) [self performSelector:@selector(autoplayEnd) withObject:nil afterDelay:0.0];
    
}//End videoDidFinishPlaying:

#pragma mark - Utility -

- (void) configureVideo {
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Load graphic media for page (.mp4 video, or .png image)
    NSString* movieName = [NSString stringWithFormat:@"rrv%dcover", self.lessonNumber];
    NSString* moviePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"mp4"];
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:movieName ofType:@"png"];
    if ([fileManager fileExistsAtPath:moviePath]) { // Movie file exists
        
        //Load and configure player
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
        UIImageView* imageView = [[[UIImageView alloc] initWithFrame:self.videoView.bounds] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
        [self.videoView addSubview:imageView];
        [self.videoView sendSubviewToBack:imageView];
        
        [self.replayButton setHidden:YES];
        
    }//End else if {} (Image for page exists)
    else { //No movie or image exists
        //Present error to user
        
        [self.replayButton setHidden:YES];
        
        UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"A video or image file seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [movieNotFoundAlert show];
        [movieNotFoundAlert release];
        
        [self.replayButton setHidden:YES];
        [self.titleLabel setTextColor:[UIColor darkGrayColor]];
        
    }//End else {} (No movie or image found)
    
}

- (void) autoplay {
    
    self.pageAutoplayEnabled = YES;
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
    
}

- (void) pausePlayback {
    
    self.pageAutoplayEnabled = NO;
    [self.videoController.player pause];
    
}

- (void) resumePlayback {
    
    self.pageAutoplayEnabled = YES;
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
}

- (void) autoplayEnd {
    
    self.pageAutoplayEnabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:StoryPageAutoplayCompleteNotification object:self];
}

/***
 - Method Name -
 titleForLessonNumber:
 
 - Description -
 This method opens a file named rrv?s.txt, where ? equals the lesson number requested.
 Assumed to be in proper (#Label#Text#Label#Text) format, the .txt file is separated into an array.
 That array is checked for validity - even numbers should be marked-up story content. (i.e. still with tags)
 These even indices of the array are added to a mutable array, which is what is returned.
 
 Thus, the format of the returned array is as follows:
 Index 0: Title for Story
 Index 1: Text for Page 1
 Index 2: Text for Page 2
 Index 3: Text for Page 3
 etc...
 
 - Return -
 Returns an NSString* that contains the title of the story (described above),
 which has been aggregated from the valid (content) text parts from the .txt file.
 ***/
- (NSString*) titleFromLessonNumber:(NSInteger)lessonNumberInt {
    //Get text from file
    NSString* storyFilename = [NSString stringWithFormat:@"rrv%ds", lessonNumberInt];
    NSString* lessonStoryFilePath = [[NSBundle mainBundle] pathForResource:storyFilename ofType:@"txt"];
    NSURL* lessonStoryURL = [NSURL fileURLWithPath:lessonStoryFilePath];
    NSString* lessonTextFromFile = [NSString stringWithContentsOfURL:lessonStoryURL encoding:NSUTF8StringEncoding error:nil];
    
    //Break apart into array of strings
    NSArray* textChunksFromFile = [lessonTextFromFile componentsSeparatedByString:@"#"];
    NSMutableArray* lessonStoryText = [[[NSMutableArray alloc] init] autorelease]; //make mutable array to aggregate story text - starts empty
    NSLog(@"ARRAY LENGTH: %i", [textChunksFromFile count]);
    for (NSInteger i = 0; i < [textChunksFromFile count]; i++) {//for each chunk of text
        NSLog(@"Chunk %i is %@.", i, [textChunksFromFile objectAtIndex:i]);
        if (i == 0 || (i%2)) {//if number is zero or odd
            NSLog(@"%i is ZERO OR ODD, omitted.", i);
            //Index 0 is empty (file starts with separator)
            //ODD indices are labels
        }//End else{} (number is even)
        else{//if number is odd
            NSLog(@"%i is EVEN, trimmed and added.", i);
            //It is story text - trim it and add to lessonStoryText array
            NSString* trimmedChunkOfText = [[textChunksFromFile objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lessonStoryText addObject:trimmedChunkOfText];
        }//End else{} (number is odd)
    }//End for{} (each of chunk of text)
    
    return [lessonStoryText objectAtIndex:0];
}//End textArrayForLesson

@end
