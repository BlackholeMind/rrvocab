//
//  QuizViewController_iPad.m
//  RRV101
//
//  Created by Brian C. Grant on 1/25/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "QuizViewController_iPad.h"
#import "QuestionObject.h"
#import "QuestionViewController.h"
#import "QuizObject.h"
#import "QuizCoverViewController.h"
#import "QuizSubmitViewController.h"
#import "RRVConstants.txt"

@implementation QuizViewController_iPad

#pragma mark Synthesizers

//Data
@synthesize quizObject; 
//Views
@synthesize wordBankView, wordBankTableView;
@synthesize quizAreaView, wordBankButton, quizCurrentPageLabel, quizTotalPagesLabel, quizHeaderView, quizDateLabel, quizNameLabel, quizAreaScrollView;
//Controllers
@synthesize quizAreaViewControllers, activeController;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void)dealloc{
    
    //Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.quizAreaScrollView.delegate = nil;
    self.wordBankTableView.delegate = nil;
    self.wordBankTableView.dataSource = nil;
    
    //Data
    [quizObject release];
    
    //Views
    [wordBankView release];
    [wordBankTableView release];
    [quizAreaView release];
    [wordBankButton release];
    [quizCurrentPageLabel release];
    [quizTotalPagesLabel release];
    [quizHeaderView release];
    [quizDateLabel release];
    [quizNameLabel release];
    [quizAreaScrollView release];
    
    //Controllers
    [quizAreaViewControllers release];
    [activeController release];
    
    [super dealloc];
}//End dealloc

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) { //If view is not in use
    
        //Data
        self.quizObject = nil;
    
        //Views
        self.wordBankView = nil;
        self.wordBankTableView = nil;
        self.quizAreaView = nil;
        self.wordBankButton = nil;
        self.quizCurrentPageLabel = nil;
        self.quizTotalPagesLabel = nil;
        self.quizHeaderView = nil;
        self.quizDateLabel = nil;
        self.quizNameLabel = nil;
        self.quizAreaScrollView = nil;
    
        //Controllers
        self.quizAreaViewControllers = nil;
        self.activeController = nil;
        
    }
    
}//End didReceiveMemoryWarning

- (void) viewDidDisappear:(BOOL)animated {
    
    //Notify observers of quiz state
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizClosedNotification object:self];
    
}//End viewDidDisappear:

#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    //Return YES from this method for supported orientations 
    return YES;
    
}//End shouldAutorotateToInterfaceOrientation:

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration { //Before rotation...
    
    /*
    ///WORDBANK TRANSITION PREP///
     
    //Disable interaction
    [self.quizAreaView setUserInteractionEnabled:NO];
    [self.wordBankView setUserInteractionEnabled:NO]; 
     
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) { //Portrait Transition
        
        //Prepare wordBankView for "detach"
        [self.wordBankView setFrame: CGRectMake(0.0, 0.0, 500.0, 500.0)];
        
        //ANIMATION: Portrait Transition (phase 1)
            //iOS 4.0 and later...
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                         animations:^{
                             
                            //"Detach" wordBankView
                             self.wordBankView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             self.wordBankView.center = self.view.center;
                             
                             //QuizAreaView expand to portrait bounds
                             [self.quizAreaView setFrame: self.view.bounds];
                             
                         } 
                         completion:^(BOOL finished){
                             //Afterwards...
                             
                         }];//End ANIMATION{^} (phase 1)
        
    }//End if{} (portrait transition)
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) { //Landscape Transition
        
        //Disable WordBankButton
        [self.wordBankButton setEnabled:NO];
        
        //Reverse Transforms in prep for reappearance
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self.wordBankView.transform = CGAffineTransformScale(translateTransform, 1.0, 1.0);
        
        //Prepare wordBankView for "reattach" (expansion)
        [self.wordBankView setFrame: CGRectMake(0.0, 0.0, 0, self.view.bounds.size.height)];
        
        //ANIMATE: Landscape Transition (phase 1)
            //iOS 4.0 and later...
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
                         animations:^{
                             
                             //WordBankView shrink to WordBankButton & hide
                             //[self.wordBankView setAlpha:1.0];
                             //[self.wordBankView setFrame: CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height)];
                             
                             //WordBankButton opacity to 0 hide
                             [self.wordBankButton setAlpha:0.0];
                             
                             //QuizAreaView change to landscape bounds
                             //[self.quizAreaView setFrame: CGRectMake(320.0, 0.0, 704.0, self.view.bounds.size.height)];
                             
                         } 
                         completion:^(BOOL finished){
                             //Afterwards...
                             
                         }];
    
    }//End else{} (landscape transition)
    
    ///END WORD BANK TRANSITION PREP///
    */
    
}//End willRotateToInterfaceOrientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation { //After rotation...
    
    /*
    ///WORDBANK TRANSITION///
    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) { //Portrait
        
        //ANIMATION: Portrait Transition (phase 2)
            //iOS 4.0 and later...
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut 
         
                         animations:^{
                                                
                             //WordBankView shrink to WordBankButton & fade
                             [self.wordBankView setAlpha:0.05];
                             CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(self.wordBankButton.center.x-self.wordBankView.center.x, self.wordBankButton.center.y-self.wordBankView.center.y);
                             self.wordBankView.transform = CGAffineTransformScale(translateTransform, self.wordBankButton.bounds.size.width/self.wordBankView.bounds.size.width, self.wordBankButton.bounds.size.height/self.wordBankView.bounds.size.height);
                                                  
                             //WordBankButton opacity to 100 (unhide)
                             [self.wordBankButton setAlpha:1.0];
                             
                             //Resize quizAreaView as needed
                             [self.quizAreaView setFrame: self.view.bounds];
                                                  
                         } //End animations^{}
         
                         completion:^(BOOL finished){
                             //Afterwards...
                                                  
                             //Complete transparency of wordBankView
                             [self.wordBankView setAlpha:0.0];
                                                  
                             //Enable now-visible wordBankButton
                             [self.wordBankButton setEnabled:YES];
                                                  
                             //Re-enable interaction
                             [self.quizAreaView setUserInteractionEnabled:YES];
                                //wordBankView is transparent (leave disabled)
                             
                         }//End completion^{}
         
         ];//End ANIMATION (portrait phase 2)
        
    }//End if{} (portrait transition)
    else if (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){ //Landscape
        
        //Disable WordBankButton
        [self.wordBankButton setEnabled:NO];
        
        //Reverse Transforms
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self.wordBankView.transform = CGAffineTransformScale(translateTransform, 1.0, 1.0);
        
        //ANIMATE: Landscape Transition (phase 2)
            //iOS 4.0 and later...
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear
         
                         animations:^{
                             
                             //WordBankView appear and place
                             [self.wordBankView setAlpha:1.0];
                             [self.wordBankView setFrame: CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height)];
                             
                             //WordBankButton opacity to 0 hide
                             [self.wordBankButton setAlpha:0.0];
                             
                             //QuizAreaView change to landscape bounds
                             [self.quizAreaView setFrame: CGRectMake(320.0, 0.0, 704.0, self.view.bounds.size.height)];
                             
                             
                         } //End animations^{}
         
                         completion:^(BOOL finished){
                             //Afterwards...
                             
                             //Re-enable interaction
                             [self.quizAreaView setUserInteractionEnabled:YES];
                             [self.wordBankView setUserInteractionEnabled:YES];
                             
                             
                         }//End completion^{}
         
         ];//End ANIMATION (landscape phase 2)
        
    }//End else{} (landscape transition)
    
    //Snap to page
    [self scrollPage];
    
    ///END WORDBANK TRANSITION///
    */
    
}//End didRotateFromInterfaceOrientation:

#pragma mark Setup

//Custom initialization includes lessonNumberToLoad
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad embedded:(BOOL)partOfLesson preQuiz:(BOOL)precursor{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //Assemble a unique quiz
        self.quizObject = [[[QuizObject alloc] initForLessonNumber:lessonNumberToLoad] autorelease];
        self.quizObject.quizIsEmbedded = partOfLesson;
        self.quizObject.quizIsPrecursor = precursor;
    }
    
    return self;
    
}//End initWithNibName: bundle: forLesson:

- (void)viewDidLoad{
    [super viewDidLoad];
    /* Do any additional setup after loading the view from its nib. */
    
    //Notify observers of quiz state
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizOpenedNotification object:self];
    
    //Set dateLabel
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    [self.quizDateLabel setText:[dateFormatter stringFromDate:self.quizObject.dateStarted]];
    [dateFormatter release];
    
    //Draw quiz to quizAreaScrollView
    [self displayQuiz:self.quizObject];
    
    //Pre-quiz conditions
    if (self.quizObject.quizIsPrecursor) {
        
        //Disable scrolling
        [self.quizAreaScrollView setScrollEnabled:NO];
        
    }
    
    //Scroll to first question
    [self performSelector:@selector(scrollPage) withObject:nil afterDelay:0.5];
    
    NSLog(@"Finished Drawing Quiz.");
    
}//End viewDidLoad:

#pragma mark - Data Sources -

#pragma mark UITableView

#pragma mark required

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    //[pronunciationButton addTarget:self action:@selector(pronounceWordFromButton:) forControlEvents:UIControlEventTouchUpInside];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_up.png"] forState:UIControlStateNormal];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateSelected];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateHighlighted];
    [pronunciationButton setImage:[UIImage imageNamed:@"audioBtn_disabled.png"] forState:UIControlStateDisabled];
    [pronunciationButton setUserInteractionEnabled:NO];
    
    //Set the pronunciation button in the contentView
    [cell.contentView addSubview: pronunciationButton];
    
    //Set the label to the word from wordListArray
    QuestionObject* questionObjectToQueryForWord = [self.quizObject.questionObjects objectAtIndex:[indexPath row]];
    [cell.textLabel setText:questionObjectToQueryForWord.wordForQuestion];
    [cell.textLabel setFont:[UIFont fontWithName:@"Georgia" size:20.0]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    //Indent the label to show the pronunciationButton
    cell.indentationWidth = 50.0;
    cell.indentationLevel = 1;
    
    return cell;
    
}//End tableView: cellForRowAtIndexPath: {}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //Return count of questions
    //NOTE: This only works when questionObjects only have one word!!! When expanded to multiple words per question, modify QuizObject class to maintain a separate wordList property.
    NSLog(@"Sending word count to table view.");
    
    return [self.quizObject.questionObjects count];
    
}//End tableView: numberOfRowsInSection: {}

#pragma mark optional

#pragma mark - Delegates -

#pragma mark AVAudioPlayer

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully: (BOOL)flag{ //An AVAudioPlayer finished playing
    
    //Release any audio player after it finishes
    [player release];
    
}//End audioPlayerDidFinishPlaying: successfully:

#pragma mark UIScrollView

-(void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView {
    
    //Set current page
    [self updatePageControlLabels];
    
    //Update observations
    [self setAppropriateObservers];
    
}//End scrollViewDidEndDecelerating:

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

#pragma mark - Utility -

#pragma mark Quiz Drawing

-(void) configureQuizArea {
    
    //Configure the quizAreaScrollView
    self.quizAreaScrollView.contentSize = CGSizeMake(self.quizAreaScrollView.bounds.size.width*(1+[self.quizObject.questionObjects count]+1), 393);//Height of QuestionView
    [self.quizAreaScrollView scrollRectToVisible:CGRectMake(0, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height) animated:NO];
    
    //Configure the pageControlLabel variables
    self.quizObject.currentPage = 0;
    self.quizObject.numberOfPages = 1+[self.quizObject.questionObjects count]+1;
    [self.quizCurrentPageLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.currentPage]];
    [self.quizTotalPagesLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.numberOfPages-1]];
    
}//End configureQuizArea

-(void) displayQuiz: (QuizObject*)quiz {
    
    //Configure the quiz area
    [self configureQuizArea]; 
    
    //Keep an array of View Controllers used
    NSMutableArray* VCs = [NSMutableArray arrayWithCapacity:(1+[quiz.questionObjects count]+1)];
    
    //Cover Page
    QuizCoverViewController* newCoverVC = [[QuizCoverViewController alloc] initWithNibName:@"QuizCoverViewController" bundle:NULL quizInfoDictionary:[quiz collapseToDictionary]];
    newCoverVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //Set autoresizing
    [newCoverVC.view setFrame:CGRectMake(0, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height)];
    [VCs addObject:newCoverVC];//Add to array
    [self.quizAreaScrollView addSubview:newCoverVC.view];//Add view to quizArea
    [newCoverVC release];
    
    //Questions
    for (int questionIndex = 0; questionIndex < [quiz.questionObjects count]; questionIndex++) {//For each QuestionObject in Quiz
        //Create current question view controller (temp)
        QuestionViewController* newQuestionVC = [[QuestionViewController alloc] initWithNibName:@"QuestionViewController" bundle:NULL forQuestion:[quiz.questionObjects objectAtIndex:questionIndex]];
        newQuestionVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //Set autoresizing
        [newQuestionVC.view setFrame:CGRectMake((questionIndex+1)*self.quizAreaScrollView.bounds.size.width, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.contentSize.height)];
        [VCs addObject:newQuestionVC];//Add to array
        [self.quizAreaScrollView addSubview:newQuestionVC.view];//Add view to quizArea
        [newQuestionVC release];//Release temp VC (retained by array)
        
    }//End for{} (each QuestionObject in Quiz)
    
    //Submit Page
    QuizSubmitViewController* newSubmitVC = [[QuizSubmitViewController alloc] initWithNibName:@"QuizSubmitViewController" bundle:NULL];
    newSubmitVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //Set autoresizing
    [newSubmitVC.view setFrame:CGRectMake([VCs count]*self.quizAreaScrollView.bounds.size.width, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.contentSize.height)];
    if (self.quizObject.quizIsPrecursor) {
        [newSubmitVC.submitButton setHidden:YES];
        [newSubmitVC.instructionTextView setText:@"You are finished!"];
    }
    [newSubmitVC.view setUserInteractionEnabled:NO];
    [VCs addObject:newSubmitVC];
    [self.quizAreaScrollView addSubview:newSubmitVC.view];
    [newSubmitVC release];
    
    //Retain view controllers used
    self.quizAreaViewControllers = [NSArray arrayWithArray:VCs];
    
    //Redraw if necessary
    [self.quizAreaScrollView setNeedsLayout];
    
    //Set active controller
    self.activeController = [self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage];
    
}//End displayQuiz:

-(void) showGradedQuiz: (QuizObject*) quiz {
    
    //Update cover
    [(QuizCoverViewController*)[self.quizAreaViewControllers objectAtIndex:0] setCoverWithQuiz:quiz];
    
    //Update Question Views
    for (NSInteger questionIndex = 1; questionIndex < ([self.quizAreaViewControllers count]-1); questionIndex++) {//For each questionView in viewControllers
        [(QuestionViewController*)[self.quizAreaViewControllers objectAtIndex:questionIndex] showGradedQuestion];
    }
    
}//End showGradedQuiz:

#pragma mark Quiz Events

-(void) doneWithQuiz {//User wishes to move on
    
    //Post completion notification with metrics
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizFinishedNotification object:self userInfo:[self.quizObject collapseToDictionary]];
    NSLog(@"Posted QuizFinished Notification");
    
}//End doneWithQuiz:

-(void) submitQuiz{//User has pushed "Turn In Quiz" button
    
    self.quizObject.dateSubmitted = [NSDate date];//Set submit date
    [self.quizObject grade];//Grade Quiz
    //TO DO: Save Quiz somewhere
    if (!self.quizObject.quizIsPrecursor) { //If NOT pre-quiz
        
        //Update Views if NOT Pre-Quiz
        [self showGradedQuiz:self.quizObject]; 
        
        //Scroll to cover
        [self.quizAreaScrollView scrollRectToVisible:CGRectMake(0, 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height) animated:YES];
        [self performSelector:@selector(updatePageControlLabels) withObject:nil afterDelay:1.0];
        [self performSelector:@selector(setAppropriateObservers) withObject:nil  afterDelay:1.0];
        
    }//End if{} (not pre-quiz)
    
}//End submitQuiz:

-(void) choseAnswer{
    
    NSLog(@"QuestionAnsweredNotification Observed.");
    [self performSelector:@selector(scrollPage) withObject:nil afterDelay:0.2];
    
}//End choseAnswer:

-(void) scrollPage{
    
    [self.quizAreaScrollView scrollRectToVisible:CGRectMake(((self.quizObject.currentPage+1)*self.quizAreaScrollView.bounds.size.width), 0, self.quizAreaScrollView.bounds.size.width, self.quizAreaScrollView.bounds.size.height) animated:YES];
    
    [self performSelector:@selector(updatePageControlLabels) withObject:self.quizAreaScrollView afterDelay:0.6];
    [self performSelector:@selector(setAppropriateObservers) withObject:nil  afterDelay:0.6];
    
}//End scrollPage

-(void) updatePageControlLabels{
    //Calculate page after scrolling ends, set that page
	self.quizObject.currentPage = self.quizAreaScrollView.contentOffset.x/self.quizAreaScrollView.bounds.size.width;
    [self.quizCurrentPageLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.currentPage]];
    [self.quizTotalPagesLabel setText:[NSString stringWithFormat:@"%i", self.quizObject.numberOfPages-1]];
}//End setPageControlLabels

-(void) setAppropriateObservers{
    
    //Remove observation
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Catch Pre-Quiz submission
    if (self.quizObject.currentPage == (self.quizObject.numberOfPages - 1) && self.quizObject.quizIsPrecursor) { //Submit Page of Pre-Quiz
        [self submitQuiz];
        [self performSelector:@selector(doneWithQuiz) withObject:nil afterDelay:2.0];
    }
    //Decide observer
    else if (self.quizObject.currentPage == 0) {//Cover Page
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneWithQuiz) name:QuizFinishedNotification object:[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage]];
        NSLog(@"Added Cover Observer");
    }
    else if (self.quizObject.currentPage == (self.quizObject.numberOfPages - 1)) {//Submit Page
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitQuiz) name:QuizSubmittedNotification object:[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage]];
        NSLog(@"Added Submit Observer");
        
        [[[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage] view] setUserInteractionEnabled:YES];
    }
    else {//Question Page
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(choseAnswer) name:QuestionAnsweredNotification object:[self.quizAreaViewControllers objectAtIndex:self.quizObject.currentPage]];
        NSLog(@"Added Question Observer");
    }
    
}//End setAppropriateObservers

-(void) pronounceWord:(NSString*)word{//User pressed a pronunciationButton
    
    //Play the audio file with the name of wordToPronounce
    AVAudioPlayer* wordAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:word ofType:@"mp3"]] error:NULL];
    [wordAudioPlayer setDelegate:self];
    
    [wordAudioPlayer play];
    
}//End pronounceWord:

@end
