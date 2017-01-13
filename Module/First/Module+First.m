//
//  Module+First.m
//  Pods
//
//  Created by zhengfeng on 16/11/7.
//
//

#import "Module+First.h"

@implementation First

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"绘图";
        self.loadingImage = @"login_1";
        self.identifier = @"identifier";
        self.version = @"1.0.0";
        self.detail = @"this is a first module detail";
        self.rootViewController = [UIStoryboard storyboardWithName:@"FirstMain" bundle:nil].instantiateInitialViewController;
    }
    return self;
}


@end
