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
@property (nonatomic, readonly) NSArray<ModuleModel*> *modules;
+ (instancetype)shareInstance;
- (BOOL)containsModule:(NSString *)moduleName;

- (id)performAction:(NSString *)moduleName selector:(NSString *)sel args:(id)args;

@end


@interface ModuleModel : NSObject<NSMutableCopying, NSCopying>
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * loadingImage;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * detail;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) UIViewController* rootViewController;
@end
