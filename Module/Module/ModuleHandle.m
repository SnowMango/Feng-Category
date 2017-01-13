//
//  ModuleHandle.m
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import "ModuleHandle.h"
#import "Module.h"

#import <objc/runtime.h>



@interface ModuleHandle ()
@property (nonatomic, strong) Module *module;
@end

@implementation ModuleHandle

- (instancetype)init
{
    self = [super init];
    if (self) {
        unsigned int count;
        objc_property_t * propertyList = class_copyPropertyList([ModuleHandle class], &count);
        
        for (int i = 0; i < count; i++) {
            objc_property_t property = propertyList[i];
            const char * attribute = property_getAttributes(property);
            const char* name   = property_getName(property);
            
            NSLog(@" %s <%s>", name, attribute);
        }
    }
    return self;
}

@end
