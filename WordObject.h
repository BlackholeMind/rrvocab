//
//  WordObject.h
//  RRV101
//
//  Created by Brian C. Grant on 3/23/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordObject : NSObject {
    
    NSInteger lessonNumber;
    NSString* wordString;
    NSString* definitionString;
    NSString* sentenceString;
    NSArray* wrongDefinitions;
    
}
////PROPERTIES////

@property NSInteger lessonNumber;
@property (nonatomic, copy) NSString* wordString;
@property (nonatomic, copy) NSString* definitionString;
@property (nonatomic, copy) NSString* sentenceString;
@property (nonatomic, copy) NSArray* wrongDefinitions;

////METHODS////
//PUBLIC
//Constructors
+(WordObject*) loadWithArray:(NSArray*)arrayForWord;
+(WordObject*) loadWord:(NSString*)word fromLesson:(NSInteger)lessonNumberForWord;
+(WordObject*) wordObjectFromWordObject: (WordObject*)wordObjectToCopy;

//PRIVATE
//Constructors
-(WordObject*) initWithArrayForWord:(NSArray*)arrayForWord;
-(WordObject*) initWithWord:(NSString *)word fromLesson:(NSInteger)lessonNumberForWord;
-(WordObject*) initWithWordObject:(WordObject*)wordObject;
//Collapsers
-(NSArray*) collapseToArray;

@end
