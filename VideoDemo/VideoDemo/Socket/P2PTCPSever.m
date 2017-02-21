//
//  P2PTCPSever.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "P2PTCPSever.h"
#import <UIKit/UIKit.h>

#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation P2PTCPSever
- (void)dealloc
{
    [tcp_sever disconnect];
}

+ (NSString *)localIP
{
    return [self getIpAddresses] ;
}

+ (NSString *)getIpAddresses{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSArray *)allContentHost
{
    NSMutableArray *host = [NSMutableArray new];
    [tcp_client enumerateObjectsUsingBlock:^(GCDAsyncSocket* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [host addObject:obj.connectedHost];
    }];
    return host;
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
    NSLog(@"AcceptNew ip:%@", newSocket.connectedHost);
    
}

- (void)socket:(GCDAsyncSocket *)socket didWriteDataWithTag:(long)tag
{
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"tcp Read %@", msg);
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(nullable NSError *)err
{
    [tcp_client removeObject:socket];
    NSLog(@"DidDisconnect");
}
@end
