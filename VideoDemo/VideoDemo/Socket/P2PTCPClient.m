//
//  P2PTCPClient.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "P2PTCPClient.h"

@interface P2PTCPClient ()
@property (nonatomic, assign) UInt16         socketPort;
@end

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
    if (_socketHost) {
        [self socketConnectDeviceServer];
    }
}

-(void)socketConnectDeviceServer{
    if ([tcp_client isConnected]) {
        [tcp_client disconnect];
    }
    NSError *error = nil;
    
    [tcp_client connectToHost:self.socketHost onPort:self.socketPort withTimeout:-1 error:&error];
}

- (void)dissonnect
{
    if ([tcp_client isConnected]) {
        [tcp_client disconnect];
    }
    self.socketHost = nil;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"socket连接成功");

}

- (void)socket:(GCDAsyncSocket *)socket didWriteDataWithTag:(long)tag
{
    NSLog(@"数据发送成功");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"数据读取成功");
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(nullable NSError *)err
{
    NSLog(@"断开连接");
}

@end
