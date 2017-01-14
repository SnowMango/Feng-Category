//
//  ModuleBasic.m
//  Demo
//
//  Created by zhengfeng on 16/11/7.
//
//

#import "Module.h"

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

@implementation ExampleModule



@end

@implementation ToolModule


@end

