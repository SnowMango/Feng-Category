//
//  ZFCipherManager.m
//  CipherBook
//
//  Created by zhengfeng on 2017/10/10.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFCipherManager.h"

NSString * getUUID(void)
{
    NSString *uid =[NSUUID UUID].UUIDString;
    return [uid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@interface ZFCipherManager ()
@property (nonatomic, strong) NSMutableDictionary * ciphers;
@property (nonatomic, strong) NSMutableDictionary * groups;

@end

@implementation ZFCipherManager

+ (instancetype)defaultManager;
{
    static id mg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mg = [[self alloc] init];
    });
    return mg;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ciphers = [NSMutableDictionary dictionary];
        self.groups = [NSMutableDictionary dictionary];
    }
    return self;
}
- (NSArray*)allGroup
{
    return self.groups.allValues;
}
- (NSArray*)allCipher
{
    return self.ciphers.allValues;
}

//add
-(BOOL)addGroupWithName:(NSString *)gName
{
    ZFCipherGroup *g =[[ZFCipherGroup alloc] init];
    g.identifier = getUUID();
    g.title = gName;
    [self.groups setObject:g forKey:g.identifier];
    return YES;
}
-(BOOL)addCipherWithData:(NSDictionary *)cipher
{
    ZFCipher *c = [[ZFCipher alloc] init];
    c.identifier = getUUID();
    c.title = c.identifier;
    [self.ciphers setObject:c forKey:c.identifier];
    return YES;
}
//delete
-(BOOL)deleteGroupWithIdentifier:(NSString *)identifier
{
    [self.groups removeObjectForKey:identifier];
    return YES;
}
-(BOOL)deleteCipherWithIdentifier:(NSString *)identifier
{
    [self.ciphers removeObjectForKey:identifier];
    return YES;
}
//update
-(BOOL)updateGroupWithName:(NSString *)gName
{
    return YES;
}
-(BOOL)updateCipherWithData:(NSDictionary *)cipher
{
    return YES;
}
//refer
-(NSArray *)referGroupWithName:(NSString *)gName
{
    return nil;
}
-(NSArray *)referGroupWithIdentifier:(NSString *)identifier
{
    return nil;
}
-(NSArray *)referCipherWithIdentifier:(NSString *)identifier
{
    return nil;
}

@end
