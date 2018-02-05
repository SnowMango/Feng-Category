//
//  ZFPriceSystom.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFPriceSystom.h"

@implementation ZFPriceSystom
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.identifier = [self uuidIdentifier];
    }
    return self;
}

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[ZFPriceSystom class]]) {
        ZFDishesGroup* obj = object;
        return [obj.identifier isEqualToString:self.identifier];
    }
    return [super isEqual:object];
}

@end
