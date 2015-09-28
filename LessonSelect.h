//
//  LessonSelect.h
//  RRV101
//
//  Created by Brian C. Grant on 5/28/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>

@interface LessonSelect : UIViewController <UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    
    //Data
    BOOL appRunningOnIPad;
    BOOL multipleLessonsSelectable;
    BOOL backButtonEnabled;
    NSMutableArray* purchasedProductIDs;
    NSArray* lessonsAvailable;
    NSArray* lessonsPurchased;
    NSArray* lessonsCompleted;
    NSArray* lessonTitles;
    SKProduct* productToPurchase;
    SKProductsRequest* productsRequest;
    
    //Views
    UITableView* lessonsTableView;
    UIToolbar* titleBar;
    UIBarButtonItem* backButton;
        //Loading View
    UIView* loadingView;
    UIActivityIndicatorView* loadingIndicator;
    
    //Controllers
    
}
////PROPERTIES////

//Data
@property BOOL appRunningOnIPad;
@property BOOL multipleLessonsSelectable;
@property BOOL backButtonEnabled;
@property (nonatomic, retain) NSMutableArray* purchasedProductIDs;
@property (nonatomic, retain) NSArray* lessonsAvailable;
@property (nonatomic, retain) NSArray* lessonsPurchased;
@property (nonatomic, retain) NSArray* lessonsCompleted;
@property (nonatomic, retain) NSArray* lessonTitles;
@property (nonatomic, retain) SKProduct* productToPurchase;
@property (nonatomic, retain) SKProductsRequest* productsRequest;

//Views
@property (nonatomic, retain) IBOutlet UITableView* lessonsTableView;
@property (nonatomic, retain) IBOutlet UIToolbar* titleBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* backButton;
    //Loading View
@property (nonatomic, retain) IBOutlet UIView* loadingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* loadingIndicator;

////METHODS////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil multipleLessons:(BOOL)enableMultipleLessons backButton:(BOOL)enableBackButton;

//Actions
- (IBAction) back:(id)sender;
- (IBAction) syncPurchases:(id)sender;
- (void) buyLesson101:(id)sender;

//Store
- (void)loadStore;
- (BOOL)connectedToNetwork;
- (BOOL)canMakePurchases;
- (void)requestLessonProductData;
- (void)purchaseLessonProduct:(SKProduct*)product;
    //Purchase Helpers
- (void)recordTransaction:(SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString*)productID;
- (void)addCellForLessonNumber:(NSInteger)lessonNumberForCell;
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;

//Utility
- (void) showLoadingMaskWithDuration:(CGFloat)duration;
- (void) hideLoadingMaskWithDuration:(CGFloat)duration;
- (void) postLessonSelections;
- (void) postLessonSelection: (NSInteger)lessonNumberSelected;
- (NSIndexPath*) indexPathFromLessonNumber:(NSInteger)lessonNumberForPath;
- (NSInteger) lessonNumberFromIndexPath:(NSIndexPath*)indexPathForLessonNumber;
- (NSArray*) availableLessonsList;
- (NSArray*) purchasedLessonsList;
- (NSArray*) completedLessonsList;
- (BOOL) hasAvailableLessonNumber:(NSInteger)lessonNumberToVerify;
- (BOOL) hasPurchasedLessonNumber:(NSInteger)lessonNumberToVerify;
- (BOOL) hasCompletedLessonNumber:(NSInteger)lessonNumberToVerify;
- (BOOL) readyToTakeLessonNumber:(NSInteger)lessonNumberToCheck;
- (NSArray*) titlesForLessons:(NSArray*)lessonNumbersArray;
- (NSString*) titleFromLessonNumber:(NSInteger)lessonNumberInt;
    //Views
- (UIButton*) thumbnailButtonForLessonNumber:(NSInteger)lessonNumberForThumbnail grayedOut:(BOOL)grayedOut;
- (UIButton*) buyButtonWithTag:(NSInteger)tag;
- (UIButton*) comingSoonButtonWithTag:(NSInteger)tag;

@end
