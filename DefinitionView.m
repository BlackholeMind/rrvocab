//
//  DefinitionView.m
//  RRV101
//
//  Created by Christy Keck on 10/2/12.
//
//

#import "DefinitionView.h"
#import "WordObject.h"
#import "RRVConstants.txt"

@implementation DefinitionView

#pragma mark Synthesizers

@synthesize wordObject;
@synthesize wordBar, textView, doneButton;
@synthesize wordAudioPlayer, definitionAudioPlayer;

#pragma mark - PUBLIC METHODS -

#pragma mark Constructors


#pragma mark - PRIVATE METHODS -
#pragma mark View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{//Release objects
    
    //Observations
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.wordAudioPlayer = nil;
    self.definitionAudioPlayer = nil;
    
    //Dismantle Audio Session
    [self stopAllAudioPlayers];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
    
    //Data
    [wordObject release];
    
    //Views
    [wordBar release];
    [textView release];
    [doneButton release];
    
    //Controllers & Media
    [wordAudioPlayer release];
    [definitionAudioPlayer release];
    
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
        self.textView = nil;
        self.doneButton = nil;
    
        //Controllers & Media
        self.wordAudioPlayer = nil;
        self.definitionAudioPlayer = nil;
        
    }
}

#pragma mark Orientation

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forWordObject:(WordObject*)word {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //Receive the word for this view
        self.wordObject = word;
        
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
    
    //Load audio for word
    [self configureAudio];
    
    //Text
    [self.textView setText:self.wordObject.definitionString];
    
    NSLog(@"WordView viewDidLoad");
    
}//End viewDidLoad

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureAudio];
    
}//End viewDidAppear:

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Dismantle Audio Session
    [self stopAllAudioPlayers];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&activationError];
}

#pragma mark - Delegates -

#pragma mark AVAudioPlayer

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (player == self.definitionAudioPlayer && flag) { //Definition audio finished playing
        
        //Unhighlight label
        self.textView.backgroundColor = [UIColor clearColor];
        
    }
    else if (player == self.wordAudioPlayer && flag){ //wordAudioPlayer finished
        
    }
    
}//End audioPlayerDidFinishPlaying: successfully:

#pragma mark - IBActions -
#pragma mark Word Bar

-(IBAction) closeWordView:(id)sender{//User pressed the closeButton
    
    //Dismantle Audio Session
    [self stopAllAudioPlayers];
    
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
    self.textView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.6 alpha:0.4];
        
    [self stopAllAudioPlayers];
        
    if ([self.definitionAudioPlayer prepareToPlay])
        [self.definitionAudioPlayer play];
    
}//End readInfo:

#pragma mark - Utility -

-(void) setWordLabelForTitleBar {
    
    //Set custom label to UINavigationBar's titleView property
    UILabel* wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    wordLabel.backgroundColor = [UIColor clearColor];
    wordLabel.font = [UIFont fontWithName:@"Georgia" size:36.0];
    wordLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    wordLabel.textAlignment = UITextAlignmentCenter;
    wordLabel.textColor = [UIColor whiteColor];
    wordLabel.text = self.wordObject.wordString;
    self.wordBar.topItem.titleView = wordLabel;
    [wordLabel release];
    
    NSLog(@"WordView wordLabel set to UINavigationBar");
}//End setWordLabelForTitleBar

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
    
}

@end
