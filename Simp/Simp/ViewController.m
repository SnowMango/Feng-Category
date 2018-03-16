//
//  ViewController.m
//  Simp
//
//  Created by zhengfeng on 2017/8/29.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <AppKit/AppKit.h>

@interface ViewController ()<NSOpenSavePanelDelegate>
@property (weak) IBOutlet NSTextField *textField;
@property (unsafe_unretained) IBOutlet NSTextView *logOutputView;
@property (weak) IBOutlet NSScrollView *logScroll;

@property (strong, nonatomic) NSString *resourcePath;
@property (strong, nonatomic) NSString *sourcePath;
@property (strong, nonatomic) NSString *destinationPath;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resourcePath = [[NSBundle mainBundle] pathForResource:@"feng1024" ofType:@"png"];
}

- (void)clearLog
{
    self.logOutputView.string = @"";
}
- (void)addLog:(NSString *)log
{
    NSString*newLog =[self.logOutputView.string stringByAppendingFormat:@"\n%@",log];
    self.logOutputView.string = newLog;

}

- (IBAction)open:(id)sender {
    [self openPanelFile];
}

- (IBAction)save:(id)sender {
    [self openPanelDirectory];
}

- (void)saveImages
{
    if (!self.sourcePath.length) {
        return;
    }
    NSData *jsonData = [[NSFileHandle fileHandleForReadingAtPath:self.sourcePath] readDataToEndOfFile];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSArray *iconImages = dict[@"images"];
    NSMutableArray *des =[NSMutableArray array];
    __block NSInteger successCount = 0;
    [self clearLog];
    [self addLog:[NSString stringWithFormat:@"预计生成文件：%@ 正在生成...", @(iconImages.count)]];
    for (NSDictionary *item in iconImages) {
        __weak typeof(self)weakSelf = self;
        NSMutableDictionary *result = item.mutableCopy;
        [self saveAppIconWithItem:item compelete:^(BOOL finish, NSString *fileName) {
            if (finish) {
                [result setObject:fileName forKey:@"filename"];
                successCount++;
                
            }
            [weakSelf addLog:[NSString stringWithFormat:@"%@（%@）",fileName,finish?@"√":@"×"]];
        }];
        
        [des addObject:result];
    }
    NSString *log = [NSString stringWithFormat:@"文件全部生成"];
    if (successCount != iconImages.count) {
        log = [NSString stringWithFormat:@"完成：%@,未完成：%@",@(successCount),@(iconImages.count - successCount)];
    }
    [self addLog:log];
    [dict setObject:des forKey:@"images"];
    //Contents.json
    if ([self createContentJson:dict]) {
        [self addLog:@"Contents.json 创建成功"];
    }
}
- (BOOL)createContentJson:(NSDictionary *)data
{
    if (!self.destinationPath.length || !data.count) {
        return NO ;
    }
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *contentsPath = [self.destinationPath stringByAppendingPathComponent:@"Contents.json"];
    return [json writeToFile:contentsPath atomically:YES];
}

- (void)saveAppIconWithItem:(NSDictionary*)item compelete:(void (^)(BOOL finish, NSString *fileName))compelete
{
    NSString * idiom = item[@"idiom"];
    NSInteger scale = [item[@"scale"] integerValue];
    NSArray *sizeArray = [item[@"size"] componentsSeparatedByString:@"x"];
    NSSize size = NSMakeSize([sizeArray.firstObject floatValue]*scale, [sizeArray.lastObject floatValue]*scale);
    
    NSString *suffix = @"";
    if (scale > 1) {
        suffix = [NSString stringWithFormat:@"@%@x",@(scale)];
    }
    NSString *fileType = @"png";
    NSString * filename = [NSString stringWithFormat:@"%@(%@)%@.%@",idiom,item[@"size"],suffix,fileType];
    NSImage *image = [self createImageWithSize:size];
    
    BOOL finish = NO;
    if (image) {
       finish = [self saveFileWithName:filename withImage:image];
    }
    if (compelete) {
        compelete(finish, filename);
    }
}

- (BOOL)saveFileWithName:(NSString *)fileName withImage:(NSImage*)image
{
    if (!self.destinationPath.length || !image) {
        return NO;
    }
    NSString *path = [self.destinationPath stringByAppendingPathComponent:fileName];
    return [[image TIFFRepresentation] writeToFile:path atomically:YES];
}


- (void)savePanel
{
    
    NSSavePanel *save = [NSSavePanel savePanel];
    save.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    save.delegate = self;
    save.allowedFileTypes = @[@"png"];
    [save beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"save = %@", result ?@"Ok":@"Cancel");
        if (result) {
            NSString *path = save.URL.filePathURL.path;
            NSLog(@"path = %@", path);
        }else{
            
        }
    }];
}

- (void)openPanelDirectory
{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    open.delegate = self;
    open.allowedFileTypes = @[@"appiconset"];
    open.canCreateDirectories = YES;
    open.canChooseDirectories = YES;
    open.canChooseFiles =NO;
    [open beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"save = %@", result ?@"Ok":@"Cancel");
        if (result) {
            NSString *path = open.URL.filePathURL.path;
            NSLog(@"path = %@",path);
            self.destinationPath = [path stringByAppendingPathComponent:@"AppIcon.appiconset"];
            NSFileManager *fm = [NSFileManager defaultManager];
          
            BOOL dir;
            if (![fm fileExistsAtPath:self.destinationPath isDirectory:&dir]) {

                if ([fm createDirectoryAtPath:self.destinationPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil])
                {
                    [self saveImages];
                }
            }else{
                if (dir) {
                    [fm removeItemAtPath:self.destinationPath error:nil];
                    if ([fm createDirectoryAtPath:self.destinationPath
                      withIntermediateDirectories:YES
                                       attributes:nil
                                            error:nil])
                    {
                        [self saveImages];
                    }
                }else{
                    [self saveImages];
                }
            }
        }else{
            
        }
    }];

}

- (void)openPanelFile
{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    open.delegate = self;
    open.allowedFileTypes = @[@"json"];
    open.canCreateDirectories = YES;
    open.canChooseDirectories = YES;
    [open beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"save = %@", result ?@"Ok":@"Cancel");
        if (result) {
            NSString *path = open.URL.filePathURL.path;
            NSLog(@"path = %@",path);
            self.textField.stringValue = path;
            self.sourcePath = path;
        }else{
            
        }
    }];

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}



- (void)touchesEndedWithEvent:(NSEvent *)event
{
    
}


- (NSImage*)createImageWithSize:(NSSize)desSize
{
    if (!self.resourcePath.length) {
        return nil;
    }
    
    CGImageRef ref = [self createImage:self.resourcePath withSize:desSize];
    NSImage *image = [[NSImage alloc] initWithCGImage:ref size:desSize];
    return image;
}

- (NSImage*)resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    return targetImage;
}

-(CGImageRef)createImage:(NSString*)inputImagePath withSize:(NSSize)desSize {
    
    NSImage *inputRetinaImage = [[NSImage alloc] initWithContentsOfFile:inputImagePath];
    if (!inputRetinaImage) {
        return nil;
    }
    //determine new size
    NSSize size = desSize;
    
    NSData *imageData = [inputRetinaImage TIFFRepresentation];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    
    CGImageRef oldImageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CGColorSpaceRef colorSpace=  CGImageGetColorSpace(oldImageRef);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
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
    
    [self drawArcRectangle:bitmap
                  withRect:imageRect
                    radius:size.width/2.0];
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, imageRect, oldImageRef);
    CGImageRelease(oldImageRef);
    // Get an image from the context
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);

    return newImageRef;
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
