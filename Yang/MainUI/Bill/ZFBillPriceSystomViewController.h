//
//  ZFBillPriceSystomViewController.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPriceSystom.h"
@interface ZFBillPriceSystomViewController : UIViewController
@property (nonatomic, strong) NSArray <ZFPriceSystom*>* showData;
@property (nonatomic, strong) ZFPriceSystom * selectSystom;

@property (copy, nonatomic) void (^complete)(ZFPriceSystom *systom);
@end
