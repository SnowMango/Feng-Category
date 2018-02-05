//
//  ZFBillAddViewController.h
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
@interface ZFBillAddViewController : UIViewController

@property (strong, nonatomic) ZFPriceSystom *systom;
@property (copy, nonatomic) void (^compelte)(ZFBill* bill);

@end
