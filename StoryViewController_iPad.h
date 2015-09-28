//
//  StoryViewController_iPad.h
//  RRV101
//
//  Created by Brian C. Grant on 1/23/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@class StoryTextView;
@class VideoPlayerViewController;

@interface StoryViewController_iPad : UIViewController <AVAudioPlayerDelegate> {
    
    //Data
    BOOL pageIsBlank;
    BOOL pageIsTheEnd;
    BOOL pageAutoplayEnabled;
    NSInteger lessonNumberForView;
    NSInteger pageNumberForView;
    NSString* textWithTags;
    NSAttributedString* textWithAttributes;
    
    //Views
    UIImageView* imageView;
    UIView* titleVideoView;
    UIButton* titleReplayButton;
    UIView* videoView;
    UIView* textView;
    StoryTextView* textDrawnView;
    UIActivityIndicatorView* movieIndicator;
    UILabel* movieLoadingLabel;
    UIActivityIndicatorView* audioIndicator;
    UIButton* readStoryButton;
    UIButton* replayButton;
    UILabel* pageNumberLabel;
    UIView* pageEdgeMarginView;
    UIView* pageContentWrapperView;
    UIImageView* pageGradientFillImageView;
    UIImageView* pageSpineImageView;
    UILabel* titleLabel;
    UILabel* lessonLabel;
    UILabel* theEndLabel;
    UIButton* theEndButton;
    
    //Controllers & Media
    VideoPlayerViewController* videoController;
    AVAudioPlayer* storyReader;
    
}
////PROPERTIES////

//Data
@property BOOL pageIsBlank;
@property BOOL pageIsTheEnd;
@property BOOL pageAutoplayEnabled;
@property NSInteger lessonNumberForView;
@property NSInteger pageNumberForView;
@property (nonatomic, copy) NSString* textWithTags;
@property (nonatomic, copy) NSAttributedString* textWithAttributes;

//Views
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIView* titleVideoView;
@property (nonatomic, retain) IBOutlet UIButton* titleReplayButton;
@property (nonatomic, retain) IBOutlet UIView* videoView;
@property (nonatomic, retain) IBOutlet UIView* textView;
@property (nonatomic, retain) StoryTextView* textDrawnView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* movieIndicator;
@property (nonatomic, retain) IBOutlet UILabel* movieLoadingLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* audioIndicator;
@property (nonatomic, retain) IBOutlet UIButton* readStoryButton;
@property (nonatomic, retain) IBOutlet UIButton* replayButton;
@property (nonatomic, retain) IBOutlet UILabel* pageNumberLabel;
@property (nonatomic, retain) IBOutlet UIView* pageEdgeMarginView;
@property (nonatomic, retain) IBOutlet UIView* pageContentWrapperView;
@property (nonatomic, retain) IBOutlet UIImageView* pageGradientFillImageView;
@property (nonatomic, retain) IBOutlet UIImageView* pageSpineImageView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* lessonLabel;
@property (nonatomic, retain) IBOutlet UILabel* theEndLabel;
@property (nonatomic, retain) IBOutlet UIButton* theEndButton;

//Controllers & Media
@property (nonatomic, retain) VideoPlayerViewController* videoController;
@property (nonatomic, retain) AVAudioPlayer* storyReader;


////METHODS////

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forTextWithTags:(NSString*)taggedText lessonNumber:(NSInteger)lessonNumber pageNumber:(NSInteger)pageNumber blankPage:(BOOL)blank;

//Actions
-(IBAction) readPage:(id)sender;
-(IBAction) replay:(id)sender;
-(IBAction) theEndButtonPressed:(id)sender;

//Utility
-(void) configurePage;
-(void) configureVideo;
-(void) configureAudio;
-(void) autoplay;
-(void) pausePlayback;
-(void) resumePlayback;
-(void) autoplayEnd;

@end
