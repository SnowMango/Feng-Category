//
//  ZFIconImage.m
//  MySimp
//
//  Created by zfeng on 2018/9/10.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import "ZFIconImage.h"



@implementation ZFIconImage

-(void)setRadius:(CGFloat)radius
{
  @synchronized(self)  {
    if (radius <0) {
        _radius = 0;
    }else if (radius > 0.5){
        _radius = 0.5;
    }else{
        _radius = radius;
    }
  }
}

- (ICON_IMAGE*)imageIconWithFile:(NSString*)inputImagePath withSize:(NSSize)desSize
{
    CGImageRef ref = [self generateIconWithFile:inputImagePath withSize:desSize];
#if TARGET_OS_IPHONE || TARGET_OS_TV || TARGET_OS_SIMULATOR
    ICON_IMAGE *icon = [[ICON_IMAGE alloc] initWithCGImage:ref];
#elif TARGET_OS_MAC
    ICON_IMAGE *icon = [[ICON_IMAGE alloc] initWithCGImage:ref size:desSize];
#endif
    
    CGImageRelease(ref);
    return icon;
}
- (ICON_IMAGE*)imageIconWithImage:(ICON_IMAGE*)inputImage withSize:(NSSize)desSize
{
    CGImageRef ref = [self generateIconWithImage:inputImage withSize:desSize];
#if TARGET_OS_IPHONE || TARGET_OS_TV
    ICON_IMAGE *icon = [[ICON_IMAGE alloc] initWithCGImage:ref];
#elif TARGET_OS_MAC
    ICON_IMAGE *icon = [[ICON_IMAGE alloc] initWithCGImage:ref size:desSize];
#endif
    
    CGImageRelease(ref);
    return icon;
}

- (CGImageRef)generateIconWithFile:(NSString*)inputImagePath withSize:(NSSize)desSize {
    
    ICON_IMAGE *inputRetinaImage = [[ICON_IMAGE alloc] initWithContentsOfFile:inputImagePath];
    return [self generateIconWithImage:inputRetinaImage withSize:desSize];
}


- (CGImageRef)generateIconWithImage:(ICON_IMAGE*)inputImage withSize:(NSSize)desSize
{
    if (!inputImage) {
        return nil;
    }
    NSSize size = desSize;
    NSData *imageData = nil;
#if TARGET_OS_IPHONE || TARGET_OS_TV
    imageData = UIImagePNGRepresentation(imageData);
#elif TARGET_OS_MAC
    imageData = [inputImage TIFFRepresentation];
#endif
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    
    CGImageRef oldImageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CGColorSpaceRef colorSpace=  CGImageGetColorSpace(oldImageRef);
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Little;
    if (self.radius != 0) {
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast;
    }
    size_t bitsPer = CGImageGetBitsPerComponent(oldImageRef);
    
    // Build a bitmap context
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                size.width,
                                                size.height,
                                                bitsPer,
                                                4* size.width,
                                                colorSpace,
                                                bitmapInfo);
    
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    
    
    if (self.radius != 0) {
        CGFloat radius= CGRectGetHeight(imageRect)/self.radius;
        [self drawArcRectangle:bitmap withRect:imageRect radius:radius];
    }
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, imageRect, oldImageRef);
    CGImageRelease(oldImageRef);
    // Get an image from the context
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);

    return newImageRef ;
}



#pragma mark - 绘制圆角矩形
- (void)drawArcRectangle:(CGContextRef) context withRect:(CGRect)rect radius:(CGFloat)radius{
    
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    CGContextSaveGState(context);
    
    CGContextMoveToPoint(context, x, y);  // 开始坐标右边开始
    CGContextAddArcToPoint(context, x+w, y , x+w, y+radius , radius);//右上角
    CGContextAddArcToPoint(context, x+w, y+h, x+w-radius, y+h, radius); // 右下角
    CGContextAddArcToPoint(context, x, y+h , x, y+h-radius , radius);// 左下角
    CGContextAddArcToPoint(context,x, y, x+radius, y, radius);// 左上角
    CGContextClosePath(context);
    
    CGContextRestoreGState(context);
    
    CGContextEOClip(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

@implementation ICON_IMAGE (ICONGEN)

- (CGImageRef)iconCImageithSize:(CGSize)size radius:(CGFloat)radius
{
    ZFIconImage *icon = [[ZFIconImage alloc] init];
    icon.radius =radius;
    
    return [icon generateIconWithImage:self withSize:size];
}

- (ICON_IMAGE *)iconImageWithSize:(CGSize)size radius:(CGFloat)radius
{
    ZFIconImage *icon = [[ZFIconImage alloc] init];
    icon.radius =radius;
    
    return [icon imageIconWithImage:self withSize:size];
}

@end
