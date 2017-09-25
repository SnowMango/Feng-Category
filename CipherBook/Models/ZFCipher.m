//
//  ZFCipher.m
//  CipherBook
//
//  Created by zhengfeng on 2017/9/25.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFCipher.h"
#import <UIKit/UIKit.h>
@implementation ZFCipher

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
