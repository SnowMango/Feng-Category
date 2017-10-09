//
//  ZFCipherView.h
//  CipherBook
//
//  Created by 郑丰 on 2017/10/2.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCipher.h"

typedef enum : NSUInteger {
    ZFCipherViewStyleList,
    ZFCipherViewStyleCard,
    ZFCipherViewStyleFast,
} ZFCipherViewStyle;


@interface ZFCipherView : UIView

@property (nonatomic) ZFCipherViewStyle style;
@property (strong, nonatomic) UICollectionView *itemsView;
@property (strong, nonatomic) NSArray<ZFCipher*>*items;

- (void)reloadData;
@end
