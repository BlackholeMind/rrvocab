//
//  StoryBookVC_iPad.h
//  RRV101
//
//  Created by Brian C. Grant on 6/29/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoryPageViewController_iPad;

@interface StoryBookVC_iPad : UIViewController {
    
    //Data
    NSInteger lessonNumber;
    
    //Views
    UIView* storyPageViewArea;
    
    //Controllers
    
}

////PROPERTIES////

//Data
@property NSInteger lessonNumber;

//Views
@property (nonatomic, retain) IBOutlet UIView* storyPageViewArea;

//Controllers

////METHODS////

//Constructors
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLesson:(NSInteger)lessonNumberToLoad;

//Actions

//Utility

@end
