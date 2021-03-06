//
//  ZFIconTemplate.h
//  MySimp
//
//  Created by zfeng on 2018/9/10.
//  Copyright © 2018年 郑丰. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFAppIcon;
@interface ZFIconTemplate : NSObject
+(instancetype)templateWithJsonFile:(NSString *)jsonFile;
-(instancetype)initWithJsonFile:(NSString *)jsonFile;
-(instancetype)initWithJsonData:(NSData *)jsonData;

-(instancetype)init;

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSArray<ZFAppIcon*> *images;

- (BOOL)save:(BOOL)useAuxiliaryFile;
- (BOOL)saveTemplateToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile;
@end


@interface ZFAppIcon : NSObject
@property (nonatomic, strong) NSString *idiom;
@property (nonatomic, strong) NSString *filename;

@property (nonatomic) CGSize size;
@property (nonatomic) NSInteger scale;

@property (readonly, strong) NSString *role;
@property (readonly, strong) NSString *subtype;

+ (instancetype)appIconWithDictionary:(NSDictionary*)dic;
+ (ZFAppIcon*)marketingIphone;
+ (ZFAppIcon*)marketingWatch;
- (NSDictionary*)getSaveInfo;

- (NSString *)genFilename;
- (CGSize)pxsize;
@end




static NSString* kAppIconIdiomIphone    = @"iphone";
static NSString* kAppIconIdiomIpad      = @"ipad";
static NSString* kAppIconIdiomCarPlay   = @"car";
static NSString* kAppIconIdiomWatch     = @"watch";
static NSString* kAppIconIdiomMac       = @"mac";

static NSString* kAppIconIdiomMarketingIOS         = @"ios-marketing";
static NSString* kAppIconIdiomMarketingWatch       = @"watch-marketing";

