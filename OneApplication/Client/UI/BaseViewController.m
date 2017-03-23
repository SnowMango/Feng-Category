//
//  BaseViewController.m
//  OneApplication
//
//  Created by 郑丰 on 2017/1/12.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



@end


@implementation UIViewController (BaseViewController)

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return YES;
}

@end
