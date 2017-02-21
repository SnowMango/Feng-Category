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
#import "LiveViewController.h"
@interface SeverViewController ()

@property (weak, nonatomic) IBOutlet UILabel *ipLabel;
@end

@implementation SeverViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ipLabel.text = [P2PTCPSever localIP];
}

- (IBAction)startLive:(id)sender {
    
    [self live];
}

- (void)live
{
    LiveViewController * vc =  [[LiveViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
