//
//  LessonSelect.m
//  RRV101
//
//  Created by Brian C. Grant on 5/28/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "LessonSelect.h"
#import "RRVConstants.txt"

#import "Reachability.h"


@implementation LessonSelect

#pragma mark Synthesizers

//Data
@synthesize appRunningOnIPad, multipleLessonsSelectable, backButtonEnabled;
@synthesize purchasedProductIDs, lessonsAvailable, lessonsPurchased, lessonsCompleted, lessonTitles;
@synthesize productToPurchase, productsRequest;
//Views
@synthesize lessonsTableView, titleBar, backButton;
@synthesize loadingView, loadingIndicator;

#pragma mark - View Lifecycle -

#pragma mark Memory Management

- (void) dealloc {
    
    //Notifications
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Delegation
    self.lessonsTableView.delegate = nil;
    self.lessonsTableView.dataSource = nil;
    self.productsRequest.delegate = nil;
    
    //Data
    [purchasedProductIDs release];
    [lessonsAvailable release];
    [lessonsPurchased release];
    [lessonsCompleted release];
    [lessonTitles release];
    [productToPurchase release];
    [productsRequest release];
    
    //Views
    [lessonsTableView release];
    [titleBar release];
    [backButton release];
    [loadingView release];
    [loadingIndicator release];
    
    [super dealloc];
}//End dealloc

- (void) didReceiveMemoryWarning {
    //Releases the view if it doesn't have a superView
    [super didReceiveMemoryWarning];
    
    //Release any cached data, views, etc that aren't in use.
    
    if ([self isViewLoaded] && ![[self view] window]) {
        
        //Data
        self.purchasedProductIDs = nil;
        self.lessonsAvailable = nil;
        self.lessonsPurchased = nil;
        self.lessonsCompleted = nil;
        self.lessonTitles = nil;
        self.productToPurchase = nil;
        self.productsRequest = nil;
    
        //Views
        self.lessonsTableView = nil;
        self.titleBar = nil;
        self.backButton = nil;
        self.loadingView = nil;
        self.loadingIndicator = nil;
        
    }
}

#pragma mark Orientation

//// iOS 6.0+
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    if (self.appRunningOnIPad) 
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
    
}//End supportedInterfaceOrientations

- (BOOL) shouldAutorotate {
    
    return YES;
    
}

//// iOS 5.1-
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    BOOL shouldRotate = NO;
    
    //Detect device
    if(self.appRunningOnIPad){ //Device is an iPad
        shouldRotate = YES;
    }
    else { //Device is an iPhone/iPod
        shouldRotate = (interfaceOrientation == UIInterfaceOrientationPortrait) ;
    }
    
    return shouldRotate;
    
}//End shouldAutorotateToInterfaceOrientation:

#pragma mark Setup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil multipleLessons:(BOOL)enableMultipleLessons backButton:(BOOL)enableBackButton {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.multipleLessonsSelectable = enableMultipleLessons;
        self.backButtonEnabled = enableBackButton;
        self.lessonsAvailable = [self availableLessonsList];
        self.lessonsPurchased = [self purchasedLessonsList];
        self.lessonsCompleted = [self completedLessonsList];
        self.lessonTitles = [self titlesForLessons:self.lessonsAvailable];
        
        //Detect device
        NSString* detectedDevice = [[UIDevice currentDevice] model];
        NSRange textRange = [[detectedDevice lowercaseString] rangeOfString:@"ipad"];
        if(textRange.location != NSNotFound){ //Device is an iPad
            self.appRunningOnIPad = YES;
        }
        else { //Device is an iPhone/iPod
            self.appRunningOnIPad = NO;
        }
        
    }
    return self;
    
}//End initWithNibName: bundle:

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadStore];
    
    //Reload
    [self.lessonsTableView reloadData];
    
}//End viewDidLoad

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self hideLoadingMaskWithDuration:0.0];
    
    if (self.backButtonEnabled) {
        [self.titleBar setItems:[NSArray arrayWithObjects:self.backButton, nil] animated:YES]; NSLog(@"backButton ENABLED");
    }
    
}
#pragma mark - Data Sources -

#pragma mark UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NOTE: This function will be called for each cell as the table is scrolled, and therefore will scroll through the array simultaneously and automatically.
    
    NSInteger comingSoonLessonNumber = 102; //Serves as a cut-off point for available lessons
    
    //// CELL ALLOCATION (Setup)
    
    //Create a cell indentifier
    static NSString* cellIdentifier = @"cellIdentifier";
    
    //Reuse cells to conserve memory...
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){//...unless more cells are needed.
        
        //Anything that needs to happen to create a NEW cell goes in here... (alloc's)
        
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        
        //Indent the labels to show the pronunciationButton
        [cell setIndentationWidth:50.0];
        [cell setIndentationLevel:1];
        
    }//End if{} (no reuseable cells)
    
    //// CELL DRAWING (Tailoring)
    
        //Any UNIQUE changes to an ALREADY EXISTING cell, go below here
    
    //Text settings
    [[cell textLabel] setFont:[UIFont fontWithName:@"Georgia" size:20.0]];
    [[cell detailTextLabel] setFont:[UIFont fontWithName:@"American Typewriter" size:14.0]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    NSInteger lessonNumberForCell = [self lessonNumberFromIndexPath:indexPath];
    NSLog(@"LessonNumber: %d, for cell at Section %d, Row %d", lessonNumberForCell, [indexPath section]+1, [indexPath row]+1);
    
    //Thumbnail button
    UIButton* lessonPreviewThumbnailButton = [self thumbnailButtonForLessonNumber:lessonNumberForCell grayedOut:NO];
    [[cell contentView] addSubview: lessonPreviewThumbnailButton];
    
    //Title text
        //Grab title from array
    if (self.lessonTitles && [indexPath row] < [self.lessonTitles count]) { //If corresponding index is valid
        
        NSInteger indexForTitle = [self indexPathFromLessonNumber:lessonNumberForCell].row;
        
        [cell.textLabel setText:[self.lessonTitles objectAtIndex:indexForTitle]]; //Title from array, string object at this row (index)
        
    }
    
    //Detail text
    if (self.lessonsPurchased && [self.lessonsPurchased count] == 0) { //SPECIAL CASE - Lite Lesson
        [cell.detailTextLabel setText:@"Story 101 (Lite)"];
    }
    else if (self.lessonsAvailable && [indexPath row] < [self.lessonsAvailable count]) {
        
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"Story %d", lessonNumberForCell]];
        
    }//End if{} (lessonNumbers arry exists & is not out of bounds)
    
    //Accessory Views
        //IMPORTANT: accessoryView.tag = lessonNumber
    
    //Refresh the space
    [cell.accessoryView removeFromSuperview];
    cell.accessoryView = nil;
    
        //Soon! Button (lesson not yet available for purchase)
    if (lessonNumberForCell >= comingSoonLessonNumber) { //Lesson not available at this time
        
        cell.accessoryView = [self comingSoonButtonWithTag:lessonNumberForCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
        //Buy Button
    else if ([self hasAvailableLessonNumber:lessonNumberForCell] && ![self hasPurchasedLessonNumber:lessonNumberForCell]) { //Lesson is available and has NOT been purchased
        
        //Buy button (ready to purchase)
        cell.accessoryView = [self buyButtonWithTag:lessonNumberForCell];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
        //Do ___ (prerequisite lesson not yet completed)
    else if ([self hasAvailableLessonNumber:lessonNumberForCell] && ![self readyToTakeLessonNumber:lessonNumberForCell]) { //Lesson is available & purchased, but previous lesson not completed
        
        UILabel* completionLabel = [[[UILabel alloc] initWithFrame:[self buyButtonWithTag:0].frame] autorelease];
        [completionLabel setFont:[UIFont fontWithName:@"Georgia" size:10.0]];
        NSInteger lessonToCompleteFirst;
        if (self.lessonsCompleted && [self.lessonsCompleted count] > 0) {
            lessonToCompleteFirst = [[self.lessonsCompleted objectAtIndex:([self.lessonsCompleted count] - 1)] intValue];
        }
        else if (self.lessonsAvailable && [self.lessonsAvailable count] > 0)
            lessonToCompleteFirst = [[self.lessonsAvailable objectAtIndex:0] intValue];
        else
            lessonToCompleteFirst = 101;
        
        [completionLabel setText:[NSString stringWithFormat:@"Do Story %d", lessonToCompleteFirst]];
        [completionLabel setBackgroundColor:[UIColor clearColor]];
        [completionLabel setTextColor:[UIColor purpleColor]];
        
        cell.accessoryView = completionLabel;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    else { //Lesson ready to take
        
        //Info button?
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    }
    
    
    //Return the requested cell
    return cell;
    
}//End tableView: cellForRowAtIndexPath:

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //Minimum
    NSInteger numberOfRows = 0;
    
    if (section == 0) { //Level 1
        
        numberOfRows = 1;
    
        //If list exists and is longer than minimum
        if (self.lessonsAvailable && self.lessonsPurchased && [self.lessonsAvailable count] > [self.lessonsPurchased count]) {
            //There are more available lessons (to be purchased)
            
            numberOfRows = [self.lessonsPurchased count] + 1; // +1 to add the next available lesson (so that it can be purchased) or coming soon
            
        }
        else if (self.lessonsPurchased && [self.lessonsPurchased count] > 0) {
            //There are purchased lessons (& none left available for purchase)
        
            numberOfRows = [self.lessonsPurchased count];
        
        }//End if{}(list is longer than minimum)
        
    }//End if{} (level 1)
    
    return numberOfRows;
    
}//End tableView: numberOfRowsInSection:

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //Levels 1 - 9 or I - IX
    return 9;
    
}//End numberOfSectionsInTableView:

#pragma mark - Delegates -

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
    
}//End tableView: heightForRowAtIndexPath:

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger lessonNumberForCell = [self lessonNumberFromIndexPath:indexPath];
    
    if (!self.multipleLessonsSelectable && [self readyToTakeLessonNumber:lessonNumberForCell]) { //Not selecting multiple lessons && lesson is unlocked
        
        //Post selected lesson
        [self postLessonSelection:lessonNumberForCell];
        [self dismissViewControllerAnimated:YES completion:^{
            //Afterwards...
        }];
        
    }//End if{} (no multiple selections)
    else if (!self.multipleLessonsSelectable && self.lessonsPurchased && [self.lessonsPurchased count] == 0) {
        
        //SPECIAL CASE - Demo Lesson
        [self postLessonSelection:0];
        [self dismissViewControllerAnimated:YES completion:^{
            //Afterwards...
        }];
        
    }
    else { //Can select multiple lessons
        
        //Not yet implemented
        
    }
    
    //Unselect if already selected (toggle off)
    if ([tableView cellForRowAtIndexPath:indexPath].isHighlighted || [tableView cellForRowAtIndexPath:indexPath].isSelected) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
        [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
        
    }
    else {
        
        //Leave selected row selected
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES];
    }

}//End tableView: didSelectRowAtIndexPath:

#pragma mark SKProductsRequest

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    //Grab the first product in the list (We only have one feature at the moment)
    NSArray *products = response.products;
    self.productToPurchase = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
    if (self.productToPurchase)
    {
        NSLog(@"Product title: %@" , self.productToPurchase.localizedTitle);
        NSLog(@"Product description: %@" , self.productToPurchase.localizedDescription);
        NSLog(@"Product price: %@" , self.productToPurchase.price);
        NSLog(@"Product id: %@" , self.productToPurchase.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LessonProductsRequestFetchedNotification object:self userInfo:nil];
    
}

#pragma mark SKPaymentTransactionObserver

//Called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    NSLog(@" $$$ PAYMENT QUEUE UPDATED TRANSACTIONS $$$ ");
    
    [self showLoadingMaskWithDuration:0.5];
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    //NOTE: This method will automatically invoke paymentQueue: updatedTransactions for the returned products, which then calls provideContent for that product
    NSLog(@"Received restored transactions: %i", queue.transactions.count);
    
    [self showLoadingMaskWithDuration:0.5];
    
    //Keep a list
    self.purchasedProductIDs = [[[NSMutableArray alloc] init] autorelease];
    for (SKPaymentTransaction *transaction in queue.transactions) { //For each transaction in the queue
        
        //Add the ID to our list
        NSString *productID = transaction.payment.productIdentifier;
        [self.purchasedProductIDs addObject:productID];
        
    }
    
    [self hideLoadingMaskWithDuration:0.5];
    
    //Alert the user that the restoration is complete
    UIAlertView* restorationAlert = [[UIAlertView alloc] initWithTitle:@"Purchases Restored" message:@"Your previously purchased products have been restored." delegate:nil cancelButtonTitle:@"Thanks!" otherButtonTitles:nil];
    [restorationAlert show];
    [restorationAlert release];

}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    [self hideLoadingMaskWithDuration:0.5];
    
}

#pragma mark - Actions -

-  (IBAction) back:(id)sender {
    
    //Post cancellation - nil userInfo
    [[NSNotificationCenter defaultCenter] postNotificationName:LessonSelectionCompleteNotification object:self userInfo:nil];
    
}//End done:

- (IBAction) syncPurchases:(id)sender {
    
    [self showLoadingMaskWithDuration:0.5];
    
    if(![self connectedToNetwork]) {
        
        //Not connected!!
        UIAlertView* networkErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Network connection failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [networkErrorAlertView show];
        [networkErrorAlertView release];
        
        [self hideLoadingMaskWithDuration:0.5];
        
    } else {
        
        //Connection verified
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }

    
}//End syncPurchases:

- (void) buyLesson101: (id)sender {
    //Buy button has been pushed for lesson (Future Features: lesson number is button's tag)
    
    if (![self connectedToNetwork]) { //Network connection failed
        
        //Not connected!!
        UIAlertView* networkErrorAlertView = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Network connection failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [networkErrorAlertView show];
        [networkErrorAlertView release];
        
        [self hideLoadingMaskWithDuration:0.5];
        
    }
    else {
        //Connection Verified
        
        [self showLoadingMaskWithDuration:0.5];
        
        if (self.productToPurchase && self.productToPurchase.productIdentifier) { //Product object and its identifier not null/nil
        
            //Add payment to the queue (start transaction)
            SKPayment *payment = [SKPayment paymentWithProduct:self.productToPurchase];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        }
        else { //Product or its identifier are invalid!!
            
            [self hideLoadingMaskWithDuration:0.5];
        
        }
    }
    
    
}//End buyLesson101:

#pragma mark - Store -

// *** Call this method once on startup ***
- (void)loadStore {
    
    // Restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Get the product data
    [self requestLessonProductData];
    
}//End loadStore

- (BOOL)canMakePurchases {
    
    return [SKPaymentQueue canMakePayments];
    
}//End canMakePurchases

- (BOOL) connectedToNetwork {
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL internet;
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
        internet = NO;
    } else {
        internet = YES;
    }
    return internet;
    
}

- (void) requestLessonProductData {
    
    NSSet *productIdentifiers = [NSSet setWithObject:kIAPLesson101ProductID];
    self.productsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers] autorelease];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
    
}//End requestLessonProductData

- (void)purchaseLessonProduct:(SKProduct*)product {
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}//End purchaseLessonProduct:

#pragma mark Purchase Helpers

//Saves a record of the transaction by storing the receipt to disk
- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    
    if ([transaction.payment.productIdentifier isEqualToString:kIAPLesson101ProductID])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"Lesson101TransactionReceipt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)provideContent:(NSString *)productId {
    //Enable the purchased content
    
    NSLog(@"provideContent:");
    
    NSInteger lessonNumberForProduct = -1; //Initalize to error value
    
    if ([productId isEqualToString:kIAPLesson101ProductID]) { //Lesson 101 Product
        
        lessonNumberForProduct = 101;
        
        // *** RRVLocalAuthority ***
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RRVLocalAuthority.plist"];
  
        //THIS FILE SHOULD BE GARUNTEED TO EXIST.
            //App delegate: if not found at path, it is copied from mainBundle to Documents.
        if([fileManager fileExistsAtPath:plistPath]){ //File found. Update for content.
            
            //Load verified lessons dictionary from locally stored reference
            NSMutableDictionary* localAuthorityDict = [[NSMutableDictionary dictionaryWithContentsOfFile:plistPath] retain];
            NSMutableDictionary* purchasedLessonsDict = [[NSMutableDictionary dictionaryWithDictionary:[localAuthorityDict objectForKey:@"PurchasedLessons"]] retain]; //Ensure retain
            NSDictionary* completedLessonsDict = [[NSDictionary dictionaryWithDictionary:[localAuthorityDict objectForKey:@"CompletedLessons"]] retain];
            
            //Set flag for lesson
            [purchasedLessonsDict setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", lessonNumberForProduct]];
            
            //Update the RRVLocalAuthority (Overwrite file)
            NSMutableDictionary* localAuthorityUpdateDict = [NSMutableDictionary dictionaryWithDictionary:localAuthorityDict];
            [localAuthorityUpdateDict setObject:completedLessonsDict forKey:@"CompletedLessons"];
            [localAuthorityUpdateDict setObject:purchasedLessonsDict forKey:@"PurchasedLessons"];
            [localAuthorityUpdateDict writeToFile:plistPath atomically:YES];
            
            //Release retained dictionaries
            [localAuthorityDict release];
            [purchasedLessonsDict release];
            [completedLessonsDict release];
            
        }
        
        //Refresh the datasource
        self.lessonsPurchased = [self purchasedLessonsList];
        
        //Update the table (delay to give time to write/refresh data)
        [self.lessonsTableView performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
        
        NSLog(@"Updated Table");
        
    }//End if{} (productID = lesson101)
    
}//End provideContent:

- (void)addCellForLessonNumber:(NSInteger)lessonNumberForCell {
    
    //Determine the indexPath for the cell
    NSInteger rowNumber = (lessonNumberForCell % 100) - 1;
    NSInteger sectionNumber = lessonNumberForCell;
    while (sectionNumber % 100 != 0) { sectionNumber--; } //Decrement until multiple of 100
    sectionNumber /= 100; //Divide by the 100 seperation range to get a single digit (should be 1-9)
    NSIndexPath* indexPathForCell = [[NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber] retain];
    
    //Prompt tableView to put a cell there
    [self.lessonsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathForCell] withRowAnimation:UITableViewRowAnimationFade];
    
    [indexPathForCell release];
    
}//End addCellForLessonNumber:

//Removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    
    NSLog(@"finishedTransaction");
    
    //Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        //Send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseSucceededNotification object:self userInfo:nil];
    }
    else
    {
        //Send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseFailedNotification object:self userInfo:nil];
    }
    
    [self hideLoadingMaskWithDuration:0.5];
}

//Called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@" $$$ completedTransaction $$$ ");
    
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//Called when a transaction has been restored and and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@" $$$ restoreTransaction $$$ ");
    
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//Called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@" !?$$$ failedTransaction $$$!? ");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@" $$$ ERROR $$$ ");
        
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        NSLog(@" $NO$ User has cancelled the transaction $NO$ ");
        
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [self hideLoadingMaskWithDuration:0.5];
    }
    
}

#pragma mark - Utility -

- (void) showLoadingMaskWithDuration:(CGFloat)duration {
    
    //Disable the tableView, add & show the loadingMask
    [self.lessonsTableView setUserInteractionEnabled:NO];
    [self.view addSubview:self.loadingView];
    [self.loadingIndicator startAnimating];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         self.loadingView.alpha = 1.0;
                     
                     } completion:^(BOOL finished) {
                         //Afterwards...
                         
                     }];
    
}//End showLoadingMask

- (void) hideLoadingMaskWithDuration:(CGFloat)duration {
    
    //Hide the loadingMask, remove it, & re-enable the tableView
    [self.loadingIndicator stopAnimating];
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         self.loadingView.alpha = 0.0;
                         
                         
                     } completion:^(BOOL finished) {
                         //Afterwards...
                         
                         [self.loadingView removeFromSuperview];
                         [self.lessonsTableView setUserInteractionEnabled:YES];
                     }];
    
}//End hideLoadingMask

- (void) postLessonSelection: (NSInteger)lessonNumberSelected {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LessonSelectionCompleteNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[NSNumber numberWithInt:lessonNumberSelected]] forKey:kLessonSelectionArrayInDictionary]];
    
}//End postLessonSelection:

- (void) postLessonSelections {
    
    //Buildable list of selected lessons
    NSMutableArray* lessonsSelected = [[[NSMutableArray alloc] init] autorelease];
    
    //Determine selected lesson numbers by scrolling the cells
    for (NSInteger section = 0; section < [self.lessonsTableView numberOfSections]; section++) { //Each section in tableView
        for (NSInteger row = 0; row < [self.lessonsTableView numberOfRowsInSection:section]; row++) { //Each row in tableView
            
            //Note the index path
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if ([[self.lessonsTableView cellForRowAtIndexPath:indexPath] isHighlighted]) { //If cell is highlighted
                //This cell is highlighted
                
                NSLog(@"Cell highlighted at Section %d, Row %d", [indexPath section], [indexPath row]);
                
                //Add corresponding lesson number from array to posting array
                [lessonsSelected addObject:[NSNumber numberWithInt:[self lessonNumberFromIndexPath:indexPath]]];
                
            }//End if{} (cell is highlighted)
            else {
                NSLog(@"Cell NOT highlighted at row: %d", [indexPath row]);
            }
            
        }//End for{} (each row)
    }//End for{} (each section)
    
    //Post a notification with userInfo dictionary - NSArray of lesson numbers, key = kLessonSelectionArrayInDictionary
    if ([lessonsSelected count] > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LessonSelectionCompleteNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:lessonsSelected] forKey:kLessonSelectionArrayInDictionary]];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LessonSelectionCompleteNotification object:self userInfo:nil];
    }
    
}//End postLessonSelections

-(NSIndexPath*)indexPathFromLessonNumber:(NSInteger)lessonNumberForPath {
    //Determine the indexPath for the lessonNumber
    
    //Row
    NSInteger rowNumber = (lessonNumberForPath % 100) - 1;
    
    //Section
    NSInteger sectionNumber = lessonNumberForPath;
    while (sectionNumber % 100 != 0) { sectionNumber--; } //Decrement until multiple of 100
    sectionNumber /= 100; //Divide by the 100 seperation range to get level digit (should be 1-9)
    sectionNumber--; //Sections start at zero, while Levels start at 1 (section = level - 1)
    
    return [NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber];
    
}//End indexPathFromLessonNumber

-(NSInteger)lessonNumberFromIndexPath:(NSIndexPath*)indexPathForLessonNumber {
    
    return ((indexPathForLessonNumber.section+1) * 100) + (indexPathForLessonNumber.row + 1);
    
}//End lessonNumberFromIndexPath:

- (NSArray*)availableLessonsList {
    //Returns an array of available lesson numbers, whose story files exist (NSNumber integers)
    
    //Buildable array of lesson numbers to display - will be synced to self.lessonsTableCellMap
    NSMutableArray* lessonsList = [[[NSMutableArray alloc] init] autorelease];
    
    //Lesson numbers increment by 100, from 100 - 900
    for (NSInteger level = 100; level <= 900; level += 100) { //Each level
        
        //Lesson subnumber (added to level) 1-20
        for (NSInteger lessonSubnumber = 1; lessonSubnumber <= 20; lessonSubnumber++) { //Each lesson in level
            
            //Assemble correct lesson number
            NSInteger lessonNumberProper = level+lessonSubnumber;
            
            NSString* path = [[NSBundle mainBundle] bundlePath];
            NSString* filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"rrv%ds.txt", lessonNumberProper]];
            NSFileManager* fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:filePath]) { //File exists
                NSLog(@"Lesson %d story exists.", lessonNumberProper);
                
                //Add lesson number to verified array - must wrap in NSNumber
                [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                
            }//End if{} (lesson purchased)
            else { //BOOL value for lesson is NO, invalid, or does not exist
                NSLog(@"Lesson %d story missing.", lessonNumberProper);
                //Lesson not verified, omit from list
                
            }//End else{} (lesson not purchased)
        }//End for{} (each lesson in level)
    }//End for{} (each level)
    
    //Return verified lesson numbers
    return [NSArray arrayWithArray:lessonsList];
}

- (NSArray*)purchasedLessonsList {
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
    if([fileManager fileExistsAtPath:plistPath]){ //File found.
        NSDictionary* verifiedLessonsDict = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"PurchasedLessons"] retain]; //Ensure retain
    
        //Lesson numbers increment by 100, from 100 - 900
        for (NSInteger level = 100; level <= 900; level += 100) { //Each level
        
            //Lesson subnumber (added to level) 1-20
            for (NSInteger lessonSubnumber = 1; lessonSubnumber <= 20; lessonSubnumber++) { //Each lesson in level
            
                //Assemble correct lesson number
                NSInteger lessonNumberProper = level+lessonSubnumber; 
            
                //Check BOOL value for lesson, key = lesson number as NSString
                BOOL lessonVerified = [[verifiedLessonsDict objectForKey:[NSString stringWithFormat:@"%d", lessonNumberProper]] boolValue];
            
                if (lessonVerified) { //BOOL value from dictionary is YES
                    NSLog(@"Lesson %d PURCHASED.", lessonNumberProper);
                    //Lesson is verified
                
                    //Add lesson number to verified array - must wrap in NSNumber
                    [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                
                }//End if{} (lesson purchased)
                else { //BOOL value for lesson is NO, invalid, or does not exist
                    NSLog(@"Lesson %d not purchased.", lessonNumberProper);
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
    
}//End purchasedLessonsList

- (NSArray*)completedLessonsList {
    //Returns an array of verified lesson numbers (NSNumber integers)
    
    //Buildable array of lesson numbers to display - will be synced to self.lessonsTableCellMap
    NSMutableArray* lessonsList = [[[NSMutableArray alloc] init] autorelease];
    
    //Load verified lessons dictionary from locally stored reference
    // *** RRVLocalAuthority ***
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"RRVLocalAuthority.plist"];
    
    if ([fileManager fileExistsAtPath:plistPath]) { //File found.
        
        NSDictionary* completedLessonsDict = [[[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"CompletedLessons"] retain]; //Ensure retain
    
    //Lesson numbers increment by 100, from 100 - 900
    for (NSInteger level = 100; level <= 900; level += 100) { //Each level
        
        //Lesson subnumber (added to level) 1-20
        for (NSInteger lessonSubnumber = 1; lessonSubnumber <= 20; lessonSubnumber++) { //Each lesson in level
            
            //Assemble correct lesson number
            NSInteger lessonNumberProper = level+lessonSubnumber;
            
            //Check BOOL value for lesson, key = lesson number as NSString
            BOOL lessonVerified = [[completedLessonsDict objectForKey:[NSString stringWithFormat:@"%d", lessonNumberProper]] boolValue];
            
            if (lessonVerified) { //BOOL value from dictionary is YES
                NSLog(@"Lesson %d completed.", lessonNumberProper);
                //Lesson is verified
                
                //Add lesson number to verified array - must wrap in NSNumber
                [lessonsList addObject:[NSNumber numberWithInt:lessonNumberProper]];
                
            }//End if{} (lesson purchased)
            else { //BOOL value for lesson is NO, invalid, or does not exist
                NSLog(@"Lesson %d incomplete.", lessonNumberProper);
                //Lesson not verified, omit from list
                
            }//End else{} (lesson not purchased)
        }//End for{} (each lesson in level)
    }//End for{} (each level)
    
    //Release retained dictionary
    [completedLessonsDict release];
    
    }//End if{} (RRVLocalAuthority.plist exists)
    else {
        
        NSLog(@"RRVLocalAuthority not found!");
        
    }
    
    //Return verified lesson numbers
    return [NSArray arrayWithArray:lessonsList];
    
}//End completedLessonsList

- (BOOL) hasAvailableLessonNumber:(NSInteger)lessonNumberToVerify { NSLog(@"hasAvailableLessonNumber:%d", lessonNumberToVerify);
    
    BOOL isAvailable = NO;
    
    for (NSInteger verifiedLessonIndex = 0; verifiedLessonIndex < [self.lessonsAvailable count]; verifiedLessonIndex++) { //For each verified lesson
        
        NSInteger lessonNumberBeingChecked = [[self.lessonsAvailable objectAtIndex:verifiedLessonIndex] intValue];
        
        if (lessonNumberBeingChecked == lessonNumberToVerify) { //If lesson number matches
            isAvailable = YES;
        }
        
    }
    
    return isAvailable;
    
}//End isPurchased

- (BOOL) hasPurchasedLessonNumber:(NSInteger)lessonNumberToVerify { NSLog(@"hasPurchasedLessonNumber:%d", lessonNumberToVerify);
    
    BOOL isPurchased = NO;
    
    for (NSInteger verifiedLessonIndex = 0; verifiedLessonIndex < [self.lessonsPurchased count]; verifiedLessonIndex++) { //For each verified lesson
        
        NSInteger lessonNumberBeingChecked = [[self.lessonsPurchased objectAtIndex:verifiedLessonIndex] intValue];
        
        if (lessonNumberBeingChecked == lessonNumberToVerify) { //If lesson number matches
            isPurchased = YES;
        }
        
    }
    
    return isPurchased;
    
}//End isPurchased

- (BOOL) hasCompletedLessonNumber:(NSInteger)lessonNumberToVerify { NSLog(@"hasCompletedLessonNumber:%d", lessonNumberToVerify);
    
    BOOL isComplete = NO;
    
    for (NSInteger verifiedLessonIndex = 0; verifiedLessonIndex < [self.lessonsCompleted count]; verifiedLessonIndex++) { //For each verified lesson
        
        NSInteger lessonNumberBeingChecked = [[self.lessonsCompleted objectAtIndex:verifiedLessonIndex] intValue];
        
        if (lessonNumberBeingChecked == lessonNumberToVerify) { //If lesson number matches
            isComplete = YES;
        }
        
    }
    
    return isComplete;
    
}//End hasCompletedLessonNumber:

- (BOOL) readyToTakeLessonNumber:(NSInteger)lessonNumberToCheck {
    
    NSLog(@"readyToTake?");
    
    BOOL readyToLearn = NO;
    
    if ([self hasPurchasedLessonNumber:lessonNumberToCheck]) { // Lesson is purchased
        
        NSLog(@"readyToTake? Purchased");
        if ( [self hasCompletedLessonNumber:lessonNumberToCheck-1] || (lessonNumberToCheck-1)%100 == 0 ) { // Previous lesson completed or first lesson in level
            
            NSLog(@"readyToTake? Purchased & Completed %d, or is first in level (<-- if number is multiple of 100)", lessonNumberToCheck-1);
            readyToLearn = YES;
            
        }
    }
    else {
        
        NSLog(@"readyToTake? NOT PURCHASED.");
    }
    
    return readyToLearn;
    
}//End readyToTakeLessonNumber:

- (NSArray *)titlesForLessons:(NSArray *)lessonNumbersArray {
    
    //Buildable list
    NSMutableArray* titles = [NSMutableArray arrayWithCapacity:[lessonNumbersArray count]];
    
    //For each lesson number
    for (NSInteger lessonNumberIndex = 0; lessonNumberIndex < [lessonNumbersArray count]; lessonNumberIndex++) {
        
        //Load text file for lesson number & grab title. Add to list.
        NSInteger lessonNumber = [[lessonNumbersArray objectAtIndex:lessonNumberIndex] intValue];
        [titles addObject:[self titleFromLessonNumber:lessonNumber]];
        
    }
    
    return [NSArray arrayWithArray:titles];
    
}//End titlesForLessons:

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
    
    for (NSInteger i = 0; i < [textChunksFromFile count]; i++) {//for each chunk of text
        
        if (i == 0 || (i%2)) {//if number is zero or odd
            
            //Index 0 is empty (file starts with separator)
            //ODD indices are labels
        }//End else{} (number is even)
        else{//if number is odd
            
            //It is story text - trim it and add to lessonStoryText array
            NSString* trimmedChunkOfText = [[textChunksFromFile objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [lessonStoryText addObject:trimmedChunkOfText];
        }//End else{} (number is odd)
    }//End for{} (each of chunk of text)
    
    return [lessonStoryText objectAtIndex:0];
    
}//End textArrayForLesson

#pragma mark Programmatically Created Subviews

-(UIButton*) thumbnailButtonForLessonNumber:(NSInteger)lessonNumberForThumbnail grayedOut:(BOOL)grayedOut {
    
    //Thumbnail button
    UIButton* lessonPreviewThumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lessonPreviewThumbnailButton.layer.cornerRadius = 8.0f;
    lessonPreviewThumbnailButton.layer.masksToBounds = YES;
    //button.imageView.layer.cornerRadius = 12.0f;
    //button.imageView.layer.masksToBounds = YES;
    lessonPreviewThumbnailButton.clipsToBounds = YES;
    lessonPreviewThumbnailButton.contentMode = UIViewContentModeScaleAspectFill; //BGImage
    lessonPreviewThumbnailButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //Image
    NSString* lessonIconImageName = @"";
    if (grayedOut) lessonIconImageName = [NSString stringWithFormat:@"rrv%dicon_gray.png", lessonNumberForThumbnail];
    else lessonIconImageName = [NSString stringWithFormat:@"rrv%dicon.png", lessonNumberForThumbnail];
    [lessonPreviewThumbnailButton setBackgroundImage:[UIImage imageNamed:lessonIconImageName] forState:UIControlStateNormal];
    //[lessonPreviewThumbnail setBackgroundImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateSelected];
    //[lessonPreviewThumbnail setBackgroundImage:[UIImage imageNamed:@"audioBtn_down.png"] forState:UIControlStateHighlighted];
    //[lessonPreviewThumbnail setBackgroundImage:[UIImage imageNamed:@"audioBtn_disabled.png"] forState:UIControlStateDisabled];
    
    //IF LOCKED, PUT LOCK IMAGE AS REGULAR BUTTON IMAGE (will appear over background image above)
    
    //Settings
    lessonPreviewThumbnailButton.frame = CGRectMake(0, 0, self.lessonsTableView.rowHeight, self.lessonsTableView.rowHeight);
    [lessonPreviewThumbnailButton setUserInteractionEnabled:NO]; //Remove this call & perform a selector for event to enable this button
    
    return lessonPreviewThumbnailButton;
    
}//End thumbnailButtonForLessonNumber: grayedOut:

-(UIButton*) buyButtonWithTag:(NSInteger)tag {
    
    //Load image
    UIImage *image = [UIImage imageNamed:@"button_red.png"];
    
    //Stretchable version
    float width = image.size.width / 2, height = image.size.height / 2;
    UIImage *stretch = [image stretchableImageWithLeftCapWidth:width topCapHeight:height];
    
    //Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonWidth = 66.0f;
    if (self.appRunningOnIPad) {
        buttonWidth = 88.0f;
    }
    button.bounds = CGRectMake(0.0f, 0.0f, buttonWidth, 33.0f);
    [button setBackgroundImage:stretch forState:UIControlStateNormal];
    [button setTitle:@"Buy" forState:UIControlStateNormal];
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button setShowsTouchWhenHighlighted:YES];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setAdjustsImageWhenDisabled:YES];
    button.tag = tag;
    
    //Attach callback target
    [button addTarget:self action:@selector(buyLesson101:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
    
}

-(UIButton*) comingSoonButtonWithTag:(NSInteger)tag {

    //Load image
    UIImage *image = [UIImage imageNamed:@"button_gray.png"];
    
    //Stretchable version
    float width = image.size.width / 2, height = image.size.height / 2;
    UIImage *stretch = [image stretchableImageWithLeftCapWidth:width topCapHeight:height];
    
    //Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonWidth = 66.0f;
    if (self.appRunningOnIPad) {
        buttonWidth = 88.0f;
    }
    button.bounds = CGRectMake(0.0f, 0.0f, buttonWidth, 33.0f);
    [button setBackgroundImage:stretch forState:UIControlStateNormal];
    [button setTitle:@"Soon!" forState:UIControlStateNormal];
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button setShowsTouchWhenHighlighted:NO];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setAdjustsImageWhenDisabled:YES];
    button.tag = tag;
    
    button.userInteractionEnabled = NO;
    return button;
    
}

@end
