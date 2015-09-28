//
//  StoryViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 9/27/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@class StoryTextView;
@class WordView;
@class VideoPlayerViewController;

@interface StoryViewController : UIViewController <AVAudioPlayerDelegate> {
    
    //Data
    NSString* textWithTags;
    NSAttributedString* textWithAttributes;
    NSInteger lessonNumberForView;
    NSInteger pageNumberForView;
    NSInteger pageCountForStory;
    BOOL pageAutoplayEnabled;
    
    //Views
    UIView* videoView;
    UIImageView* imageView;
    UIView* textView;
    UIButton* readStoryButton;
    UIButton* replayButton;
    UILabel* pageNumberLabel;
    StoryTextView* textDrawnView;
    UIActivityIndicatorView* movieIndicator;
    UILabel* movieLoadingLabel;
    UIActivityIndicatorView* audioIndicator;
    
    //Controllers & Media
    VideoPlayerViewController* videoController;
    AVAudioPlayer* storyReader;
}
////PROPERTIES////

//Data
@property (nonatomic, copy) NSString* textWithTags;
@property (nonatomic, copy) NSAttributedString* textWithAttributes;
@property NSInteger lessonNumberForView;
@property NSInteger pageNumberForView;
@property NSInteger pageCountForStory;
@property BOOL pageAutoplayEnabled;

//Views
@property (nonatomic, retain) IBOutlet UIView* videoView;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIView* textView;
@property (nonatomic, retain) IBOutlet UIButton* readStoryButton;
@property (nonatomic, retain) IBOutlet UIButton* replayButton;
@property (nonatomic, retain) IBOutlet UILabel* pageNumberLabel;
@property (nonatomic, retain) StoryTextView* textDrawnView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* movieIndicator;
@property (nonatomic, retain) IBOutlet UILabel* movieLoadingLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* audioIndicator;

//Controllers & Media
@property (nonatomic, retain) VideoPlayerViewController* videoController;
@property (nonatomic, retain) AVAudioPlayer* storyReader;

////METHODS////
//PUBLIC
//Constructors

//PRIVATE

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forTextWithTags:(NSString*)taggedText lessonNumber:(NSInteger)lessonNumber pageNumber:(NSInteger)pageNumber pageCount:(NSInteger)pageCount;

//IBActions
-(IBAction) readPage:(id)sender;
-(IBAction) replay:(id)sender;

//Utility
-(void) configureVideo;
-(void) configureAudio;
-(void) autoplay;
-(void) pausePlayback;
-(void) resumePlayback;
-(void) autoplayEnd;
-(void) tappedStoryText: (UITapGestureRecognizer*) tapGesture;

@end
