//
//  TextTagsParser.m
//  RRV101
//
//  Created by Brian C. Grant on 11/9/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant All rights reserved.
//

#import "TextTagsParser.h"

@implementation TextTagsParser

@synthesize fontName, fontSize, fillColor, strokeColor, strokeWidth, wordToLoad;

-(void) dealloc {//Release objects
    
    [fontName release];
    [fillColor release];
    [strokeColor release];
    [wordToLoad release];
    
    [super dealloc];
}

-(id)init{
    
    self = [super init];
    
    if (self) {
        
        //Code
        self.fontName = @"Georgia";
        self.fontSize = 18.0f;
        self.fillColor = [UIColor darkGrayColor];
        self.strokeColor = [UIColor blackColor];
        self.strokeWidth = 0.0;
    }
    
    return self;
}

-(NSAttributedString*) attrStringFromTags:(NSString *)markedText{
        
    //Setup a string that reads tags from a passed string
    NSMutableAttributedString* stringToParse =[[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* chunksOfText = [regex matchesInString:markedText options:0 range:NSMakeRange(0, [markedText length])];
    [regex release];
    
    //Build attributed final attributed string, by running chunks of text through formatter loop
    for (NSTextCheckingResult* b in chunksOfText) {
        NSArray* parts = [[markedText substringWithRange:b.range] componentsSeparatedByString:@"<"];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.fontName, self.fontSize, NULL);
        
        //Apply current text style
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (id) self.fillColor.CGColor, (NSString*)kCTForegroundColorAttributeName,
                                    (id) fontRef, (NSString*)kCTFontAttributeName,
                                    (id) self.strokeColor.CGColor, (NSString*)kCTStrokeColorAttributeName,
                                    (id) [NSNumber numberWithFloat: self.strokeWidth], (NSString*)kCTStrokeWidthAttributeName,
                                    (id) self.wordToLoad, @"wordToLoad",
                                    nil];
        [stringToParse appendAttributedString:[[[NSAttributedString alloc] initWithString:[parts objectAtIndex:0] attributes:attributes]autorelease]];
        CFRelease(fontRef);
        
        //Handle new formatting
        if ([parts count] > 1) {
            NSString* tag = (NSString*) [parts objectAtIndex:1];
            if ([tag hasPrefix:@"wordToLearn"]) {//Is a beginning tag: <wordToLearn="wordToLoad"> (first appearance of word)
                
                //Search word tag for "wordToLoad" attribute and set
                self.fontName = @"Helvetica Bold Oblique";
                self.fillColor = [UIColor blueColor];
                self.strokeColor = [UIColor blackColor];
                self.strokeWidth = 0.0;
                NSArray* piecesOfTag = [tag componentsSeparatedByString:@"\""];//break into 3 part array: [word=] [wordToLoad] [ ]
                self.wordToLoad = [piecesOfTag objectAtIndex:1];
                
            }//End if{} (tag hasPrefix "font")
            else if ([tag hasPrefix:@"wordNOTHighlighted"]) {//Is a beginning tag: <wordNOTHighlighted="wordToLoad"> (repeated words from this lesson)
                
                self.fontName = @"Georgia";
                self.fillColor = [UIColor darkGrayColor];
                self.strokeColor = [UIColor blackColor];
                self.strokeWidth = 0.0;
                NSArray* piecesOfTag = [tag componentsSeparatedByString:@"\""];//break into 3 part array: [word=] [wordToLoad] [ ]
                self.wordToLoad = [piecesOfTag objectAtIndex:1];
                
            }
            else if ([tag hasPrefix:@"wordToKnow"]) {//Is a beginning tag: <wordToKnow="wordToLoad"> (for previous lessons' words)
                
                self.fontName = @"Georgia";
                self.fillColor = [UIColor darkGrayColor];
                self.strokeColor = [UIColor blackColor];
                self.strokeWidth = 0.0;
                NSArray* piecesOfTag = [tag componentsSeparatedByString:@"\""];//break into 3 part array: [word=] [wordToLoad] [ ]
                self.wordToLoad = [piecesOfTag objectAtIndex:1];
                
            }
            else if ([tag hasPrefix:@"/"]) {//Is a closing tag - return to normal
                
                self.fontName = @"Georgia";
                self.fillColor = [UIColor darkGrayColor];
                self.strokeColor = [UIColor blackColor];
                self.strokeWidth = 0.0;
                self.wordToLoad = @"";
                
            }
        }//End if{} (parts > 1)
    }
    
    return (NSAttributedString*)stringToParse;
}

@end
