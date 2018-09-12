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

-(instancetype)initTemplateWithJsonFile:(NSString *)jsonFile
{
    self = [super init];
    if (self) {
        
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
    }
    return self;
}


- (BOOL)save:(BOOL)useAuxiliaryFile
{
    if (!self.loadFilePath.length) {
        return NO;
    }
    return [self.info writeToFile:self.loadFilePath atomically:useAuxiliaryFile];
}


- (BOOL)saveTemplateToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    return [self.info writeToFile:filePath atomically:useAuxiliaryFile];
}

@end

@implementation ZFAppIcon

+ (instancetype)appIconWithDictionary:(NSDictionary*)dic
{
    ZFAppIcon*icon = [[self alloc] init];
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
    return save;
}

@end
