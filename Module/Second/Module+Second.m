//
//  Module+Second.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/14.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "Module+Second.h"

@implementation Module (Second)

module_synthesize(Second_title)
module_synthesize(Second_loadingImage)
module_synthesize(Second_identifier)
module_synthesize(Second_version)
module_synthesize(Second_detail)
module_synthesize(Second_rootViewController)

- (void)Second_loadModule
{
    self.Second_title = @"2222";
    self.Second_loadingImage = @"login_1";
    self.Second_identifier = @"Second";
    self.Second_version = @"1.0.0";
    self.Second_detail = @"this is a Second module detail";
    self.Second_rootViewController = [UIStoryboard storyboardWithName:@"SecondMain" bundle:nil].instantiateInitialViewController;
}

@end
