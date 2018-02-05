//
//  ZFBillDateViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillDateViewController.h"
#import "LZFCalendarView.h"
#import "SVProgressHUD.h"
@interface ZFBillDateViewController ()
@property (nonatomic,weak) IBOutlet LZFCalendarView *calenderView;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@end

@implementation ZFBillDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.calenderView.startDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    self.calenderView.selectDay = ^(NSDate *day) {
        NSArray *days = [weakSelf.calenderView currentSelectDays];
        if (days.count > 2) {
            NSDate *start = days.firstObject;
            NSDate *end = days.lastObject;
            [weakSelf.calenderView removeSelectDays:days];
            [weakSelf.calenderView addSelectDays:@[start,end]];
            [weakSelf.calenderView updateCalendarView];
        }
        
    };
}

- (IBAction)cancelBtn:(id)sender
{
    if (self.complete) {
        self.complete(nil, nil);
    }
    [self.view removeFromSuperview];
}
- (IBAction)doneBtn:(id)sender
{
    NSArray *days = [self.calenderView currentSelectDays];
    if (days.count) {
        days = [days sortedArrayUsingSelector:@selector(compare:)];
        self.startDate= days.firstObject;
        self.endDate = days.lastObject;
    }
    if (!self.startDate && !self.endDate) {
        [SVProgressHUD showErrorWithStatus:@"未选择时间"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    if (self.complete) {
        self.complete(self.startDate, self.endDate);
    }
    [self.view removeFromSuperview];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint loc = [[touches anyObject] locationInView:self.view];
    if (!CGRectContainsPoint(self.calenderView.superview.frame, loc)) {
        [self.view removeFromSuperview];
    }
}

@end
