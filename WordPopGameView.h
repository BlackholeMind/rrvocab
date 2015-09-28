//
//  WordPopGameView.h
//  RRV101
//
//  Created by Brian C. Grant on 1/8/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordPopGameLayer;

@interface WordPopGameView : UIViewController {
    
    //Data
    BOOL runningOniPad;
    BOOL runningOnRetina;
    NSInteger lessonNumber;
    
    //Views & Layers
    WordPopGameLayer* mainLayer;
    
    //Controllers, Scenes, & Media
    
}
////PROPERTIES////

//Data
@property BOOL runningOniPad;
@property BOOL runningOnRetina;
@property NSInteger lessonNumber;

//Views & Layers
@property (nonatomic, retain) WordPopGameLayer* mainLayer;
//Controllers, Scenes, & Media

////METHODS////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forLessonNumber:(NSInteger)lessonNumberToPlay;
    //Callbacks
- (void) quitPlaying:(NSNotification*)notification;
    //Math
- (CGFloat) radianFromDegree: (CGFloat) degree;

@end
