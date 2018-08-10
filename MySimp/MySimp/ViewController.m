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

@property (weak) IBOutlet NSTextField *iconTextField;
@property (weak) IBOutlet NSImageView *iconIV;
@property (weak) IBOutlet NSTextField *textField;
@property (unsafe_unretained) IBOutlet NSTextView *logOutputView;
@property (weak) IBOutlet NSScrollView *logScroll;

@property (strong, nonatomic) NSString *resourcePath;
@property (strong, nonatomic) NSString *sourcePath;
@property (strong, nonatomic) NSString *tempPath;
@property (strong, nonatomic) NSString *destinationPath;

@end


@implementation ViewController

- (void)dealloc
{
    [self.iconTextField removeObserver:self forKeyPath:@"stringValue" ];
    [self.textField removeObserver:self forKeyPath:@"stringValue" ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.resourcePath = [[NSBundle mainBundle] pathForResource:@"logo1024" ofType:@"png"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidNotification:) name:NSControlTextDidChangeNotification object:nil];

    [self.iconTextField addObserver:self forKeyPath:@"stringValue" options:NSKeyValueObservingOptionNew context:nil ];
    [self.textField addObserver:self forKeyPath:@"stringValue" options:NSKeyValueObservingOptionNew context:nil ];
    self.tempPath= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/AppIcon.appiconset"];
    self.view.layer.backgroundColor =[NSColor whiteColor].CGColor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (self.iconTextField == object) {
        NSString *path = self.iconTextField.stringValue;
        self.iconIV.image = [[NSImage alloc] initWithContentsOfFile:path];
        self.resourcePath = path;
    }else if (self.textField == object){
        self.sourcePath = self.textField.stringValue;
    }
}

- (void)textDidNotification:(NSNotification*)noti
{
    id object = noti.object;
    if (self.iconTextField == object) {
        NSString *path = self.iconTextField.stringValue;
        self.iconIV.image = [[NSImage alloc] initWithContentsOfFile:path];
        self.resourcePath = path;
    }else if (self.textField == object){
        self.sourcePath = self.textField.stringValue;
    }
}


- (void)clearLog
{
    self.logOutputView.string = @"";
}
- (void)addLog:(NSString *)log
{
    NSString*newLog =[self.logOutputView.string stringByAppendingFormat:@"\n%@",log];
    self.logOutputView.string = newLog;
    [self.logOutputView scrollRangeToVisible:NSMakeRange(newLog.length - 1, 1)];
}

- (NSString *)copyFilesToDest
{
    NSString*bashPath =@"/bin/bash";
    NSString * exePath = [[NSBundle mainBundle] pathForResource:@"copyfiles" ofType:@"sh"];
    NSTask *copytask = [[NSTask alloc] init];
    copytask.launchPath = bashPath;
    copytask.arguments = @[exePath, self.tempPath];
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    copytask.standardOutput = pipe;
    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    [copytask launch];

    // 获取运行结果
    NSData *data = [file readDataToEndOfFile];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

- (IBAction)open:(NSButton*)sender {
    if (sender.tag == 0) {
        [self openIconPanelFile];
    }else{
         [self openPanelFile];
    }

}

- (IBAction)save:(id)sender {
//    [self openPanelDirectory];
    [self checkSavePath];
}

-(void)checkSavePath
{
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL dir;
    if (![fm fileExistsAtPath:self.tempPath isDirectory:&dir]) {
        NSError*err;
        if ([fm createDirectoryAtPath:self.tempPath
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&err])
        {
            [self saveImages];
        }else{
            NSLog(@"%@",err);
        }
    }else{
        if (dir) {
            [fm removeItemAtPath:self.tempPath error:nil];
            if ([fm createDirectoryAtPath:self.tempPath
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
    if (successCount == iconImages.count) {
        NSString * ret=  [self copyFilesToDest];
        NSLog(@"copy return=> %@",ret);
    }
}
- (BOOL)createContentJson:(NSDictionary *)data
{
    if (!self.tempPath.length || !data.count) {
        return NO ;
    }
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *contentsPath = [self.tempPath stringByAppendingPathComponent:@"Contents.json"];
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
    if (!self.tempPath.length || !image) {
        return NO;
    }
    NSString *path = [self.tempPath stringByAppendingPathComponent:fileName];
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
            self.destinationPath = path ;
            [self checkSavePath];
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
    [open beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"save = %@", result ?@"Ok":@"Cancel");
        if (result) {
            NSString *path = open.URL.filePathURL.path;
            NSLog(@"path = %@",path);
            self.textField.stringValue = path;
        }else{
            
        }
    }];

}

- (void)openIconPanelFile
{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.directoryURL = [NSURL URLWithString:NSHomeDirectory()];
    open.delegate = self;
    open.allowedFileTypes = @[@"png"];
    NSLog(@"->%@",self.iconTextField.stringValue);
    [open beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"save = %@", result ?@"Ok":@"Cancel");
        if (result) {
            NSString *path = open.URL.filePathURL.path;
            NSLog(@"path = %@",path);
            self.iconTextField.stringValue = path;
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
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Little;
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
