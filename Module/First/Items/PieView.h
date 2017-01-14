//
//  PieView.h
//  DemoDev
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieView;

@protocol PieViewDataSource <NSObject>
@required
- (NSInteger)numberOfSlicesInPieChartView:(PieView *)pieView;
- (double)pieChartView:(PieView*)pieView valueForSliceAtIndex:(NSInteger) index;
- (UIColor *)pieChartView:(PieView*)pieView colorForSliceAtIndex:(NSInteger) index;
@optional
- (NSString *)pieChartView:(PieView*)pieView titleForSliceAtIndex:(NSInteger) index;

@end
@protocol PieViewDelegete <NSObject>
- (CGFloat)centerCircleRadius:(PieView*)pieView;

@end

@interface PieView : UIView

- (void)realoadData;

@property (weak, nonatomic) id<PieViewDataSource> dataSource;
@property (weak, nonatomic) id<PieViewDelegete> delegate;
@end


@interface PieShowView : UIView<PieViewDelegete, PieViewDataSource>

@property (nonatomic, strong) PieView * pie;
@property (nonatomic, strong) UISlider * numberSlider;
@property (nonatomic, strong) UISlider * centerRadius;
@property (nonatomic, strong) UILabel * numberLabel;
@property (nonatomic, strong) UILabel * centerRadiusLabel;
@end
