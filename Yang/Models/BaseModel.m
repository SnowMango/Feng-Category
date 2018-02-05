//
//  BaseModel.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel
+ (NSString *)uuidIdentifier
{
    NSString *u =[NSUUID UUID].UUIDString;
    NSMutableArray*temp = [u componentsSeparatedByString:@"-"].mutableCopy;
    [temp removeLastObject];
    NSString *uIdentifir = [temp componentsJoinedByString:@""];
    return uIdentifir;
}
- (NSString *)uuidIdentifier
{
    return [[self class] uuidIdentifier];
}
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
    for (NSString *key in properties) {
        id value = [self valueForKey:key];
        if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
            value = [value mutableCopy];
        }
        [newObj setValue:value forKey:key];
    }
    return newObj;
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
    free(propertList);
    return properties;
}
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *properties = [self objc_properties];
    for (NSString *key in properties) {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        NSArray *properties = [self objc_properties];
        for (NSString *key in properties) {
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}
@end
