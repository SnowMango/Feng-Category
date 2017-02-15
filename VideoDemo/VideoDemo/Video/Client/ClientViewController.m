//
//  ClientViewController.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ClientViewController.h"
#import "P2PTCPClient.h"
#import "P2PUDPClient.h"

@interface ClientViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) P2PUDPClient* udp;
@property (nonatomic, strong) P2PTCPClient* tcp;
@end

@implementation ClientViewController

- (void)dealloc{
    self.udp = nil;
//    self.tcp = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.udp = [P2PUDPClient new];
//     self.tcp = [P2PTCPClient new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    return cell;
}


@end
