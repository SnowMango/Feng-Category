//
//  BaseModel.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject<NSCopying, NSMutableCopying,NSCoding>
+ (NSString *)uuidIdentifier;
- (NSString *)uuidIdentifier;
@end

