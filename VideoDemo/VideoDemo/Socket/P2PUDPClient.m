//
//  P2PUDPClient.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "P2PUDPClient.h"
#import <UIKit/UIKit.h>

@implementation P2PUDPClient

- (void)dealloc
{
    if (!udp_client.isClosed) {
        [udp_client closeAfterSending];
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        dispatch_queue_t clientQueue = dispatch_queue_create("com.mango.p2pClient", DISPATCH_QUEUE_SERIAL);
        udp_client = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udp_client bindToPort:9000 error:nil];
        [udp_client beginReceiving:nil];
    }
    return self;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)socket didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    NSLog(@"udp client data:C->%@, sever address:%@:%d", @(data.length), host,port);
    if (self.delegete && [self.delegete respondsToSelector:@selector(udpClient:refreshData:)]) {
        [self.delegete udpClient:self refreshData:data];
    }
    [udp_client beginReceiving:nil];
}

- (void)closeUDP
{
    if (!udp_client.isClosed) {
        [udp_client closeAfterSending];
    }
}
@end
