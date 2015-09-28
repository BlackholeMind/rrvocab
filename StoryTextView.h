//
//  StoryTextView.h
//  RRV101
//
//  Created by Brian C. Grant on 11/7/11.
//  Copyright (c) 2011 Rich and Rare Vocabulary Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface StoryTextView : UIView {
    
    NSString* taggedText;
    CFAttributedStringRef attributedText;
    CTFrameRef textCTFrame;
    CGContextRef contextForFrame;
    
}

////PROPERTIES////
@property (nonatomic, copy) NSString* taggedText;
@property CFAttributedStringRef attributedText;
@property CTFrameRef textCTFrame;
@property CGContextRef contextForFrame;

////METHODS////
-(id)initWithFrame:(CGRect)frame andText:(NSString*)text;

@end
