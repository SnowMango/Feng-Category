//
//  P2PTCPSever.h
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaAsyncSocket.h"
@interface P2PTCPSever : NSObject<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *tcp_sever;
    NSMutableArray * tcp_client;
}
@property (nonatomic, assign) UInt16         socketPort;

@end
