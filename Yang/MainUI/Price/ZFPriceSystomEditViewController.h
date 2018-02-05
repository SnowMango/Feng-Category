//
//  ZFPriceSystomEditViewController.h
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPriceSystom.h"
@interface ZFPriceSystomEditViewController : UIViewController
@property (strong, nonatomic) ZFPriceSystom *systom;
@property (copy, nonatomic) void (^compelte)(BOOL finish);
@end
