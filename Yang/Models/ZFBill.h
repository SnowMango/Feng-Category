//
//  ZFBill.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

#import "ZFBillStatus.h"
#import "ZFDishes.h"

@interface ZFBill : BaseModel

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSDate *time;

@property (strong, nonatomic) NSArray <ZFDishes*>*dishes;
@property (nonatomic) double amount;
@property (nonatomic) double income;
@property (nonatomic) double itemCount;

@property (strong, nonatomic) ZFBillStatus *status;

@property (strong, nonatomic) NSString *systomId;
@property (strong, nonatomic) NSString *systomName;
@end
