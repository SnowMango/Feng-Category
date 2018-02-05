//
//  ZFLocalDataManager.h
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"
#import "Model.h"

#define kBillNeedUpdateUINotification @"kBillNeedUpdateUINotification"
#define kPriceSystomNeedUpdateUINotification @"kPriceSystomNeedUpdateUINotification"

@interface ZFLocalDataManager : NSObject
+(ZFLocalDataManager*)shareInstance;

- (ZFBillStatus*)defaultBillStatus;
- (BOOL)setDefaultBillStatus:(ZFBillStatus*)status;

//read
- (NSArray<ZFBill*> *)allBill;

- (NSArray<ZFBillStatus*> *)allBillStatus;

- (NSArray<ZFPriceSystom*> *)allPriceSystom;

- (NSArray<ZFDishesGroup*> *)allDishesGroup;

//save
- (BOOL)saveBill:(ZFBill*)bill;

- (BOOL)saveBillStatus:(ZFBillStatus*)billStatus;

- (BOOL)savePriceSystom:(ZFPriceSystom*)systom;

- (BOOL)saveDishesGroup:(ZFDishesGroup*)group;

//delete
- (BOOL)deleteBill:(ZFBill*)bill;

- (BOOL)deleteBillStatus:(ZFBillStatus*)billStatus;

- (BOOL)deletePriceSystom:(ZFPriceSystom*)systom;

- (BOOL)deleteDishesGroup:(ZFDishesGroup*)group;

- (void)synchronize;
@end
