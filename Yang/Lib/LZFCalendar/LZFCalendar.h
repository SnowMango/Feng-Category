//
//  LZFCalendar.h
//  LayoutTest
//
//  Created by zhengfeng on 2017/9/8.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Lunar;

@interface LZFCalendar : NSObject

+ (NSDate *)lunarToSolar:(Lunar *)lunar;

+ (Lunar *)solarToLunar:(NSDate *)solar;

+ (NSArray <NSString*>*)lunarMoths;
+ (NSArray <NSString*>*)lunarDays;
@end


@interface Lunar : NSObject
/**
 *是否闰月
 */
@property(assign) BOOL isleap;
/**
 *农历 日
 */
@property(assign) int lunarDay;
/**
 *农历 月
 */
@property(assign) int lunarMonth;
/**
 *农历 年
 */
@property(assign) int lunarYear;

@end


@interface NSDate (LZFCalendar)

- (NSDate *)firstDayOfMonth;

- (NSDate *)addMonths:(NSInteger)months;
- (NSDate *)addDays:(NSInteger)days;

- (NSUInteger)numberOfWeeks;

- (NSUInteger)weeklyOrdinality;

- (NSInteger)month;
@end
