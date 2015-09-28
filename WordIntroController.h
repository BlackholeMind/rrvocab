//
//  WordIntroController.h
//  RRV101
//
//  Created by Brian C. Grant on 4/1/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordObject, WordView;
@class QuestionObject, QuestionViewController;

@interface WordIntroController : UIViewController {
    
    //Data
    BOOL runningOniPad;
    BOOL runningOnRetina;
    BOOL presentedModally;
    WordObject* wordToIntroduce;
    QuestionObject* questionObjectToReturn;
    
    //Native Views
    UIImageView* mountingBackground;
    UIView* mountArea;
    
    //Controllers
    
}
////PROPERTIES////

//Data
@property BOOL runningOniPad;
@property BOOL runningOnRetina;
@property BOOL presentedModally;
@property (nonatomic, retain) WordObject* wordToIntroduce;
@property (nonatomic, retain) QuestionObject* questionObjectToReturn;

//Views
@property (nonatomic, retain) IBOutlet UIImageView* mountingBackground;
@property (nonatomic, retain) IBOutlet UIView* mountArea;

//Controllers

////METHODS////

//Constructors
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forWordObject:(WordObject*)wordObjectToIntroduce presentedModally:(BOOL)shouldBePresentedModally iPad:(BOOL)isOniPad retina:(BOOL)isOnRetina;

//Callbacks
-(void) userAnsweredQuestion:(NSNotification*)notification;
-(void) userFinishedWithWordView:(NSNotification*)notification;

//Utility
-(void) moveToWordViewFromQuestionVC:(QuestionViewController*)precursorQuestionVC;

@end
