//
//  FilterObject.h
//  Pods
//
//  Created by 郑丰 on 2017/1/21.
//
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

extern NSString const *kFilterNameKey;
extern NSString const *kFilterObjectKey;

@interface FilterObject : NSObject

- (NSArray *)filters;
@end
