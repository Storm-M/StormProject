//
//  HandWriteView.m
//  HandWriteDemo
//
//  Created by jianglihui on 2017/4/26.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "HandWriteView.h"

@interface HandWriteView ()

@property (strong)  NSMutableArray *touchArray;  //单前绘制的点阵
@property (strong)  NSMutableArray *allTouchArray; //总绘制点阵

@end

@implementation HandWriteView

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
        if ([array count] > 2) { //大于1个点说明有移动，才绘制
            for (int i = 0; i < array.count-1; i++) {
                CGPoint startPoint = CGPointFromString(array[i]);
                CGPoint endPoint = CGPointFromString(array[i+1]);
                CGContextMoveToPoint(context, startPoint.x, startPoint.y);//设置起始点
                CGContextAddLineToPoint(context, endPoint.x, endPoint.y);//增加点
            }
        }
    }
   
//    if ([self.touchArray count] > 2) {
//        for (int i = 0; i < self.touchArray.count-1; i++) {
//            CGPoint startPoint = CGPointFromString(self.touchArray[i]);
//            CGPoint endPoint = CGPointFromString(self.touchArray[i+1]);
//            CGContextMoveToPoint(context, startPoint.x, startPoint.y);//设置起始点
//            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);//增加点
//        }
//    }

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

@end
