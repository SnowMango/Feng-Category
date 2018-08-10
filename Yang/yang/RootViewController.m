//
//  RootViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/30.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "RootViewController.h"
#import "ZFLocalDataManager.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"home =%@", NSHomeDirectory());
    
//    [self loadingDefault];
}

- (void)loadingDefault
{
    NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"plist"];
    NSString *docFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DefaultData.plist"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:docFilePath]) {
        NSData *fileData = [fm contentsAtPath:bundleFilePath];
        BOOL finish = NO;
        if ([fm createFileAtPath:docFilePath contents:fileData attributes:nil]) {
            NSDictionary *loading = [NSDictionary dictionaryWithContentsOfFile:docFilePath];
            
            NSArray *priceSystom = loading[@"PriceSystom"];
            NSMutableArray *priceSystomObj= [NSMutableArray array];
            
            NSMutableArray *dishesGroup = [NSMutableArray array];
            for (NSDictionary * systom in priceSystom) {
                ZFPriceSystom *s = [[ZFPriceSystom alloc] init];
                NSArray *groupList = systom[@"group"];
                s.name = systom[@"name"];
                NSMutableArray *groupObj= [NSMutableArray array];
                for (NSDictionary *group in groupList) {
                    ZFDishesGroup *g = [[ZFDishesGroup alloc] init];
                    g.name = group[@"name"];
                    
                    NSArray *priceList = group[@"dishes"];
                    NSMutableArray *dishesObj= [NSMutableArray array];
                    NSMutableArray *dishes = [NSMutableArray array];
                    for (NSDictionary *priceDishes in priceList) {
                        ZFDishes *d = [[ZFDishes alloc] init];
                        d.name = priceDishes[@"name"];
                        d.unit = priceDishes[@"unit"];
                        [dishes addObject:d.mutableCopy];
                        d.price = [priceDishes[@"price"] doubleValue];
                        [dishesObj addObject:d];
                    }
                    g.dishes = dishes;
                    [dishesGroup addObject:g.mutableCopy];
                    g.dishes = dishesObj;
                    [groupObj addObject:g];
                }
                s.group = groupObj;
                [priceSystomObj addObject:s];
            }
            for (ZFPriceSystom *systom  in priceSystomObj) {
                [[ZFLocalDataManager shareInstance] savePriceSystom:systom];
            }
            for (ZFDishesGroup *group  in dishesGroup) {
                [[ZFLocalDataManager shareInstance] saveDishesGroup:group];
            }
            finish = YES;
        }
        if (finish) {
            NSLog(@"初始化成功！");
        }else{
            NSLog(@"初始化失败！");
        }
    }else{
        NSLog(@"已经加载初始化数据！");
    }
}

@end
