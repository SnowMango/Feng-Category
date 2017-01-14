//
//  BezierView.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/11.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "BezierView.h"
@interface BezierView ()
@property BOOL Flip;

@end

@implementation BezierView

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.Flip = !self.Flip;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.Flip) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, 0, self.frame.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
    }
    
    
    [self drawEllipse];
    // 绘制三角
    [self drawTriangle];
    // 绘制矩形
    [self drawRectangle1];
    [self drawRectangle2];
    // 绘制圆角矩形
    [self drawArcRectangle1];
    [self drawArcRectangle2];
    // 绘制曲线
    [self drawCurve];
    // 绘制圆形
    [self drawCircleAtX:120 Y:170];
    [self drawCircleAtX:200 Y:170];
    // 绘制线段
    [self drawLineDash];
    
}

#pragma mark - 绘制矩形
- (void)drawRectangle1 {
    // 定义矩形的rect
    CGRect rectangle = CGRectMake(100, 290, 120, 25);
    UIBezierPath *bezier = [UIBezierPath bezierPathWithRect:rectangle];
    //设置填充区域颜色
    [[UIColor whiteColor] setFill];
    // 开始填充区域
    [bezier fill];
}

#pragma mark - 绘制矩形
- (void)drawRectangle2 {
    
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    [bezier moveToPoint:CGPointMake(100, 290)];
    [bezier addLineToPoint:CGPointMake(220, 290)];
    [bezier addLineToPoint:CGPointMake(220, 315)];
    [bezier addLineToPoint:CGPointMake(100, 315)];
    //设置描边域颜色
    [[UIColor redColor] setStroke];
    // 关闭并终止当前路径的子路径
    [bezier closePath];
    //开始绘制描边
    [bezier stroke];
}

#pragma mark - 绘制圆角矩形
- (void)drawArcRectangle1 {
    
    // 定义矩形的rect
    CGRect rectangle = CGRectMake(120, 300, 80, 70);
    UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:rectangle byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(40, 40)];
    //设置描边域颜色
    [[UIColor redColor] setFill];
    //开始绘制描边
    [bezier fill];
}

- (void)drawArcRectangle2 {
    // 定义矩形的rect
    CGRect rectangle = CGRectMake(110, 265, 100, 20);
//    UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:rectangle byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:rectangle cornerRadius:10];
    //设置描边域颜色
    [[UIColor blackColor] setFill];
    //开始绘制描边
    [bezier fill];
}



#pragma mark - 绘制线段
- (void)drawLineDash {
    
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    bezier.lineWidth = 4;
    [[UIColor whiteColor] setStroke];
    CGFloat dash[4] = {6, 1, 5, 3};
    [bezier setLineDash:dash count:4 phase:0];
    for (int i = 0; i < 4; i++) {
        CGFloat x = 240 + i*8;
        CGFloat y = 100 ;
        [bezier moveToPoint:CGPointMake(x, y)];
        [bezier addLineToPoint:CGPointMake(x, y + 90)];
        //开始绘制描边
        [bezier stroke];
    }
}

#pragma mark - 绘制椭圆
- (void)drawEllipse {
    // 定义其rect
    CGRect rectangle = CGRectMake(10, 100, 300, 280);
    //创建贝塞尔曲线
    UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:rectangle];
    //设置填充区域颜色
    [[UIColor orangeColor] setFill];
    //绘制填充区域
    [bezier fill];
}
#pragma mark - 绘制三角形
- (void)drawTriangle {
    
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    [bezier moveToPoint:CGPointMake(160, 220)];
    [bezier addLineToPoint:CGPointMake(190, 260)];
    [bezier addLineToPoint:CGPointMake(130, 260)];
    //设置填充区域颜色
    [[UIColor blackColor] setFill];
    // 关闭并终止当前路径的子路径
    [bezier closePath];
    // 开始填充区域
    [bezier fill];
}

#pragma mark - 绘制曲线
- (void)drawCurve {
    
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    bezier.lineWidth = 20;
    [[UIColor brownColor] setStroke];
    [bezier moveToPoint:CGPointMake(160, 100)];
    /**
     在指定点追加二次贝塞尔曲线，通过控制点和结束点指定曲线

     @param endPoint 指定点的坐标值
     @param controlPoint  曲线控制点的坐标
     */
    [bezier addQuadCurveToPoint:CGPointMake(190, 50) controlPoint:CGPointMake(160, 50)];
    
    //开始绘制描边
    [bezier stroke];
}

#pragma mark - 以指定中心点绘制圆弧
- (void)drawCircleAtX:(float)x Y:(float)y {
    
    CGFloat radius = 20;
    
//    在当前路径添加圆弧
//    @param center 圆弧的中心点坐标
//    @param radius 圆弧半径
//    @param startAngle  弧的起点与正X轴的夹角，
//    @param endAngle    弧的终点与正X轴的夹角
//    @param clockwise   指定1创建一个顺时针的圆弧，或是指定0创建一个逆时针圆弧
    UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];

    [[UIColor blackColor] setFill];
    [bezier fill];
    
}



@end
