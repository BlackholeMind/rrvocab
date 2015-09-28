//
//  WordBurstVictoryVC.h
//  RRV101
//
//  Created by Brian C. Grant on 5/17/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordBurstVictoryVC : UIViewController {
    
    //Data
    NSInteger score;
    NSInteger correctCount;
    NSInteger incorrectCount;
    CGFloat accuracy;
    
    //Views
    UILabel* scoreNumberLabel;
    UILabel* correctCountLabel;
    UILabel* incorrectCountLabel;
    UILabel* accuracyLabel;
    UILabel* commentLabel;
    
    //Controllers
    
}
////PROPERTIES////

//Data
@property NSInteger score;
@property NSInteger correctCount;
@property NSInteger incorrectCount;
@property CGFloat accuracy;

//Views
@property (nonatomic, retain) IBOutlet UILabel* scoreNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel* correctCountLabel;
@property (nonatomic, retain) IBOutlet UILabel* incorrectCountLabel;
@property (nonatomic, retain) IBOutlet UILabel* accuracyLabel;
@property (nonatomic, retain) IBOutlet UILabel* commentLabel;

//Controllers


////METHODS////
//Constructors
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil gameVictoryInfo:(NSArray*)victoryInfoArray;

//IBActions
- (IBAction) playAgain:(id)sender;
- (IBAction) quitGame:(id)sender;

@end
