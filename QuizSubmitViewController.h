//
//  QuizSubmitViewController.h
//  RRV101
//
//  Created by Brian C. Grant on 3/29/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizSubmitViewController : UIViewController {
    
    UIButton* submitButton;
    UITextView* instructionTextView;
    
}
////PROPERTIES////
@property (nonatomic, retain) IBOutlet UIButton* submitButton;
@property (nonatomic, retain) IBOutlet UITextView* instructionTextView;

////METHODS////
//PUBLIC

//PRIVATE
//IBActions
-(IBAction) submit:(id)sender;


@end
