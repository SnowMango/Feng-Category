//
//  LZFCalendarMiniView.h
//  yang
//
//  Created by 郑丰 on 2018/6/15.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LZFCalendarMiniViewSelectionType) {
    LZFCalendarMiniViewSelectionSingle = 0,          // 单选
    LZFCalendarMiniViewSelectionMultiple = 1,        // 多选
};
typedef void(^CalendarViewDidSelect)(NSDate *day);

@interface LZFCalendarMiniView : UIView
@property (nonatomic) LZFCalendarMiniViewSelectionType calendarSelectType;

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

@interface LZFCalendarMiniCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *selectIV;
@property (strong, nonatomic) UILabel *solar;
@property (strong, nonatomic) UILabel *Lunar;

@property (nonatomic, copy) NSDate * cellDay;
@end


