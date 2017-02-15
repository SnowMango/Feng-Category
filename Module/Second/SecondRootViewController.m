//
//  SecondRootViewController.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/14.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "SecondRootViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
@interface SecondRootViewController ()

@end

@implementation SecondRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", [[NSBundle mainBundle] infoDictionary]);
    
//    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
   
//    AVSampleBufferDisplayLayer
}

- (void)touchId
{
    LAContext* context = [[LAContext alloc] init];
    NSError * error;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Biometrics" reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * str = [NSString stringWithFormat:@"%@", success? @"解锁成功":error.localizedDescription];
                NSLog(@"== %@", str);
                switch (error.code) {
                    case LAErrorAuthenticationFailed: NSLog(@"身份验证失败。");      break;
                    case LAErrorUserCancel: NSLog(@"用户点击取消按钮。");             break;
                    case LAErrorUserFallback: NSLog(@"用户点击输入密码。");           break;
                    case LAErrorSystemCancel: NSLog(@"另一个应用程序去前台。");        break;
                    case LAErrorPasscodeNotSet: NSLog(@"密码在设备上没有设置。");      break;
                    case LAErrorTouchIDNotAvailable: NSLog(@"触摸ID在设备上不可用.");  break;
                };
            });
        }];
    }
    
}


@end
