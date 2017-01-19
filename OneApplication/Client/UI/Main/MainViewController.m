//
//  MainViewController.m
//  OneApplication
//
//  Created by 郑丰 on 2017/1/12.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "MainViewController.h"
#import <BaseJSON.h>

@interface MainViewController ()

@end


@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = [UIColor whiteColor];
    BaseJSON *base = [BaseJSON new];
    base.identifer = @"base";
    [base setValuesForKeysWithDictionary:@{@"name":@"feng",@"age":@24}];
    NSLog(@"base®%@",base );
    SubJSON * sub = [SubJSON new];
    [sub setValue:@"sub" forKey:@"identifer"];
    [sub setValuesForKeysWithDictionary:@{@"name":@"zfeng",@"age":@23}];
    NSLog(@"sub®%@",sub );
}



@end
