//
//  Module.h
//  Demo
//
//  Created by zhengfeng on 16/11/7.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


#define property_set(key, value)  objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC)

#define property_get(key)  objc_getAssociatedObject(self, key)

/**
 使用runtime自动为属性创建 setter和getter方法
 @param type     属性类型
 @param property 属性
 */
#define module_synthesize(property) \
-(void)set##property:(id)value {  property_set(#property , value);}\
- (id)property { return property_get(#property);}

@protocol ModuleRootViewControllerDelegate <NSObject>

- (id)performAction:(NSString *)moduleName selector:(NSString *)sel args:(id)args;

@end

@interface Module : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * loadingImage;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * detail;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) UIViewController * rootViewController;

- (void)loadModule;

@end
