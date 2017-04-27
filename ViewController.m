//
//  ViewController.m
//  HandWriteDemo
//
//  Created by jianglihui on 2017/4/26.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "ViewController.h"
#import "HandWriteView.h"
#import "BezierHandWriteView.h"
#import "ImageBezierHandWriteView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    HandWriteView *view = [[HandWriteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 400)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    
    BezierHandWriteView *bezierView = [[BezierHandWriteView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width, 400)];
    bezierView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.view addSubview:bezierView];
    
    ImageBezierHandWriteView *imageBezierView = [[ImageBezierHandWriteView alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 400)];
    imageBezierView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self.view addSubview:imageBezierView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
