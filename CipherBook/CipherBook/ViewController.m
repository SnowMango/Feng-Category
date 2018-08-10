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
#import <CommonCrypto/CommonDigest.h>
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

//@property (nonatomic, strong) ZFCipherView *clipherView;
@property (nonatomic, weak) IBOutlet ZFCipherView *clipherView;
@end

@implementation ViewController
- (IBAction)changeStyle:(UISegmentedControl*)sender {
    self.clipherView.style = sender.selectedSegmentIndex;

}

- (NSString *)MD5:(NSString *)mdStr
{
    const char *original_str = [mdStr UTF8String];
    UInt8 result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self testShow];
}


- (void)testShow
{
//    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [[ZFCipherManager defaultManager] addCipherWithData:nil];
    }

    self.clipherView.items = [[ZFCipherManager defaultManager] allCipher];
    self.clipherView.style = ZFCipherViewStyleFast;
    [self.view addSubview:self.clipherView];
    [self.clipherView reloadData];
    [self.view sendSubviewToBack:self.clipherView];
}


@end

ZFNetwork ZFNetworkType(void){
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
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


