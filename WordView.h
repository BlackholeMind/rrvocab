//
//  WordView.h
//  RRV101
//
//  Created by Brian C. Grant on 9/27/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class WordObject;
@class VideoPlayerViewController;

@interface WordView : UIViewController <AVAudioPlayerDelegate, UIAlertViewDelegate> {
    
    //Data
    WordObject* wordObject;
    BOOL presentedModally;
    BOOL infoAutoplayCycleComplete;
    
    //Views
    UINavigationBar* wordBar;
    UIView* videoView; 
    
    UIActivityIndicatorView* movieIndicator;
    UILabel* movieIndicatorLabel;
    UIButton* infoMeaningButton;
    UIButton* infoUsageButton;
    UITextView* infoTextView;
    UIButton* levelIndicatorButton;
    UIButton* masteryIndicatorButton;
    
    //Controllers & Media
    VideoPlayerViewController* videoController;
    AVAudioPlayer* wordAudioPlayer;
    AVAudioPlayer* definitionAudioPlayer;
    AVAudioPlayer* sentenceAudioPlayer;
    
}
////PROPERTIES////

//Data
@property (nonatomic, retain) WordObject* wordObject;
@property BOOL presentedModally;
@property BOOL infoAutoplayCycleComplete;

//Views
@property (nonatomic, retain) IBOutlet UINavigationBar* wordBar;
@property (nonatomic, retain) IBOutlet UIView* videoView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* movieIndicator;
@property (nonatomic, retain) IBOutlet UILabel* movieIndicatorLabel;
@property (nonatomic, retain) IBOutlet UIButton* infoMeaningButton;
@property (nonatomic, retain) IBOutlet UIButton* infoUsageButton;
@property (nonatomic, retain) IBOutlet UITextView* infoTextView;
@property (nonatomic, retain) IBOutlet UIButton* levelIndicatorButton;
@property (nonatomic, retain) IBOutlet UIButton* masteryIndicatorButton;

//Controllers & Media
@property (nonatomic, retain) VideoPlayerViewController* videoController;
@property (nonatomic, retain) AVAudioPlayer* wordAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* definitionAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* sentenceAudioPlayer;

////METHODS////
//PUBLIC
//Constructors

//PRIVATE

//Constructors
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forWordObject:(WordObject*)word modalPresentation:(BOOL)shouldPresentModally;

//IBActions
 //wordBar
-(IBAction) closeWordView: (id)sender;
-(IBAction) pronounceWordForView: (id)sender;
 //infoView
-(IBAction) readInfo: (id)sender;
-(IBAction) replay: (id)sender;
-(IBAction) infoSelect:(id)sender;
 //Indicators
-(IBAction) levelDetail: (id)sender;
-(IBAction) masteryDetail: (id)sender;
//Utility
-(void) setWordLabelForTitleBar;
-(void) configureVideo;
-(void) configureAudio;
-(void) stopAllAudioPlayers;

@end
