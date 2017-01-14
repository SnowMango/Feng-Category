//
//  ModuleHandle.m
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import "ModuleHandle.h"

#import <objc/runtime.h>
#import "ModuleManager.h"
@interface ModuleHandle ()

@property (nonatomic, strong) NSDictionary *moduleNames;
@end

@implementation ModuleHandle

- (instancetype)initWithClass:(Class)cls
{
    self = [super init];
    if (self) {
        _modules  = [self mg_loadModules:cls];
        _identifer = NSStringFromClass([self class]);
    }
    return self;
}

+(instancetype)handleWithClass:(Class)cls
{
    id obj = [[self alloc] initWithClass: cls];
    return obj;
}

- (BOOL)containsModule:(NSString *)moduleName
{
    BOOL ret =[self.moduleNames.allKeys containsObject:moduleName];
    return ret;
}

- (NSMutableArray *)mg_loadModules:(Class)cls
{
    NSMutableArray *modules = [NSMutableArray new];
    NSMutableDictionary *classDic = [NSMutableDictionary new];
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL,0);
    
    if (numClasses >0 )
    {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class cl = classes[i];
            
            if (class_getSuperclass(cl) == cls){
                NSString *name = NSStringFromClass(cl);
                NSLog(@"%@", name);
                id obj = [[cl alloc] init];
                [modules addObject:obj];
                classDic[name] = obj;
            }
        }
        free(classes);
    }
    
    
    self.moduleNames = [classDic copy];
    return modules;
}

- (id)performAction:(NSString *)moduleName selector:(NSString *)sel args:(id)args
{
    if (moduleName.length) {
        id obj = self.moduleNames[moduleName];
        if (obj) {
            mg_SuppressPerformSelectorLeakWarning(return [obj performSelector:NSSelectorFromString(sel) withObject:args]);
        }
    }
    return nil;
}


@end
