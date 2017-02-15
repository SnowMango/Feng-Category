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
//        dispatch_queue_t clientQueue = dispatch_queue_create("com.mango.p2pClient", DISPATCH_QUEUE_SERIAL);
        udp_client = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError* err = nil;
        [udp_client bindToPort:9000 error:&err];
        if (err) {
            NSLog(@"udp client bind fail");
        }else{
            NSLog(@"udp client Receiving success");
        }

        self.autoUpdate =YES;
        err =nil;
        [udp_client beginReceiving:&err];
        
        if (err) {
            NSLog(@"udp client Receiving fail");
        }else{
            NSLog(@"udp client Receiving success");
        }
        
//        [self sendMessage];
    }
    return self;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    NSLog(@"udp client data:C->%@, sever address:%@:%d", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], host,port);
}
- (void)sendMessage
{
    NSData *message = [[UIDevice currentDevice].name dataUsingEncoding:NSUTF8StringEncoding];
    [udp_client sendData:message toHost:@"172.30.220.17" port:9000 withTimeout:-1 tag:0];
}


- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error
{
    
}


- (void)closeUDP
{
    if (!udp_client.isClosed) {
        [udp_client closeAfterSending];
    }
}
@end
