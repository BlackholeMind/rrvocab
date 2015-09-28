//
//  WordListObject.h
//  RRV101
//
//  Created by Brian C. Grant on 3/31/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WordObject;

@interface WordListObject : NSObject {
    
    NSArray* lessonNumbers;
    NSArray* wordObjects;
    
}
////PROPERTIES////
@property (nonatomic, retain) NSArray* lessonNumbers;
@property (nonatomic, retain) NSArray* wordObjects;

////METHODS////
//PUBLIC
//Constructors
+(WordListObject*) listForLessons: (NSArray*) lessonNumbersToLoad;
+(WordListObject*) listForLessonNumber: (NSInteger) lessonToLoad;
+(WordListObject*) listFromList: (WordListObject*) listToCopy;
//PRIVATE
//Constructors
-(WordListObject*) initWithLesson: (NSInteger) lessonNumberToLoad;
-(WordListObject*) initWithLessons: (NSArray*) lessonNumbersToLoad;
//Organization
-(void) appendWordsFromLessonNumber: (NSInteger)lessonNumberToAppend;
-(void) shuffle;
-(void) alphabetize;
-(void) ensureFirstWord: (NSString*) wordForFirst;
-(void) ensureLastWord: (NSString*) wordForLast;
-(void) removeWord: (NSString*) wordOfObjectToRemove;
//Queries
-(WordObject*) randomWordObject;
-(NSString*) randomWordStringOnly;
-(WordObject*) popWordObject;
//Utility
-(NSArray*) arrayOfWordsFromLessonPListNumber: (NSInteger) lessonNumberForPList;
//Support
NSInteger randomShuffle(id num1, id num2, void *context);
NSInteger sortWordObjectsByAlpha(id word1, id word2, void *context);

@end
