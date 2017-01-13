//
//  Module+Third.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/28.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "Module+Third.h"

@implementation Third


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"数据库";
        self.loadingImage = @"login_1";
        self.identifier = @"Third";
        self.version = @"1.0.0";
        self.detail = @"this is a Third module detail";
        self.rootViewController = [UIStoryboard storyboardWithName:@"ThirdMain" bundle:nil].instantiateInitialViewController;
    }
    return self;
}
@end
