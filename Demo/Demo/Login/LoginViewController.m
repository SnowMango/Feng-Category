//
//  LoginViewController.m
//  qingsongshi
//
//  Created by 郑丰 on 2017/1/4.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginView.h"
#import "AppDelegate.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {   
    [super viewDidLoad];
    LoginView *view = (LoginView*)self.view;
    NSString * defaultUser = [[self localUserList] firstObject];
    [view loadSubView];
    view.titleLabel.text = @"我是一只猫头鹰";
    view.titleLabel.textColor = [UIColor whiteColor];
    if (defaultUser) {
        view.textField1.text = defaultUser;
    }
    __weak typeof(self) weakObj = self;
    [view setClickBlock:^(NSString *acount, NSString *password) {
        if ([weakObj checkLoginInformation:acount password:password]) {
            [weakObj saveLoginUsers:acount];
            [weakObj scuccessLogin];
        }else{
            [SVProgressHUD showProgress:1 status:@"账号错误"];
            [SVProgressHUD dismissWithDelay:0.5 completion:nil];
        }
    }];
}

- (BOOL)checkLoginInformation:(NSString *)acount password:(NSString*)password
{
    for (NSString * user in [self localUserList]) {
        if ([user isEqualToString:acount]) {
            return YES;
        }
    }
    return NO;
}

- (void)scuccessLogin
{
    RootViewController * root = (RootViewController * )self.view.window.rootViewController;
    [root login];
}

- (NSArray *)localUserList
{
    return @[@"admin"];
}

- (id)lastUsers
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_USERS"];
}

- (void)saveLoginUsers:(id)users
{
    [[NSUserDefaults standardUserDefaults] setValue:users forKey:@"LAST_USERS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
