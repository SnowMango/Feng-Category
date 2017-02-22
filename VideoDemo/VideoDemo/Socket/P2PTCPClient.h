//
//  P2PTCPClient.h
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket.h"
@interface P2PTCPClient : NSObject<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *tcp_client;
}

@property (nonatomic, copy  ) NSString      *socketHost;

- (void)dissonnect;


@end
