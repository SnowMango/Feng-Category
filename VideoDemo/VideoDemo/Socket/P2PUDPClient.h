//
//  P2PUDPClient.h
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket.h"
@interface P2PUDPClient : NSObject<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket * udp_client;
}

- (void)closeUDP;

@end
