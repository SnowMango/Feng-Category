//
//  Module+First.h
//  Pods
//
//  Created by zhengfeng on 16/11/7.
//
//

#import "Module.h"
#import "TestViewController.h"

@interface Module (First)

@property (nonatomic, readonly) NSString * First_title;
@property (nonatomic, strong) NSString * First_loadingImage;
@property (nonatomic, strong) NSString * First_identifier;
@property (nonatomic, strong) NSString * First_detail;
@property (nonatomic, strong) NSString * First_version;
@property (nonatomic, strong) UIViewController * First_rootViewController;

@end

