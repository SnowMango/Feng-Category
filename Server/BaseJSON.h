//
//  BaseJSON.h
//  OneApplication
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseJSON : NSObject<NSCopying, NSMutableCopying, NSCoding>
{
    NSMutableDictionary * ivar_list;
}
@property (nonatomic, strong) NSString * identifer;

- (void)setValuesForKeysAutoObjectWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;

- (void)setValue:(id)value forKey:(NSString *)key;

@end




