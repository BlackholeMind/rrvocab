//
//  ThesaurusViewController.m
//  RRV101
//
//  Created by Brian C. Grant on 8/20/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "ThesaurusViewController.h"
#import "WordListObject.h"
#import "WordObject.h"
#import "WordView.h"
#import "RRVConstants.txt"

@implementation ThesaurusViewController

@synthesize thesaurusList;
@synthesize thesaurusSections;
@synthesize sectionA, sectionB, sectionC, sectionD, sectionE, sectionF, sectionG, sectionH, sectionI, sectionJ, sectionK, sectionL, sectionM, sectionN,
sectionO, sectionP, sectionQ, sectionR, sectionS, sectionT, sectionU, sectionV, sectionW, sectionX, sectionY, sectionZ;
@synthesize thesaurusTableView;

#pragma mark - PRIVATE METHODS -
#pragma mark View Lifecycle -

#pragma mark Memory Management

- (void)dealloc {
    
    //Delegation
    self.thesaurusTableView.delegate = nil;
    self.thesaurusTableView.dataSource = nil;
    
    //Data
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
    [thesaurusTableView release];
    //Controllers
   
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
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
        self.thesaurusTableView = nil;
        
        //Controllers
        
    }
    
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown); //Everything but upsidedown
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Load thesaurus using a verified WordListObject
    [self loadAndVerifyWordList];
    [self separateWordListToSections];
    
    [self.thesaurusTableView reloadData];
}//End viewDidLoad

- (void)viewWillAppear:(BOOL)animated {
    
    [self.thesaurusTableView reloadData];
    
}//End viewWillAppear:

#pragma mark - Delegate Methods -

#pragma mark REQUIRED


//Cell configuration - return : UITableViewCell*
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NOTE: This function will be called for each cell as the table is scrolled, and therefore will scroll through the array simultaneously and automatically.
    
    // Modify BG and font  of sectionIndices
    for(UIView *view in [tableView subviews]) {
        
        if([[[view class] description] isEqualToString:@"UITableViewIndex"]) {
            
            //Set custom index properties
            //[view setBackgroundColor:[UIColor blackColor]];
            [view setAlpha:0.8];
            //[view setFont:[UIFont fontWithName:@"Futura" size:14]];
            
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
    
    //Create the pronunciation button
    UIButton* pronunciationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pronunciationButton.frame = CGRectMake(8, 3, 44, 44);
    [pronunciationButton addTarget:self action:@selector(pronounceWordFromButton:) forControlEvents:UIControlEventTouchUpInside];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_up.png"] forState:UIControlStateNormal];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateSelected];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateHighlighted];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_disabled.png"] forState:UIControlStateDisabled];
    
    //Indent the labels to show the pronunciationButton
    [cell setIndentationWidth:50.0];
    [cell setIndentationLevel:1];
    
    //Set the pronunciation button in the contentView
    [[cell contentView] addSubview: pronunciationButton];
    
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

#pragma mark OPTIONAL

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //Return # of sections desired in tableView
    return 26;
}//End numberOfSectionsInTableView:

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    
    //Return desired height of a cell from indexPath
    return 50;
}//End tableView: heightForRowAtIndexPath:

//Sets the title (in the header) for the section at [section 
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    //ASCII capitals start at 65 and increment by one (as does sectionNumber).
    // To assign A-Z to any one sectionNumber (starts at 0) simply add 65 to the sectionNumber and assign to a char
    char letterForSectionTitle = section + 65;
    
    //Return the character as a string
    return [NSString stringWithFormat:@"%c", letterForSectionTitle];
}//End tableView: titleForHeaderInSection:

//Sets up the section index titles for this table - the alphabet
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSArray* titles = [[[NSArray alloc]initWithObjects: @"{search}",
                        @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                        @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", 
                        nil] autorelease];
    
    return titles;
}//End sectionIndexTitlesForTableView:

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //User clicked a cell in the tableView
    
    //Initialize with wordView for the clicked cell's word
    WordView* wordViewModalVC = [[[WordView alloc] initWithNibName:@"WordView" bundle:NULL forWordObject:[WordObject loadWord:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text] fromLesson:101] modalPresentation:YES] autorelease];
    [wordViewModalVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:wordViewModalVC animated:YES completion:^{
        //Afterwards...
    }];
    
    //Observe
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWordView:) name:WordViewFinishedNotification object:wordViewModalVC];
    
    //Deselect the cell
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
    
}//End tableView:

#pragma mark - IBActions -

-(IBAction) dismissThesaurus:(id)sender{
    
    //Notify
    [[NSNotificationCenter defaultCenter] postNotificationName:ThesaurusQuitNotification object:self];
    
}//End dismissThesaurus

#pragma mark - Callbacks -

-(void) dismissWordView:(NSNotification*)notification {
    
    //Catch wordView
    WordView* wordVC = [notification object];
    [wordVC dismissViewControllerAnimated:YES completion:^{
        //Afterwards...
    }];
}

#pragma mark - Utility -

-(void) pronounceWord:(NSString*)word {
    
    //Play the audio file with the name of that word
    NSString* newAudioFile = [[NSBundle mainBundle] pathForResource:word ofType:@"mp3"];
    AVAudioPlayer* wordAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:newAudioFile] error:NULL];
    wordAudioPlayer.delegate = self;
    [wordAudioPlayer play];
    
}//End pronounceWord:

-(void) pronounceWordFromButton:(id)sender {
    
    //Obtain the word string for this button, then pronounce it
    NSString* wordToPronounce = [self obtainWordForPronunciationButton:sender];
    [self pronounceWord:wordToPronounce];
    
}//End pronounceWordFromButton:

-(void) loadAndVerifyWordList {
    
    //Load a WordListObject by passing an array of verified (purchased/unlocked) lesson numbers (NSNumber* intValues)
    NSArray* lessons = [self verifiedLessonsList];
    if ([lessons count] > 0)
        self.thesaurusList = [WordListObject listForLessons:[self verifiedLessonsList]];
    else
        self.thesaurusList = [WordListObject listForLessonNumber:0];
    
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
            
            //Add Story 101 (Lite)
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
            }//End switch
        }//End for{}
    
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

-(NSString*) obtainWordForPronunciationButton:(id)sender {
    
    //Get index path of the cell in which the button was pressed
    NSIndexPath *indexPath = [self.thesaurusTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    //Get the word on that cell's label
    NSString* wordToReturn = [[[self.thesaurusTableView cellForRowAtIndexPath:indexPath] textLabel] text];
    return wordToReturn;
    
}//End obtainWordForProununciationButton:

@end
