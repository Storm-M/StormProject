//
//  ImageBezierHandWriteView.m
//  HandWriteDemo
//
//  Created by jianglihui on 2017/4/27.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "ImageBezierHandWriteView.h"


@interface ImageBezierHandWriteView ()

@property (strong)  NSMutableArray *touchArray;  //单前绘制的点阵
@property (strong)  NSMutableArray *allTouchArray; //总绘制点阵

@property (strong)  CAShapeLayer *shapeLayer;

@end

@implementation ImageBezierHandWriteView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allTouchArray = [NSMutableArray array];
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchArray = [NSMutableArray array];
    [self.allTouchArray addObject:self.touchArray];
    CGPoint pt = [[touches anyObject] locationInView:self];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
    
    self.shapeLayer = nil;//每次点击把shaperlayer变量置空。一次用户操作就是一个shapelayer
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
    //[self setNeedsDisplay];
    if (!self.shapeLayer) {
        self.shapeLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.shapeLayer];
        self.shapeLayer.frame = self.bounds;                // 与showView的frame一致
        if (0) {
            self.shapeLayer.strokeColor   = [UIColor blackColor].CGColor; //可以使用纯色
        }
        else {
            self.shapeLayer.strokeColor   = [UIColor colorWithPatternImage:[self blendImage:[UIImage imageNamed:@"pencil"] withColor:[UIColor redColor]]].CGColor;//用pencil这张图片来绘制
        }
        
        self.shapeLayer.fillColor     = [UIColor clearColor].CGColor;   // 闭环填充的颜色
        self.shapeLayer.lineCap       = kCALineCapRound;     // lineCap 属性指定线段的末端如何绘制
        self.shapeLayer.lineWidth     = 5;                           // 线条宽度
        self.shapeLayer.strokeStart   = 0.0f;
        self.shapeLayer.strokeEnd     = 1.0f;
    }
    
    [self calucatePath:self.touchArray];
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
    
    //[self setNeedsDisplay];
    [self calucatePath:self.touchArray];
}

- (CGPoint)getPoint:(int)index withTouchArray:(NSArray *)touchArray {
    if (index >= 0 && index < touchArray.count) {
        return CGPointFromString(touchArray[index]);
    }
    return CGPointZero;
}

- (CGFloat)getPenPressure:(int)index {
    return 1;
}


- (NSArray *)calucatePath:(NSArray *)touchArray {
    float offset_x = 0.0f;
    float offset_y = 0.0f;
    float scale = 1;
    
    
    float scaled_pen_thickness =(float) 2;
    float x0, x1, x2, x3, y0, y1, y2, y3, p0, p1, p2, p3;
    float vx01, vy01, vx21, vy21;  // unit tangent vectors 0->1 and 1<-2
    float norm;
    float n_x0, n_y0, n_x2, n_y2; // the normals
    int N = touchArray.count;
    if (N < 2) {
        return nil;
    }
    // the first actual point is treated as a midpoint
    x0 = [self getPoint:0 withTouchArray:touchArray].x * scale + offset_x + 0.1f;
    y0 = [self getPoint:0 withTouchArray:touchArray].y * scale + offset_y;
    p0 = [self getPenPressure:0];
    
    x1 = [self getPoint:1 withTouchArray:touchArray].x * scale + offset_x + 0.1f;
    y1 = [self getPoint:1 withTouchArray:touchArray].y * scale + offset_y;
    p1 = [self getPenPressure:1];
    vx01 = x1 - x0;
    vy01 = y1 - y0;
    // instead of dividing tangent/norm by two, we multiply norm by 2
    norm = sqrt(vx01*vx01 + vy01*vy01 + 0.0001f) * 2.0f;
    vx01 = vx01 / norm * scaled_pen_thickness * p0;
    vy01 = vy01 / norm * scaled_pen_thickness * p0;
    n_x0 = vy01;
    n_y0 = -vx01;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 2; i < N; i++) {
        // (x0,y0) and (x2,y2) are midpoints, (x1,y1) and (x3,y3) are actual points
        x3 =[self getPoint:i withTouchArray:touchArray].x * scale + offset_x;
        y3 = [self getPoint:i withTouchArray:touchArray].y * scale + offset_y;
        p3 = [self getPenPressure:i];
        x2 = (x1 + x3) / 2.0f;
        y2 = (y1 + y3) / 2.0f;
        p2 = (p1 + p3) / 2.0f;
        
        vx21 = x1 - x2;
        vy21 = y1 - y2;
        norm = sqrt(vx21*vx21 + vy21*vy21 + 0.0001f) * 2.0f;
        vx21 = vx21 / norm * scaled_pen_thickness * p2;
        vy21 = vy21 / norm * scaled_pen_thickness * p2;
        n_x2 = -vy21;
        n_y2 = vx21;
        
        NSDictionary *dic = @{@"point1":NSStringFromCGPoint(CGPointMake(x0 + n_x0,y0 + n_y0)),
                              @"point2":NSStringFromCGPoint(CGPointMake(x1 + n_x0, y1 + n_y0)),
                              @"point3":NSStringFromCGPoint(CGPointMake(x1 + n_x2, y1 + n_y2)),
                              @"point4":NSStringFromCGPoint(CGPointMake(x2 + n_x2, y2 + n_y2))};
        [array addObject:dic];
        
        dic = @{@"point1":NSStringFromCGPoint(CGPointMake(x2 + n_x2,y2 + n_y2)),
                @"point2":NSStringFromCGPoint(CGPointMake(x2 + n_x2 - vx21, y2 + n_y2 - vy21)),
                @"point3":NSStringFromCGPoint(CGPointMake(x2 - n_x2 - vx21, y2 - n_y2 - vy21)),
                @"point4":NSStringFromCGPoint(CGPointMake(x2 - n_x2, y2 - n_y2))};
        [array addObject:dic];
        
        
        dic = @{@"point1":NSStringFromCGPoint(CGPointMake(x2 - n_x2,y2 - n_y2)),
                @"point2":NSStringFromCGPoint(CGPointMake(x1 - n_x2, y1 - n_y2)),
                @"point3":NSStringFromCGPoint(CGPointMake(x1 - n_x0, y1 - n_y0)),
                @"point4":NSStringFromCGPoint(CGPointMake(x0 - n_x0, y0 - n_y0))};
        [array addObject:dic];
        
        
        dic = @{@"point1":NSStringFromCGPoint(CGPointMake(x0 - n_x0,y0 - n_y0)),
                @"point2":NSStringFromCGPoint(CGPointMake(x0 - n_x0 - vx01, y0 - n_y0 - vy01)),
                @"point3":NSStringFromCGPoint(CGPointMake(x0 + n_x0 - vx01, y0 + n_y0 - vy01)),
                @"point4":NSStringFromCGPoint(CGPointMake(x0 + n_x0, y0 + n_y0))};
        [array addObject:dic];
        
        
        x0 = x2;   y0 = y2;  p0 = p2;
        x1 = x3;   y1 = y3;  p1 = p3;
        vx01 = -vx21;  vy01 = -vy21;
        n_x0 = n_x2;   n_y0 = n_y2;
    }
    [self setShapeLayerPath:array];
    return array;
}

- (void)setShapeLayerPath:(NSArray *)array {
    if ([array count]) {
        
        UIBezierPath *drawPath = [UIBezierPath bezierPath];
        [drawPath setLineWidth:1];
        for (int i = 0; i < array.count; i++) {
            NSDictionary *dic = [array objectAtIndex:i];
            if (dic) {
                CGPoint point1 = CGPointFromString([dic objectForKey:@"point1"]);
                CGPoint point2 = CGPointFromString([dic objectForKey:@"point2"]);
                CGPoint point3 = CGPointFromString([dic objectForKey:@"point3"]);
                CGPoint point4 = CGPointFromString([dic objectForKey:@"point4"]);
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:point1];
                [path addCurveToPoint:point4 controlPoint1:point2 controlPoint2:point3];
                [drawPath appendPath:path];//把计算出来的贝塞尔曲线统一到一个总路径中去
            }
        }
        
        self.shapeLayer.path = drawPath.CGPath;                    // 从贝塞尔曲线获取到形状
    }
}

- (UIImage *)blendImage:(UIImage *)image withColor:(UIColor *)color {
    UIImage *blendImage = nil;
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]; //设置成临时模式，忽视本身颜色
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, image.size.width, image.size.height)];
    imageView.image = image;
    imageView.tintColor = color; //需要的颜色
    
    UIGraphicsBeginImageContext(imageView.bounds.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    blendImage = UIGraphicsGetImageFromCurrentImageContext();//混合出来的图片
    UIGraphicsEndImageContext();
    return blendImage;
}

@end
