//
//  Module+Second.h
//  DemoDev
//
//  Created by zhengfeng on 16/11/14.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "Module.h"

@interface Module (Second)

@property (nonatomic, readonly) NSString * Second_title;
@property (nonatomic, strong) NSString * Second_loadingImage;
@property (nonatomic, strong) NSString * Second_identifier;
@property (nonatomic, strong) NSString * Second_detail;
@property (nonatomic, strong) NSString * Second_version;
@property (nonatomic, strong) UIViewController * Second_rootViewController;
@end
