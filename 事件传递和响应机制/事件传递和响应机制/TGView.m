//
//  TGView.m
//  事件传递和响应机制
//
//  Created by TT on 2018/3/2.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "TGView.h"

@implementation TGView

#pragma mark - UITouch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"===== 开始触摸 %@", touches);
    // 1. 先做自己的事
    self.backgroundColor = [UIColor cyanColor];
    
    // 2. 再调用系统的默认做法，再把事件交给上一个响应者处理
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"+++++ 触摸移动");
    // 让view跟随手指移动而移动
    UITouch *touch = [touches anyObject];
    
    // 获取当前触摸点的位置
    CGPoint currentPoint = [touch locationInView:self];
    // 获取上个触摸点的位置
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    // 获取x轴上偏移量
    CGFloat offsetX = currentPoint.x - previousPoint.x;
    // 获取y轴上偏移量
    CGFloat offsetY = currentPoint.y - previousPoint.y;
    
    /**
       修改控件的形变或者frame,center,就可以控制控件的位置
       形变也是相对上一次形变(平移)
       CGAffineTransformMakeTranslation:会把之前形变给清空,重新开始设置形变参数
       make:相对于最原始的位置形变
       CGAffineTransform t:相对这个t的形变的基础上再去形变
       如果相对哪个形变再次形变,就传入它的形变
     */
    self.transform = CGAffineTransformTranslate(self.transform, offsetX, offsetY);
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"----- 触摸结束");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"***** 触摸取消");
}

@end
