//
//  BaseJSON.h
//  OneApplication
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseJSON : NSObject
{
    NSMutableDictionary * ivar_list;
}


- (void)setValue:(id)value forKey:(NSString *)key;

@end
