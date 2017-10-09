//
//  ZFCipherViewCell.h
//  CipherBook
//
//  Created by 郑丰 on 2017/10/2.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCipher.h"
@interface ZFCipherViewCell : UICollectionViewCell

@property (strong, nonatomic) ZFCipher* clipher;

@property (strong, nonatomic) UILabel * titleLb;
@end
