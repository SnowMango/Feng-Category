//
//  ZFBillDetailViewController.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBill.h"

@interface ZFBillDetailViewController : UIViewController

@property (strong, nonatomic) ZFBill *showBill;

@property (copy, nonatomic) void (^change)(BOOL finish);
@end
