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
    
    NSData *avData = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
    Byte dataType;
    NSLog(@"udp client data:%c=%@, sever address:%@:%d",dataType, @(data.length), host,port);
    [data getBytes:&dataType length:1];
    if (dataType == 'A') {
        if (self.delegete && [self.delegete respondsToSelector:@selector(udpClient:refreshAudioData:)]) {
            [self.delegete udpClient:self refreshAudioData:avData];
        }
    }else if (dataType == 'H'){
        if (self.delegete && [self.delegete respondsToSelector:@selector(udpClient:refreshVideoData:)]) {
            [self.delegete udpClient:self refreshVideoData:avData];
        }
    }

    [udp_client beginReceiving:nil];
}


@end
