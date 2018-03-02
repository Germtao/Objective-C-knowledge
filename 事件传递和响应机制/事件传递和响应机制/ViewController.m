//
//  ViewController.m
//  事件传递和响应机制
//
//  Created by TT on 2018/3/2.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "ViewController.h"
#import "TGView.h"

@interface ViewController ()

@property (nonatomic, strong) TGView *touchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.touchView];
    
}

#pragma mark - UIResponder 内部触摸方法

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"======开始触摸");
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"------触摸移动");
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"++++++触摸结束");
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"******触摸打断");
//}

- (TGView *)touchView {
    if (!_touchView) {
        _touchView = [[TGView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _touchView.backgroundColor = [UIColor redColor];
    }
    return _touchView;
}

@end
