//
//  ModuleManager.h
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Module.h"

@class ModuleModel;

@interface ModuleManager : NSObject
@property (nonatomic, readonly) NSArray<Module*> *modules;
+ (instancetype)shareInstance;
- (BOOL)containsModule:(NSString *)moduleName;

- (id)performAction:(NSString *)identifier selector:(NSString *)sel args:(id)args;

@end


@interface NSObject (DymicProperty)
+ (id)getPropertyValueWithTarget:(id)target withPropertyName:(NSString *)propertyName;
+ (void)addPropertyWithtarget:(id)target withPropertyName:(NSString *)propertyName withValue:(id)value;
@end
