//
//  RRV101AppDelegate.h
//  RRV101
//
//  Created by Brian C. Grant on 9/16/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RRV101ViewController;
@class LandingPageViewController_iPad;

@interface RRV101AppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet RRV101ViewController *viewController;

@end
