//
//  ZFIconImage.h
//  MySimp
//
//  Created by zfeng on 2018/9/10.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSImage.h>
#import <CoreImage/CoreImage.h>

@interface ZFIconImage : NSObject
/*  0~0.5 */
@property (nonatomic) CGFloat radius;

- (NSImage*)imageIconWithFile:(NSString*)inputImagePath withSize:(NSSize)desSize;
- (NSImage*)imageIconWithImage:(NSImage*)inputImage withSize:(NSSize)desSize;

- (CGImageRef)generateIconWithFile:(NSString*)inputImagePath withSize:(NSSize)desSize;
- (CGImageRef)generateIconWithImage:(NSImage*)inputImage withSize:(NSSize)desSize;
@end

@interface NSImage (ICONGEN)
- (CGImageRef)iconCImageithSize:(CGSize)size radius:(CGFloat)radius;
- (NSImage *)iconImageWithSize:(CGSize)size radius:(CGFloat)radius;
@end


