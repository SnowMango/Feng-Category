//
//  ZFCipherGroup.h
//  CipherBook
//
//  Created by zhengfeng on 2017/9/26.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFBaseModel.h"

@class ZFCipher;

@interface ZFCipherGroup : ZFBaseModel
@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray<ZFCipher*> *ciphers;
@end
