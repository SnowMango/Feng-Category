//
//  Teacher.m
//  
//
//  Created by 郑丰 on 2017/1/15.
//
//  This file was automatically generated and should not be edited.
//

#import "Teacher.h"
#import "Student.h"
@implementation Teacher
@dynamic subject;
@dynamic students;

- (void)addStudentsObject:(Student *)value
{
    if (![self.students containsObject:value]) {
        value.teacher = self;
        NSMutableSet *set = [NSMutableSet setWithSet:self.students];
        [set addObject:value];
        self.students = [set copy];
    }
}
- (void)removeStudentsObject:(Student *)value
{
    if ([self.students containsObject:value]) {
        NSMutableSet *set = [NSMutableSet setWithSet:self.students];
        [set removeObject:value];
        self.students = [set copy];
    }
}
- (void)addStudents:(NSSet<Student *> *)values
{
    for (Student *s in [values allObjects]) {
        [self addStudents:(id)s];
    }
}
- (void)removeStudents:(NSSet<Student *> *)values
{
    for (Student *s in [values allObjects]) {
        [self removeStudents:(id)s];
    }
}

@end

