//
//  ZFCipherFileHandle.m
//  CipherBook
//
//  Created by 郑丰 on 2017/10/3.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFCipherFileHandle.h"
#import <Foundation/NSFileManager.h>
@implementation ZFCipherFileHandle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)save:(NSString *)path data:(NSDictionary*)dat withFileName:(NSString*)fileName
{

    NSString *filePath = [path stringByAppendingFormat:@"/%@", fileName];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    
    };
    
    
}

@end
