//
//  WordObject.m
//  RRV101
//
//  Created by Brian C. Grant on 3/23/12 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "WordObject.h"
#import "WordListObject.h"
#import "RRVConstants.txt"

@implementation WordObject

@synthesize lessonNumber, wordString, definitionString, sentenceString, wrongDefinitions;

#pragma mark - PUBLIC METHODS -

+(WordObject*) loadWithArray:(NSArray *)arrayForWord {
    
    return [[[self alloc] initWithArrayForWord:arrayForWord] autorelease];
    
}//End loadWithArray:

+(WordObject*) loadWord:(NSString *)word fromLesson:(NSInteger)lessonNumberForWord {
    
    return [[[self alloc] initWithWord:word fromLesson:lessonNumberForWord] autorelease];
    
}//End loadWord: fromLesson:

+(WordObject*) wordObjectFromWordObject:(WordObject *)wordObjectToCopy {
    
    return [[[self alloc] initWithWordObject:wordObjectToCopy] autorelease];
    
}

#pragma mark - PRIVATE METHODS -
#pragma mark Object Lifecycle -

#pragma mark Memory Management

-(void) dealloc {
    
    [wordString release];
    [definitionString release];
    [sentenceString release];
    [wrongDefinitions release];
    
    [super dealloc];
}//End dealloc

#pragma mark Constructors

-(WordObject*) init {
    
    return [self initWithArrayForWord:[NSArray arrayWithObjects:
                                                                [NSNumber numberWithInt:000],
                                                                [NSString stringWithFormat:@"--word--"],
                                                                [NSString stringWithFormat:@"--definition--"],
                                                                [NSString stringWithFormat:@"--sentence--"],
                                                                [NSString stringWithFormat:@"--wrong definition 1 or nil--"],
                                                                [NSString stringWithFormat:@"--wrong definition 2 or nil--"],
                                                                [NSString stringWithFormat:@"--wrong definition 3 or nil--"],
                                                                nil]
            ];
    
}//End init

-(WordObject*) initWithWordObject:(WordObject *)wordObject {
    
    return [self initWithArrayForWord:[wordObject collapseToArray]];
    
}//End initWithWordObject:

-(WordObject*) initWithArrayForWord:(NSArray *)arrayForWord {
    
    if (self=[super init]) {//Successful allocation
        
        if ( [arrayForWord count] == kWordObjectCollapsedArrayMandatoryPropertyCount ) {//Valid array
            
            self.lessonNumber = [[arrayForWord objectAtIndex:kWordLessonNumber]intValue];
            self.wordString = [arrayForWord objectAtIndex:kWordString];
            self.definitionString = [arrayForWord objectAtIndex:kWordDefinition];
            self.sentenceString = [arrayForWord objectAtIndex:kWordSentence];
            
            //Check wrong definitions for validity/applicability, if valid add to a collection
            NSMutableArray* wrongDefs = [NSMutableArray arrayWithCapacity:4];
            if ([arrayForWord objectAtIndex:kWordWrongDefinition1] && ![[arrayForWord objectAtIndex:kWordWrongDefinition1] isEqualToString:@""]) {//WrongDefinition1 exists & is not empty
                [wrongDefs addObject:[arrayForWord objectAtIndex:kWordWrongDefinition1]];
            }
            if ([arrayForWord objectAtIndex:kWordWrongDefinition2] && ![[arrayForWord objectAtIndex:kWordWrongDefinition2] isEqualToString:@""]) {//WrongDefinition2 exists & is not empty
                [wrongDefs addObject:[arrayForWord objectAtIndex:kWordWrongDefinition2]];
            }
            if ([arrayForWord objectAtIndex:kWordWrongDefinition3] && ![[arrayForWord objectAtIndex:kWordWrongDefinition3] isEqualToString:@""]) {//WrongDefinition3 exists & is not empty
                [wrongDefs addObject:[arrayForWord objectAtIndex:kWordWrongDefinition3]];
            }
            self.wrongDefinitions = wrongDefs; //Assign collection of valid answer choices
            
        }//End if{} (array not empty)
        
    }//End if{} (super init)
    
    return self;
    
}//End initWithArrayForWord:

//// NOTE: This method is for convenience only, WordListObject is recommended for multiple WordObjects!
-(WordObject*) initWithWord:(NSString *)word fromLesson:(NSInteger)lessonNumberForWord {//Fetch an object from a string & lessonNumber. (If parameters invalid, returns nil)
    
    WordObject* wordToLoad = [[[WordObject alloc] init] autorelease]; //This is not returned
    
    //WordListObject is already optimized to load wordObjects to itself from a simple NSNumber - let's use that!
    //Note: WordListObject calls THIS CLASS's +loadWithArray: (above) to accomplish this!
    WordListObject* listToQuery = [WordListObject listForLessonNumber:lessonNumberForWord];
    
    //Search the list for the word (compare to each object's wordString)
    if ([listToQuery.wordObjects count] > 0) {//Ensure there are wordObjects!
        
        for (NSInteger wordIndex = 0; wordIndex < [listToQuery.wordObjects count]; wordIndex++) {//For each wordObject in wordList
            
            if ([[[listToQuery.wordObjects objectAtIndex:wordIndex] wordString] isEqualToString:word]) {//If wordObject wordString matches
                
                wordToLoad = [listToQuery.wordObjects objectAtIndex:wordIndex];//Assign to self
                
            }//End if{} (desired word found)
            
        }//End for{} (each wordObject in wordList)
        
    }//End if{} (wordObjects not empty)
    else {//Did not find wordObjects
        
        wordToLoad = nil;
        
    }//End else{} (no wordObjects)
    
    return [self initWithArrayForWord:[wordToLoad collapseToArray]];
    
}//End initWithWord: fromLesson:

#pragma mark Collapsers

-(NSArray*) collapseToArray {
    
    NSString* wrongDefinition1 = @"";
    NSString* wrongDefinition2 = @"";
    NSString* wrongDefinition3 = @"";
    
    if ([self.wrongDefinitions count] >= 1) wrongDefinition1 = [self.wrongDefinitions objectAtIndex:0];
    if ([self.wrongDefinitions count] >= 2) wrongDefinition2 = [self.wrongDefinitions objectAtIndex:1];
    if ([self.wrongDefinitions count] >= 3) wrongDefinition3 = [self.wrongDefinitions objectAtIndex:2];
    
    //Return formatted array
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:self.lessonNumber],
            self.wordString,
            self.definitionString,
            self.sentenceString,
            wrongDefinition1, //Array of NSStrings
            wrongDefinition2,
            wrongDefinition3,
            nil];
    
}//End arrayToStoreForQuestion

@end
