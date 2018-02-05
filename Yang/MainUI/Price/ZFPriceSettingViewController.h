//
//  ZFPriceSettingViewController.h
//  yang
//
//  Created by 郑丰 on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFPriceSettingViewController : UIViewController
@property (strong, nonatomic) NSArray *systoms;
@property (copy, nonatomic) void (^didEdit)(NSArray *systoms);

@end
