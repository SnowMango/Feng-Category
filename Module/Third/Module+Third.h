//
//  Module+Third.h
//  DemoDev
//
//  Created by zhengfeng on 16/11/28.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "Module.h"

@interface Module (Third)
@property (nonatomic, readonly) NSString * Third_title;
@property (nonatomic, strong) NSString * Third_loadingImage;
@property (nonatomic, strong) NSString * Third_identifier;
@property (nonatomic, strong) NSString * Third_detail;
@property (nonatomic, strong) NSString * Third_version;
@property (nonatomic, strong) UIViewController * Third_rootViewController;
@end
