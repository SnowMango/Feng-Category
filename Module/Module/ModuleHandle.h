//
//  ModuleHandle.h
//  Pods
//
//  Created by zhengfeng on 16/11/9.
//
//

#import <Foundation/Foundation.h>



@interface ModuleHandle : NSObject

@property (nonatomic, strong) NSArray * nsArray;
@property (nonatomic, readonly) NSArray * nrArray;

@property (nonatomic, strong) NSDictionary * nsDic;
@property (nonatomic, readonly) NSDictionary * nrDic;

@property (nonatomic, strong) NSNumber * number;
@property (nonatomic, strong) NSString * string;

@property (assign, nonatomic) BOOL anBool;

@end
