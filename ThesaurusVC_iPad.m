//
//  ThesaurusVC_iPad.m
//  RRV101
//
//  Created by Brian C. Grant on 6/22/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "ThesaurusVC_iPad.h"
#import "WordObject.h"
#import "WordListObject.h"
#import "VideoPlayerViewController.h"
#import "RRVConstants.txt"

@implementation ThesaurusVC_iPad

#pragma mark Synthesizers

//Data
@synthesize wordObject, infoType, infoAutoplayCycleComplete;
    //TableView Data
@synthesize thesaurusList, thesaurusSections, sectionA, sectionB, sectionC, sectionD, sectionE, sectionF, sectionG, sectionH, sectionI, sectionJ, sectionK;
@synthesize sectionL, sectionM, sectionN, sectionO, sectionP, sectionQ, sectionR, sectionS, sectionT, sectionU, sectionV, sectionW, sectionX, sectionY, sectionZ;

//Views
@synthesize dictionaryBGImageView, wordTableView;
    //Word Area View
@synthesize doneButton, wordAreaView, pronunciationButton, wordLabel, wordMediaAreaView, wordMediaActivityLabel, wordMediaActivityIndicator, replayButton;
@synthesize infoAreaView, readInfoButton, infoLabel, infoTextView, infoToggleButton, masteryIndicatorButton, levelIndicatorButton;

//Controllers
@synthesize videoController, wordAudioPlayer, definitionAudioPlayer, sentenceAudioPlayer;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

-(void) dealloc {
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegations
    self.wordTableView.delegate = nil;
    self.wordTableView.dataSource = nil;
    self.wordAudioPlayer.delegate = nil;
    self.definitionAudioPlayer.delegate = nil;
    self.sentenceAudioPlayer.delegate = nil;
    
    //Data
    [wordObject release];
        //TableView Data
    [thesaurusList release];
    [thesaurusSections release];
    [sectionA release];
    [sectionB release];
    [sectionC release];
    [sectionD release];
    [sectionE release];
    [sectionF release];
    [sectionG release];
    [sectionH release];
    [sectionI release];
    [sectionJ release];
    [sectionK release];
    [sectionL release];
    [sectionM release];
    [sectionN release];
    [sectionO release];
    [sectionP release];
    [sectionQ release];
    [sectionR release];
    [sectionS release];
    [sectionT release];
    [sectionU release];
    [sectionV release];
    [sectionW release];
    [sectionX release];
    [sectionY release];
    [sectionZ release];
    
    //Views
    [doneButton release];
    [dictionaryBGImageView release];
    [wordTableView release];
    [wordAreaView release];
    [pronunciationButton release];
    [wordLabel release];
    [wordMediaAreaView release];
    [wordMediaActivityIndicator release];
    [wordMediaActivityLabel release];
    [replayButton release];
    [infoAreaView release];
    [readInfoButton release];
    [infoLabel release];
    [infoTextView release];
    [infoToggleButton release];
    [masteryIndicatorButton release];
    [levelIndicatorButton release];
    
    //Controllers & Media
    //[wordViewController release];
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
            //TableView Data
        self.thesaurusList = nil;
        self.thesaurusSections = nil;
        self.sectionA = nil;
        self.sectionB = nil;
        self.sectionC = nil;
        self.sectionD = nil;
        self.sectionE = nil;
        self.sectionF = nil;
        self.sectionG = nil;
        self.sectionH = nil;
        self.sectionI = nil;
        self.sectionJ = nil;
        self.sectionK = nil;
        self.sectionL = nil;
        self.sectionM = nil;
        self.sectionN = nil;
        self.sectionO = nil;
        self.sectionP = nil;
        self.sectionQ = nil;
        self.sectionR = nil;
        self.sectionS = nil;
        self.sectionT = nil;
        self.sectionU = nil;
        self.sectionV = nil;
        self.sectionW = nil;
        self.sectionX = nil;
        self.sectionY = nil;
        self.sectionZ = nil;
    
        //Views
        self.doneButton = nil;
        self.dictionaryBGImageView = nil;
        self.wordTableView = nil;
        self.wordAreaView = nil;
        self.pronunciationButton = nil;
        self.wordLabel = nil;
        self.wordMediaAreaView = nil;
        self.wordMediaActivityIndicator = nil;
        self.wordMediaActivityLabel = nil;
        self.replayButton = nil;
        self.infoAreaView = nil;
        self.readInfoButton = nil;
        self.infoLabel = nil;
        self.infoTextView = nil;
        self.infoToggleButton = nil;
        self.masteryIndicatorButton = nil;
        self.levelIndicatorButton = nil;
    
        //Controllers & Media
        self.videoController = nil;
        self.wordAudioPlayer = nil;
        self.definitionAudioPlayer = nil;
        self.sentenceAudioPlayer = nil;
        
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        
        [self.wordTableView setDelegate:self];
        [self.wordTableView setDataSource:self];
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Load thesaurus using a verified WordListObject
    [self loadAndVerifyWordList];
    [self separateWordListToSections];
    
    [self.wordTableView reloadData];
    
    self.infoType = kInfoTypeDefinition;
    [self updateWordAreaForWordObject:[self.thesaurusList randomWordObject]];
    [self configureVideo];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self stopAllAudioPlayers];
    
}

#pragma mark - Data Sources -

#pragma mark UITableView

#pragma mark required

//Cell configuration - return : UITableViewCell*
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NOTE: This function will be called for each cell as the table is scrolled, and therefore will scroll through the array simultaneously and automatically.
    
    // Modify BG and font  of sectionIndices
    for(UIView *view in [tableView subviews]) {
        
        if([[[view class] description] isEqualToString:@"UITableViewIndex"]) {
            
            //Set custom index properties
            //[view setBackgroundColor:[UIColor blackColor]];
            [view setAlpha:0.8];
            //[view setFont:[UIFont fontWithName:@"Geneva" size:14]];
            
        }//End if{} (view is UITableViewIndex)
    }//End for{} (each view in the subviews of the tableView)
    
    //// CELL ALLOCATION
    
    //Create a cell indentifier
    static NSString* cellIdentifier = @"cellIdentifier";
    
    //Reuse cells to conserve memory...
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){//...unless more cells are needed.
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier]autorelease];
    }//End if{} (no reuseable cells)
    
    //// CELL DRAWING
    
    //Text settings
    [[cell textLabel] setFont:[UIFont fontWithName:@"Georgia" size:20.0]];
    [[cell detailTextLabel] setFont:[UIFont fontWithName:@"Georgia" size:14.0]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    //Determine the corresponding letter array from section #
    switch ([indexPath section]) {
            //Set the cell.*.text label with the corresponding WordObject from row #
        case 0:
            if (sectionA != nil) {
                cell.textLabel.text = [[sectionA objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionA objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 1:
            if (sectionB != nil) {
                cell.textLabel.text = [[sectionB objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionB objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 2:
            if (sectionC != nil) {
                cell.textLabel.text = [[sectionC objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionC objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 3:
            if (sectionD != nil) {
                cell.textLabel.text = [[sectionD objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionD objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 4:
            if (sectionE != nil) {
                cell.textLabel.text = [[sectionE objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionE objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 5:
            if (sectionF != nil) {
                cell.textLabel.text = [[sectionF objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionF objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 6:
            if (sectionG != nil) {
                cell.textLabel.text = [[sectionG objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionG objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 7:
            if (sectionH != nil) {
                cell.textLabel.text = [[sectionH objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionH objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 8:
            if (sectionI != nil) {
                cell.textLabel.text = [[sectionI objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionI objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 9:
            if (sectionJ != nil) {
                cell.textLabel.text = [[sectionJ objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionJ objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 10:
            if (sectionK != nil) {
                cell.textLabel.text = [[sectionK objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionK objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 11:
            if (sectionL != nil) {
                cell.textLabel.text = [[sectionL objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionL objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 12:
            if (sectionM != nil) {
                cell.textLabel.text = [[sectionM objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionM objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 13:
            if (sectionN != nil) {
                cell.textLabel.text = [[sectionN objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionN objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 14:
            if (sectionO != nil) {
                cell.textLabel.text = [[sectionO objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionO objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 15:
            if (sectionP != nil) {
                cell.textLabel.text = [[sectionP objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionP objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 16:
            if (sectionQ != nil) {
                cell.textLabel.text = [[sectionQ objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionQ objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 17:
            if (sectionR != nil) {
                cell.textLabel.text = [[sectionR objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionR objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 18:
            if (sectionS != nil) {
                cell.textLabel.text = [[sectionS objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionS objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 19:
            if (sectionT != nil) {
                cell.textLabel.text = [[sectionT objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionT objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 20:
            if (sectionU != nil) {
                cell.textLabel.text = [[sectionU objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionU objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 21:
            if (sectionV != nil) {
                cell.textLabel.text = [[sectionV objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionV objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 22:
            if (sectionW != nil) {
                cell.textLabel.text = [[sectionW objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionW objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 23:
            if (sectionX != nil) {
                cell.textLabel.text = [[sectionX objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionX objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 24:
            if (sectionY != nil) {
                cell.textLabel.text = [[sectionY objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionY objectAtIndex:[indexPath row]] definitionString];
            }
            break;
        case 25:
            if (sectionZ != nil) {
                cell.textLabel.text = [[sectionZ objectAtIndex:[indexPath row]] wordString];
                cell.detailTextLabel.text = [[sectionZ objectAtIndex:[indexPath row]] definitionString];
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}//End 

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //Return the number of rows that should be in the passed section (fired for every section in tableView)
    
    NSInteger rowsForSection = 0;
    switch (section) {
        case 0:
            rowsForSection = [self.sectionA count];
            break;
        case 1:
            rowsForSection = [self.sectionB count];
            break;
        case 2:
            rowsForSection = [self.sectionC count];
            break;
        case 3:
            rowsForSection = [self.sectionD count];
            break;
        case 4:
            rowsForSection = [self.sectionE count];
            break;
        case 5:
            rowsForSection = [self.sectionF count];
            break;
        case 6:
            rowsForSection = [self.sectionG count];
            break;
        case 7:
            rowsForSection = [self.sectionH count];
            break;
        case 8:
            rowsForSection = [self.sectionI count];
            break;
        case 9:
            rowsForSection = [self.sectionJ count];
            break;
        case 10:
            rowsForSection = [self.sectionK count];
            break;
        case 11:
            rowsForSection = [self.sectionL count];
            break;
        case 12:
            rowsForSection = [self.sectionM count];
            break;
        case 13:
            rowsForSection = [self.sectionN count];
            break;
        case 14:
            rowsForSection = [self.sectionO count];
            break;
        case 15:
            rowsForSection = [self.sectionP count];
            break;
        case 16:
            rowsForSection = [self.sectionQ count];
            break;
        case 17:
            rowsForSection = [self.sectionR count];
            break;
        case 18:
            rowsForSection = [self.sectionS count];
            break;
        case 19:
            rowsForSection = [self.sectionT count];
            break;
        case 20:
            rowsForSection = [self.sectionU count];
            break;
        case 21:
            rowsForSection = [self.sectionV count];
            break;
        case 22:
            rowsForSection = [self.sectionW count];
            break;
        case 23:
            rowsForSection = [self.sectionX count];
            break;
        case 24:
            rowsForSection = [self.sectionY count];
            break;
        case 25:
            rowsForSection = [self.sectionZ count];
            break;
            
            
        default:
            break;
    }//End switch{} (section#)
    
    return rowsForSection;
}//End tableView: numberOfRowsInSection:

#pragma mark optional

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //Return # of sections desired in tableView
    return 26;
}//End numberOfSectionsInTableView:

//Sets the title (in the header) for the section at [section 
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    //ASCII capitals start at 65 and increment by one (as does sectionNumber).
    // To assign A-Z to any one sectionNumber (starts at 0) simply add 65 to the sectionNumber and assign to a char
    char letterForSectionTitle = section + 65;
    
    //Return the character as a string
    return [NSString stringWithFormat:@"%c", letterForSectionTitle];
}//End tableView: titleForHeaderInSection:
*/

//Sets up the section index titles for this table - the alphabet
-(NSArray *)sectionIndexTitlesForTableView: (UITableView *)tableView {
    
    NSArray* titles = [[[NSArray alloc]initWithObjects: @"{search}",
                        @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                        @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", 
                        nil] autorelease];
    
    return titles;
    
}//End sectionIndexTitlesForTableView:


#pragma mark - Delegates -

#pragma mark AVAudioPlayer

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (player != self.wordAudioPlayer && flag) { //An audio player that is not the wordAudioPlayer (assumed to be an infoType audio player)
        
        //Unhighlight label
        if (self.infoLabel.highlighted == YES) {
        
            [self.infoLabel setHighlighted:NO];
            self.infoTextView.backgroundColor = self.infoLabel.backgroundColor = [UIColor clearColor];
        }
    
        //Check infoAutoPlayAdvancement
        if (!self.infoAutoplayCycleComplete) [self performSelector:@selector(infoAutoplayAdvance) withObject:nil afterDelay:1.0];
    }
    else { //wordAudioPlayer finished
    
        //Autoplay
        self.infoAutoplayCycleComplete = NO;
        self.infoType = kInfoTypeDefinition;
        [self configureText];
        [self.videoController.player play];
        
    }
    
}//End audioPlayerDidFinishPlaying: successfully:

#pragma mark UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    
    //Return desired height of a cell from indexPath
    return 50;
    
}//End tableView: heightForRowAtIndexPath:

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //User clicked a cell in the tableView
    
    [self stopAllAudioPlayers];
    
    //Initialize with word area view for the clicked cell's word
    WordObject* wordObjectSelected = [[[WordObject alloc] init] autorelease];
    
    //Determine the section & grab the corresponding word object
    switch ([indexPath section]) {
        case 0:
            if (sectionA != nil) wordObjectSelected = [sectionA objectAtIndex:[indexPath row]];
            break;
        case 1:
            if (sectionB != nil) wordObjectSelected = [sectionB objectAtIndex:[indexPath row]];
            break;
        case 2:
            if (sectionC != nil) wordObjectSelected = [sectionC objectAtIndex:[indexPath row]];
            break;
        case 3:
            if (sectionD != nil) wordObjectSelected = [sectionD objectAtIndex:[indexPath row]];
            break;
        case 4:
            if (sectionE != nil) wordObjectSelected = [sectionE objectAtIndex:[indexPath row]];
            break;
        case 5:
            if (sectionF != nil) wordObjectSelected = [sectionF objectAtIndex:[indexPath row]];
            break;
        case 6:
            if (sectionG != nil) wordObjectSelected = [sectionG objectAtIndex:[indexPath row]];
            break;
        case 7:
            if (sectionH != nil) wordObjectSelected = [sectionH objectAtIndex:[indexPath row]];
            break;
        case 8:
            if (sectionI != nil) wordObjectSelected = [sectionI objectAtIndex:[indexPath row]];
            break;
        case 9:
            if (sectionJ != nil) wordObjectSelected = [sectionJ objectAtIndex:[indexPath row]];
            break;
        case 10:
            if (sectionK != nil) wordObjectSelected = [sectionK objectAtIndex:[indexPath row]];
            break;
        case 11:
            if (sectionL != nil) wordObjectSelected = [sectionL objectAtIndex:[indexPath row]];
            break;
        case 12:
            if (sectionM != nil) wordObjectSelected = [sectionM objectAtIndex:[indexPath row]];
            break;
        case 13:
            if (sectionN != nil) wordObjectSelected = [sectionN objectAtIndex:[indexPath row]];
            break;
        case 14:
            if (sectionO != nil) wordObjectSelected = [sectionO objectAtIndex:[indexPath row]];
            break;
        case 15:
            if (sectionP != nil) wordObjectSelected = [sectionP objectAtIndex:[indexPath row]];
            break;
        case 16:
            if (sectionQ != nil) wordObjectSelected = [sectionQ objectAtIndex:[indexPath row]];
            break;
        case 17:
            if (sectionR != nil) wordObjectSelected = [sectionR objectAtIndex:[indexPath row]];
            break;
        case 18:
            if (sectionS != nil) wordObjectSelected = [sectionS objectAtIndex:[indexPath row]];
            break;
        case 19:
            if (sectionT != nil) wordObjectSelected = [sectionT objectAtIndex:[indexPath row]];
            break;
        case 20:
            if (sectionU != nil) wordObjectSelected = [sectionU objectAtIndex:[indexPath row]];
            break;
        case 21:
            if (sectionV != nil) wordObjectSelected = [sectionV objectAtIndex:[indexPath row]];
            break;
        case 22:
            if (sectionW != nil) wordObjectSelected = [sectionW objectAtIndex:[indexPath row]];
            break;
        case 23:
            if (sectionX != nil) wordObjectSelected = [sectionX objectAtIndex:[indexPath row]];
            break;
        case 24:
            if (sectionY != nil) wordObjectSelected = [sectionY objectAtIndex:[indexPath row]];
            break;
        case 25:
            if (sectionZ != nil) wordObjectSelected = [sectionZ objectAtIndex:[indexPath row]];
            break;
            
        default:
            break;
    }
    
    //Display selected wordObject
    [self updateWordAreaForWordObject:wordObjectSelected];
    
    //Deselect the cell
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
    
}//End tableView:

#pragma mark - Callbacks -

#pragma mark VideoPlayerViewController

-(void) videoReadyToPlay: (NSNotification*)notification {
    
    [self.wordMediaAreaView addSubview:self.videoController.view];
    [self.wordMediaAreaView sendSubviewToBack:self.videoController.view];
    [self.wordMediaAreaView setBackgroundColor:[UIColor clearColor]];
    
    [self.wordMediaActivityIndicator stopAnimating];
    [self.wordMediaActivityIndicator setHidden:YES];
    [self.wordMediaActivityLabel setHidden:YES];
    
}//End videoReadyToPlay:


-(void) videoDidFinishPlaying: (NSNotification*)notification {
    
    [self performSelector:@selector(readInfo:) withObject:self.readInfoButton afterDelay:0.5];
    
}//End videoDidFinishPlaying:

#pragma mark - IBActions -

-(IBAction) doneWithThesaurus:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ThesaurusQuitNotification object:self];
    
}//End doneWithThesaurus:

-(IBAction) pronounceWordForView:(id)sender{//User pressed a pronunciationButton
    
    [self stopAllAudioPlayers];
    
    [self.wordAudioPlayer play];
    
}//End pronounceWord:

-(IBAction) readInfo:(id)sender{//User has clicked the readInfoButton
    
    [self stopAllAudioPlayers];
    
    //Highlight label for info being read (unhighlight upon audio completion)
    if (self.infoLabel.highlighted == NO) {
            
        [self.infoLabel setHighlighted:YES];
        self.infoTextView.backgroundColor = self.infoLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0];
        
    }
    

    //Determine audio to play
        //IMPORTANT: readInfo is part of the infoAutoplay cycle, the last kInfoType case should set this flag to NO (to cease infoAutoplayCycle)
    switch (self.infoType) {
            
        case kInfoTypeDefinition: //Definition is showing
            
            [self.definitionAudioPlayer play];
            break;
            
        case kInfoTypeSentence: //Sentence is showing
            
            self.infoAutoplayCycleComplete = YES; // <--- IMPORTANT
            
            [self.sentenceAudioPlayer play];
            break;
            
        default:
            break;
    }
    
}//End readInfo:

-(IBAction) replay:(id)sender{//User has clicked the replayButton
    
    [self.videoController.player seekToTime:kCMTimeZero];
    [self.videoController.player play];
    
}//End replay:

-(IBAction) infoToggle:(id)sender{//User has changed value of infoControl
    
    [self stopAllAudioPlayers];
    
    //Cycle the infoType
    [self cycleInfoType];
        
    //Update info views
    [self configureText];
    
    //Read info
    [self performSelector:@selector(readInfo:) withObject:self.readInfoButton afterDelay:0.5];
    
}//End infoSelect:

-(IBAction) levelDetail:(id)sender{//User has clicked the levelIndicatorButton
    
    //Alert view for now...
    UIAlertView* levelDetailAlert = [[UIAlertView alloc] initWithTitle:@"Word Level" message:@"This is an icon showing what RRVocab Level this word belongs to." delegate:self cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
    [levelDetailAlert show];
    [levelDetailAlert release];
    
}//End levelDetail:

-(IBAction) masteryDetail:(id)sender{//User has clicked the masteryIndicatorButton
    
    //Alert view for now...
    UIAlertView* masteryDetailAlert = [[UIAlertView alloc] initWithTitle:@"Word Mastery" message:@"This is an icon showing the user's mastery rating - out of five stars." delegate:self cancelButtonTitle:@"Cool" otherButtonTitles:nil];
    [masteryDetailAlert show];
    [masteryDetailAlert release];
    
    
}//End masteryDetail:

#pragma mark - Utility -

#pragma mark Word List

-(void) loadAndVerifyWordList {
    
    //Load a WordListObject by passing an array of verified (purchased/unlocked) lesson numbers (NSNumber* intValues)
    self.thesaurusList = [WordListObject listForLessons:[self verifiedLessonsList]];
    
}//End loadAndVerifyWordList

- (NSArray*)verifiedLessonsList {
    //Returns an array of verified lesson numbers (NSNumber integers)
    
    //Buildable array of lesson numbers to display - will be synced to self.lessonsTableCellMap
    NSMutableArray* lessonsList = [[[NSMutableArray alloc] init] autorelease];
    
    //Load verified lessons dictionary from locally stored reference
    // *** RRVLocalAuthority ***
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RRVLocalAuthority.plist"];
    
    //THIS FILE SHOULD BE GARUNTEED TO EXIST.
    //App delegate: if not found at path, it is copied from mainBundle to Documents.
    if([fileManager fileExistsAtPath:plistPath]) { //File found.
        
        NSDictionary* verifiedLessonsDict = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"CompletedLessons"] retain]; //Ensure retain
        
        //SPECIAL CASE - Lite Story
        if ( ![[verifiedLessonsDict objectForKey:@"101"] boolValue] && [[verifiedLessonsDict objectForKey:@"0"] boolValue] ) { //If Story 101 NOT complete && Story 0 (demo) IS complete
            
            //Add Story 0 (demo)
            [lessonsList addObject:[NSNumber numberWithInt:0]];
            
        }
        
        //Lesson numbers increment by 100, from 100 - 900
        for (NSInteger level = 100; level <= 900; level += 100) { //Each level
            
            //Lesson subnumber (added to level) 1-20
            for (NSInteger lessonSubnumber = 1; lessonSubnumber <= 20; lessonSubnumber++) { //Each lesson in level
                
                //Assemble correct lesson number
                NSInteger lessonNumberProper = level+lessonSubnumber;
                
                //Check BOOL value for lesson, key = lesson number as NSString
                BOOL lessonVerified = [[verifiedLessonsDict objectForKey:[NSString stringWithFormat:@"%d", lessonNumberProper]] boolValue];
                if (lessonVerified) { //BOOL value from dictionary is YES
                    NSLog(@"Lesson %d purchased.", lessonNumberProper);
                    //Lesson is verified
                    
                    //Add lesson number to verified array - must wrap in NSNumber
                    [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                    
                }//End if{} (lesson purchased)
                else { //BOOL value for lesson is NO, invalid, or does not exist
                    NSLog(@"Lesson %d NOT PURCHASED.", lessonNumberProper);
                    //Lesson not verified, omit from list
                    
                }//End else{} (lesson not purchased)
            }//End for{} (each lesson in level)
        }//End for{} (each level)
        
        //Release retained dictionary
        [verifiedLessonsDict release];
        
    }//End if{} (RRVLocalAuthority.plist exists)
    else {
        
        NSLog(@"RRVLocalAuthority not found!");
        
    }
    
    //Return verified lesson numbers
    return [NSArray arrayWithArray:lessonsList];
    
}//End verifiedLessonsList

-(void) separateWordListToSections {
    //// SEPARATE INTO LETTER-SPECIFIC ARRAYS
    
    //Declare mutable aggregators
    NSMutableArray* arrayForA = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForB = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForC = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForD = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForE = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForF = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForG = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForH = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForI = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForJ = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForK = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForL = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForM = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForN = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForO = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForP = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForQ = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForR = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForS = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForT = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForU = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForV = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForW = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForX = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForY = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray* arrayForZ = [[NSMutableArray alloc] initWithObjects:nil];
    
    //Traverse sortedDictionaryArray and add to appropriate section based on Object(i), Object(0), Character(0) - {i.e. by first character of array item holding the word}
    for(NSInteger wordObjectIndex = 0; wordObjectIndex < [self.thesaurusList.wordObjects count]; wordObjectIndex++)
    {
        WordObject* wordObjectToSort = [self.thesaurusList.wordObjects objectAtIndex:wordObjectIndex];
        char firstLetter = [wordObjectToSort.wordString characterAtIndex:0]; NSLog(@"Word: %@, Letter: %c", wordObjectToSort.wordString, firstLetter);
        switch (firstLetter) {
            case 'a':
                [arrayForA addObject:wordObjectToSort];
                break;
            case 'b':
                [arrayForB addObject:wordObjectToSort];
                break;
            case 'c':
                [arrayForC addObject:wordObjectToSort];
                break;
            case 'd':
                [arrayForD addObject:wordObjectToSort];
                break;
            case 'e':
                [arrayForE addObject:wordObjectToSort];
                break;
            case 'f':
                [arrayForF addObject:wordObjectToSort];
                break;
            case 'g':
                [arrayForG addObject:wordObjectToSort];
                break;
            case 'h':
                [arrayForH addObject:wordObjectToSort];
                break;
            case 'i':
                [arrayForI addObject:wordObjectToSort];
                break;
            case 'j':
                [arrayForJ addObject:wordObjectToSort];
                break;
            case 'k':
                [arrayForK addObject:wordObjectToSort];
                break;
            case 'l':
                [arrayForL addObject:wordObjectToSort];
                break;
            case 'm':
                [arrayForM addObject:wordObjectToSort];
                break;
            case 'n':
                [arrayForN addObject:wordObjectToSort];
                break;
            case 'o':
                [arrayForO addObject:wordObjectToSort];
                break;
            case 'p':
                [arrayForP addObject:wordObjectToSort];
                break;
            case 'q':
                [arrayForQ addObject:wordObjectToSort];
                break;
            case 'r':
                [arrayForR addObject:wordObjectToSort];
                break;
            case 's':
                [arrayForS addObject:wordObjectToSort];
                break;
            case 't':
                [arrayForT addObject:wordObjectToSort];
                break;
            case 'u':
                [arrayForU addObject:wordObjectToSort];
                break;
            case 'v':
                [arrayForV addObject:wordObjectToSort];
                break;
            case 'w':
                [arrayForW addObject:wordObjectToSort];
                break;
            case 'x':
                [arrayForX addObject:wordObjectToSort];
                break;
            case 'y':
                [arrayForY addObject:wordObjectToSort];
                break;
            case 'z':
                [arrayForZ addObject:wordObjectToSort];
                break;
                
            default:
                break;
        }
    }
    
    //Set temp mutables to global sections for table construction {Note: synthesizers make section properties immutable - hence need for temps}
    self.sectionA = arrayForA;
    self.sectionB = arrayForB;
    self.sectionC = arrayForC;
    self.sectionD = arrayForD;
    self.sectionE = arrayForE;
    self.sectionF = arrayForF;
    self.sectionG = arrayForG;
    self.sectionH = arrayForH;
    self.sectionI = arrayForI;
    self.sectionJ = arrayForJ;
    self.sectionK = arrayForK;
    self.sectionL = arrayForL;
    self.sectionM = arrayForM;
    self.sectionN = arrayForN;
    self.sectionO = arrayForO;
    self.sectionP = arrayForP;
    self.sectionQ = arrayForQ;
    self.sectionR = arrayForR;
    self.sectionS = arrayForS;
    self.sectionT = arrayForT;
    self.sectionU = arrayForU;
    self.sectionV = arrayForV;
    self.sectionW = arrayForW;
    self.sectionX = arrayForX;
    self.sectionY = arrayForY;
    self.sectionZ = arrayForZ;
    
    //Release temp arrays
    [arrayForA release];
    [arrayForB release];
    [arrayForC release];
    [arrayForD release];
    [arrayForE release];
    [arrayForF release];
    [arrayForG release];
    [arrayForH release];
    [arrayForI release];
    [arrayForJ release];
    [arrayForK release];
    [arrayForL release];
    [arrayForM release];
    [arrayForN release];
    [arrayForO release];
    [arrayForP release];
    [arrayForQ release];
    [arrayForR release];
    [arrayForS release];
    [arrayForT release];
    [arrayForU release];
    [arrayForV release];
    [arrayForW release];
    [arrayForX release];
    [arrayForY release];
    [arrayForZ release];
    
}//End separateArrayToSections:

#pragma mark Word Detail

-(void) configureVideo{//Load and fit video into videoView

    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Obtain video filepath
    NSString* moviePath = [[NSBundle mainBundle] pathForResource:self.wordObject.wordString ofType:@"mp4"];
    if ([fileManager fileExistsAtPath:moviePath]) { // Movie file exists
        
        NSLog(@"Video exists, loading...");
        
        //Load and configure player
        NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
        
        VideoPlayerViewController* player = [[VideoPlayerViewController alloc] init]; //released below
        player.URL = movieURL;
        player.view.frame = self.wordMediaAreaView.bounds;
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
    
}//End configureVideo:

-(void) configureAudio {//Load audio files into their players
    NSLog(@"Configuring Audio...");
    
    //Fetch a file manager for loading page files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileLoadError = NO;
    
    //Word
    NSString* audioFilePath = [[NSBundle mainBundle] pathForResource:self.wordObject.wordString ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:audioFilePath]) {
        
        self.wordAudioPlayer.delegate = nil;
        self.wordAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL] autorelease];
        wordAudioPlayer.delegate = self;
        
    }
    else fileLoadError = YES;
    
    //Definition
    audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_definition", self.wordObject.wordString] ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:audioFilePath]) {
        
        self.definitionAudioPlayer.delegate = nil;
        self.definitionAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL] autorelease];
        definitionAudioPlayer.delegate = self;
        
    }
    else fileLoadError = YES;
    
    //Sentence
    audioFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_sentence", self.wordObject.wordString] ofType:@"mp3"];
    
    if ([fileManager fileExistsAtPath:audioFilePath]) {
        
        self.sentenceAudioPlayer.delegate = nil;
        self.sentenceAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:NULL] autorelease];
        sentenceAudioPlayer.delegate = self;
        
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

- (void) configureText {//Assign correct text to appropriate info related views
    
    switch (self.infoType) {
            
        case kInfoTypeDefinition: //Set definition info
            
            [self.infoLabel setText:@"Definition"];
            NSString* infoToggleButtonTitleString = [NSString stringWithFormat:@"↳ Sentence"];
            [self.infoToggleButton setTitle:infoToggleButtonTitleString forState:UIControlStateNormal];
            [self.infoToggleButton setTitle:infoToggleButtonTitleString forState:UIControlStateHighlighted];
            [self.infoTextView setText: self.wordObject.definitionString];
            break;
            
        case kInfoTypeSentence: //Set sentence info
            
            [self.infoLabel setText:@"Sentence"];
            infoToggleButtonTitleString = [NSString stringWithFormat:@"↳ Definition"];
            [self.infoToggleButton setTitle:infoToggleButtonTitleString forState:UIControlStateNormal];
            [self.infoToggleButton setTitle:infoToggleButtonTitleString forState:UIControlStateHighlighted];
            [self.infoTextView setText: self.wordObject.sentenceString];
            break;
            
        default: //Unrecognized infoType
            
            NSLog(@"<LOGIC ERROR> Description: infoType value is not a recognized kInfoType constant - see/import RRVConstants.txt for constant values.\nYou have somehow assigned infoType a value that is not understood by one of its handlers.\nThe infoType has been attempted to be set to a previously known, hopefully valid value (below the code where this message is logged).");
            
            NSString* errorTitleString = [NSString stringWithFormat:@"⚠ERROR!!"];
            self.infoType = kInfoTypeDefinition; //Set to known infoType Constant (1st Constant)
            [self.infoLabel setText:errorTitleString];
            [self.infoToggleButton setTitle:errorTitleString forState:UIControlStateNormal];
            [self.infoToggleButton setTitle:errorTitleString forState:UIControlStateHighlighted];
            [self.infoTextView setText: errorTitleString];
            [self performSelector:@selector(configureText) withObject:nil afterDelay:0.25];
            break;
    }
    
}//End configureText

- (void) updateWordAreaForWordObject: (WordObject*) wordObjectToDisplay {
    
    //Set as primary
    self.wordObject = [WordObject wordObjectFromWordObject:wordObjectToDisplay];
    
    //Update views
    [self.wordLabel setText:self.wordObject.wordString];
    [self.videoController setURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:self.wordObject.wordString ofType:@"mp4"]]];
    [self configureAudio];
    [self configureText];
    
    //Ensure definition on update
    if (self.infoType != kInfoTypeDefinition) {
        
        self.infoType = kInfoTypeDefinition;
        [self configureText];
        
    }
    
    //Pronounce word (starts autoplay)
    [self pronounceWordForView:self.pronunciationButton];
        
        
}//End updateWordAreaForWordObject:

- (void) stopAllAudioPlayers {
    
    [self.infoTextView setBackgroundColor:[UIColor clearColor]];
    [self.infoLabel setBackgroundColor:[UIColor clearColor]];
    [self.infoLabel setHighlighted:NO];
    
    //Stop all players
    if ([self.wordAudioPlayer isPlaying]) [self.wordAudioPlayer stop];
    self.wordAudioPlayer.currentTime = 0;
    [self.wordAudioPlayer prepareToPlay];
    if ([self.definitionAudioPlayer isPlaying]) [self.definitionAudioPlayer stop];
    self.definitionAudioPlayer.currentTime = 0;
    [self.definitionAudioPlayer prepareToPlay];
    if ([self.sentenceAudioPlayer isPlaying]) [self.sentenceAudioPlayer stop];
    self.sentenceAudioPlayer.currentTime = 0;
    [self.sentenceAudioPlayer prepareToPlay];
    
}//End stopAllAudioPlayers

- (void) infoAutoplayAdvance {
        
    //Toggle Info Type
    [self.infoToggleButton setHighlighted:YES];
    self.infoToggleButton.backgroundColor = [UIColor colorWithRed:0.25 green:0.35 blue:1.0 alpha:1.0];
    [self performSelector:@selector(infoAutoToggle) withObject:nil afterDelay:0.5];
    
}//End infoAutoplayAdvance

- (void) infoAutoToggle {
    
    //Unhighlight button
    [self.infoToggleButton setHighlighted:NO];
    self.infoToggleButton.backgroundColor = [UIColor clearColor];
    
    //toggleInfo
    [self infoToggle:self.infoToggleButton];
    
}//End infoAutoswap

- (void) cycleInfoType {
    
    switch (self.infoType) {
            
        case kInfoTypeDefinition:
            //  case kInfoTypeNext: <-- all cases that are not last should go here without break; statements
            
            self.infoType++; //Increment infoType (next Constant)
            break;
            
        case kInfoTypeSentence: //Last Constant - should cycle back to 1st Constant
            
            self.infoType = kInfoTypeDefinition;
            break;
            
        default: //infoType not recognized
            
            // configureText handles unrecognized infoType values
            break;
    }
    
}//End

@end
