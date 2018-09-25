//
//  ZFIconTemplate.m
//  MySimp
//
//  Created by zfeng on 2018/9/10.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import "ZFIconTemplate.h"
@interface ZFIconTemplate ()
@property (nonatomic,strong) NSString *loadFilePath;
@end
@implementation ZFIconTemplate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.info = @{@"version" : @1,@"author" : @"xcode"};
    }
    return self;
}

+(instancetype)templateWithJsonFile:(NSString *)jsonFile
{
    ZFIconTemplate*icon = [[self alloc] initWithJsonFile:jsonFile];
    return icon;
}
-(instancetype)initWithJsonFile:(NSString *)jsonFile
{
    self = [super init];
    if (self) {
        self.loadFilePath = jsonFile;
        NSData *jsonData = [[NSFileHandle fileHandleForReadingAtPath:jsonFile] readDataToEndOfFile];
        
        [self setupWithData:jsonData];
    }
    return self;
}

-(instancetype)initWithJsonData:(NSData *)jsonData
{
    self = [super init];
    if (self) {
        [self setupWithData:jsonData];
    }
    return self;
}

- (void)setupWithData:(NSData*)jsonData
{
    if (!jsonData || ![NSJSONSerialization isValidJSONObject:jsonData]) {
        return;
    }
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    self.info = dict[@"info"];
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *images = dict[@"images"];
    for (NSDictionary *item in images) {
        ZFAppIcon *icon = [ZFAppIcon appIconWithDictionary:item];
        if (icon) {
            [temp addObject:icon];
        }
    }
}


- (BOOL)save:(BOOL)useAuxiliaryFile
{
    if (!self.loadFilePath.length) {
        return NO;
    }
    return [self saveTemplateToFile:self.loadFilePath atomically:useAuxiliaryFile];
}


- (BOOL)saveTemplateToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    NSMutableDictionary *save = [NSMutableDictionary dictionary];
    save[@"info"]= self.info;
    NSMutableArray *images = [NSMutableArray array];
    for (ZFAppIcon*icon in images) {
        [images addObject:[icon getSaveInfo]];
    }
    save[@"images"] = images;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:save options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
        return NO;
    }
    NSString *savePath = filePath;
    if (![filePath.lastPathComponent isEqualToString:@"Contents.json"]) {
        savePath = [filePath stringByAppendingPathComponent:@"Contents.json"];
    }
    return [jsonData writeToFile:savePath atomically:useAuxiliaryFile];
}

@end

@implementation ZFAppIcon
- (instancetype)initWithDictionary:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        _role = dic[@"role"];
        _subtype = dic[@"subtype"];
    }
    return self;
}

+ (instancetype)appIconWithDictionary:(NSDictionary*)dic
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    ZFAppIcon*icon = [[self alloc] initWithDictionary:dic];
    icon.idiom = dic[@"idiom"];
    icon.scale= [dic[@"scale"] integerValue];
    icon.filename= dic[@"filename"];
    
    NSArray *sizeArr = [dic[@"size"] componentsSeparatedByString:@"x"];
    CGFloat width = [sizeArr.firstObject floatValue];
    CGFloat height = [sizeArr.lastObject floatValue];
    icon.size = CGSizeMake(width, height);
    return icon;
}


+ (instancetype)marketingIphone
{
    ZFAppIcon*icon = [[ZFAppIcon alloc] init];
    icon.idiom = kAppIconIdiomMarketingIOS;
    icon.size = CGSizeMake(1024, 1024);
    icon.scale = 1;
    return icon;
}
+ (instancetype)marketingWatch
{
    ZFAppIcon*icon = [[ZFAppIcon alloc] init];
    icon.idiom = kAppIconIdiomMarketingWatch;
    icon.size = CGSizeMake(1024, 1024);
    icon.scale = 1;
    return icon;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSDictionary*)getSaveInfo
{
    NSMutableDictionary*save =[NSMutableDictionary dictionary];
    save[@"idiom"]= self.idiom;
    save[@"scale"]= self.scale? @(self.scale): nil;
    save[@"filename"]= self.filename.length? self.filename:nil;
    if (self.size.width && self.size.height) {
        save[@"size"]= [NSString stringWithFormat:@"%@x%@",@(self.size.width),@(self.size.height)];
    }
    save[@"role"]= self.role.length? self.role:nil;
    save[@"subtype"]= self.subtype.length? self.subtype:nil;
    return save;
}

- (NSString *)genFilename
{
    NSString *newName = [NSString stringWithFormat:@"%@-%@",self.idiom,@(self.size.width)];
    if (self.scale > 1) {
        newName = [newName stringByAppendingFormat:@"@%@x", @(self.scale)];
    }
    newName = [newName stringByAppendingPathExtension:@"png"];
    return newName;
}

- (CGSize)pxsize
{
    return CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
}

@end
