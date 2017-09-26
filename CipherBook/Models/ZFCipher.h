//
//  ZFCipher.h
//  CipherBook
//
//  Created by zhengfeng on 2017/9/25.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFBaseModel.h"
@class ZFCipherGroup;
@interface ZFCipher : ZFBaseModel

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *account;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *remark;

@property (strong, nonatomic) ZFCipherGroup *group;
@end


