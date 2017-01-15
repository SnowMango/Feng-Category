//
//  Teacher.h
//  
//
//  Created by 郑丰 on 2017/1/15.
//
//  This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import "Human.h"
#import "NSManagedObject+Base.h"
@class Student;

NS_ASSUME_NONNULL_BEGIN

@interface Teacher : Human

@property (nullable, nonatomic, copy) NSString *subject;
@property (nullable, nonatomic, retain) NSSet<Student *> *students;

- (void)addStudentsObject:(Student *)value;
- (void)removeStudentsObject:(Student *)value;
- (void)addStudents:(NSSet<Student *> *)values;
- (void)removeStudents:(NSSet<Student *> *)values;

@end
NS_ASSUME_NONNULL_END

