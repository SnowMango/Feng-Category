//
//  Modle+Fourth.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "Modle+Fourth.h"

@implementation Fourth


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"相机相册";
        self.loadingImage = @"login_1";
        self.identifier = @"identifier";
        self.version = @"1.0.0";
        self.detail = @"this is a Fourth module detail";
        self.rootViewController = [UIStoryboard storyboardWithName:@"FourthMain" bundle:nil].instantiateInitialViewController;
    }
    return self;
}
@end
