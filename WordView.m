//
//  WordView.m
//  RRV101
//
//  Created by Brian C. Grant on 9/27/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "WordView.h"
#import "WordObject.h"
#import "VideoPlayerViewController.h"
#import "RRVConstants.txt"

@implementation WordView

#pragma mark Synthesizers

@synthesize wordObject, presentedModally, infoAutoplayCycleComplete;
@synthesize wordBar, videoView, videoController, movieIndicator, movieIndicatorLabel;
@synthesize wordAudioPlayer, definitionAudioPlayer, sentenceAudioPlayer;
@synthesize infoMeaningButton, infoUsageButton, infoTextView;
@synthesize levelIndicatorButton, masteryIndicatorButton;

#pragma mark - PUBLIC METHODS -

#pragma mark Constructors


#pragma mark - PRIVATE METHODS -
#pragma mark View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{//Release objects

    //Observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.wordAudioPlayer.delegate = nil;
    self.definitionAudioPlayer.delegate = nil;
    self.sentenceAudioPlayer.delegate = nil;
    
    //Dismantle Audio Session
    [self.videoController.player pause];
    [self stopAllAudioPlayers];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
    
    //Data
    [wordObject release];
    
    //Views
    [wordBar release];
    [videoView release];
    [infoMeaningButton release];
    [infoUsageButton release];
    [infoTextView release];
    [levelIndicatorButton release];
    [masteryIndicatorButton release];
    
    //Controllers & Media
    [videoController release];
    [wordAudioPlayer release];
    [definitionAudioPlayer release];
    [sentenceAudioPlayer release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.wordObject = nil;
        
        //Views
        self.wordBar = nil;
        self.videoView = nil;
        self.infoMeaningButton = nil;
        self.infoUsageButton = nil;
        self.infoTextView = nil;
        self.levelIndicatorButton = nil;
        self.masteryIndicatorButton = nil;
    
        //Controllers & Media
        self.videoController = nil;
        self.wordAudioPlayer = nil;
        self.definitionAudioPlayer = nil;
        self.sentenceAudioPlayer = nil;
        
    }
}

#pragma mark Orientation

/// iOS 6.0+
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}//End supportedInterfaceOrientations

- (BOOL) shouldAutorotate {
    
    return YES;
    
}

///iOS 5.1-

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    // Return YES for supported orientations
    BOOL shouldRotate = NO;
    
    //Detect device
    NSString* detectedDevice = [[UIDevice currentDevice] model];
    NSRange textRange = [[detectedDevice lowercaseString] rangeOfString:@"ipad"];
    if(textRange.location != NSNotFound){ //Device is an iPad
        
        shouldRotate = YES;
        
    }
    else { //Device is an iPhone/iPod
        
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait);
        
    }
    
    return shouldRotate;
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forWordObject:(WordObject*)word modalPresentation:(BOOL)shouldPresentModally {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Receive the word for this view
        self.wordObject = word;
        self.presentedModally = shouldPresentModally;
        
    }
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Begin Audio Session
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
    
    //Pronounce the loaded word
    [self performSelector:@selector(pronounceWordForView:) withObject:nil afterDelay:0.5];
    
    //Set wordBar to word, using this custom wordLabel as the UINavigationBar's titleView property
    [self setWordLabelForTitleBar];
    
    //Load, prepare, and play video for word
    [self configureVideo];
    [self configureAudio];
    
    //Default to definition
    [self.infoMeaningButton setSelected:YES];
    [self.infoUsageButton setSelected:NO];
    [self.infoTextView setText:self.wordObject.definitionString];
    
    NSLog(@"WordView viewDidLoad");
    
}//End viewDidLoad

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.videoController.view.frame = self.videoView.bounds;
    
    [self configureVideo];
    [self configureAudio];
    
}//End viewDidAppear:

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Dismantle Audio Session
    [self.videoController.player pause];
    [self stopAllAudioPlayers];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
}

#pragma mark - Delegates -

#pragma mark AVAudioPlayer

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (player == self.definitionAudioPlayer && flag) { //Definition audio finished playing
        
        //Unhighlight label
        self.infoTextView.backgroundColor = [UIColor clearColor];
        
        //Check infoAutoPlayAdvancement
        if (!self.infoAutoplayCycleComplete) {
            [self performSelector:@selector(infoSelect:) withObject:self.infoUsageButton afterDelay:1.0];
        }
    }
    else if (player == self.sentenceAudioPlayer && flag) { //Sentence finished playing audio
        
        //Unhighlight label
        self.infoTextView.backgroundColor = [UIColor clearColor];
        
        //End Autoplay
        self.infoAutoplayCycleComplete = YES;
        
    }
    else if (player == self.wordAudioPlayer && flag){ //wordAudioPlayer finished
        
        //Autoplay
        self.infoAutoplayCycleComplete = NO;
        [self replay:nil];
        
    }
    
}//End audioPlayerDidFinishPlaying: successfully:

#pragma mark - Callbacks -

#pragma mark VideoPlayerViewController

-(void) videoReadyToPlay: (NSNotification*)notification {
    
    [self.videoView addSubview:self.videoController.view];
    [self.videoView sendSubviewToBack:self.videoController.view];
    [self.videoView setBackgroundColor:[UIColor clearColor]];
    
    [self.movieIndicator stopAnimating];
    [self.movieIndicator setHidden:YES];
    [self.movieIndicatorLabel setHidden:YES];
    
    //[self.videoController.player play];
    
}//End videoReadyToPlay:


-(void) videoDidFinishPlaying: (NSNotification*)notification {
    
    if (!self.infoAutoplayCycleComplete) {
     
        if (!self.infoMeaningButton.isSelected) {
            
            
        }
        [self performSelector:@selector(readInfo:) withObject:nil afterDelay:0.5];
    }
    
}//End videoDidFinishPlaying:

#pragma mark - IBActions -
#pragma mark Word Bar

-(IBAction) closeWordView:(id)sender{//User pressed the closeButton
    
    //Dismantle Audio Session
    [self stopAllAudioPlayers];
    [self setWordAudioPlayer: nil];
    [self setDefinitionAudioPlayer: nil];
    [self setSentenceAudioPlayer: nil];
    NSError* activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
    
    //Notify superview
    [[NSNotificationCenter defaultCenter] postNotificationName:WordViewFinishedNotification object:self]; NSLog(@"WordView posted finished notification.");
    
}//End closeWordView:

-(IBAction) pronounceWordForView:(id)sender{//User pressed a pronunciationButton
    
    //Play the audio file for the word
    if ([self.wordAudioPlayer isPlaying])
        [self.wordAudioPlayer stop];
    
    if ([self.wordAudioPlayer prepareToPlay])
        [self.wordAudioPlayer play];
    
    
}//End pronounceWord:

#pragma mark Info Area

-(IBAction) readInfo:(id)sender{//User has clicked the readInfoButton
    
    //Highlight infoTextView
    self.infoTextView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.6 alpha:0.4];
    
    //Verify which info is selected
    if ([self.infoMeaningButton isSelected] && ![self.infoUsageButton isSelected]) {//Definition is selected
        
        [self stopAllAudioPlayers];
        
        if ([self.definitionAudioPlayer prepareToPlay])
            [self.definitionAudioPlayer play];
        
    }//End if{} (definition is selected)
    else if ([self.infoUsageButton isSelected] && ![self.infoMeaningButton isSelected]) {//Sentence is selected
        
        [self stopAllAudioPlayers];
        
        if ([self.sentenceAudioPlayer prepareToPlay])
            [self.sentenceAudioPlayer play];
        
    }//End else if{} (sentence is selected)
    
}//End readInfo:

-(IBAction) replay:(id)sender{//User has clicked the replayButton
    
    if (self.videoController.player) {
        [self.videoController.player seekToTime:kCMTimeZero];
        [self.videoController.player play];
    }
    
}//End replay:

-(IBAction) infoSelect:(id)sender{//User has changed value of infoControl
    //Change the text of infoTextView
    
    //Set info and indicators
    if (sender == self.infoMeaningButton) {//Definition selected
        //Update buttons
        [self.infoMeaningButton setSelected:YES];
        [self.infoUsageButton setSelected:NO];
        //Change infoTextView's text to the definition
        [self.infoTextView setText:self.wordObject.definitionString];
    }
    else if (sender == self.infoUsageButton){//Usage selected
        //Update buttons
        [self.infoMeaningButton setSelected:NO];
        [self.infoUsageButton setSelected:YES];
        //Change infoTextView's text to the sentence
        [self.infoTextView setText:self.wordObject.sentenceString];
    }
    else {//Something went wrong
        [self.infoMeaningButton setHighlighted:NO];
        [self.infoUsageButton setHighlighted:NO];
        [self.infoTextView setText:@"\ue252 Oops! Something went wrong..."];
    }
    
    [self readInfo:nil];
    
}//End infoSelect:

#pragma mark Indicators

-(IBAction) levelDetail:(id)sender{//User has clicked the levelIndicatorButton
    
    //Alert view for now...
    UIAlertView* levelDetailAlert = [[UIAlertView alloc] initWithTitle:@"Word Level" message:@"This an icon showing what RRVocab Level this word belongs to." delegate:self cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
    [levelDetailAlert show];
    [levelDetailAlert release];
}//End levelDetail:

-(IBAction) masteryDetail:(id)sender{//User has clicked the masteryIndicatorButton
    
    //Alert view for now...
    UIAlertView* masteryDetailAlert = [[UIAlertView alloc] initWithTitle:@"Word Mastery" message:@"This an icon showing the user's mastery rating - out of five stars." delegate:self cancelButtonTitle:@"Cool" otherButtonTitles:nil];
    [masteryDetailAlert show];
    [masteryDetailAlert release];
    
}//End masteryDetail:

#pragma mark - Utility -

-(void) setWordLabelForTitleBar {
    //Set custom label to UINavigationBar's titleView property
    UILabel* wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    wordLabel.backgroundColor = [UIColor clearColor];
    wordLabel.font = [UIFont fontWithName:@"Georgia" size:36.0];
    wordLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    wordLabel.textAlignment = UITextAlignmentCenter;
    wordLabel.textColor =[UIColor whiteColor];
    wordLabel.text = self.wordObject.wordString;
    self.wordBar.topItem.titleView = wordLabel;
    [wordLabel release];
    NSLog(@"WordView wordLabel set to UINavigationBar");
}//End setWordLabelForTitleBar

-(void) configureVideo { //Load and fit video into videoView
    NSLog(@"Configuring Visual Media...");
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Obtain video filepath
    NSString* moviePath = [[NSBundle mainBundle] pathForResource:self.wordObject.wordString ofType:@"mp4"];
    if ([fileManager fileExistsAtPath:moviePath]) { // Movie file exists
        
        NSLog(@"Video exists, loading...");
        
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
    else { //No movie exists
        //Present error to user
        
        UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"A video or image file seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [movieNotFoundAlert show];
        [movieNotFoundAlert release];
        
    }//End else {} (No movie found)
    NSLog(@"Media Configured.");
}//End configureVideo:

-(void) configureAudio {//Load audio files into their players
    NSLog(@"Configuring Audio...");
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileLoadError = NO;
    
    //Word
    NSString* audioFilePath = [[NSBundle mainBundle] pathForResource:self.wordObject.wordString ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:audioFilePath]) {
        
        self.wordAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL] autorelease];
        self.wordAudioPlayer.delegate = self;
        self.wordAudioPlayer.numberOfLoops = 0;
        
    }
    else fileLoadError = YES;
    
    //Definition
    audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_definition", self.wordObject.wordString] ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:audioFilePath]) {
        
        self.definitionAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL] autorelease];
        self.definitionAudioPlayer.delegate = self;
        self.definitionAudioPlayer.numberOfLoops = 0;
        
    }
    else fileLoadError = YES;
    
    //Sentence
    audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_sentence", self.wordObject.wordString] ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:audioFilePath]) {
        
        self.sentenceAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL] autorelease];
        self.sentenceAudioPlayer.delegate = self;
        self.sentenceAudioPlayer.numberOfLoops = 0;
        
    }
    else fileLoadError = YES;
    
    //Error
    if (fileLoadError) {
        
        UIAlertView* movieNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"File Missing" message:@"An audio file for this word seems to be missing. Reinstallation should replace it." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [movieNotFoundAlert show];
        [movieNotFoundAlert release];
        
    }
    
    NSLog(@"Audio Configured.");
}//End configureAudio

-(void) stopAllAudioPlayers {
    
    [self.wordAudioPlayer stop];
    [self.definitionAudioPlayer stop];
    [self.sentenceAudioPlayer stop];
}

@end
