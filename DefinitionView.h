//
//  DefinitionView.h
//  RRV101
//
//  Created by Christy Keck on 10/2/12.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class WordObject;

@interface DefinitionView : UIViewController <AVAudioPlayerDelegate> {
    
    //Data
    WordObject* wordObject;
    
    //Views
    UINavigationBar* wordBar;
    UITextView* textView;
    UIBarButtonItem* doneButton;
    
    //Controllers & Media
    AVAudioPlayer* wordAudioPlayer;
    AVAudioPlayer* definitionAudioPlayer;
    
}

////PROPERTIES////

//Data
@property (nonatomic, retain) WordObject* wordObject;

//Views
@property (nonatomic, retain) IBOutlet UINavigationBar* wordBar;
@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* doneButton;

//Controllers & Media
@property (nonatomic, retain) AVAudioPlayer* wordAudioPlayer;
@property (nonatomic, retain) AVAudioPlayer* definitionAudioPlayer;

////METHODS////

//PUBLIC
//Constructors

//PRIVATE

//Constructors
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forWordObject:(WordObject*)word;

//IBActions
    //wordBar
-(IBAction) closeWordView: (id)sender;
-(IBAction) pronounceWordForView: (id)sender;
    //infoView
-(IBAction) readInfo: (id)sender;

//Utility
-(void) setWordLabelForTitleBar;
-(void) configureAudio;
-(void) stopAllAudioPlayers;

@end
