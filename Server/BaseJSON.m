//
//  BaseJSON.m
//  OneApplication
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "BaseJSON.h"
#import <objc/runtime.h>
id json_getter(id sel, SEL cmd);
void json_setter(id sel, SEL cmd, id newValue);


const char * IVAR_LIST = "ivar_list";

@implementation BaseJSON

- (instancetype)init
{
    self = [super init];
    if (self) {
        ivar_list = [NSMutableDictionary new];
    }
    return self;
}


- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([self checkKeyIsEffective:key]) {
        [self addPropertyWithName:key value:value];
    }
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([self checkKeyIsEffective:key]) {
        [self addPropertyWithName:key value:value];
    }
    [self setValue:value forUndefinedKey:key];
}

// 检查属性是否符合 以_和字母开头
- (BOOL)checkKeyIsEffective:(NSString *)key
{
    NSString* number=@"^[a-z_A-Z][a-z_A-Z0-9]*$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:key];
    
}
//根据valuel类型 runtime添加属性
- (void)addPropertyWithName:(NSString *)propertyName value:(id)value {
    if (!value) {
        return;
    }
    //先判断有没有这个属性，没有就添加，有就直接赋值
    NSString* ivar_name = [NSString stringWithFormat:@"_%@", propertyName];
    Ivar ivar = class_getInstanceVariable([self class], ivar_name.UTF8String);
    if (ivar) {
        return;
    }
    //属性 attributes
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([value class])] UTF8String] };
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

//获取属性值
- (id)getPropertyValueWithName:(NSString *)propertyName {
    //先判断有没有这个属性，没有就添加，有就直接赋值
    Ivar ivar = class_getInstanceVariable([self class], [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return object_getIvar(self, ivar);
    }
    ivar = class_getInstanceVariable([self class], IVAR_LIST);
    NSMutableDictionary *dict = object_getIvar(self, ivar);
    if (dict && [dict objectForKey:propertyName]) {
        return [dict objectForKey:propertyName];
    } else {
        return nil;
    }
}
- (NSString *)description
{
    NSString *des = [NSString stringWithFormat:@"%p=%@", self, ivar_list.description];
    return des;
}

@end


id json_getter(id sel, SEL cmd) {
    NSString *key = NSStringFromSelector(cmd);
    Ivar ivar = class_getInstanceVariable([sel class], IVAR_LIST);
    NSMutableDictionary *propertyList = object_getIvar(sel, ivar);
    return [propertyList objectForKey:key];
}

void json_setter(id sel, SEL cmd, id newValue) {
    NSString *property = NSStringFromSelector(cmd);
    property = [property substringWithRange:NSMakeRange(3, property.length - 4)];
    property = [[[property substringToIndex:1] lowercaseString]stringByAppendingString:[property substringFromIndex:1]];
    Ivar ivar = class_getInstanceVariable([sel class], IVAR_LIST);
    NSMutableDictionary *propertyList = object_getIvar(sel, ivar);
    if (!propertyList) {
        propertyList = [NSMutableDictionary dictionary];
        object_setIvar(sel, ivar, propertyList);
    }
    [propertyList setObject:newValue forKey:property];
}

