//
//  P2PUDPSever.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "P2PUDPSever.h"
#import <UIKit/UIKit.h>

@implementation P2PUDPSever

- (void)dealloc
{
    if (!udp_sever.isClosed) {
        [udp_sever closeAfterSending];
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        dispatch_queue_t severQueue = dispatch_queue_create("com.mango.udpsever", DISPATCH_QUEUE_SERIAL);
        udp_sever = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:severQueue];
    }
    return self;
}

- (void)sendMsg:(NSData *)data withHosts:(NSArray *)hosts
{
    [hosts enumerateObjectsUsingBlock:^(NSString * host, NSUInteger idx, BOOL * _Nonnull stop) {
        [udp_sever sendData:data toHost:host port:9000 withTimeout:-1 tag:0];
    }];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    
    NSLog(@"udp sever data:S->%@,client address:%@:%d", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], host,port);    
}

- (void)closeUDP
{
    if (!udp_sever.isClosed) {
        [udp_sever closeAfterSending];
    }
}

@end
