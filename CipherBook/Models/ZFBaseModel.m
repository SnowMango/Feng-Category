//
//  ZFBaseModel.m
//  CipherBook
//
//  Created by zhengfeng on 2017/9/25.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFBaseModel.h"
#import <objc/runtime.h>
@implementation ZFBaseModel
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
    free(ivars);
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
        free(ivars);
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
    free(propertList);
    return properties;
}
#pragma mark -
@end
