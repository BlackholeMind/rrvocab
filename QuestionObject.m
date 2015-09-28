//
//  QuestionObject.m
//  RRV101
//
//  Created by Brian C. Grant on 9/23/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import "QuestionObject.h"
#import "WordObject.h"
#import "RRVConstants.txt"


@implementation QuestionObject

#pragma mark Synthesizers

@synthesize number, wordForQuestion, correctAnswer, chosenAnswer, answerChoices, answeredCorrectly;

#pragma mark - PUBLIC METHODS -
#pragma mark Constructors

+(QuestionObject*) loadFromArray:(NSArray *)arrayForQuestion {
    
    return [[[self alloc] initQuestionWithArray:arrayForQuestion] autorelease];
    
}//End loadFromArray:

+(QuestionObject*) loadForWord:(WordObject *)wordObject questionNumber:(NSInteger)numberOfQuestion {
    
    return [[[self alloc] initWithWord:wordObject questionNumber:numberOfQuestion] autorelease];
    
}//End loadForWord: questionNumber:

#pragma mark - PRIVATE METHODS -
#pragma mark Object Lifecycle -

#pragma mark Memory Management

-(void) dealloc {
    
    [wordForQuestion release];
    [correctAnswer release];
    [chosenAnswer release];
    [answerChoices release];
    
    [super dealloc];
}//End dealloc

#pragma mark Constructors

-(QuestionObject*) initWithWord:(WordObject *)wordObject questionNumber:(NSInteger)numberOfQuestion{
    
    NSArray* arrayForQuestion = nil;
    
    if (wordObject) {//Non-nil WordObject
            
        //Array to collect valid answer choices
        NSMutableArray* validAnswerChoices = [NSMutableArray arrayWithCapacity:4];
        NSString* correctAnswerString = wordObject.definitionString;
            
        //Check correct answer, add it first (if valid)
        if (correctAnswerString && ![correctAnswer isEqualToString:@""]) {//Valid correct answer was given
            
            [validAnswerChoices addObject:correctAnswerString];
            
        }
        else {//Definition was not given
            correctAnswer = @"NOT GIVEN!";
        }
            
        //Add other answer choices (Non-nil & Non-empty checks are done in WordObject class)
        for (NSInteger index = 0; index < [wordObject.wrongDefinitions count]; index++) {//For each valid answer choice
                
            [validAnswerChoices addObject:[wordObject.wrongDefinitions objectAtIndex:index]];
                
        }//End for{} (each valid answer choice)
        self.answerChoices = [NSArray arrayWithArray:validAnswerChoices];
            
        //Not answered & not correct by default
        NSString* chosenAnswerString = @"NO ANSWER...";
        
        arrayForQuestion = [NSArray arrayWithObjects:[NSNumber numberWithInt:numberOfQuestion],
                            wordObject.wordString,
                            correctAnswerString,
                            chosenAnswerString,
                            validAnswerChoices,
                            nil];
            
        }//End if{} (wordObject exists)
    
    return [self initQuestionWithArray:arrayForQuestion];
    
}//End initWithWord: questionNumber:

-(QuestionObject*) initQuestionWithArray:(NSArray *)arrayForQuestion {
    
    if (self = [super init]) {
        
        if (arrayForQuestion != nil && [arrayForQuestion count] == kQuestionObjectCollapsedArrayMandatoryPropertyCount) {//Valid array
            
            //Load properties from array
            self.number = [[arrayForQuestion objectAtIndex:kQuestionNumber] intValue];
            self.wordForQuestion = [arrayForQuestion objectAtIndex:kQuestionWord];
            self.correctAnswer = [arrayForQuestion objectAtIndex:kQuestionCorrectAnswer];
            self.chosenAnswer = [arrayForQuestion objectAtIndex:kQuestionChosenAnswer];
            self.answerChoices = [arrayForQuestion objectAtIndex:kQuestionAnswerChoices];
            
            if ([self.chosenAnswer isEqualToString:self.correctAnswer]) self.answeredCorrectly = YES; 
            else self.answeredCorrectly = NO;
        }
        
    }
    
    return self;
    
}//End initQuestionWithArray:

#pragma mark Collapsers

-(NSArray*) collapseToArray {
    
    //Return formatted array
    return [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:self.number],
                                 self.wordForQuestion,
                                 self.correctAnswer,
                                 self.chosenAnswer,
                                 self.answerChoices,//Array of NSStrings
                                 nil];
}//End arrayToStoreForQuestion

#pragma mark - TASKS -

-(void) shuffleAnswerChoices {
    
    self.answerChoices = [self.answerChoices sortedArrayUsingFunction:shuffleArray context:NULL];
    
}//End shuffleAnswerChoices

-(void) grade {
    
    if ([self.chosenAnswer isEqualToString:self.correctAnswer]) self.answeredCorrectly = YES;
    
}//End gradedQuestionFromQuestion

-(NSString*) numberString {
    
    return [NSString stringWithFormat:@"%i", self.number];
    
}//End numberString

#pragma mark Support

NSInteger shuffleArray(id num1, id num2, void *context){
    
    //Randomly choose to change (3 values: ascending, descending, same)
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
}//End shuffleArray

@end
