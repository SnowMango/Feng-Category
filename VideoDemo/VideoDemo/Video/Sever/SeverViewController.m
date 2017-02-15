//
//  SeverViewController.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "SeverViewController.h"
#import "P2PTCPSever.h"
#import "P2PUDPSever.h"

@interface SeverViewController ()
@property (nonatomic, strong) P2PUDPSever *upd;
@property (nonatomic, strong) P2PTCPSever *tcp;
@end

@implementation SeverViewController
- (void)dealloc
{
    self.upd =nil;
//    self.tcp =nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.upd = [P2PUDPSever new];
//    self.tcp = [P2PTCPSever new];
}



@end
