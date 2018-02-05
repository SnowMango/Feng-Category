//
//  MiniPlayerView.m
//  LayoutTest
//
//  Created by zhengfeng on 2017/10/23.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "MiniPlayerView.h"

@interface MiniPlayerView ()

@end

@implementation MiniPlayerView

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
    self.enbleMoveArea = self.frame;
    UIPanGestureRecognizer * pan =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

- (void)setEnbleMoveArea:(CGRect)enbleMoveArea
{
    CGFloat width = MAX(CGRectGetWidth(enbleMoveArea), CGRectGetWidth(self.frame));
    CGFloat height = MAX(CGRectGetHeight(enbleMoveArea), CGRectGetHeight(self.frame));
    CGRect area = {enbleMoveArea.origin, {width, height}};
    _enbleMoveArea = area;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.enbleMoveArea = self.enbleMoveArea;
}


- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint p = [pan translationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        self.transform = CGAffineTransformMakeTranslation(p.x, p.y);
    }else{
        CGFloat minX = CGRectGetMinX(self.enbleMoveArea);
        CGFloat maxX = CGRectGetMaxX(self.enbleMoveArea) - CGRectGetWidth(self.frame);
        CGFloat minY = CGRectGetMinY(self.enbleMoveArea);
        CGFloat maxY = CGRectGetMaxY(self.enbleMoveArea) - CGRectGetHeight(self.frame);
        CGRect rect = self.frame;
        CGRect moveRect = self.frame;
        
        rect.origin.x += p.x;
        moveRect.origin.x += p.x;
        BOOL animate = NO;
        if (CGRectGetMinX(rect)< minX) {
            rect.origin.x = minX;
            animate =YES;
        }
        if (rect.origin.x > maxX) {
            rect.origin.x = maxX;
            animate =YES;
        }
        
        rect.origin.y += p.y;
        moveRect.origin.y += p.y;
        if (CGRectGetMinY(rect) < minY) {
            rect.origin.y = minY;
            animate =YES;
        }
        if (rect.origin.y > maxY) {
            rect.origin.y = maxY;
            animate =YES;
        }
        
        if (animate) {
            self.frame = moveRect;
            self.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = rect;
            }];
        }else{
            self.frame = rect;
            self.transform = CGAffineTransformIdentity;
        }
    }
}

@end
