//
//  StoryTitlePage.h
//  RRV101
//
//  Created by Brian C. Grant on 9/8/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All Right Reserved.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class VideoPlayerViewController;

@interface StoryTitlePage : UIViewController {
    
    //Data
    NSInteger lessonNumber;
    NSInteger pageNumberForView;
    BOOL pageAutoplayEnabled;
    
    //Views
    UILabel* titleLabel;
    UIView* videoView;
    UIButton* replayButton;
    
    //Controllers & Media
    VideoPlayerViewController* videoController;
    
}
////PROPERTIES////

//Data
@property NSInteger lessonNumber;
@property NSInteger pageNumberForView;
@property BOOL pageAutoplayEnabled;

//Views
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UIView* videoView;
@property (nonatomic, retain) IBOutlet UIButton* replayButton;

//Controllers & Media
@property (nonatomic, retain) VideoPlayerViewController* videoController;

////METHODS////

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil lessonNumber:(NSInteger)numberOfLesson;

//IBActions
- (IBAction) replay:(id)sender;

//Utility
- (NSString*) titleFromLessonNumber:(NSInteger)lessonNumberInt;
- (void) configureVideo;
- (void) autoplay;
- (void) pausePlayback;
- (void) resumePlayback;
- (void) autoplayEnd;

@end
