//
//  ModuleManager.m
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import "ModuleManager.h"
#import "ModuleHandle.h"

@interface ModuleManager ()
@property (nonatomic, strong) NSDictionary *handleDic;
@end

@implementation ModuleManager

+ (instancetype)shareInstance
{
    static ModuleManager * mg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mg = [[ModuleManager alloc] init];
    });
    
    return mg;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)moduleHandleWithIdentifer:(NSString*)identifer
{
    if (identifer.length) {
        return self.handleDic[identifer];
    }
    return nil;
}

+ (void)addModuleHandle:(ModuleHandle*)handle
{
    [[self shareInstance] addModuleHandle:handle];
}
- (void)addModuleHandle:(ModuleHandle*)handle
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.handleDic];
    [self.handleDic enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL * _Nonnull stop) {
        if ([handle isEqual:obj]) {
            [temp removeObjectForKey:key];
        }
    }];
    temp[handle.identifer] = handle;
    self.handleDic = [temp copy];
    _handles = self.handleDic.allValues;
}
+ (void)removeModuleHandle:(ModuleHandle*)handle
{
    [[self shareInstance] removeModuleHandle:handle];
}
- (void)removeModuleHandle:(ModuleHandle*)handle
{
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.handleDic];
    [temp removeObjectForKey:handle.identifer];
    self.handleDic = [temp copy];
    _handles = self.handleDic.allValues;
}


@end




