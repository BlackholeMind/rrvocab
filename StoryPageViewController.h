//
//  StoryPageViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 11/8/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate> {
    
    //Data
    NSInteger lessonNumber;
    NSInteger currentPage;
    BOOL storyAutoplayEnabled;
    BOOL definitionViewShowing;
    NSArray* arrayOfPageTexts;
    
    //Views
    UIButton* autoplayButton;
    
    //Controllers
    UIPageViewController* pageVC;
    
}
////PROPERTIES////

//Data
@property NSInteger lessonNumber;
@property NSInteger currentPage;
@property BOOL storyAutoplayEnabled;
@property BOOL definitionViewShowing;
@property (nonatomic, retain) NSArray* arrayOfPageTexts;

//Views
@property (nonatomic, retain) IBOutlet UIButton* autoplayButton;

//Controllers
@property (nonatomic, retain) UIPageViewController* pageVC;

////METHODS////

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad;

//Actions
- (IBAction) toggleAutoplay:(id)sender;

//Callbacks
- (void) openWordView: (NSNotification*)notification;
- (void) dismissWordView: (NSNotification*)notification;
- (void) autoplayFirstPageComplete: (NSNotification*)notification;
- (void) storyFinished:(NSNotification*)notification;

//Utility
- (void) attachObserversForStoryPage: (UIViewController*)viewController;
- (void) removeObserversForStoryPage: (UIViewController*)viewController;
- (void) autoplay;
- (void) pauseStoryPlayback;
- (void) resumeStoryPlaybackOnPage: (UIViewController*)pageController;
- (void) turnPagesForward;
- (NSArray*) textArrayForLesson;
- (UIViewController*) storyPageForPageNumber: (NSInteger)pageNumberToBuild;


@end
