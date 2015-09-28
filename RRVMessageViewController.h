//
//  RRVMessageViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 9/8/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All Right Reserved.
//

#import <UIKit/UIKit.h>

@interface RRVMessageViewController : UIViewController {
    
    //Data
    BOOL runningOniPad;
    BOOL autoplayEnabled;
    NSString* messageTitle;
    NSString* messageText;
    
    //Views
    UIImageView* backgroundImageView;
    UILabel* titleLabel;
    UITextView* textView;
    UIButton* yesButton;
    UIButton* noButton;
    
    //Controllers
    
}

////PROPERTIES////

//Data
@property BOOL autoplayEnabled;
@property BOOL runningOniPad;
@property (nonatomic, copy) NSString* messageTitle;
@property (nonatomic, copy) NSString* messageText;

//Views
@property (nonatomic, retain) IBOutlet UIImageView* backgroundImageView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) IBOutlet UIButton* yesButton;
@property (nonatomic, retain) IBOutlet UIButton* noButton;

//Controllers

////METHODS////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil iPad:(BOOL)isOniPad title:(NSString*)titleOfMessage description:(NSString*)messageBody;

//IBActions
- (IBAction)quitMessage:(id)sender;

//Utility
-(void) saveAutoplayFlagToSettings:(BOOL)shouldAutoplay;

@end
