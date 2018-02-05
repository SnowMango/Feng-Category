//
//  ZFBillStatusViewController.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBillStatus.h"
@interface ZFBillStatusViewController : UIViewController

@property (nonatomic, strong) NSArray <ZFBillStatus*>* showData;
@property (nonatomic, strong) ZFBillStatus * selectStatus;

@property (copy, nonatomic) void (^complete)(ZFBillStatus *status);
@end
