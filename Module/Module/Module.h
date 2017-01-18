//
//  Module.h
//  Demo
//
//  Created by zhengfeng on 16/11/7.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ModuleManager.h"
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

@interface Module : NSObject

@property (readonly, strong) ModuleHandle * handle;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * loadingImage;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * detail;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) UIViewController * rootViewController;

- (void)loadModule;
@end

@interface ExampleModule : Module


@end

@interface ToolModule : Module


@end
