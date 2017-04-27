//
//  HandWriteView.m
//  HandWriteDemo
//
//  Created by jianglihui on 2017/4/26.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "BezierHandWriteView.h"

@interface BezierHandWriteView ()

@property (strong)  NSMutableArray *touchArray;  //单前绘制的点阵
@property (strong)  NSMutableArray *allTouchArray; //总绘制点阵

@end

@implementation BezierHandWriteView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.allTouchArray = [NSMutableArray array];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //1.获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.设置当前上下问路径
    CGContextSetLineWidth(context, 3);
    [[UIColor redColor] setStroke];
    [[UIColor blueColor] setFill];
    

    for (NSArray *array in self.allTouchArray) {
        NSArray *resultArray = [self calucatePath:array];
        
        for (int i = 0; i < resultArray.count; i++) {
            NSDictionary *dic = [resultArray objectAtIndex:i];
            if (dic) {
                CGPoint point1 = CGPointFromString([dic objectForKey:@"point1"]);
                CGPoint point2 = CGPointFromString([dic objectForKey:@"point2"]);
                CGPoint point3 = CGPointFromString([dic objectForKey:@"point3"]);
                CGPoint point4 = CGPointFromString([dic objectForKey:@"point4"]);
                UIBezierPath *path1 = [UIBezierPath bezierPath];
                path1.lineWidth = 3.0;
                path1.lineCapStyle = kCGLineCapRound;  //线条拐角
                path1.lineJoinStyle = kCGLineCapRound;  //终点处理
                [path1 moveToPoint:point1];
                // [path1 setLineWidth:5];
                [path1 addCurveToPoint:point4 controlPoint1:point2 controlPoint2:point3];
                [path1 stroke];
            }
        }
    }
   
    
    //关闭路径
    CGContextClosePath(context);
    //4.绘制路径
    CGContextDrawPath(context, kCGPathFillStroke);
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchArray = [NSMutableArray array];
    [self.allTouchArray addObject:self.touchArray];
    CGPoint pt = [[touches anyObject] locationInView:self];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
    [self setNeedsDisplay];
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self];
    [self.touchArray addObject:NSStringFromCGPoint(pt)];
    
    [self setNeedsDisplay];
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
    
    return array;
}

@end
