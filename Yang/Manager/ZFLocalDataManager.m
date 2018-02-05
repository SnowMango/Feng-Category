//
//  ZFLocalDataManager.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFLocalDataManager.h"

#define DEFAULT_STATUS @"DEFAULT_STATUS"
@interface ZFLocalDataManager ()
@property (strong, nonatomic) NSString *billPath;
@property (strong, nonatomic) NSString *billStatusPath;
@property (strong, nonatomic) NSString *priceSystomPath;
@property (strong, nonatomic) NSString *dishesGroupPath;

@property (strong, nonatomic) NSString *billFile;
@property (strong, nonatomic) NSString *billStatusFile;
@property (strong, nonatomic) NSString *priceSystomFile;
@property (strong, nonatomic) NSString *dishesGroupFile;

@property (strong, nonatomic) ZFBillStatus *defaultStatus;
@property (strong, nonatomic) NSMutableArray *billList;
@property (strong, nonatomic) NSMutableArray *billStatusList;
@property (strong, nonatomic) NSMutableArray *priceSystomList;
@property (strong, nonatomic) NSMutableArray *dishesGroupList;

@end


@implementation ZFLocalDataManager

+(ZFLocalDataManager*)shareInstance
{
    static ZFLocalDataManager* obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[ZFLocalDataManager alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self localPathLoad];
    }
    return self;
}

- (void)localPathLoad
{
    // 获取Documents目录路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.billPath = [docDir stringByAppendingPathComponent:@"Admin/Bill"];
    self.billStatusPath = [docDir stringByAppendingPathComponent:@"Admin/BillStatus"];
    self.priceSystomPath = [docDir stringByAppendingPathComponent:@"Admin/PriceSystom"];
    self.dishesGroupPath = [docDir stringByAppendingPathComponent:@"Admin/DishesGroup"];
    NSArray *paths = @[self.billPath,
                       self.billStatusPath,
                       self.priceSystomPath,
                       self.dishesGroupPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *filePath in paths) {
        NSError *err = nil;
        if (![fm fileExistsAtPath:filePath]) {
            BOOL ret =[fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&err];
            if (!ret || err) {
                NSLog(@"ret = %@", ret?@"YES":@"NO");
            }else{
                NSLog(@"success");
            }
        }
    }
    self.billFile = [docDir stringByAppendingPathComponent:@"Admin/Bill.plist"];
    self.billStatusFile = [docDir stringByAppendingPathComponent:@"Admin/BillStatus.plist"];
    self.priceSystomFile = [docDir stringByAppendingPathComponent:@"Admin/PriceSystom.plist"];
    self.dishesGroupFile = [docDir stringByAppendingPathComponent:@"Admin/DishesGroup.plist"];
    NSArray *files = @[self.billFile,
                       self.billStatusFile,
                       self.priceSystomFile,
                       self.dishesGroupFile];
    for (NSString *filePath in files) {
        if (![fm fileExistsAtPath:filePath]) {
            BOOL ret = [[NSArray array] writeToFile:filePath atomically:YES];
            if (!ret) {
                NSLog(@"ret = %@", ret?@"YES":@"NO");
            }else{
                NSLog(@"success");
            }
        }
    }
    
}

- (NSMutableArray *)loadDataFormPath:(NSString *)path withFile:(NSString*)file
{
    NSArray *identifiers =[NSArray arrayWithContentsOfFile:file];
    NSMutableArray *temp =[NSMutableArray array];
    for (NSString *identifier in identifiers) {
        NSString *filePath = [path stringByAppendingPathComponent:identifier];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            if (obj) {
                [temp addObject:obj];
            }
        }
    }
    return temp;
}

- (BOOL)saveDataToPath:(NSString *)path andFile:(NSString*)file withData:(id)obj withKey:(NSString *)key
{
    if (!obj) {
        return NO;
    }
    NSString *filePath = [path stringByAppendingPathComponent:key];
    BOOL ret = [NSKeyedArchiver archiveRootObject:obj toFile:filePath];
    if (ret) {
        NSMutableArray *tempId =[NSMutableArray arrayWithContentsOfFile:file];
        if ([tempId indexOfObject:key] == NSNotFound) {
            [tempId addObject:key];
            if (![tempId writeToFile:file atomically:YES]) {
                ret = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
    return ret;
}
- (BOOL)deleteDataToPath:(NSString *)path andFile:(NSString*)file withKey:(NSString *)key
{
    NSString *filePath = [path stringByAppendingPathComponent:key];
    NSFileManager*fm =[NSFileManager defaultManager];
    
    BOOL exists = [fm fileExistsAtPath:filePath];
    if (!exists) {
        return YES;
    }
    BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    if (ret) {
        NSMutableArray *tempId =[NSMutableArray arrayWithContentsOfFile:file];
        if ([tempId indexOfObject:key] != NSNotFound) {
            [tempId removeObject:key];
            if (![tempId writeToFile:file atomically:YES]) {
                ret = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
    return ret;
}

- (ZFBillStatus*)defaultBillStatus
{
    if (!_defaultStatus) {
        NSString *filePath = [self.billStatusPath stringByAppendingPathComponent:DEFAULT_STATUS];
        self.defaultStatus = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (!self.defaultStatus) {
            self.defaultStatus = [self allBillStatus].firstObject;
        }
    }
    return self.defaultStatus;
}
- (BOOL)setDefaultBillStatus:(ZFBillStatus*)status
{
    self.defaultStatus = status;
    NSString *filePath = [self.billStatusPath stringByAppendingPathComponent:DEFAULT_STATUS];
    return [NSKeyedArchiver archiveRootObject:self.defaultStatus toFile:filePath];
}

//read
- (NSArray<ZFBill*> *)allBill
{
    if (!self.billList) {
        self.billList =[self loadDataFormPath:self.billPath
                                     withFile:self.billFile];
    }
    return self.billList;
}

- (NSArray<ZFBillStatus*> *)allBillStatus
{
    if (!self.billStatusList) {
        self.billStatusList =
        [self loadDataFormPath:self.billStatusPath
                      withFile:self.billStatusFile];
        if (!self.billStatusList.count) {
            self.defaultStatus = [[ZFBillStatus alloc] init];
            self.defaultStatus.name = @"默认";
            [self setDefaultStatus:self.defaultStatus];
            [self saveBillStatus:self.defaultStatus];
        }
    }
    return self.billStatusList;
}

- (NSArray<ZFPriceSystom*> *)allPriceSystom
{
    if (!self.priceSystomList) {
        self.priceSystomList =
        [self loadDataFormPath:self.priceSystomPath
                      withFile:self.priceSystomFile];
    }
    return self.priceSystomList;
}

- (NSArray<ZFDishesGroup*> *)allDishesGroup
{
    if (!self.dishesGroupList) {
        self.dishesGroupList =
        [self loadDataFormPath:self.dishesGroupPath
                      withFile:self.dishesGroupFile];
    }
    return self.dishesGroupList;
}
//save
- (BOOL)saveBill:(ZFBill*)bill
{
    BOOL ret = [self saveDataToPath:self.billPath
                            andFile:self.billFile
                           withData:bill
                            withKey:bill.identifier];
    if (ret) {
        self.billList =[self loadDataFormPath:self.billPath
                                     withFile:self.billFile];
    }
    return ret;
}

- (BOOL)saveBillStatus:(ZFBillStatus*)billStatus
{
    BOOL ret = [self saveDataToPath:self.billStatusPath
                            andFile:self.billStatusFile
                           withData:billStatus
                            withKey:billStatus.identifier];
    if (ret) {
        self.billStatusList =
        [self loadDataFormPath:self.billStatusPath
                      withFile:self.billStatusFile];
        NSArray *fitter = self.billList.copy;
        NSPredicate *pre =[NSPredicate predicateWithFormat:@"status.identifier == %@", billStatus.identifier];
        NSArray *reult = [fitter filteredArrayUsingPredicate:pre];
        BOOL need = NO;
        for (ZFBill *bill in reult) {
            if (![bill.status.name isEqualToString:billStatus.name]) {
                ZFBill*save = bill.mutableCopy;
                save.status.name = billStatus.name;
                if ([self saveBill:save]) {
                    bill.status.name = save.status.name;
                    need = YES;
                }
            }
        }
        if (need) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBillNeedUpdateUINotification object:self userInfo:nil];
        }
    }
    return ret;
}

- (BOOL)savePriceSystom:(ZFPriceSystom*)systom
{
    BOOL ret = [self saveDataToPath:self.priceSystomPath
                            andFile:self.priceSystomFile
                           withData:systom
                            withKey:systom.identifier];
    if (ret) {
        self.priceSystomList =
        [self loadDataFormPath:self.priceSystomPath
                      withFile:self.priceSystomFile];
        
        NSArray *fitter = self.billList.copy;
        NSPredicate *pre =[NSPredicate predicateWithFormat:@"systomId == %@", systom.identifier];
        NSArray *reult = [fitter filteredArrayUsingPredicate:pre];
        BOOL need = NO;
        for (ZFBill *bill in reult) {
            if (![bill.systomName isEqualToString:systom.name]) {
                ZFBill*save = bill.mutableCopy;
                save.systomName = systom.name;
                if ([self saveBill:save]) {
                    bill.systomName = save.systomName;
                    need = YES;
                }
            }
        }
        if (need) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBillNeedUpdateUINotification object:self userInfo:nil];
        }
    }
    return ret;
}

- (BOOL)saveDishesGroup:(ZFDishesGroup*)group
{
    BOOL ret = [self saveDataToPath:self.dishesGroupPath
                            andFile:self.dishesGroupFile
                           withData:group
                            withKey:group.identifier];
    if (ret) {
        self.dishesGroupList =
        [self loadDataFormPath:self.dishesGroupPath
                      withFile:self.dishesGroupFile];
        
        BOOL need = NO;
        for (ZFPriceSystom *systom in self.priceSystomList) {
            NSArray * fitter = systom.group.mutableCopy;
            NSPredicate *pre =[NSPredicate predicateWithFormat:@"identifier == %@", group.identifier];
            NSArray *result = [fitter filteredArrayUsingPredicate:pre];
            for (ZFDishesGroup*priceGroup in result) {
                priceGroup.name = group.name;
            }
            if (result.count) {
                ZFPriceSystom*save = systom.mutableCopy;
                save.group = fitter;
                if ([self savePriceSystom:save]) {
                    systom.group = save.group;
                    need =YES;
                }
            }
        }
        if (need) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPriceSystomNeedUpdateUINotification object:self userInfo:nil];
        }
       
    }
    return ret;
}

//delete
- (BOOL)deleteBill:(ZFBill*)bill
{
    BOOL ret = [self deleteDataToPath:self.billPath
                              andFile:self.billFile
                              withKey:bill.identifier];
    if (ret) {
        self.billList =[self loadDataFormPath:self.billPath
                                     withFile:self.billFile];
    }
    return ret;
}

- (BOOL)deleteBillStatus:(ZFBillStatus*)billStatus
{
    BOOL ret = [self deleteDataToPath:self.billStatusPath
                              andFile:self.billStatusFile
                              withKey:billStatus.identifier];
    if (ret) {
        self.billStatusList =
        [self loadDataFormPath:self.billStatusPath
                      withFile:self.billStatusFile];
    }
    return ret;
}

- (BOOL)deletePriceSystom:(ZFPriceSystom*)systom
{
    BOOL ret = [self deleteDataToPath:self.priceSystomPath
                              andFile:self.priceSystomFile
                              withKey:systom.identifier];
    if (ret) {
        self.priceSystomList =
        [self loadDataFormPath:self.priceSystomPath
                      withFile:self.priceSystomFile];
    }
    return ret;
}

- (BOOL)deleteDishesGroup:(ZFDishesGroup*)group
{
    BOOL ret = [self deleteDataToPath:self.dishesGroupPath
                              andFile:self.dishesGroupFile
                              withKey:group.identifier];
    if (ret) {
        self.dishesGroupList =
        [self loadDataFormPath:self.dishesGroupPath
                      withFile:self.dishesGroupFile];
        
        BOOL need = NO;
        for (ZFPriceSystom *systom in self.priceSystomList) {
            NSMutableArray *fitter = [NSMutableArray arrayWithArray:systom.group];
            NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
            for (int i=0; i<fitter.count; i++) {
                ZFDishesGroup *priceGrup = fitter[i];
                if ([priceGrup.identifier isEqualToString:group.identifier]) {
                    [set addIndex:i];
                }
            }
            if (set.count) {
                [fitter removeObjectsAtIndexes:set];
                ZFPriceSystom *save = systom.mutableCopy;
                save.group = fitter;
                if ([self savePriceSystom:save]) {
                    systom.group = save.group;
                    need=YES;
                }
            }
        }
        if (need) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPriceSystomNeedUpdateUINotification object:self userInfo:nil];
        }
    }
    return ret;
}

- (void)synchronize
{
    
}

@end
