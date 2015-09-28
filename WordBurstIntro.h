//
//  WordBurstIntro.h
//  RRV101
//
//  Created by Brian C. Grant on 5/14/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRVConstants.txt"

@interface WordBurstIntro : UIViewController {
    
    //Data
    NSInteger wordListCount;
    NSInteger gameCondition;
    CGFloat victoryNumber;
    BOOL reuseWords;
    NSInteger minScore;
    NSInteger maxScore;
    
    //Views
    UILabel* victoryNumberLabel;
    UILabel* victoryNumberDescription;
    UISegmentedControl* gameModeSegmentedControl;
    UIButton* reuseWordsButton;
    UIButton* endlessButton;
    UISlider* victoryNumberSlider;
    UIButton* quitGameButton;
    UIButton* playGameButton;
    
    //Controllers
    
}
////PROPERTIES////

//Data
@property NSInteger wordListCount;
@property NSInteger gameCondition;
@property CGFloat victoryNumber;
@property BOOL reuseWords;
@property NSInteger minScore;
@property NSInteger maxScore;

//Views
@property (nonatomic, retain) IBOutlet UILabel* victoryNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel* victoryNumberDescription;
@property (nonatomic, retain) IBOutlet UISegmentedControl* gameModeSegmentedControl;
@property (nonatomic, retain) IBOutlet UIButton* reuseWordsButton;
@property (nonatomic, retain) IBOutlet UIButton* endlessButton;
@property (nonatomic, retain) IBOutlet UISlider* victoryNumberSlider;
@property (nonatomic, retain) IBOutlet UIButton* quitGameButton;
@property (nonatomic, retain) IBOutlet UIButton* playGameButton;

//Controllers

////METHODS////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil wordListCount:(NSInteger)listCount;
- (IBAction) gameModeChanged:(id)sender;
- (IBAction) reuseWordsChanged:(id)sender;
- (IBAction) victorySliderChanged:(id)sender;
- (IBAction) endlessButtonChanged:(id)sender;
- (IBAction) playGameButtonPushed:(id)sender;
- (IBAction) quitGameButtonPushed:(id)sender;

@end
