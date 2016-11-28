//
//  ModuleManager.m
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import "ModuleManager.h"
#import "Module.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define GetValueSuppressPerformSelectorLeakWarning(value ,Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
value = Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface ModuleManager ()
@property (nonatomic, strong) Module *module;

@property (nonatomic, strong) NSArray *moduleNames;
@end

@implementation ModuleManager

+ (instancetype)shareInstance
{
    static ModuleManager * mg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mg = [[ModuleManager alloc] init];
    });
    
    return mg;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.module = [[Module alloc] init];
        _modules  = [self mg_loadModules];
    }
    return self;
}

- (BOOL)containsModule:(NSString *)moduleName
{
    BOOL ret =[self.moduleNames containsObject:moduleName];
    return ret;
}

- (NSMutableArray *)mg_loadModules
{
    NSMutableArray *modules = [NSMutableArray new];
    NSMutableDictionary *class = [NSMutableDictionary new];
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList([Module class] , &count);
    NSMutableArray *basicProperty = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *attributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        if (![attributes containsString:@"_"] && [name containsString:@"_"]) {
            NSString * classstr = [name componentsSeparatedByString:@"_"].firstObject;
            [class setObject:classstr forKey:classstr];
        }else{
            [basicProperty addObject:name];
        }
    }
    self.moduleNames = class.allKeys;
    NSLog(@"Load class = %@",class.allKeys);
    for (NSString *classStr in class.allKeys) {
        ModuleModel *fun = [[ModuleModel alloc] init];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@_loadModule", classStr]);
        if ([self.module respondsToSelector:selector]) {
            SuppressPerformSelectorLeakWarning([self.module performSelector:selector withObject:nil]);
        }else{
            continue;
        }
        for (NSString *basic in basicProperty) {
            SEL basicSelector = NSSelectorFromString([NSString stringWithFormat:@"%@_%@", classStr, basic]);
            id value = nil;
            if ([self.module respondsToSelector:basicSelector]) {
                GetValueSuppressPerformSelectorLeakWarning(value, [self.module performSelector:basicSelector withObject:nil]);
            }else{
                NSLog(@"module warning [%@ %@] unselector",NSStringFromClass([self.module class]), NSStringFromSelector(basicSelector));
            }
            SEL basicSelector2 = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [basic stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[basic substringToIndex:1] uppercaseString]]]);
            
            if ([fun respondsToSelector:basicSelector2]) {
                SuppressPerformSelectorLeakWarning([fun performSelector:basicSelector2 withObject:value]);
            }else{
                NSLog(@"module warning [%@ %@] unselector",NSStringFromClass([fun class]), NSStringFromSelector(basicSelector2));
            }
        }
        [modules addObject:fun];
    }
    return modules;
}


@end

@implementation ModuleModel
- (id)copyWithZone:(NSZone *)zone
{
    ModuleModel  * mm = [ModuleModel allocWithZone:zone];
    mm.name = [self.name copy];
    mm.detail = [self.detail copy];
    mm.identifier = [self.identifier copy];
    mm.version = [self.version copy];
    mm.loadingImage = [self.loadingImage copy];
    mm.rootViewController = [self.rootViewController copy];
    
    return mm;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    ModuleModel  * mm = [ModuleModel allocWithZone:zone];
    mm.name = [self.name mutableCopy];
    mm.detail = [self.detail mutableCopy];
    mm.identifier = [self.identifier mutableCopy];
    mm.version = [self.version mutableCopy];
    mm.loadingImage = [self.loadingImage mutableCopy];
    mm.rootViewController = [self.rootViewController mutableCopy];
    return mm;
}

@end

