//
//  WordListObject.m
//  RRV101
//
//  Created by Brian C. Grant on 3/31/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordListObject.h"
#import "WordObject.h"

@implementation WordListObject

#pragma mark Synthesizers

@synthesize lessonNumbers, wordObjects;

#pragma mark - PUBLIC METHODS -

#pragma mark Constructors

+(WordListObject*) listForLessons: (NSArray*) lessonNumbersToLoad {
    return [[[self alloc] initWithLessons:lessonNumbersToLoad] autorelease];
}//End listForLessons:

+(WordListObject*) listForLessonNumber: (NSInteger) lessonToLoad {
    return [[[self alloc] initWithLesson:lessonToLoad] autorelease];
}//End listForLessonNumber:

+(WordListObject*) listFromList:(WordListObject *)listToCopy {
    return [[[self alloc] initWithLessons:listToCopy.lessonNumbers] autorelease];
}//End listFromList:

#pragma mark - PRIVATE METHODS -
#pragma mark Object Lifecycle -

#pragma mark Memory Management

-(void) dealloc{

    [lessonNumbers release];
    [wordObjects release];
    
    [super dealloc];
}//End dealloc

#pragma mark Constructors

-(id)init {
    
    if (self = [super init]) {//Successful allocation
        
        //Custom initialization
        self.lessonNumbers = [[[NSArray alloc] init] autorelease];
        self.wordObjects = [[[NSArray alloc] init] autorelease];
        
    }//End if{} (successful)
    
    return self;
    
}//End init

-(WordListObject*) initWithLesson: (NSInteger) lessonNumberToLoad {//Initialize with one lesson list, as indicated by NSInteger
    
    if (self=[self init]) { //Expanded initialization
        
        //Load desired list from WordList#.plist
        NSArray* wordListArray = [self arrayOfWordsFromLessonPListNumber:lessonNumberToLoad];
    
        //Parse the words for the list from the PList and add them to an array 
        NSMutableArray* loadedWordObjects = [NSMutableArray arrayWithCapacity:[wordListArray count]];
        for (int wordIndex = 0; wordIndex < [wordListArray count]; wordIndex++){//For each object in the NSArray obtained from the file...
            
            //Obtain a word from the list, add to collector
            WordObject* loadedWord = [[WordObject alloc] initWithArrayForWord:[wordListArray objectAtIndex:wordIndex]];
            [loadedWordObjects addObject:loadedWord];
            [loadedWord release];
        }
        
        //Assign as wordObjects array & first lessonNumber
        self.wordObjects = [NSArray arrayWithArray:loadedWordObjects];
        self.lessonNumbers = [NSArray arrayWithObject:[NSNumber numberWithInt:lessonNumberToLoad]];
        
    }//End if{} (successful)
    
    return self;
    
}//End initWithLesson:

-(WordListObject*) initWithLessons: (NSArray*) lessonNumbersToLoad {//Initialize with multiple lessons
    
    if (self=[self initWithLesson:[(NSNumber*)[lessonNumbersToLoad objectAtIndex:0] intValue]]) {//Successful for first lesson number
        
        for (NSInteger indexToAppend = 1; indexToAppend < [lessonNumbersToLoad count]; indexToAppend++) {//For each additional lessonNumber (already loaded index 0)
            
            [self appendWordsFromLessonNumber:[(NSNumber*)[lessonNumbersToLoad objectAtIndex:indexToAppend] intValue]];//NSNumber* from NSArray converted to NSInteger (int)
            
        }//End for{} (each additional lessonNumber)
        
    }//End if{} (successful)
    
    return self;
    
}//End initWithLessons:

#pragma mark - Tasks -

#pragma mark Organization

-(void) appendWordsFromLessonNumber: (NSInteger)lessonNumberToAppend {
    
    //Create mutables
    NSMutableArray* appendedLessonNumbersArray = [NSMutableArray arrayWithArray:self.lessonNumbers];
    NSMutableArray* appendedWordObjectsArray = [NSMutableArray arrayWithArray:self.wordObjects];
    
    //Append new lesson number
    [appendedLessonNumbersArray addObject:[NSNumber numberWithInt:lessonNumberToAppend]];
    self.lessonNumbers = [NSArray arrayWithArray:appendedLessonNumbersArray];
    
    //Load desired list from WordList#.plist
    NSArray* wordListArray = [self arrayOfWordsFromLessonPListNumber:lessonNumberToAppend];
    
    //Parse the questions for the quiz from the PList and add them to an array of Question objects {{After shuffling their answers}}
    for (int wordIndex = 0; wordIndex < [wordListArray count]; wordIndex++){//For each wordArray in the NSArray obtained from the file...
        
        //Obtain a word from the list, add to collection
        WordObject* word = [WordObject loadWithArray:[wordListArray objectAtIndex:wordIndex]];
        [appendedWordObjectsArray addObject:word];
        
    }//End for{} (each array in wordListArray
    
    //Append wordObjects array with loadedWords
    self.wordObjects = [NSArray arrayWithArray:appendedWordObjectsArray];
    
}//End appendWordListForLesson:

-(void) shuffle {
    
    for (NSInteger randomShuffles = (arc4random()%20)+10; randomShuffles > 0 ; randomShuffles--) {
        
        self.wordObjects = [self.wordObjects sortedArrayUsingFunction:randomShuffle context:NULL];
        
    } //End for{} (random number of shuffles 10-30)
    
}//End shuffle

-(void) alphabetize {
    
    self.wordObjects = [self.wordObjects sortedArrayUsingFunction:sortWordObjectsByAlpha context:NULL];
    
}//End alphabetize

-(void) ensureFirstWord: (NSString*) wordForFirst {//Move wordObject with passed NSString to first index
    
    //Mutable to work with
    NSMutableArray* modifiedWordListWordObjects = [NSMutableArray arrayWithArray:self.wordObjects];
    
    for (NSInteger wordObjectIndex = 0; wordObjectIndex < [modifiedWordListWordObjects count]; wordObjectIndex++) {//For each wordObject
        WordObject* wordObjectToCompare = [modifiedWordListWordObjects objectAtIndex:wordObjectIndex];
        
        //Check the wordObject's wordString
        if ([wordObjectToCompare.wordString isEqualToString:wordForFirst]) {//Found the desired wordObject
            [modifiedWordListWordObjects removeObjectAtIndex:wordObjectIndex];//Remove from its current index
            [modifiedWordListWordObjects insertObject:wordObjectToCompare atIndex:0];//Insert at beginning
        }//End if{} (desired wordObject)
    }//End for{} (each wordObject)
    
    //Assign the modified array
    self.wordObjects = [NSArray arrayWithArray:modifiedWordListWordObjects];
    
}//End ensureFirstWord:

-(void) ensureLastWord: (NSString*) wordForLast {
    
    //Mutable to work with
    NSMutableArray* modifiedWordListWordObjects = [NSMutableArray arrayWithArray:self.wordObjects];
    
    for (NSInteger wordObjectIndex = 0; wordObjectIndex < [modifiedWordListWordObjects count]; wordObjectIndex++) {//For each wordObject
        WordObject* wordObjectToCompare = [modifiedWordListWordObjects objectAtIndex:wordObjectIndex];
        
        //Check the wordObject's wordString
        if ([wordObjectToCompare.wordString isEqualToString:wordForLast]) {//Found the desired wordObject
            [modifiedWordListWordObjects removeObjectAtIndex:wordObjectIndex];//Remove from its current index
            [modifiedWordListWordObjects addObject:wordObjectToCompare];//Append to end
        }//End if{} (desired wordObject)
    }//End for{} (each wordObject)
    
    //Assign the modified array
    self.wordObjects = [NSArray arrayWithArray:modifiedWordListWordObjects];
    
}//End ensureLastWord:

-(void) removeWord: (NSString*) wordOfObjectToRemove {
    
    //Mutable to work with
    NSMutableArray* modifiedWordListWordObjects = [NSMutableArray arrayWithArray:self.wordObjects];
    
    for (NSInteger wordObjectIndex = 0; wordObjectIndex < [modifiedWordListWordObjects count]; wordObjectIndex++) {//For each wordObject
        WordObject* wordObjectToCompare = [modifiedWordListWordObjects objectAtIndex:wordObjectIndex];
        
        //Check the wordObject's wordString
        if ([wordObjectToCompare.wordString isEqualToString:wordOfObjectToRemove]) {//Found the desired wordObject
           
            //Remove from its current index
            [modifiedWordListWordObjects removeObjectAtIndex:wordObjectIndex];
            
        }//End if{} (desired wordObject)
    }//End for{} (each wordObject)
    
    //Assign the modified array
    self.wordObjects = [NSArray arrayWithArray:modifiedWordListWordObjects];
    
}//End removeWord:

#pragma mark Queries

-(WordObject*) randomWordObject {
    //Return a random WordObject
    return [self.wordObjects objectAtIndex:(arc4random()%[self.wordObjects count])];
}//End randomWordObject

-(NSString*) randomWordStringOnly {
    //Return a random WordObject's word string
    return [(WordObject*)[self.wordObjects objectAtIndex:(arc4random()%[self.wordObjects count])] wordString];
}//End randomWordStringOnly

-(WordObject*) popWordObject {//Remove a WordObject from the collection and return it
    
    //Mutable to work with
    NSMutableArray* smallerWordList = [NSMutableArray arrayWithArray:self.wordObjects];
    
    //Get the first WordObject, remove after copying
    WordObject* wordObjectToPop = [WordObject wordObjectFromWordObject:[smallerWordList objectAtIndex:0]];
    if (wordObjectToPop) {
        NSLog(@"wordObjectToPop exists after copying.");
        NSLog(@"wordObjectToPop is: %@, which means: %@", wordObjectToPop.wordString, wordObjectToPop.definitionString);
    }
    else NSLog(@"wordObjectToPop IS NIL AFTER COPYING!!!");
    
    [smallerWordList removeObjectAtIndex:0];
    
    //Assign the new array - with the WordObject removed
    self.wordObjects = [NSArray arrayWithArray:smallerWordList];
    
    //Return copied WordObject which was removed
    return wordObjectToPop;
    
}//End popWordObject

#pragma mark Utility

-(NSArray*) arrayOfWordsFromLessonPListNumber: (NSInteger) lessonNumberForPList {
    
    //Load desired list from WordList#.plist
    NSString* lessonFilename = [NSString stringWithFormat:@"WordList%i.plist", lessonNumberForPList];
    NSString* path = [[NSBundle mainBundle] bundlePath];
    NSString* finalPath = [path stringByAppendingPathComponent:lessonFilename];
    
    return [[NSDictionary dictionaryWithContentsOfFile:finalPath] objectForKey:@"WordList"];
    
}//End arrayOfWordsFromLessonPListNumber:

#pragma mark Support

NSInteger randomShuffle(id num1, id num2, void *context){
    
    //Randomly choose form of change (3 choices: ascending, descending, same)
    int result = arc4random()%3;//Random number for choice (1-3)
    if (result==0){
        return NSOrderedAscending;
    }
    else if (result==1){
        return NSOrderedDescending;
    }
    else{
        return NSOrderedSame;
    }
    
}//End shuffleObjectArray(id, id, void *)

NSInteger sortWordObjectsByAlpha(id word1, id word2, void *context){
    
    //Cast the objects as WordObjects
    WordObject* firstWord = (WordObject*)word1;
    WordObject* secondWord = (WordObject*)word2;
    
    //Return the comparison of their word strings
    return [firstWord.wordString compare:secondWord.wordString];
    
}//End sortWordObjectsByAlpha(WordObject*, WordObject*, void*)

@end
