//
//  P2PUDPClient.h
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket.h"

@class P2PUDPClient;

@protocol P2PUDPClientUpdate <NSObject>

- (void)udpClient:(P2PUDPClient*)client refreshData:(NSData *)data;
@end

@interface P2PUDPClient : NSObject<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket * udp_client;
}

@property (weak,nonatomic) id<P2PUDPClientUpdate> delegete;

- (void)closeUDP;

@end
