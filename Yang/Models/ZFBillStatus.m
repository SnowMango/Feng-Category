//
//  ZFBillStatus.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillStatus.h"

@implementation ZFBillStatus

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.identifier = [self uuidIdentifier];
    }
    return self;
}
@end
