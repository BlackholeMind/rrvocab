//
//  ThesaurusVC_iPad.h
//  RRV101
//
//  Created by Brian C. Grant on 6/22/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

@class WordObject;
@class WordListObject;
@class VideoPlayerViewController;

@interface ThesaurusVC_iPad : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate> {

    //Data
    WordObject* wordObject;
    NSInteger infoType;
    BOOL infoAutoplayCycleComplete;
        //TableView Data
    WordListObject* thesaurusList;
    NSMutableArray* thesaurusSections;
    NSMutableArray* sectionA;
    NSMutableArray* sectionB;
    NSMutableArray* sectionC;
    NSMutableArray* sectionD;
    NSMutableArray* sectionE;
    NSMutableArray* sectionF;
    NSMutableArray* sectionG;
    NSMutableArray* sectionH;
    NSMutableArray* sectionI;
    NSMutableArray* sectionJ;
    NSMutableArray* sectionK;
    NSMutableArray* sectionL;
    NSMutableArray* sectionM;
    NSMutableArray* sectionN;
    NSMutableArray* sectionO;
    NSMutableArray* sectionP;
    NSMutableArray* sectionQ;
    NSMutableArray* sectionR;
    NSMutableArray* sectionS;
    NSMutableArray* sectionT;
    NSMutableArray* sectionU;
    NSMutableArray* sectionV;
    NSMutableArray* sectionW;
    NSMutableArray* sectionX;
    NSMutableArray* sectionY;
    NSMutableArray* sectionZ;
    
    //Views
    UIButton* doneButton;
    UIImageView* dictionaryBGImageView;
    UITableView* wordTableView;
    UIView* wordAreaView;
    UIButton* pronunciationButton;
    UILabel* wordLabel;
    UIView* wordMediaAreaView;
    UIActivityIndicatorView* wordMediaActivityIndicator;
    UILabel* wordMediaActivityLabel;
    UIButton* replayButton;
    UIView* infoAreaView;
    UIButton* readInfoButton;
    UILabel* infoLabel;
    UITextView* infoTextView;
    UIButton* infoToggleButton;
    UIButton* masteryIndicatorButton;
    UIButton* levelIndicatorButton;
    
    //Controllers & Media
    VideoPlayerViewController* videoController;
    AVAudioPlayer* wordAudioPlayer;
    AVAudioPlayer* definitionAudioPlayer;
    AVAudioPlayer* sentenceAudioPlayer;
    
}
////PROPERTIES////

//Data
@property (nonatomic, retain) WordObject* wordObject;
@property NSInteger infoType;
@property BOOL infoAutoplayCycleComplete;
    //TableView Data
@property (nonatomic, retain) WordListObject* thesaurusList;
@property (nonatomic, retain) NSMutableArray* thesaurusSections;
@property (nonatomic, retain) NSMutableArray* sectionA;
@property (nonatomic, retain) NSMutableArray* sectionB;
@property (nonatomic, retain) NSMutableArray* sectionC;
@property (nonatomic, retain) NSMutableArray* sectionD;
@property (nonatomic, retain) NSMutableArray* sectionE;
@property (nonatomic, retain) NSMutableArray* sectionF;
@property (nonatomic, retain) NSMutableArray* sectionG;
@property (nonatomic, retain) NSMutableArray* sectionH;
@property (nonatomic, retain) NSMutableArray* sectionI;
@property (nonatomic, retain) NSMutableArray* sectionJ;
@property (nonatomic, retain) NSMutableArray* sectionK;
@property (nonatomic, retain) NSMutableArray* sectionL;
@property (nonatomic, retain) NSMutableArray* sectionM;
@property (nonatomic, retain) NSMutableArray* sectionN;
@property (nonatomic, retain) NSMutableArray* sectionO;
@property (nonatomic, retain) NSMutableArray* sectionP;
@property (nonatomic, retain) NSMutableArray* sectionQ;
@property (nonatomic, retain) NSMutableArray* sectionR;
@property (nonatomic, retain) NSMutableArray* sectionS;
@property (nonatomic, retain) NSMutableArray* sectionT;
@property (nonatomic, retain) NSMutableArray* sectionU;
@property (nonatomic, retain) NSMutableArray* sectionV;
@property (nonatomic, retain) NSMutableArray* sectionW;
@property (nonatomic, retain) NSMutableArray* sectionX;
@property (nonatomic, retain) NSMutableArray* sectionY;
@property (nonatomic, retain) NSMutableArray* sectionZ;

//Views
@property (nonatomic, retain) IBOutlet UIButton* doneButton;
@property (nonatomic, retain) IBOutlet UIImageView* dictionaryBGImageView;
@property (nonatomic, retain) IBOutlet UITableView* wordTableView;
@property (nonatomic, retain) IBOutlet UIView* wordAreaView;
@property (nonatomic, retain) IBOutlet UIButton* pronunciationButton;
@property (nonatomic, retain) IBOutlet UILabel* wordLabel;
@property (nonatomic, retain) IBOutlet UIView* wordMediaAreaView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* wordMediaActivityIndicator;
@property (nonatomic, retain) IBOutlet UILabel* wordMediaActivityLabel;
@property (nonatomic, retain) IBOutlet UIButton* replayButton;
@property (nonatomic, retain) IBOutlet UIView* infoAreaView;
@property (nonatomic, retain) IBOutlet UIButton* readInfoButton;
@property (nonatomic, retain) IBOutlet UILabel* infoLabel;
@property (nonatomic, retain) IBOutlet UITextView* infoTextView;
@property (nonatomic, retain) IBOutlet UIButton* infoToggleButton;
@property (nonatomic, retain) IBOutlet UIButton* masteryIndicatorButton;
@property (nonatomic, retain) IBOutlet UIButton* levelIndicatorButton;

//Controllers
@property (nonatomic, retain) VideoPlayerViewController* videoController;
@property (nonatomic, retain) AVAudioPlayer* wordAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* definitionAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* sentenceAudioPlayer;

////METHODS////

//Actions
-(IBAction) doneWithThesaurus:(id)sender;
-(IBAction) pronounceWordForView: (id)sender;
-(IBAction) readInfo: (id)sender;
-(IBAction) replay: (id)sender;
-(IBAction) infoToggle:(id)sender;
-(IBAction) levelDetail: (id)sender;
-(IBAction) masteryDetail: (id)sender;

//Utility
    //Word List
-(void) loadAndVerifyWordList;
-(NSArray*) verifiedLessonsList;
-(void) separateWordListToSections;
    //Word Detail
-(void) configureVideo;
-(void) configureAudio;
-(void) configureText;
-(void) updateWordAreaForWordObject: (WordObject*) wordObjectToDisplay;
-(void) stopAllAudioPlayers;
-(void) infoAutoplayAdvance;
-(void) infoAutoToggle;
-(void) cycleInfoType;


@end
