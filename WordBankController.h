//
//  WordBankController.h
//  RRV101
//
//  Created by Brian C. Grant on 9/26/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface WordBankController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate> {
    
    //Data
    NSArray* wordListArray;
    
    //Views
    UITableView* wordlistTableView;
    
}
////PROPERTIES////

//Data
@property (nonatomic, retain) NSArray* wordListArray;

//Views
@property (nonatomic, retain) IBOutlet UITableView* wordListTableView;

////METHODS////

//Actions
-(IBAction) dismissWordListModalView:(id)sender;

//Utility
-(void) loadWordListArray;
-(void) pronounceWord:(NSString*)word;
-(void) pronounceWordFromButton:(id)sender;

@end
