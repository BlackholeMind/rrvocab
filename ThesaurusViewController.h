//
//  ThesaurusViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 8/20/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class WordListObject;
@class WordView;

@interface ThesaurusViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate> {
    
    //Data
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
    UITableView* thesaurusTableView;
    
    //Controllers
}
////PROPERTIES////

//Data
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
@property (nonatomic, retain) IBOutlet UITableView* thesaurusTableView;

//Controllers

////METHODS////
//PUBLIC

//PRIVATE

//Actions
-(IBAction) dismissThesaurus: (id)sender;
//Utility
-(void) pronounceWord:(NSString*)word;
-(void) pronounceWordFromButton:(id)sender;
-(void) loadAndVerifyWordList;
-(NSArray*) verifiedLessonsList;
-(void) separateWordListToSections;
-(NSString*) obtainWordForPronunciationButton:(id)sender;

@end
