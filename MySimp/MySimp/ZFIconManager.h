//
//  ZFIconManager.h
//  MySimp
//
//  Created by zfeng on 2018/9/12.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFIconTemplate.h"
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#define ICON_IMAGE UIImage

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>
#define ICON_IMAGE NSImage

#endif

@class ZFIconManager;

@protocol ZFIconManagerGenDelegate <NSObject>
- (void)manager:(ZFIconManager*)manager didGenImage:(ICON_IMAGE*)genImage withIndex:(NSRange)range;

- (void)manager:(ZFIconManager*)manager didFailIcon:(ZFAppIcon*)icon withIndex:(NSRange)range;
@end

@interface ZFIconManager : NSObject
{
    ZFIconTemplate*_iconTemplate;
}

/**
 source 和 sourcePath 二选一 source优先级高
 */
@property (nonatomic, strong) ICON_IMAGE *source;
//大小：1024x1024 单位：格式：png
@property (nonatomic, strong) NSString *sourcePath;

/**
 jsonTemplate 和templatePath 二选一 jsonTemplate优先级高
 */
@property (nonatomic, strong) NSData  *jsonTemplate;
//templatePath路径 支持.appiconset后缀文件夹 和 .json文件
@property (nonatomic, strong) NSString *templatePath;

/**
 templatePath有值时：savePath可选 图片生成在templatePath文件路径下
 会在非.appiconset默认生成AppIcon.appiconset
 */
@property (nonatomic, strong) NSString *savePath;


- (BOOL)loadGenerateData;
/**
 生成icon
 @param raduis 0~0.5 值为高度比例, 不等0会有alph通道;
 */
- (void)generateWithRaduis:(CGFloat)raduis;

@end
