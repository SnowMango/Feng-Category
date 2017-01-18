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
    BaseJSON * base = [BaseJSON new];
    [base setValuesForKeysAutoObjectWithDictionary:@{@"person":@{@"age":@24,@"name":@"feng"}}];
    NSLog(@"%@", base);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    ViewController * vc = (ViewController *)self.view.window.rootViewController;
    [vc showChildViewController:kRootLoginStoryboardKey];
    
}


@end
