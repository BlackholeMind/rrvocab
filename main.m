//
//  main.m
//  RRV101
//
//  Created by Brian Grant on 9/16/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRV101AppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([RRV101AppDelegate class]));
    [pool release];
    return retVal;
}
