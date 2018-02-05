//
//  ZFDishes.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@class ZFDishesGroup;

@interface ZFDishes : BaseModel

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *unit;

@property (strong, nonatomic) ZFDishesGroup * group;

@property (nonatomic) double price;

@property (nonatomic) double count;

@end



