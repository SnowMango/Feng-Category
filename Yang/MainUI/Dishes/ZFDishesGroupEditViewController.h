//
//  ZFDishesGroupEditViewController.h
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFDishesGroup.h"

@interface ZFDishesGroupEditViewController : UIViewController

@property (strong, nonatomic) ZFDishesGroup *editGroup;

@property (copy, nonatomic) void (^compelte)(BOOL finish);
@property (copy, nonatomic) void (^deleteGroup)(BOOL finish);
@end
