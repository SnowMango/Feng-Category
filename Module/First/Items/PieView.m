//
//  PieView.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "PieView.h"

@implementation PieView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor clearColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2.5);
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOpacity = 0.9;
    }
    return self;
}


- (void)realoadData
{
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat theHalf = CGRectGetWidth(rect)/2.0;
    CGFloat lineWidth = theHalf;
    if ([self.delegate respondsToSelector:@selector(centerCircleRadius:)]) {
        lineWidth -= [self.delegate centerCircleRadius:self];
        lineWidth = lineWidth <0? 0 : lineWidth;
        lineWidth = lineWidth > theHalf? theHalf : lineWidth;
    }
    CGContextSetLineWidth(context, lineWidth);
    CGFloat radius = theHalf- lineWidth/2.0;
    CGPoint center = CGPointMake(CGRectGetWidth(rect)/2.0, CGRectGetHeight(rect)/2.0);
    NSInteger count = [self.dataSource numberOfSlicesInPieChartView:self];
    if (count <=0) {
        return;
    }
    double values[count],sum = 0;
    for (int i = 0 ; i< count; i++) {
        double ivalue = [self.dataSource pieChartView:self valueForSliceAtIndex:i];
        values[i] = ivalue;
        sum += ivalue;
    }
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle;
    for (int i = 0 ; i< count; i++) {
        double value = values[i];
        UIColor * color =[self.dataSource pieChartView:self colorForSliceAtIndex:i];
        [color setStroke];
        endAngle = startAngle + M_PI*2*value/sum;
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, false);
        CGContextStrokePath(context);
        startAngle = endAngle;
    }
}

@end

@implementation PieShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pie = [[PieView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetWidth(frame))];
        self.pie.delegate = self;
        self.pie.dataSource = self;
        [self addSubview:self.pie];
        
        self.numberSlider = [[UISlider alloc] initWithFrame:CGRectMake(15 + 70, CGRectGetMaxY(self.pie.frame) +10,CGRectGetWidth(frame) -90 , 40)];
        self.numberSlider.maximumValue = 200;
        self.numberSlider.minimumValue = 0;
        self.numberSlider.tag = 1;
        [self.numberSlider addTarget:self action:@selector(chageValue:) forControlEvents:UIControlEventValueChanged];
        self.numberSlider.value = arc4random()%(int)(self.numberSlider.maximumValue - self.numberSlider.minimumValue);
        [self addSubview:self.numberSlider];
        self.centerRadius = [[UISlider alloc] initWithFrame:CGRectMake(15 + 70, CGRectGetMaxY(self.numberSlider.frame) + 10,CGRectGetWidth(frame) - 90, 40)];
        self.centerRadius.maximumValue = CGRectGetWidth(self.pie.frame)/2.0;
        self.centerRadius.minimumValue = 0;
        self.centerRadius.tag = 2;
        self.centerRadius.value = arc4random()%(int)(self.centerRadius.maximumValue - self.centerRadius.minimumValue);
        [self.centerRadius addTarget:self action:@selector(chageValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.centerRadius];
        
        self.numberLabel =[[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(self.numberSlider.frame), 70, 40)];
        self.numberLabel.font = [UIFont systemFontOfSize:11];
        self.numberLabel.text =  [NSString stringWithFormat:@"数量:%d",(int)self.numberSlider.value];
        [self addSubview:self.numberLabel];
        self.centerRadiusLabel =[[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(self.centerRadius.frame), 70, 40)];
        self.centerRadiusLabel.font = [UIFont systemFontOfSize:11];
        self.centerRadiusLabel.text =  [NSString stringWithFormat:@"半径:%.2f",self.centerRadius.value];
        [self addSubview:self.centerRadiusLabel];

    }
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)chageValue:(UISlider *)slider
{
    [self.pie realoadData];
    self.numberLabel.text =  [NSString stringWithFormat:@"数量:%d",(int)self.numberSlider.value];
    self.centerRadiusLabel.text =  [NSString stringWithFormat:@"半径:%.2f",self.centerRadius.value];
}

#pragma mark - PieViewDataSource
- (NSInteger)numberOfSlicesInPieChartView:(PieView *)pieView
{
    return self.numberSlider.value;
}
- (double)pieChartView:(PieView*)pieView valueForSliceAtIndex:(NSInteger) index
{
    return 360.0/self.numberSlider.value;
}
- (UIColor *)pieChartView:(PieView*)pieView colorForSliceAtIndex:(NSInteger) index
{
    float r = (arc4random()%234 + 20)/255.0;
    float g = (arc4random()%234 + 20)/255.0;
    float b = (arc4random()%234 + 20)/255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
#pragma mark - PieViewDelegete
- (CGFloat)centerCircleRadius:(PieView *)pieView
{
    return self.centerRadius.value;
}

@end
