//
//  QuizObject.m
//  RRV101
//
//  Created by Brian C. Grant on 9/26/11 for Rich and Rare Vocabulary Company.
//  Copyright (c) 2012 Brian C. Grant. All rights reserved.
//

#import "QuizObject.h"
#import "QuestionObject.h"
#import "WordObject.h"
#import "RRVConstants.txt"

@implementation QuizObject

#pragma mark Synthesizers

@synthesize quizIsEmbedded, quizIsPrecursor, quizIsGraded;
@synthesize nameOfUser, classOfUser, dateStarted, dateSubmitted, lessonNumber;
@synthesize numberQuestionsTotal, numberQuestionsCorrect, numberQuestionsMissed, percentageGrade;
@synthesize wordsCorrect, wordsMissed;
@synthesize questionObjects;
@synthesize currentPage, numberOfPages;

#pragma mark - PUBLIC METHODS -

#pragma mark Constructors

+(QuizObject*) loadForLessonNumber:(NSInteger)lessonNumberToLoad {
    
    return [[[self alloc] initForLessonNumber:lessonNumberToLoad] autorelease];
    
}//End loadForLessonNumber:

+(QuizObject*) loadQuizFromDictionary:(NSDictionary *)dictionaryWithInfo {
    
    return [[[self alloc] initQuizWithDictionary:dictionaryWithInfo] autorelease];
    
}//End loadQuizFromDictionary:

#pragma mark - PRIVATE METHODS -
#pragma mark Object Lifecycle -

#pragma mark Memory Management

-(void) dealloc {
    
    [nameOfUser release];
    [classOfUser release];
    [dateStarted release];
    [dateSubmitted release];
    [wordsCorrect release];
    [wordsMissed release];
    [questionObjects release];
    
    [super dealloc];
}//End dealloc

#pragma mark Constructors

-(id) init {
    if(self = [super init]) {
        //
        // [ VERY IMPORTANT! ] ----- Complications arise from collapsing with a nil property, as nil ends input into NSDictionary/NSArray ----- [ VERY IMPORTANT! ]
        //
        
        NSLog(@"QuizObject fires init!");
        //Intialize properties to non-nil, avoids complications from above
        self.nameOfUser = @"";
        self.classOfUser = @"";
        self.lessonNumber = 0;
        self.dateStarted = [NSDate date];
        self.dateSubmitted = [NSDate date];//So that it is not nil
        self.numberQuestionsTotal = 0;
        self.numberQuestionsCorrect = 0;
        self.numberQuestionsMissed = 0;
        self.wordsCorrect = [[[NSArray alloc] init] autorelease];
        self.wordsMissed = [[[NSArray alloc] init] autorelease];
        self.percentageGrade = 0.0;
        self.questionObjects = [[[NSArray alloc] init] autorelease];
        self.currentPage = 0;
        self.numberOfPages = 0;
    }
    return self;
}//End init

-(QuizObject*) initForLessonNumber:(NSInteger)lessonNumberToLoad{
    
    if ([self init]) {//Ensure successful initialization
    
        self.lessonNumber = lessonNumberToLoad;
        
        //FUTURE FEATURE: Load nameOfUser & classOfUser?
        
        //Load desired quiz from Quiz.plist into (NSArray)quizQuestions
        NSString* lessonFilename = [NSString stringWithFormat:@"WordList%i.plist", self.lessonNumber];
        NSString* path = [[NSBundle mainBundle] bundlePath];
        NSString* finalPath = [path stringByAppendingPathComponent:lessonFilename];
        NSArray* quizQuestions = [[NSDictionary dictionaryWithContentsOfFile:finalPath] objectForKey:@"WordList"];
        NSLog(@"%i", [quizQuestions count]);
        
        //Parse the questions for the quiz from the PList and add them to an array of Question objects {{After shuffling their answers}}
        NSMutableArray* quizQuestionObjects = [[[NSMutableArray alloc] init] autorelease];
        for (int questionIndex = 0; questionIndex < [quizQuestions count]; questionIndex++){//For each object in the NSArray obtained from the file...
            
            //Obtain a word from the list, build WordObject
            WordObject* wordForQuestion = [WordObject loadWithArray:[quizQuestions objectAtIndex:questionIndex]];
            
            //Make a QuestionObject from the WordObject
            QuestionObject* questionObject = [QuestionObject loadForWord:wordForQuestion questionNumber:questionIndex];
            
            //Shuffle its answers (3 times for efficiency)
            [questionObject shuffleAnswerChoices]; [questionObject shuffleAnswerChoices]; [questionObject shuffleAnswerChoices];
            
            //Add to quizQuestionObjects
            [quizQuestionObjects addObject:questionObject]; 
            
        }//End for{} (each object in array from file)
        
        //Shuffle the quesionObjects themselves and return them as (NSArray*) {{Shuffles the objects twice}}
        self.questionObjects = [[quizQuestionObjects sortedArrayUsingFunction:shuffleObjectArray context:NULL] sortedArrayUsingFunction:shuffleObjectArray context:NULL];
        self.numberQuestionsTotal = [self.questionObjects count];
        self.numberOfPages = 1 + self.numberQuestionsTotal + 1;
        
        //Reset scrambled question numbers
        for (NSInteger index = 0; index < [self.questionObjects count]; index++) {//For each questionObject
            
            //Set number to corresponding index
            [(QuestionObject*)[self.questionObjects objectAtIndex:index] setNumber:(index+1)];
            
        }//End for{} (each questionObject)
    }
    return self;
}//End initForLessonNumber

-(QuizObject*) initQuizWithDictionary:(NSDictionary*)dictionaryWithInfo {
    
    if ([self init]) {//After successful init 
        //Set properties from passed NSDictionary
        
        //Name & Class
        self.nameOfUser = [dictionaryWithInfo valueForKey:key_QuizNameOfUser];
        self.classOfUser = [dictionaryWithInfo valueForKey:key_QuizClassOfUser];
        self.lessonNumber = [[dictionaryWithInfo valueForKey:key_QuizNumber] intValue];
        
        //Dates
        self.dateStarted = (NSDate*)[dictionaryWithInfo objectForKey:key_QuizDateStarted];
        self.dateSubmitted = (NSDate*)[dictionaryWithInfo objectForKey:key_QuizDateSubmitted];
    
        //Question Counts
        self.numberQuestionsTotal = [[dictionaryWithInfo valueForKey:key_QuizTotalQuestionsCount] intValue];
        self.numberQuestionsCorrect = [[dictionaryWithInfo valueForKey:key_QuizCorrectQuestionCount] intValue];
        self.numberQuestionsMissed = [[dictionaryWithInfo valueForKey:key_QuizMissedQuestionCount] intValue];
    
        //Grades
        self.percentageGrade = [[dictionaryWithInfo valueForKey:key_QuizPercentageGrade] floatValue];
    
        //Word Tracking
        self.wordsCorrect = (NSArray*)[dictionaryWithInfo objectForKey:key_QuizWordsCorrectArray];
        self.wordsMissed = (NSArray*)[dictionaryWithInfo objectForKey:key_QuizWordsMissedArray];
    
        //QuestionObjects
        NSArray* arrayToLoadQuestionsFrom = [dictionaryWithInfo objectForKey:key_QuizQuestionArraysArray];//Grab the arrays (collapsed QuestionObjects)
        NSMutableArray* loadedQuestionObjects = [NSMutableArray arrayWithCapacity:[arrayToLoadQuestionsFrom count]];//Mutable to stack loaded QuestionObjects
        for (NSInteger index = 0; index < [arrayToLoadQuestionsFrom count]; index++) {//For each collapsed QuestionObject in array
            
            //Rebuild the collapsed QuestionObject, add to collection stack
            QuestionObject* questionToAdd = [QuestionObject loadFromArray:[arrayToLoadQuestionsFrom objectAtIndex:index]];
            [loadedQuestionObjects addObject:questionToAdd];
            
        }//End for {} (each array in array)
        self.questionObjects = [NSArray arrayWithArray:loadedQuestionObjects];//Assign collection stack to non-mutable property
    }
    return self;
}//End loadFromDictionary:

#pragma mark Collapsers

-(NSDictionary*) collapseToDictionary {
    
    //Collapse QuestionObjects for storage
    NSMutableArray* questionArraysMutableArray = [NSMutableArray arrayWithCapacity:[self.questionObjects count]];//Mutable to collect QuestionObjects
    for (NSInteger index = 0; index < [self.questionObjects count]; index++) {//For each QuestionObject in array
        
        //Collapse and add to collection
        NSArray* questionArray = [(QuestionObject*)[self.questionObjects objectAtIndex:index] collapseToArray];
        [questionArraysMutableArray addObject:questionArray];
        
    }//End for {} (each QuestionObject in array)
    NSArray* questionArraysArray = [NSArray arrayWithArray:questionArraysMutableArray];//Assign to non-mutable
    
    //Arrange an array of metrics
    NSArray* objectsForDictionary = [NSArray arrayWithObjects:
                                     self.nameOfUser,
                                     self.classOfUser,
                                     [NSNumber numberWithInt:self.lessonNumber],
                                     self.dateStarted,
                                     self.dateSubmitted,
                                     [NSNumber numberWithInt:self.numberQuestionsTotal],
                                     [NSNumber numberWithInt:self.numberQuestionsCorrect],
                                     [NSNumber numberWithInt:self.numberQuestionsMissed],
                                     [NSNumber numberWithFloat:self.percentageGrade],
                                     self.wordsCorrect,
                                     self.wordsMissed,
                                     questionArraysArray,
                                     nil ];
    
    //Arrange an accompany array of keys
    NSArray* keysForDictionary = [NSArray arrayWithObjects:
                                  key_QuizNameOfUser,
                                  key_QuizClassOfUser,
                                  key_QuizNumber,
                                  key_QuizDateStarted,
                                  key_QuizDateSubmitted,
                                  key_QuizTotalQuestionsCount,
                                  key_QuizCorrectQuestionCount,
                                  key_QuizMissedQuestionCount,
                                  key_QuizPercentageGrade,
                                  key_QuizWordsCorrectArray,
                                  key_QuizWordsMissedArray,
                                  key_QuizQuestionArraysArray,
                                  nil ];
    
    return [NSDictionary dictionaryWithObjects:objectsForDictionary forKeys:keysForDictionary];
}//End collapseToDictionary

#pragma mark - Tasks -

#pragma mark Data Manipulators

-(void) appendQuestionObject:(QuestionObject *)questionObjectToAppend {
    NSLog(@"QuizObject appending QuestionObject!");
    //Add to questionObjects array
    NSMutableArray* aggregator = [NSMutableArray arrayWithArray:self.questionObjects];
    [aggregator addObject:questionObjectToAppend];
    self.questionObjects = [NSArray arrayWithArray:aggregator];
    NSLog(@"New last QuestionObject: %@", [[self.questionObjects objectAtIndex:([self.questionObjects count]-1)] wordForQuestion]);
}//End appendQuestionObject:

#pragma mark Queries

-(void) grade {
    
    //Grade Quiz
    NSInteger quizAnswerTally = 0;
    NSMutableArray* wordsMissedTemp = [NSMutableArray arrayWithCapacity:self.numberQuestionsTotal];
    NSMutableArray* wordsCorrectTemp = [NSMutableArray arrayWithCapacity:self.numberQuestionsTotal];
    for (int questionNumberToGrade = 0; questionNumberToGrade < [self.questionObjects count]; questionNumberToGrade++) {//For each QuestionObject in the array
        
        //Get reference to the current Question object from self.questionObjects array
        QuestionObject* questionObjectToGrade = [self.questionObjects objectAtIndex:questionNumberToGrade];
        [questionObjectToGrade grade];
        
        //Measure results
        if (questionObjectToGrade.answeredCorrectly) {//User answered the questionObjectToGrade correctly
            
            //Add word string to correct words array & increment tally of correctly answered questions
            [wordsCorrectTemp addObject:questionObjectToGrade.wordForQuestion];
            quizAnswerTally++;
            
        }//End of if{} - Correct Answer segment
        else{//User did not answer the questionObjectToGrade correctly
            
            [wordsMissedTemp addObject:questionObjectToGrade.wordForQuestion];
            
        }//End of else{} - Incorrect Answer segment
        
    }//End of for{} - Grade Quiz segment
    self.numberQuestionsTotal = [self.questionObjects count];
    self.numberQuestionsCorrect = quizAnswerTally;
    self.numberQuestionsMissed =  quizAnswerTally - self.numberQuestionsTotal;
    self.percentageGrade = ( (CGFloat)self.numberQuestionsCorrect / (CGFloat)self.numberQuestionsTotal ) * 100.0;
    self.wordsCorrect = [NSArray arrayWithArray:wordsCorrectTemp];
    self.wordsMissed = [NSArray arrayWithArray:wordsMissedTemp];
    
    self.quizIsGraded = YES;
}//End gradedQuizFromQuiz:

- (NSString*) ratioString {
    
    //Ratio string (#Correct / #Missed)
    return [NSString stringWithFormat:@"%i / %i", self.numberQuestionsCorrect, self.numberQuestionsTotal];
    
}//End ratioString

- (NSString*) percentString {
    
    //Percent string (% Number)
    return [NSString stringWithFormat:@"%.1f %%", self.percentageGrade]; //One decimal place
    
}//End percentString

-(NSString*) letterGradeString {
    
    //Decide letter grade from percentage
    NSString* letterGradeString = [[[NSString alloc] initWithFormat:@""] autorelease];
    if (self.percentageGrade >= 97) {//A+
        letterGradeString = @"A+";
    }
    else if (self.percentageGrade >= 93 && self.percentageGrade < 97) {//A
        letterGradeString = @"A";
    }
    else if (self.percentageGrade >= 90 && self.percentageGrade < 93) {//A-
        letterGradeString = @"A-";
    }
    else if (self.percentageGrade >= 87 && self.percentageGrade < 90) {//B+
        letterGradeString = @"B+";
    }
    else if (self.percentageGrade >= 83 && self.percentageGrade < 87) {//B
        letterGradeString = @"B";
    }
    else if (self.percentageGrade >= 80 && self.percentageGrade < 83) {//B-
        letterGradeString = @"B-";
    }
    else if (self.percentageGrade >= 77 && self.percentageGrade < 80) {//C+
        letterGradeString = @"C+";
    }
    else if (self.percentageGrade >= 73 && self.percentageGrade < 77) {//C
        letterGradeString = @"C";
    }
    else if (self.percentageGrade >= 70 && self.percentageGrade < 73) {//C-
        letterGradeString = @"C-";
    }
    else if (self.percentageGrade >= 67 && self.percentageGrade < 70) {//D+
        letterGradeString = @"D+";
    }
    else if (self.percentageGrade >= 63 && self.percentageGrade < 67) {//D
        letterGradeString = @"D";
    }
    else if (self.percentageGrade >= 60 && self.percentageGrade < 63) {//D-
        letterGradeString = @"D-";
    }
    else if (self.percentageGrade < 60) {//F
        letterGradeString = @"F";
    }
    
    //Return letter grade string
    return letterGradeString;
}//End letterGradeString

#pragma mark Support

NSInteger shuffleObjectArray(id num1, id num2, void *context){
    
    //Randomly choose to change (3 values: ascending, descending, same)
    int result = arc4random()%3;
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

@end
