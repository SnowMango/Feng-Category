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
        tcp_client = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.socketPort = 8800;
    }
    return self;
}

- (void)setSocketHost:(NSString *)socketHost
{
    if ([_socketHost isEqualToString:socketHost]) {
        return;
    }
    _socketHost = socketHost;
    [self socketConnectDeviceServer];
}

-(void)socketConnectDeviceServer{
    if ([tcp_client isConnected]) {
        [tcp_client disconnect];
    }
    NSError *error = nil;
    
    [tcp_client connectToHost:self.socketHost onPort:self.socketPort withTimeout:-1 error:&error];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket连接成功");
    
    
}

- (void)socket:(GCDAsyncSocket *)socket didWriteDataWithTag:(long)tag
{
    NSLog(@"sever断开连接");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"数据读取成功");
    NSLog(@"tcp Read %@", data);
}

@end
