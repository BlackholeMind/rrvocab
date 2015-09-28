//
//  QuestionObject.h
//  RRV101
//
//  Created by Brian C. Grant on 9/23/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2011 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WordObject;

@interface QuestionObject : NSObject {
    NSInteger number;
    NSString* wordForQuestion;
    NSString* correctAnswer;
    NSString* chosenAnswer;
    NSArray* answerChoices;
    BOOL answeredCorrectly;
}
////PROPERTIES////
@property NSInteger number;
@property (nonatomic, retain) NSString* wordForQuestion;
@property (nonatomic, retain) NSString* correctAnswer;
@property (nonatomic, retain) NSString* chosenAnswer;
@property (nonatomic, retain) NSArray* answerChoices;
@property BOOL answeredCorrectly;

////METHODS////
//PUBLIC
//Constructors
+(QuestionObject*) loadFromArray:(NSArray*)arrayForQuestion;
+(QuestionObject*) loadForWord:(WordObject*)wordObject questionNumber:(NSInteger)numberOfQuestion;

//PRIVATE
//Constructors
-(QuestionObject*) initWithWord:(WordObject *)wordObject questionNumber:(NSInteger)numberOfQuestion;
-(QuestionObject*) initQuestionWithArray:(NSArray*)arrayForQuestion;
//Collapsers
-(NSArray*) collapseToArray;
//Tasks
-(void) shuffleAnswerChoices;
-(void) grade;
-(NSString*) numberString;
//Support
NSInteger shuffleArray(id num1, id num2, void *context);

@end
