//
//  LaunchViewController.m
//  OneApplication
//
//  Created by 郑丰 on 2017/1/12.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "LaunchViewController.h"
#import "AppDelegate.h"
@interface LaunchViewController ()
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reminderLabel.text = @"轻轻点击跳转到Guide...";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    ViewController * vc = (ViewController *)self.view.window.rootViewController;
    
    [vc showChildViewController:kRootGuideStoryboardKey];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
