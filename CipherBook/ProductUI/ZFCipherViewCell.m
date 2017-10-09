//
//  ZFCipherViewCell.m
//  CipherBook
//
//  Created by 郑丰 on 2017/10/2.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFCipherViewCell.h"

@implementation ZFCipherViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.titleLb =[[UILabel alloc] initWithFrame:self.contentView.bounds];
    self.titleLb.textColor =[UIColor blackColor];
    self.titleLb.textAlignment = NSTextAlignmentCenter;
    self.titleLb.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.titleLb];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLb.frame = self.bounds;
}
- (void)setClipher:(ZFCipher *)clipher
{
    _clipher = clipher;
    self.titleLb.text = _clipher.title;
}
@end
