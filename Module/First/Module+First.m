//
//  Module+First.m
//  Pods
//
//  Created by zhengfeng on 16/11/7.
//
//

#import "Module+First.h"

@implementation Module (First)

module_synthesize(First_name)
module_synthesize(First_loadingImage)
module_synthesize(First_identifier)
module_synthesize(First_version)
module_synthesize(First_detail)
module_synthesize(First_rootViewController)

- (void)First_loadModule
{
    self.First_name = @"绘图";
    self.First_loadingImage = @"login_1";
    self.First_identifier = @"identifier";
    self.First_version = @"1.0.0";
    self.First_detail = @"this is a first module detail";
    self.First_rootViewController = [UIStoryboard storyboardWithName:@"FirstMain" bundle:nil].instantiateInitialViewController;
}

@end
