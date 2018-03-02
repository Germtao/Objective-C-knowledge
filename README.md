# Objective-C-knowledge
主要记录 objective-c 一些基础知识

## iOS中的事件

iOS中的事件大致分为以下3类：

1. 触摸事件
2. 加速计事件
3. 远程控制事件

### 响应者对象（UIResponder）

在iOS中不是任何对象都能处理事件，只有继承了UIResponder的对象才能接受并处理事件，我们称之为“响应者对象”。以下都是继承自UIResponder的，所以都能接收并处理事件。

 · UIApplication
 · UIViewController
 · UIView

那么为什么继承自UIResponder的类能够接收并处理事件呢？

UIResponder中提供了以下4个对象方法来处理触摸事件：
```
UIResponder内部提供了以下方法来处理事件触摸事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
加速计事件
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;
远程控制事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;
```
### UIView 触摸事件

#### 1. UITouch 对象
```
1. 当用户用一根手指触摸屏幕时，会创建一个与手指相关的UITouch对象
2. 一根手指对应一个UITouch对象
3. 如果两根手指同时触摸一个view，那么view只会调用一次touchesBegan:withEvent:方法，touches参数中装着2个UITouch对象
4. 如果这两根手指一前一后分开触摸同一个view，那么view会分别调用2次touchesBegan:withEvent:方法，并且每次调用时的touches参数中只包含一个UITouch对象
```

#### 2. UITouch 作用
```
1. 保存着跟手指相关的信息，比如触摸的位置、时间、阶段
2. 当手指移动时，系统会更新同一个UITouch对象，使之能够一直保存该手指在的触摸位置
3. 当手指离开屏幕时，系统会销毁相应的UITouch对象
```

### 3. UITouch 属性
```
触摸产生时所处的窗口
@property(nonatomic,readonly,retain) UIWindow *window;

触摸产生时所处的视图
@property(nonatomic,readonly,retain) UIView *view;

短时间内点按屏幕的次数，可以根据tapCount判断单击、双击或更多的点击
@property(nonatomic,readonly) NSUInteger tapCount;

记录了触摸事件产生或变化时的时间，单位是秒
@property(nonatomic,readonly) NSTimeInterval timestamp;

当前触摸事件所处的状态
@property(nonatomic,readonly) UITouchPhase phase;
```

### 4. UITouch 方法
```
/** 返回值表示触摸在view上的位置
       这里返回的位置是针对view的坐标系的（以view的左上角为原点(0, 0)）
       调用时传入的view参数为nil的话，返回的是触摸点在UIWindow的位置 */
(CGPoint)locationInView:(UIView *)view;

// 该方法记录了前一个触摸点的位置
(CGPoint)previousLocationInView:(UIView *)view;
```

UIView跟随手指移动而移动的代码实现：
```
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
```
