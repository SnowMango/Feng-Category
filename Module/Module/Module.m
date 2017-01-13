//
//  ModuleBasic.m
//  Demo
//
//  Created by zhengfeng on 16/11/7.
//
//

#import "Module.h"


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


@implementation Module

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadModule];
    }
    return self;
}
- (void)loadModule
{
    self.title = @"Basic: Module name";
    self.loadingImage = @"Icon: module icon"; 
    self.identifier = @"identifier";
    self.version = @"1.0.0";
    self.detail = @"this is a basic module detail";
    self.rootViewController = nil;
    
}

- (id)performAction:(NSString *)moduleName selector:(NSString *)sel args:(id)args
{
    NSString *moduleSELstr = [NSString stringWithFormat:@"%@_%@",moduleName, sel];
    SEL moduleSEL = NSSelectorFromString(moduleSELstr);
    if ([self respondsToSelector:moduleSEL]) {
        
#pragma clang diagnostic
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:moduleSEL withObject:args];
#pragma clang diagnostic pop
    }
    return nil;
}

@end

