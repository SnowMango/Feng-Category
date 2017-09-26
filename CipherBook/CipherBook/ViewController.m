//
//  ViewController.m
//  CipherBook
//
//  Created by zhengfeng on 2017/9/25.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ViewController.h"
#import "ZFCipher.h"

typedef enum : NSUInteger {
    NetworkNone,
    Network2G,
    Network3G,
    Network4G,
    NetworkLTE,
    NetworkWIFI
} ZFNetwork;
ZFNetwork ZFNetworkType(void);

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}




@end

ZFNetwork ZFNetworkType(void){
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    id dataNetworkItemView = nil;

    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
    ZFNetwork network = [[dataNetworkItemView valueForKey:@"dataNetworkType"] integerValue];
    return network;
}


