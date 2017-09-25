//
//  ZFCipher.h
//  CipherBook
//
//  Created by zhengfeng on 2017/9/25.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFBaseModel.h"

typedef enum : NSUInteger {
    NetworkNone,
    Network2G,
    Network3G,
    Network4G,
    NetworkLTE,
    NetworkWIFI
} ZFNetwork;
ZFNetwork ZFNetworkType(void);

@interface ZFCipher : ZFBaseModel

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *saveType;

@end


