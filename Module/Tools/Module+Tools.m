//
//  Module+Tools.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/17.
//
//

#import "Module+Tools.h"

@implementation Tools
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"手电筒";
        self.loadingImage = @"login_1";
        self.identifier = @"tool";
        self.version = @"1.0.0";
        self.detail = @"this is a tool 1 module detail";
        self.rootViewController = [UIStoryboard storyboardWithName:@"ToolMain" bundle:nil].instantiateInitialViewController;
    }
    return self;
}
@end
