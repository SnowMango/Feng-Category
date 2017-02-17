//
//  P2PTCPSever.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "P2PTCPSever.h"
#import <UIKit/UIKit.h>
@implementation P2PTCPSever
- (void)dealloc
{
    [tcp_sever disconnect];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        tcp_client = [NSMutableArray new];
        
        self.socketPort = 8800;
        tcp_sever = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [tcp_sever acceptOnPort:self.socketPort error:nil];
    }
    return self;
}

- (void)sendMessage:(GCDAsyncSocket*)socket
{
    NSData *message = [[UIDevice currentDevice].name dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:message withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [tcp_client addObject:newSocket];
    [self sendMessage:newSocket];
    NSLog(@"AcceptNew");
}

- (void)socket:(GCDAsyncSocket *)socket didWriteDataWithTag:(long)tag
{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"tcp Read %@", data);
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(nullable NSError *)err
{
    [tcp_client removeObject:socket];
    NSLog(@"DidDisconnect");
}
@end
