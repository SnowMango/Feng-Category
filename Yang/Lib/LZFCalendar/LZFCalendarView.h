//
//  LZFCalendarView.h
//  LayoutTest
//
//  Created by zhengfeng on 2017/9/8.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LZFCalendar.h"


typedef NS_ENUM(NSInteger, LZFCalendarViewSelectionType) {
    LZFCalendarViewSelectionSingle = 0,          // 单选
    LZFCalendarViewSelectionMultiple = 1,        // 多选
};
typedef void(^CalendarViewDidSelect)(NSDate *day);

@interface LZFCalendarView : UIView

@property (nonatomic) LZFCalendarViewSelectionType calendarSelectType;

@property (nonatomic, copy) NSDate *startDate;

@property (nonatomic, copy) NSDate *fireDate;


@property (nonatomic, copy) CalendarViewDidSelect selectDay;

- (void)updateCalendarView;

- (void)addSelectDay:(NSDate *)day;
- (void)removeSelectDay:(NSDate *)day;

- (void)addSelectDays:(NSArray *)days;
- (void)removeSelectDays:(NSArray *)days;

- (NSArray *)currentSelectDays;
@end


@interface LZFCalendarCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *selectIV;
@property (strong, nonatomic) UILabel *solar;
@property (strong, nonatomic) UILabel *Lunar;

@property (nonatomic, copy) NSDate * cellDay;

@end

@interface LZFCalendarHeaderCell : UICollectionReusableView

@property (strong, nonatomic) UILabel *monthTitle;

@property (nonatomic, copy) NSDate * cellMonth;
@end
