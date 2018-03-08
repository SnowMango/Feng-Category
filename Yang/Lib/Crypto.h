//
//  Crypto.h
//  LayoutTest
//
//  Created by zhengfeng on 2017/9/28.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
//加密
@interface EnCrypt : NSObject
+(NSData *)AES256ParmEncryptWithKey:(NSString *)key Encrypttext:(NSData *)text ;
@end

//解密
@interface DeCrypt : NSObject
+ (NSData *)AES256ParmDecryptWithKey:(NSString *)key Decrypttext:(NSData *)text;
@end
