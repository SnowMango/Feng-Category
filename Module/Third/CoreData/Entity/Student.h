//
//  Student.h
//  
//
//  Created by 郑丰 on 2017/1/15.
//
//  This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import "Human.h"
#import "NSManagedObject+Base.h"
@class Teacher;

NS_ASSUME_NONNULL_BEGIN

@interface Student : Human

@property (nullable, nonatomic, copy) NSString *grade;
@property (nullable, nonatomic, retain) Teacher *teacher;



@end


NS_ASSUME_NONNULL_END

