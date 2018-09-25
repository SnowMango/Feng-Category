//
//  ZFIconManager.m
//  MySimp
//
//  Created by zfeng on 2018/9/12.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import "ZFIconManager.h"
#import "ZFIconImage.h"

@implementation ZFIconManager

- (ICON_IMAGE*)checkSource
{
    ICON_IMAGE *srcImage = self.source;
    if (!srcImage) {
        NSString *format = [self.sourcePath pathExtension];
        NSArray *support = @[@"png"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.sourcePath] && [support containsObject:format]) {
            srcImage = [[ICON_IMAGE alloc] initWithContentsOfFile:self.sourcePath];
        }
    }
    return srcImage;
}

- (NSData*)checkTemplate
{
    NSData *json = self.jsonTemplate;
    if (!json) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.templatePath]) {
            json = [NSData dataWithContentsOfFile:self.templatePath];
        }
    }
    return json;
}
- (BOOL)loadGenerateData
{
    _iconTemplate = nil;
    ICON_IMAGE *srcImage = [self checkSource];
    if (!srcImage) {
        return NO;
    }
    
    NSData *json = [self checkTemplate];
    if (!json) {
        return NO;
    }
    
    _iconTemplate = [[ZFIconTemplate alloc] initWithJsonData:json];
    return YES;
}

- (void)generateWithRaduis:(CGFloat)raduis;
{
    
    ICON_IMAGE *srcImage = [self checkSource];
    if (!srcImage) {
        return ;
    }
    
    NSData *json = [self checkTemplate];
    if (!json) {
        return;
    }
    ZFIconTemplate *iconTemplate = [[ZFIconTemplate alloc] initWithJsonData:json];
    
    NSString *savePath = self.savePath;
    if (!savePath && self.templatePath.length) {
        savePath = self.templatePath;
    }
  
    if ([savePath.lastPathComponent isEqualToString:@"Contents.json"]) {
        NSString *parentPath = savePath.stringByDeletingLastPathComponent;
        if (![parentPath.pathExtension isEqualToString:@".appiconset"]) {
            savePath = [parentPath stringByAppendingPathComponent:@"AppIcon.appiconset"];
        }else{
            savePath = parentPath;
        }
    }else if (![savePath.pathExtension isEqualToString:@".appiconset"]){
        savePath = [savePath stringByAppendingPathComponent:@"AppIcon.appiconset"];
    }
    
    for (ZFAppIcon*icon in iconTemplate.images) {
        NSString *fileName = [icon genFilename];
        
        CGSize drawSize = [icon pxsize];
        CGImageRef desImageRef = [srcImage iconCImageithSize:drawSize radius:raduis];
        NSData *imageData = [self dataImageWithCGImage:desImageRef];

        NSString *filePath = [savePath stringByAppendingPathComponent:fileName];
        
        if (imageData) {
            if ([imageData writeToFile:filePath atomically:YES]) {
                icon.filename = fileName;
            }
        }
    }
    NSString* templateName = @"Contents.json";
    [iconTemplate saveTemplateToFile:[savePath stringByAppendingPathComponent:templateName] atomically:YES];
}

- (NSData*)dataImageWithCGImage:(CGImageRef)cgImage
{
    NSData *imageData = nil;
#if TARGET_OS_IPHONE || TARGET_OS_TV
    UIImage*image = [UIImage imageWithCGImage:cgImage];;
    imageData = UIImagePNGRepresentation(image);
#elif TARGET_OS_MAC
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
    imageData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{NSImageInterlaced:@(YES)}];
#endif
    return imageData;
    
}


@end
