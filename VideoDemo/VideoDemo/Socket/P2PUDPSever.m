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
//        dispatch_queue_t severQueue = dispatch_queue_create("com.mango.p2psever", DISPATCH_QUEUE_SERIAL);
        udp_sever = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError* err = nil;
        [udp_sever bindToPort:9000 error:&err];
//        [udp_sever joinMulticastGroup:@"239.223.1.1" error:&err];
        if (err) {
            NSLog(@"udp sever bind fail");
        }else{
            NSLog(@"udp sever bind success");
        }
        err = nil;
        [udp_sever beginReceiving:&err];
    
        if (err) {
            NSLog(@"udp sever Receiving fail");
        }else{
            NSLog(@"udp sever Receiving success");
        }
        self.autoUpdate =YES;
        [self sendMessage];
    }
    return self;
}

- (void)sendMessage
{
    NSData *message = [[UIDevice currentDevice].name dataUsingEncoding:NSUTF8StringEncoding];
    [udp_sever sendData:message toHost:@"172.30.220.17" port:9000 withTimeout:-1 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    
    NSLog(@"udp sever data:S->%@,client address:%@:%d", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], host,port);
    
//    NSData *message = [[UIDevice currentDevice].name dataUsingEncoding:NSUTF8StringEncoding];
    
//    [udp_sever sendData:message toAddress:address withTimeout:-1 tag:0];
//    [udp_sever sendData:message toHost:host port:port withTimeout:-1 tag:0];
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error
{
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"send");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error
{
    NSLog(@"no send");
}

- (void)closeUDP
{
    if (!udp_sever.isClosed) {
        [udp_sever closeAfterSending];
    }
}

@end
