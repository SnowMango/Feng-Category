//
//  P2PTCPClient.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "P2PTCPClient.h"

@implementation P2PTCPClient

- (void)dealloc
{
    if (!tcp_client.isConnected) {
        [tcp_client disconnect];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.socketHost = @"172.30.220.17";
        self.socketPort = 8800;
        
        [self socketConnectDeviceServer];
    }
    return self;
}

-(void)socketConnectDeviceServer{
    if ([tcp_client isConnected]) {
        [tcp_client disconnect];
        tcp_client = nil;
    }
//    dispatch_queue_t clientQueue = dispatch_queue_create("com.mango.tcpClient", DISPATCH_QUEUE_CONCURRENT);
    tcp_client = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [tcp_client connectToHost:self.socketHost onPort:self.socketPort withTimeout:-1 error:&error];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket连接成功");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"数据读取成功");
    NSLog(@"tcp Read %@", data);
}

@end
