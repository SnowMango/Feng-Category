//
//  ModuleBasic.m
//  Demo
//
//  Created by zhengfeng on 16/11/7.
//
//

#import "Module.h"

@implementation Module

+ (void)load
{
    
}

- (void)loadModule
{
    self.name = @"Basic: Module name";
    self.loadingImage = @"Icon: module icon";
    self.identifier = @"identifier";
    self.version = @"1.0.0";
    self.detail = @"this is a basic module detail";
    self.rootViewController = nil;
    

}

@end

