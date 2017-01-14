//
//  FShowViewController.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/11.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "FShowViewController.h"

@interface FShowViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation FShowViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    if (self.showView) {
        [self.scrollView addSubview:self.showView];
    }
//    [self.view addSubview:self.showView];
}


@end
