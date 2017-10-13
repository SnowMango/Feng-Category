//
//  ViewController.m
//  CipherBook
//
//  Created by zhengfeng on 2017/9/25.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ViewController.h"
#import "ZFCipher.h"
#import "ZFCipherManager.h"
typedef enum : NSUInteger {
    NetworkNone,
    Network2G,
    Network3G,
    Network4G,
    NetworkLTE,
    NetworkWIFI
} ZFNetwork;
ZFNetwork ZFNetworkType(void);

#import "ZFCipherView.h"

BOOL saveCipher(NSString *path, NSData* dat, NSString*fileName)
{
    NSString *filePath = [path stringByAppendingFormat:@"/%@", fileName];
    NSError * err;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&err]){
            NSLog(@"%@",err);
            return NO;
        }
    }
    return [[NSFileManager defaultManager] createFileAtPath:filePath contents:dat attributes:nil];
}

@interface ViewController ()

@property (nonatomic, strong) ZFCipherView *clipherView;

@end

@implementation ViewController
- (IBAction)changeStyle:(UISegmentedControl*)sender {
    self.clipherView.style = sender.selectedSegmentIndex;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self testShow];
}


- (void)testShow
{
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [[ZFCipherManager defaultManager] addCipherWithData:nil];
    }
    self.clipherView = [[ZFCipherView alloc] initWithFrame:self.view.bounds];
    self.clipherView.items = [[ZFCipherManager defaultManager] allCipher];
    self.clipherView.style = ZFCipherViewStyleCard;
    [self.view addSubview:self.clipherView];
    [self.clipherView reloadData];
    [self.view sendSubviewToBack:self.clipherView];
}


@end

ZFNetwork ZFNetworkType(void){
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    id dataNetworkItemView = nil;

    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
    ZFNetwork network = [[dataNetworkItemView valueForKey:@"dataNetworkType"] integerValue];
    return network;
}


