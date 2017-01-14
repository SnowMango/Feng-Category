//
//  DrawView.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/11.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "DrawView.h"


@interface DrawView ()
@property BOOL Flip;
@property (nonatomic) UIImageView *imgView;
@end

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      _imgView =  [[UIImageView alloc] init];
        [self addSubview:_imgView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _imgView.frame = CGRectMake(0, 100, 80, 80);
    _imgView.backgroundColor = [UIColor blackColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.Flip = !self.Flip;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
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
    // 绘制线段
    [self drawLineDash];
    // 绘制曲线
    [self drawCurve];
    // 绘制圆形
    [self drawCircleAtX:120 Y:170];
    [self drawCircleAtX:200 Y:170];
    
    UIImage *image = [UIImage imageNamed:@"login_1"];
    [self drawImage:image inRect:rect];
    
    UIGraphicsBeginImageContext(rect.size);
    [self drawEllipse];
    // 绘制三角
    [self drawTriangle];
    // 绘制矩形
    [self drawRectangle1];
    [self drawRectangle2];
    // 绘制圆角矩形
    [self drawArcRectangle1];
    // 绘制曲线
    [self drawCurve];
    // 绘制圆形
    [self drawCircleAtX:120 Y:170];
    [self drawCircleAtX:200 Y:170];
    // 绘制线段
    [self drawLineDash];
    [self drawImage:image inRect:rect];
    self.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}



#pragma mark - 绘制矩形
- (void)drawRectangle1 {
    // 定义矩形的rect
    CGRect rectangle = CGRectMake(100, 290, 120, 25);
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 在当前路径下添加一个矩形路径
    CGContextAddRect(ctx, rectangle);
    // 设置试图的当前填充色
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    // 绘制当前路径区域
    CGContextFillPath(ctx);
}

- (void)drawRectangle2 {
    
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGPoint aPoints[5];
    aPoints[0] =CGPointMake(100, 290);
    aPoints[1] =CGPointMake(220, 290);
    aPoints[2] =CGPointMake(220, 315);
    aPoints[3] =CGPointMake(100, 315);
    aPoints[4] =CGPointMake(100, 290);
    CGContextAddLines(context, aPoints, 5);
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - 绘制圆角矩形
- (void)drawArcRectangle1 {
    
    float fw = 80;
    float fh = 70;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, 120, 300);  // 开始坐标右边开始
    CGContextAddArcToPoint(context, 200, 300 , 200, 340 , 0); // 右下角

    CGContextAddArcToPoint(context, 200, 300 + fh , 120, 300 + fh , fw/2.0); // 右下角
    CGContextAddArcToPoint(context, 120, 300 + fh, 120, 300, fw/2.0); // 左下角
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}


#pragma mark - 绘制线段
- (void)drawLineDash {
    // 获取当前图形，视图推入堆栈的图形
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIColor *lineColor = [UIColor whiteColor];
    // 设置图形描边颜色
    [[lineColor colorWithAlphaComponent:0.5] setStroke];
    // 设置图形的线宽
    CGContextSetLineWidth(context, 4);
    // 设置图形的线段格式
    CGContextSetLineDash(context, 0, (CGFloat[]){6, 1, 5, 3}, 4);
    for (int i = 0; i < 4; i++) {
        CGFloat x = 240 + i*8;
        CGFloat y = 100 ;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context,x, y + 90);
        // 根据当前路径，宽度及颜色绘制线
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);

}


#pragma mark - 绘制椭圆
- (void)drawEllipse {
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 定义其rect
    CGRect rectangle = CGRectMake(10, 100, 300, 280);
    // 在当前路径下添加一个椭圆路径
    CGContextAddEllipseInRect(ctx, rectangle);
    // 设置当前视图填充色
    CGContextSetFillColorWithColor(ctx, [UIColor orangeColor].CGColor);
    // 绘制当前路径区域
    CGContextFillPath(ctx);
}
#pragma mark - 绘制三角形
- (void)drawTriangle {
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    /**
     *  @brief 在指定点开始一个新的子路径 参数按顺序说明
     */
    CGContextMoveToPoint(ctx, 160, 220);
    /**
     *  @brief 在当前点追加直线段，参数说明与上面一样
     */
    CGContextAddLineToPoint(ctx, 190, 260);
    CGContextAddLineToPoint(ctx, 130, 260);
    // 关闭并终止当前路径的子路径，并在当前点和子路径的起点之间追加一条线
    CGContextClosePath(ctx);
    // 设置当前视图填充色
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    // 绘制当前路径区域
    CGContextFillPath(ctx);
}

#pragma mark - 绘制曲线
- (void)drawCurve {
    
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 创建一个新的空图形路径。
    CGContextBeginPath(ctx);
    /**
     *  @brief 在指定点开始一个新的子路径 参数按顺序说明
     */
    CGContextMoveToPoint(ctx, 160, 100);
    
    /**
     *  @brief 在指定点追加二次贝塞尔曲线，通过控制点和结束点指定曲线。
     *         关于曲线的点的控制见下图说明，图片来源苹果官方网站。参数按顺序说明
     *  @param c   当前图形
     *  @param cpx 曲线控制点的x坐标
     *  @param cpy 曲线控制点的y坐标
     *  @param x   指定点的x坐标值
     *  @param y   指定点的y坐标值
     *
     */
    CGContextAddQuadCurveToPoint(ctx, 160, 50, 190, 50);
    // 设置图形的线宽
    CGContextSetLineWidth(ctx, 20);
    
    // 设置图形描边颜色
    [[UIColor brownColor] setStroke];
    
    // 根据当前路径，宽度及颜色绘制线
    CGContextStrokePath(ctx);
}

#pragma mark - 以指定中心点绘制圆弧
- (void)drawCircleAtX:(float)x Y:(float)y {
    
    // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 创建一个新的空图形路径。
    [[UIColor blackColor] setFill];
    
    /**
     *  @brief 在当前路径添加圆弧 参数按顺序说明
     *
     *  @param c           当前图形
     *  @param x           圆弧的中心点坐标x
     *  @param y           曲线控制点的y坐标
     *  @param radius      指定点的x坐标值
     *  @param startAngle  弧的起点与正X轴的夹角，
     *  @param endAngle    弧的终点与正X轴的夹角
     *  @param clockwise   指定1创建一个顺时针的圆弧，或是指定0创建一个逆时针圆弧
     *
     */
    CGContextAddArc(ctx, x, y, 20, 0, 2 * M_PI, 1);
    
    //绘制当前路径区域
    CGContextFillPath(ctx);
}

#pragma mark - 绘制图片
- (void)drawImage:(UIImage *)image inRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, self.frame.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGImageRef imageRef = image.CGImage;
    CGContextSaveGState(ctx);
    CGRect touchRect = CGRectMake(160 - image.size.width/2.0, 200, image.size.width, image.size.height);
    CGContextDrawImage(ctx, touchRect, imageRef);
    CGContextRestoreGState(ctx);
    
    CGContextTranslateCTM(ctx, 0, self.frame.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
}
@end
