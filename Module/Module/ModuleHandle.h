//
//  ModuleHandle.h
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import <Foundation/Foundation.h>

@class ModuleManager, Module;

@interface ModuleHandle : NSObject

@property (nonatomic, readonly) NSString *identifer;

@property (nonatomic, readonly) NSArray<Module*> *modules;

+(instancetype)handleWithClass:(Class)cls;

- (BOOL)containsModule:(NSString *)moduleName;

- (id)performAction:(NSString *)moduleName selector:(NSString *)sel args:(id)args;
@end

