//
//  ZFBillDateViewController.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFBillDateViewController : UIViewController

@property (copy, nonatomic) void (^complete)(NSDate *start, NSDate *end);

@end
