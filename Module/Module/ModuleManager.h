//
//  ModuleManager.h
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ModuleHandle.h"

#define mg_SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define mg_GetValueSuppressPerformSelectorLeakWarning(value ,Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
value = Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@class ModuleModel;

@interface ModuleManager : NSObject
@property (nonatomic, readonly) NSArray<ModuleHandle*> *handles;
+ (instancetype)shareInstance;
- (id)moduleHandleWithIdentifer:(NSString*)identifer;
+ (void)addModuleHandle:(ModuleHandle*)handle;
+ (void)removeModuleHandle:(ModuleHandle*)handle;
@end

