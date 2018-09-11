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
#import "ZFIconImage.h"

@interface ViewController ()<NSOpenSavePanelDelegate>

@property (weak) IBOutlet NSTextField *iconTextField;
@property (weak) IBOutlet NSImageView *iconIV;
@property (weak) IBOutlet NSTextField *textField;
@property (unsafe_unretained) IBOutlet NSTextView *logOutputView;
@property (weak) IBOutlet NSScrollView *logScroll;
@property (weak) IBOutlet NSSegmentedControl *seg;

@property (strong, nonatomic) NSString *resourcePath;
@property (strong, nonatomic) NSString *sourcePath;
//@property (strong, nonatomic) NSString *tempPath;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidNotification:) name:NSControlTextDidChangeNotification object:nil];

    [self.iconTextField addObserver:self forKeyPath:@"stringValue" options:NSKeyValueObservingOptionNew context:nil ];
    [self.textField addObserver:self forKeyPath:@"stringValue" options:NSKeyValueObservingOptionNew context:nil ];
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


- (IBAction)open:(NSButton*)sender {
    if (sender.tag == 0) {
        [self openIconPanelFile];
    }else{
         [self openPanelFile];
    }

}

- (IBAction)save:(id)sender {
    [self openPanelDirectory];
//    [self checkSavePath];
}
- (IBAction)segValueChange:(NSSegmentedControl *)sender {
}

-(void)checkSavePath
{
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL dir;
    if (![fm fileExistsAtPath:self.destinationPath isDirectory:&dir]) {
        NSError*err;
        if ([fm createDirectoryAtPath:self.destinationPath
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
    NSImage *source = [[NSImage alloc] initWithContentsOfFile:self.resourcePath];
    if (self.seg.segmentCount == 1) {
        return [source iconImageWithSize:desSize radius:0.5];
    }
    return [source iconImageWithSize:desSize radius:0];
}



@end
