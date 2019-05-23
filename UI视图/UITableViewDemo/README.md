# 数据源同步问题

### 解决方案

1. 并发访问、数据拷贝

![并发访问 & 数据拷贝](https://github.com/Germtao/Objective-C-knowledge/blob/master/UI%E8%A7%86%E5%9B%BE/%E5%B9%B6%E5%8F%91%E8%AE%BF%E9%97%AE%E3%80%81%E6%95%B0%E6%8D%AE%E6%8B%B7%E8%B4%9D.png)

2. 串行队列

![串行队列](https://github.com/Germtao/Objective-C-knowledge/blob/master/UI%E8%A7%86%E5%9B%BE/%E4%B8%B2%E8%A1%8C%E9%98%9F%E5%88%97.png)

---

# UIView 和 CALayer

![UIView和CALayer](https://github.com/Germtao/Objective-C-knowledge/blob/master/UI%E8%A7%86%E5%9B%BE/UIView%E5%92%8CCALayer.png)

### 两者职责的分工

* `UIView`为其提供内容，以及负责处理触摸等事件，参与响应链。
* `CALayer`负责显示内容contents

---

# 事件传递与视图响应链

![事件传递与视图响应链](https://github.com/Germtao/Objective-C-knowledge/blob/master/UI%E8%A7%86%E5%9B%BE/%E4%BA%8B%E4%BB%B6%E4%BC%A0%E9%80%92%E4%B8%8E%E8%A7%86%E5%9B%BE%E5%93%8D%E5%BA%94%E9%93%BE.png)

> ViewC2接收事件 -不响应-> ViewB2 -不响应-> ViewA -不响应-> ... -> UIApplication

**🐷: 该事件最后无视图响应，不会导致崩溃，只是无响应（该事件未发生）**

### 事件传递
* `- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event;`
* `- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event;`

1. 流程图
![事件传递流程图](https://github.com/Germtao/Objective-C-knowledge/blob/master/UI%E8%A7%86%E5%9B%BE/%E4%BA%8B%E4%BB%B6%E4%BC%A0%E9%80%92%E6%B5%81%E7%A8%8B.png)

2. `hitTest:withEvent:`的系统实现

![hitTest:withEvent](https://github.com/Germtao/Objective-C-knowledge/blob/master/UI%E8%A7%86%E5%9B%BE/hitTestwithEvent%E7%9A%84%E7%B3%BB%E7%BB%9F%E5%AE%9E%E7%8E%B0.png)

3. 代码实现

- 方形按钮指定区域接收事件响应
```
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
```

### 视图事件响应

- `- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;`
- `- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;` 
- `- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;`

---

# 图像显示原理

