//
//  CustomButton.m
//  Event
//
//  Created by QDSG on 2019/5/22.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.userInteractionEnabled ||
        self.hidden ||
        self.alpha <= 0.01) {
        return nil;
    }
    
    if ([self pointInside:point withEvent:event]) {
        // 遍历当前对象的子视图
        __block UIView *hit = nil;
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 坐标转换
            CGPoint convertPoint = [self convertPoint:point toView:obj];
            
            // 调用子视图的hitTest方法
            hit = [obj hitTest:convertPoint withEvent:event];
            
            // 如果找到了接收事件的对象, 停止遍历
            if (hit) {
                *stop = YES;
            }
        }];
        
        if (hit) {
            return hit;
        } else {
            return self;
        }
    } else {
        return nil;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGFloat x1 = point.x;
    CGFloat y1 = point.y;
    
    CGFloat x2 = self.frame.size.width * 0.5;
    CGFloat y2 = self.frame.size.height * 0.5;
    
    double dis = sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)); // sqrt - 非负平方根
    
    // 在以当前控件中心为圆心, 直径为当前控件宽度的院内
    if (dis <= self.frame.size.width * 0.5) {
        return YES;
    } else {
        return NO;
    }
}



@end
