//
//  ToolModule+Calendar.m
//  DemoDev
//
//  Created by zhengfeng on 2017/8/17.
//
//

#import "ToolModule+Calendar.h"

@implementation ToolModule (Calendar)
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"日历";
        self.loadingImage = @"login_1";
        self.identifier = @"identifier";
        self.version = @"1.0.0";
        self.detail = @"this is a Calendar module detail";
        self.rootViewController = [UIStoryboard storyboardWithName:@"Calendar" bundle:nil].instantiateInitialViewController;
    }
    return self;
}
@end
