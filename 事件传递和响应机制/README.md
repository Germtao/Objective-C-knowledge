## iOS中的事件

iOS中的事件大致分为以下3类：

- 触摸事件
- 加速计事件
- 远程控制事件

### 响应者对象（UIResponder）

在iOS中不是任何对象都能处理事件，只有继承了UIResponder的对象才能接受并处理事件，我们称之为“响应者对象”。以下都是继承自UIResponder的，所以都能接收并处理事件。

- UIApplication
- UIViewController
- UIView

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

### iOS中事件的产生和传递

#### 1. 事件的产生

- 发生触摸事件后，系统会将该事件加入到一个由UIApplication管理的事件队列中，为什么是队列而不是栈？因为队列的特点是FIFO，即先进先出，先产生的事件先处理才符合常理，所以把事件添加到队列。
- UIApplication会从事件队列中取出最前面的事件，并将事件分发下去以便处理，通常，先发送事件给应用程序的主窗口（keyWindow）。
- 主窗口会在视图层次结构中找到一个最合适的视图来处理触摸事件，这也是整个事件处理过程的第一步。
找到合适的视图控件后，就会调用视图控件的touches方法来作具体的事件处理。

#### 2. 事件的传递

- 触摸事件的传递是从父控件传递到子控件
- 也就是UIApplication -> window -> 寻找处理事件最合适的view

> 注意： 如果父控件不能接受触摸事件，那么子控件就不可能接收到触摸事件。

```
##### 应用如何找到最合适的控件来处理事件？

1. 首先判断主窗口（keyWindow）自己是否能接受触摸事件
2. 判断触摸点是否在自己身上
3. 子控件数组中从后往前遍历子控件，重复前面的两个步骤（所谓从后往前遍历子控件，就是首先查找子控件数组中最后一个元素，然后执行1、2步骤）
4. touchView，那么会把这个事件交给这个touchView，再遍历这个touchView的子控件，直至没有更合适的view为止
5. 如果没有符合条件的子控件，那么就认为自己最合适处理这个事件，也就是自己是最合适的view

```
##### UIView 不能接收触摸事件的三种情况：
- 不允许交互：userInteractionEnabled = NO
- 隐藏：hidden = YES，隐藏的控件不能接受事件
- 透明度：如果控件 alpha < 0.01，会直接影响子控件触发事件，alpha：0.0 ~ 0.01

#### 3. 如何寻找最合适的 view？

##### 3.1 底层实现

```
两个重要的方法：
/**
调用时机：只要事件一传递给一个控件,这个控件就会调用该方法
作用：寻找并返回最合适的view(能够响应事件的那个最合适的view)
*/
hitTest:withEvent:
pointInside方法
```

###### 拦截事件处理：
- 正因为 ```hitTest:withEvent:```方法可以返回最合适的view，所以可以通过重写```hitTest:withEvent:```方法，返回指定的view作为最合适的view
- 不管点击哪里，最合适的view都是```hitTest:withEvent:```方法中返回的那个view
- 通过重写```hitTest:withEvent:```，就可以拦截事件的传递过程，想让谁处理事件谁就处理事件
事件传递给谁，就会调用谁的hitTest:withEvent:方法。

> 注 意：如果```hitTest:withEvent:```方法中返回nil，那么调用该方法的控件本身和其子控件都不是最合适的view，也就是在自己身上没有找到更合适的view。那么最合适的view就是该控件的父控件。

###### 所以事件的传递顺序是这样的：
　>　产生触摸事件->UIApplication事件队列->[UIWindow hitTest:withEvent:]->返回更合适的view->[子控件 hitTest:withEvent:]->返回最合适的view
　
　#### 总结
　
　事件处理的整个流程总结：
　```
　1. 触摸屏幕产生触摸事件后，触摸事件会被添加到由UIApplication管理的事件队列中（即，首先接收到事件的是UIApplication）
　2. UIApplication会从事件队列中取出最前面的事件，把事件传递给应用程序的主窗口（keyWindow）
　3. 主窗口会在视图层次结构中找到一个最合适的视图来处理触摸事件。（至此，第一步已完成)
　4. 最合适的view会调用自己的touches方法处理事件
　5. touches默认做法是把事件顺着响应者链条向上抛
　```
　
　事件的传递与响应：
　```
　1. 当一个事件发生后，事件会从父控件传给子控件，也就是说由UIApplication -> UIWindow -> UIView -> initial view,以上就是事件的传递，也就是寻找最合适的view的过程
　
　2. 接下来是事件的响应。首先看initial view能否处理这个事件，如果不能则会将事件传递给其上级视图（inital view的superView）；如果上级视图仍然无法处理则会继续往上传递；一直传递到视图控制器view controller，首先判断视图控制器的根视图view是否能处理此事件；如果不能则接着判断该视图控制器能否处理此事件，如果还是不能则继续向上传 递；（对于第二个图视图控制器本身还在另一个视图控制器中，则继续交给父视图控制器的根视图，如果根视图不能处理则交给父视图控制器处理）；一直到 window，如果window还是不能处理此事件则继续交给application处理，如果最后application还是不能处理此事件则将其丢弃
　
　3. 在事件的响应中，如果某个控件实现了touches...方法，则这个事件将由该控件来接受，如果调用了[supertouches….];就会将事件顺着响应者链条往上传递，传递给上一个响应者；接着就会调用上一个响应者的touches….方法
　```
　
　事件的传递和响应的区别：
　```
　事件的传递是从上到下（父控件到子控件），事件的响应是从下到上（顺着响应者链条向上传递：子控件到父控件
　```
