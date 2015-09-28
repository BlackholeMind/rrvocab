//
//  WordBankController.m
//  RRV101
//
//  Created by Brian C. Grant on 9/26/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "WordBankController.h"

@implementation WordBankController

#pragma mark Synthesizers

@synthesize wordListTableView;
@synthesize wordListArray;

#pragma mark - View Lifecycle  -

#pragma mark Memory Management

- (void)dealloc{
    
    //Delegation
    self.wordListTableView.delegate = nil;
    self.wordListTableView.dataSource = nil;
    
    //Data
    [wordListArray release];
    
    //Views
    [wordListTableView release];
    
    [super dealloc];
}//End dealloc

- (void)didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
        
        self.wordListTableView = nil;
        self.wordListArray = nil;
    }
}

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}//End initWithNibName: bundle:

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Reposition view from transition
    //self.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    //Load the wordList from file
    [self loadWordListArray];
}//End viewDidLoad

#pragma mark - Delegates -

#pragma mark required

#pragma mark UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //CELL MANAGEMENT
    
    //Create a cell indentifier
    static NSString* cellIdentifier = @"cellIdentifier";
    
    //Reuse cells to conserve memory...
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //...unless more cells are needed.
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]autorelease];
    }
    
    //CELL DRAWING
    
    //Create the pronunciation button
    UIButton* pronunciationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pronunciationButton.frame = CGRectMake(8, 3, 44, 44);
    [pronunciationButton addTarget:self action:@selector(pronounceWordFromButton:) forControlEvents:UIControlEventTouchUpInside];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_up.png"] forState:UIControlStateNormal];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateSelected];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateHighlighted];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_disabled.png"] forState:UIControlStateDisabled];
    
    //Set the pronunciation button in the contentView
    [cell.contentView addSubview: pronunciationButton];
    
    //Set the label to the word from wordListArray
    [cell.textLabel setText:[[self.wordListArray objectAtIndex:[indexPath row]] objectAtIndex:0]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Georgia" size:24.0]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    //Indent the label to show the pronunciationButton
    cell.indentationWidth = 50.0;
    cell.indentationLevel = 1;
    
    return cell;
}//End tableView: cellForRowAtIndexPath:

//Number of rows in section (passed as parameter, catch and test for value - act accordingly)
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.wordListArray count];
}//End tableView: numberOfRowsInSection:

#pragma mark optional

#pragma mark UITableView

//Number of sections in the table - return desired number : NSInteger
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}//End numberOfSectionsInTableView:

//Sets height of cell at [indexPath row] - return desired height in pixels/points: CGFloat
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}//End tableView: heightForRowAtIndexPath:

//Sets the title (in the header) for the section at section
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Lesson 1.01";
}
*/

//METHOD FOR CLICKING A CELL
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{//User clicked a cell
    
    //Pronounce the word
    NSLog(@"Should pronounce: %@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
    [self pronounceWord:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
    
    //Deselect the cell
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
    
}//End tableView: didSelectRowAtIndexPath:

#pragma mark AVAudioPlayer

//Release any audio player after it finishes
-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [player release];
    
}//End audioPlayerDidFinishPlaying:

#pragma mark - Actions -

-(IBAction) dismissWordListModalView:(id)sender{
    
    [self dismissModalViewControllerAnimated:YES];
    
}//End dismissWordListModalView:

#pragma mark - Utility -

-(void) loadWordListArray{
    
    //Load RRThesaurus.plist into (NSDictionary)thesaurusDictionary
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"WordList.plist"];
    NSDictionary* pListData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    self.wordListArray = [pListData objectForKey:@"WordList"];
}//End loadWordListArray

-(NSString*) obtainWordForPronunciationButtonInTableViewCell: (id)sender{
    
    //Get index path of the cell in which the button was pressed
    NSIndexPath *indexPath = [self.wordListTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    //Get the word on that cell's label
    NSString* wordToReturn = [[[self.wordListTableView cellForRowAtIndexPath:indexPath] textLabel] text];
    
    return wordToReturn;
    
}//End obtainWordForPronunciationButtonInTableViewCell: {}

-(void) pronounceWord:(NSString*)word{//User pressed a pronunciationButton

    //Play the audio file with the name of that word
    NSString* newAudioFile = [[NSBundle mainBundle] pathForResource:word ofType:@"mp3"];
    AVAudioPlayer* wordAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:newAudioFile] error:NULL];
    wordAudioPlayer.delegate = self;
    [wordAudioPlayer play];
    
}//End pronounceWord:

-(void) pronounceWordFromButton:(id)sender{
    
    NSString* wordToPronounce = [self obtainWordForPronunciationButtonInTableViewCell:sender];
    [self pronounceWord:wordToPronounce];
    
}

@end
