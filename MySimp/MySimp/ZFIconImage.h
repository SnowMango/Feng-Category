//
//  ZFIconImage.h
//  MySimp
//
//  Created by zfeng on 2018/9/10.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreImage/CoreImage.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#define ICON_IMAGE UIImage

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>
#define ICON_IMAGE NSImage
#endif

@interface ZFIconImage : NSObject
/*  0~0.5 */
@property (nonatomic) CGFloat radius;


- (CGImageRef)generateIconWithFile:(NSString*)inputImagePath withSize:(NSSize)desSize;
- (CGImageRef)generateIconWithImage:(ICON_IMAGE*)inputImage withSize:(NSSize)desSize;
@end

@interface ICON_IMAGE (ICONGEN)
- (CGImageRef)iconCImageithSize:(CGSize)size radius:(CGFloat)radius;
@end


