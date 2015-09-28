//
//  StoryTextView.m
//  RRV101
//
//  Created by Brian C. Grant on 11/7/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "StoryTextView.h"
#import "TextTagsParser.h"

@implementation StoryTextView

@synthesize taggedText, attributedText, textCTFrame, contextForFrame;

- (void) dealloc {
    
    [taggedText release];
    CFRelease(attributedText);
    CFRelease(textCTFrame);
    
    [super dealloc];
    
}//End dealloc{}

- (id) initWithFrame:(CGRect)frame andText:(NSString*)text{ //Custom init method includes taggedText
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        //Initialize code and text
        self.backgroundColor = [UIColor clearColor];
        self.taggedText = text;
        
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    // Drawing code //
    
    //Get the context
    self.contextForFrame = UIGraphicsGetCurrentContext();
    CGContextSaveGState(self.contextForFrame);
    
    //Convert Coordinate System
    CGContextSetTextMatrix(self.contextForFrame, CGAffineTransformIdentity);
    CGContextTranslateCTM(self.contextForFrame, 0, self.bounds.size.height);
    CGContextScaleCTM(self.contextForFrame, 1.0, -1.0);
    
    //Create path for frame
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    //Create a custom parser to send tags with code
    TextTagsParser* parser = [[TextTagsParser alloc] init];
    
    //Prepare the attributed string to be drawn
    self.attributedText = CFRetain((CFAttributedStringRef)[parser attrStringFromTags:taggedText]);
    [parser release];
    
    //Create frameSetter
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    
    //Create frame to draw
    self.textCTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(self.attributedText)), path, NULL);
    
    //Draw the frame to the context
    CTFrameDraw(self.textCTFrame, self.contextForFrame);
    
    //Release objects
    CFRelease(path);
    CFRelease(frameSetter);
    
    //Reset the context
    CGContextRestoreGState(self.contextForFrame);
    
}//End drawRect:

@end
