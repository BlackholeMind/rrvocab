//
//  TextTagsParser.h
//  RRV101
//
//  Created by Brian C. Grant on 11/9/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface TextTagsParser : NSObject {
    
    NSString* fontName;
    float fontSize;
    UIColor* fillColor;
    UIColor* strokeColor;
    float strokeWidth;
    NSString* wordToLoad;
    
}
@property (nonatomic, retain) NSString* fontName;
@property (assign, readwrite) float fontSize;
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, retain) UIColor* strokeColor;
@property (assign, readwrite) float strokeWidth;
@property (nonatomic, retain) NSString* wordToLoad;
-(NSAttributedString*) attrStringFromTags: (NSString*)markedText;

@end
