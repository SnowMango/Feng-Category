//
//  Module+Third.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/28.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "Module+Third.h"

@implementation Module (Third)
module_synthesize(Third_title)
module_synthesize(Third_loadingImage)
module_synthesize(Third_identifier)
module_synthesize(Third_version)
module_synthesize(Third_detail)
module_synthesize(Third_rootViewController)

- (void)Third_loadModule
{
    self.Third_title = @"数据库";
    self.Third_loadingImage = @"login_1";
    self.Third_identifier = @"Third";
    self.Third_version = @"1.0.0";
    self.Third_detail = @"this is a Third module detail";
    self.Third_rootViewController = [UIStoryboard storyboardWithName:@"ThirdMain" bundle:nil].instantiateInitialViewController;
}

@end
