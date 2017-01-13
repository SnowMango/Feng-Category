//
//  Module+Second.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/14.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "Module+Second.h"

@implementation Second
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"2222";
        self.loadingImage = @"login_1";
        self.identifier = @"Second";
        self.version = @"1.0.0";
        self.detail = @"this is a Second module detail";
        self.rootViewController = [UIStoryboard storyboardWithName:@"SecondMain" bundle:nil].instantiateInitialViewController;
    }
    return self;
}



@end
