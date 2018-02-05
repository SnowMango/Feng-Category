//
//  ZFDishes.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFDishes.h"

@implementation ZFDishes

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
    if ([object isKindOfClass:[self class]]) {
        ZFDishes* obj = object;
        return [obj.identifier isEqualToString:self.identifier];
    }
    return [super isEqual:object];
}
@end
