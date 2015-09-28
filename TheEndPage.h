//
//  TheEndPage.h
//  RRV101
//
//  Created by Brian C. Grant on 3/20/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TheEndPage : UIViewController {
    
    //Data
    NSInteger pageNumberForView;
    BOOL pageAutoplayEnabled;
    
    //Views
    UIButton* continueButton;
}
////PROPERTIES////

//Data
@property NSInteger pageNumberForView;
@property BOOL pageAutoplayEnabled;

//Views
@property (nonatomic, retain) IBOutlet UIButton* continueButton;

////METHODS////
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageNumber:(NSInteger)pageNum;
-(IBAction) continueButtonPressed:(id)sender;
-(void) autoplay;


@end
