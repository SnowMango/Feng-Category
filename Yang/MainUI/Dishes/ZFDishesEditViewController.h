//
//  ZFDishesEditViewController.h
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZFDishes.h"
@interface ZFDishesEditViewController : UIViewController

@property (strong, nonatomic)  ZFDishes*editDishes;

@property (copy, nonatomic) void (^compelte)(BOOL finish);
@end
