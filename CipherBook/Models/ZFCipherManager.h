//
//  ZFCipherManager.h
//  CipherBook
//
//  Created by zhengfeng on 2017/10/10.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCipher.h"
#import "ZFCipherGroup.h"
@interface ZFCipherManager : NSObject

+ (instancetype)defaultManager;
- (NSArray*)allGroup;
- (NSArray*)allCipher;

//add
-(BOOL)addGroupWithName:(NSString *)gName;
-(BOOL)addCipherWithData:(NSDictionary *)cipher;
//delete
-(BOOL)deleteGroupWithIdentifier:(NSString *)identifier;
-(BOOL)deleteCipherWithIdentifier:(NSString *)identifier;
//update
-(BOOL)updateGroupWithName:(NSString *)gName;
-(BOOL)updateCipherWithData:(NSDictionary *)cipher;
//refer
-(NSArray *)referGroupWithName:(NSString *)gName;
-(NSArray *)referGroupWithIdentifier:(NSString *)identifier;
-(NSArray *)referCipherWithIdentifier:(NSString *)identifier;

@end
