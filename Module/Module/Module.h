//
//  Module.h
//  Demo
//
//  Created by zhengfeng on 16/11/7.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@interface Module : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * loadingImage;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * detail;
@property (nonatomic, strong) NSString * version;
@property (nonatomic, strong) UIViewController * rootViewController;

- (void)loadModule;
@end
