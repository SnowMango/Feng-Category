//
//  P2PUDPSever.h
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket.h"
@interface P2PUDPSever : NSObject<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket * udp_sever;
}

@property (nonatomic) BOOL autoUpdate;

- (void)closeUDP;

@end