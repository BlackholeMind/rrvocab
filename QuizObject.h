//
//  QuizObject.h
//  RRV101
//
//  Created by Brian C. Grant on 9/26/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QuestionObject;

@interface QuizObject : NSObject {
    BOOL quizIsEmbedded;
    BOOL quizIsPrecursor;
    BOOL quizIsGraded;
    NSString* nameOfUser;
    NSString* classOfUser;
    NSDate* dateStarted;
    NSDate* dateSubmitted;
    NSInteger lessonNumber;
    NSInteger numberQuestionsTotal;
    NSInteger numberQuestionsCorrect;
    NSInteger numberQuestionsMissed;
    NSArray* wordsCorrect;
    NSArray* wordsMissed;
    CGFloat percentageGrade;
    NSArray* questionObjects;
    NSInteger currentPage;
    NSInteger numberOfPages;
}
////PROPERTIES////
@property BOOL quizIsEmbedded;
@property BOOL quizIsPrecursor;
@property BOOL quizIsGraded;
@property (nonatomic, copy) NSString* nameOfUser;
@property (nonatomic, copy) NSString* classOfUser;
@property (nonatomic, retain) NSDate* dateStarted;
@property (nonatomic, retain) NSDate* dateSubmitted;
@property NSInteger lessonNumber;
@property NSInteger numberQuestionsTotal;
@property NSInteger numberQuestionsCorrect;
@property NSInteger numberQuestionsMissed;
@property (nonatomic, retain) NSArray* wordsCorrect;
@property (nonatomic, retain) NSArray* wordsMissed;
@property CGFloat percentageGrade;
@property (nonatomic, retain) NSArray* questionObjects;
@property NSInteger numberOfPages;
@property NSInteger currentPage;

////METHODS////
//PUBLIC
//Constructors
+(QuizObject*) loadForLessonNumber:(NSInteger)lessonNumberToLoad;
+(QuizObject*) loadQuizFromDictionary:(NSDictionary*)dictionaryWithInfo;

//PRIVATE
//Constructors
-(QuizObject*) initForLessonNumber:(NSInteger)lessonNumberToLoad;
-(QuizObject*) initQuizWithDictionary:(NSDictionary*)dictionaryWithInfo;
//Collapsers
-(NSDictionary*) collapseToDictionary;
//Tasks
-(void) appendQuestionObject:(QuestionObject *)questionObjectToAppend;
-(void) grade;
- (NSString*) ratioString;
- (NSString*) percentString;
- (NSString*) letterGradeString; 
//Support
NSInteger shuffleObjectArray(id num1, id num2, void *context);

@end
