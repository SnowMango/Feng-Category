//
//  GuideViewController.m
//  OneApplication
//
//  Created by 郑丰 on 2017/1/12.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "GuideViewController.h"
#import "AppDelegate.h"
#import <BaseJSON.h>
@interface GuideViewController ()<NSKeyedArchiverDelegate,NSKeyedUnarchiverDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   
   
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    ViewController * vc = (ViewController *)self.view.window.rootViewController;
    
    [vc showChildViewController:kRootLoginStoryboardKey];
    
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
