//
//  BaseJSON.m
//  OneApplication
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "BaseJSON.h"
#import <objc/runtime.h>

NSString * const kJOSNOnlyArrayKey = @"onlyArray";

static id json_getter(id sel, SEL cmd);
static void json_setter(id sel, SEL cmd, id newValue);

//与类中定义的存储属性的Dictionary成员变量名一致
const char * IVAR_LIST = "ivar_list";

@implementation BaseJSON

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone
{
    id newObj = [[self class] allocWithZone:zone];
    NSArray *properties = [self objc_properties];
    NSDictionary *propertyDic = [self dictionaryWithValuesForKeys:properties];
    [newObj setValuesForKeysWithDictionary:propertyDic];
    return newObj;
}
#pragma mark - NSMutableCoping
-(id)mutableCopyWithZone:(NSZone *)zone
{
    id newObj = [[self class] allocWithZone:zone];
    NSArray *properties = [self objc_properties];
    NSMutableDictionary *propertyDic = [NSMutableDictionary new];
    for (NSString *key in properties) {
        id value = [self valueForKey:key];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            value = [value mutableCopy];
        }
        [newObj setValue:value forKey:key];
    }
    return newObj;
}
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int ivarCount = 0;
    Ivar * ivars = class_copyIvarList([self class], &ivarCount);
    
    for (int i = 0; i < ivarCount; i++) {
        const char * name = ivar_getName(ivars[i]);
        NSString * ivarName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:ivarName];
        [aCoder encodeObject:value forKey:ivarName];
    }
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        
        unsigned int ivarCount = 0;
        Ivar * ivars = class_copyIvarList([self class], &ivarCount);
        for (int i = 0; i < ivarCount; i++) {
            const char * name = ivar_getName(ivars[i]);
            NSString * ivarName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            id value = [aDecoder decodeObjectForKey:ivarName];
            [self setValue:value forKey:ivarName];
        }
        [ivar_list enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * _Nonnull stop) {
            [self setValue:obj forKey:key];
        }];
    }
    return self;
}

- (NSArray *)objc_properties
{
    NSMutableArray *properties=[NSMutableArray new];
    unsigned int propertyCount = 0;
    objc_property_t * propertList = class_copyPropertyList( [self class], &propertyCount);
    for ( NSUInteger i = 0; i < propertyCount; i++ ){
        const char * name = property_getName(propertList[i]);
        NSString * propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        [properties addObject:propertyName];
    }
    return properties;
}
#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        ivar_list = [NSMutableDictionary new];
    }
    return self;
}
#pragma mark - Public
- (NSArray *)runtimeProperties
{
    return ivar_list.allKeys;
}

- (void)setValuesForKeysAutoObjectWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
    [keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString * key, id value , BOOL * _Nonnull stop) {
        __block id newValue = value;
        if ([value isKindOfClass:[NSDictionary class]]) {
            newValue = [[self class] new];
            [newValue setValuesForKeysAutoObjectWithDictionary:value];
        }else if ([value isKindOfClass:[NSArray class]]){
            [((NSArray *)value) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    newValue = [[self class] new];
                    [newValue setValuesForKeysAutoObjectWithDictionary:value];
                }
            }];
        }
        [self setValue:newValue forKey:key];
    }];
}


- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([self checkKeyIsEffective:key]) {
        [self addPropertyWithName:key value:value];
    }
    [super setValue:value forKey:key];
}

#pragma mark -
// 检查属性是否符合 以_和字母开头
- (BOOL)checkKeyIsEffective:(NSString *)key
{
    NSString* number=@"^[a-z_A-Z][a-z_A-Z0-9]*$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:key];
}
//根据valuel类型 runtime添加属性
- (void)addPropertyWithName:(NSString *)propertyName value:(id)newValue {
    NSString* ivar_name = [NSString stringWithFormat:@"_%@", propertyName];
    //判断是否是动态属性 动态属性 没有成员变量
    Ivar user_ivar = class_getInstanceVariable([self class], ivar_name.UTF8String);
    if (user_ivar || !newValue) {
        return;
    }
    Ivar ivar = class_getInstanceVariable([self class], IVAR_LIST);
    NSMutableDictionary *propertyList = object_getIvar(self, ivar);
    id oldValue = [propertyList objectForKey:propertyName];
    //判断是否添加过动态属性并且class相同，不同就添加
    if ([NSStringFromClass([oldValue class]) isEqualToString:NSStringFromClass([newValue class])]) {
        return ;
    }
    NSLog(@"new property %@:<%@:%@> ", NSStringFromClass([self class]), propertyName, newValue);
    //属性 attributes (strong, nonatomic)
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([newValue class])] UTF8String] };
    objc_property_attribute_t ownership = { "&", "N" };
    objc_property_attribute_t backingivar  = {"V",ivar_name.UTF8String};
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    //添加属性
    if (!class_addProperty([self class], [propertyName UTF8String], attrs, 3)) {
        class_replaceProperty([self class], [propertyName UTF8String], attrs, 3);
    }
    //添加get和set方法
    class_addMethod([self class], NSSelectorFromString(propertyName), (IMP)json_getter, "@@:");
    class_addMethod([self class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)json_setter, "v@:@");
}

- (NSString *)description
{
    NSString *des = [NSString stringWithFormat:@"<%p>=%@", self, ivar_list.description];
    
    return des;
}

@end


#pragma mark - Setter
id json_getter(id sel, SEL cmd) {
    NSString *key = NSStringFromSelector(cmd);
    Ivar ivar = class_getInstanceVariable([sel class], IVAR_LIST);
    NSMutableDictionary *propertyList = object_getIvar(sel, ivar);
    return [propertyList objectForKey:key];
}
#pragma mark - Getter
void json_setter(id sel, SEL cmd, id newValue) {
    
    NSString *property = NSStringFromSelector(cmd);
    property = [property substringWithRange:NSMakeRange(3, property.length - 4)];
    property = [[[property substringToIndex:1] lowercaseString]stringByAppendingString:[property substringFromIndex:1]];
    Ivar ivar = class_getInstanceVariable([sel class], IVAR_LIST);
    NSMutableDictionary *propertyList = object_getIvar(sel, ivar);
    if (!propertyList) {
        propertyList = [NSMutableDictionary new];
        object_setIvar(sel, ivar, propertyList);
    }
    if (!newValue) {
        newValue= [NSNull null];
    }
    [propertyList setObject:newValue forKey:property];

}

