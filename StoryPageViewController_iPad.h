//
//  StoryPageViewController_iPad.h
//  RRV101
//
//  Created by Brian C. Grant on 1/22/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class StoryViewController_iPad;

@interface StoryPageViewController_iPad : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIPopoverControllerDelegate, UIGestureRecognizerDelegate> {
    
    //Data
    BOOL storyAutoplayEnabled;
    NSInteger lessonNumber;
    NSInteger currentPage;
    NSArray* arrayOfPageTexts;
    
    //Views
    UIView* autoplayMountView;
    UIButton* autoplayButton;
    
    //Controllers
    UIPageViewController* pageVC;
    UIPopoverController* definitionPopover;
    
}
////PROPERTIES////

//Data
@property BOOL storyAutoplayEnabled;
@property NSInteger lessonNumber;
@property NSInteger currentPage;
@property (nonatomic, retain) NSArray* arrayOfPageTexts;

//Views
@property (nonatomic, retain) IBOutlet UIView* autoplayMountView;
@property (nonatomic, retain) IBOutlet UIButton* autoplayButton;

//Controllers
@property (nonatomic, retain) UIPageViewController* pageVC;
@property (nonatomic, retain) UIPopoverController* definitionPopover;

////METHODS////

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad;

//Actions
- (IBAction) toggleAutoplay:(id)sender;

//Callbacks
- (void) storyPageBeginReadInfo: (NSNotification*)notification;
- (void) openDefinitionPopover: (NSNotification*)notification;
- (void) autoplayFirstPageComplete: (NSNotification *)notification;
- (void) autoplaySecondPageComplete: (NSNotification *)notification;

//Utility
-(void) attachObserversForStoryPage: (StoryViewController_iPad*)pageController;
-(void) removeObserversForStoryPage: (StoryViewController_iPad*)pageController;
- (StoryViewController_iPad*) storyPageForPageNumber: (NSInteger)pageNumberToBuild;
- (void) turnPagesForward;
- (void) autoplay;
- (void) pauseStoryPlayback;
- (void) resumeStoryPlaybackOnPage: (UIViewController*)pageController;
- (NSArray*) textArrayForLesson;

@end
