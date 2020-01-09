# RunLoop

- 概念
- 数据结构
- RunLoop的Mode
- RunLoop的实现机制
- RunLoop与NSTimer
- RunLoop与多线程

## 一、概念

通过内部维护的**事件循环**来对**事件/消息进行管理**的一个对象。

#### 1、事件循环是什么呢？

- 没有消息需要处理时, 休眠以避免资源占用

![1](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/用户态-内核态.png)

- 有消息需要处理时, 立刻被唤醒

![2](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/%E5%86%85%E6%A0%B8%E6%80%81-%E7%94%A8%E6%88%B7%E6%80%81.png)

#### 2、状态切换

![3](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/RunLoop%E6%A6%82%E5%BF%B5%E6%80%BB%E7%BB%93.png)

#### 3、为什么`main`函数不会退出？

```
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```

- `UIApplicationMain`内部默认开启了主线程的`RunLoop`，并执行了一段无限循环的代码（不是简单的for循环或while循环）。

```
//无限循环代码模式(伪代码)
int main(int argc, char * argv[]) {        
    BOOL running = YES;
    do {
        // 执行各种任务，处理各种事件
        // ......
    } while (running);

    return 0;
}
```

- `UIApplicationMain`函数一直没有返回，而是不断地接收处理消息以及等待休眠，所以运行程序之后会保持持续运行状态。

--- 

## 二、数据结构

`NSRunLoop`是`CFRunLoop`的封装，提供了面向对象的API。

- `CFRunLoop`：RunLoop对象

![CFRunLoop](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/CFRunLoop.png)

- `CFRunLoopMode`：运行模式

![CFRunLoopMode](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/CFRunLoopMode.png)

- `CFRunLoopSource`：输入源/事件源

    - `source0`
        
        - 即非基于`port`的，也就是用户触发的事件。
        - 需要手动唤醒线程，将当前线程从内核态切换到用户态。
        
    - `source1`：
    
        - 基于port的，包含一个`mach_port`和一个回调，可监听系统端口和通过内核和其他线程发送的消息。
        - 能主动唤醒`RunLoop`，接收分发系统事件，具备唤醒线程的能力。

- `CFRunLoopTimer`：定时源

    - 基于时间的触发器，基本上说的就是NSTimer，在预设的时间点唤醒RunLoop执行回调。
    - 因为它是基于RunLoop的，因此它不是实时的（就是NSTimer是不准确的。因为RunLoop只负责分发源的消息。如果线程当前正在处理繁重的任务，就有可能导致Timer本次延时，或者少执行一次）。

- `CFRunLoopObserver`：观察者，监听以下时间点：`CFRunLoopActivity`

    - `kCFRunLoopEntry`
        - RunLoop准备启动
    - `kCFRunLoopBeforeTimers`
        - RunLoop将要处理一些Timer相关事件
    - `kCFRunLoopBeforeSources`
        - RunLoop将要处理一些Source事件
    - `kCFRunLoopBeforeWaiting`
        - RunLoop将要进行休眠状态,即将由用户态切换到内核态
    - `kCFRunLoopAfterWaiting`
        - RunLoop被唤醒，即从内核态切换到用户态后
    - `kCFRunLoopExit`
        - RunLoop退出
    - `kCFRunLoopAllActivities`
        - 监听所有状态

![Source/Timer/Observer](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/Source:Timer:Observer.png)

> **各个数据结构之间的关系？**

`n/m`：*代表多*

![数据结构关系](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84%E4%B9%8B%E9%97%B4%E7%9A%84%E5%85%B3%E7%B3%BB.png)

---

## 三、RunLoop的Mode

- *`RunLoop`的各个`Mode`数据不共享*

![RunLoop的Mode](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/RunLoop%E7%9A%84Mode.png)

- 总共是有五种`CFRunLoopMode`:

    - `kCFRunLoopDefaultMode`
        - 默认模式，主线程是在这个运行模式下运行
    - `UITrackingRunLoopMode`
        - 跟踪用户交互事件（用于`ScrollView`追踪触摸滑动，保证界面滑动时不受其他`Mode`影响）
    - `UIInitializationRunLoopMode`
        - 在刚启动App时第进入的第一个Mode，启动完成后就不再使用
    - `GSEventReceiveRunLoopMode`
        - 接受系统内部事件，通常用不到
    - `kCFRunLoopCommonModes`
        - 伪模式，不是一种真正的运行模式，是同步Source/Timer/Observer到多个Mode中的一种解决方案

---

## 四、RunLoop的实现机制

![RunLoop实现机制]()

对于`RunLoop`而言最核心的事情就是保证线程在没有消息的时候休眠，在有消息时唤醒，以提高程序性能。RunLoop这个机制是依靠系统内核来完成的（苹果操作系统核心组件Darwin中的Mach）。

大致逻辑为：

1. 通知观察者`RunLoop`即将启动。
2. 通知观察者即将要处理`Timer`事件。
3. 通知观察者即将要处理`source0`事件。
4. 处理`source0`事件。
5. 如果基于端口的源`Source1`准备好并处于等待状态，进入步骤`9`。
6. 通知观察者线程即将进入休眠状态。
7. 将线程置于休眠状态，由用户态切换到内核态，直到下面的任一事件发生才唤醒线程。

    - 一个基于`port`的`Source1`的事件(图里应该是`source0`)。
    - 一个`Timer`到时间了。
    - `RunLoop`自身的超时时间到了。
    - 被其他调用者手动唤醒。
    
8. 通知观察者线程将被唤醒。
9. 处理唤醒时收到的事件。

    - 如果用户定义的定时器启动，处理定时器事件并重启`RunLoop`。进入步骤`2`。
    - 如果输入源启动，传递相应的消息。
    - 如果`RunLoop`被显示唤醒而且时间还没超时，重启`RunLoop`。进入步骤`2`。

10. 通知观察者`RunLoop`结束。

---

## 五、RunLoop与NSTimer

- 一个比较常见的问题：滑动`tableView`时，定时器还会生效吗？

    - 默认情况下`RunLoop`运行在`kCFRunLoopDefaultMode`下，而当滑动`tableView`时，`RunLoop`切换到`UITrackingRunLoopMode`，而`Timer`是在`kCFRunLoopDefaultMode`下的，就无法接受处理`Timer`的事件。
    
- 怎么去解决这个问题呢？把`Timer`添加到`UITrackingRunLoopMode`上并不能解决问题，因为这样在默认情况下就无法接受定时器事件了。

    - 所以需要把`Timer`同时添加到`UITrackingRunLoopMode`和`kCFRunLoopDefaultMode`上。那么如何把`timer`同时添加到多个`mode`上呢？就要用到`NSRunLoopCommonModes`了。
    - `Timer`就被添加到多个`mode`上，这样即使`RunLoop`由`kCFRunLoopDefaultMode`切换到`UITrackingRunLoopMode`下，也不会影响接收`Timer`事件。
    
```
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```

---

## 六、RunLoop与多线程

- 线程和`RunLoop`是一一对应的，其映射关系是保存在一个全局的`Dictionary`里。
- 自己创建的线程默认是没有开启`RunLoop`的。

#### 1、怎么创建一个常驻线程？

- 为当前线程开启一个`RunLoop`（第一次调用 `[NSRunLoop currentRunLoop]`方法时实际是会先去创建一个`RunLoop`）

- 向当前`RunLoop`中添加一个`Port/Source`等维持`RunLoop`的事件循环（如果`RunLoop`的`mode`中一个`item`都没有，`RunLoop`会退出）

- 启动该`RunLoop`

```
@autoreleasepool {
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    [runLoop run];
    
}
```

#### 2、输出下边代码的执行顺序

```
- (void)test1 {
    NSLog(@"1");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"2");
        
        [self performSelector:@selector(test) withObject:nil afterDelay:2];
        
        NSLog(@"3");
    });
    
    NSLog(@"4");
}

- (void)test {
    NSLog(@"5");
}
```

> 打印结果：1432，test方法并不会执行

- 如果是带`afterDelay`的延时函数，会在内部创建一个`NSTimer`，然后添加到当前线程的`RunLoop`中。
- 也就是如果当前线程没有开启`RunLoop`，该方法会失效。
- 改成如下：

```
dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    NSLog(@"2");
    
    [[NSRunLoop currentRunLoop] run];
    
    [self performSelector:@selector(test) withObject:nil afterDelay:2];
    
    NSLog(@"3");
});
```

> test方法依然不执行

- 如果`RunLoop`的`mode`中一个`item`都没有，`RunLoop`会退出。
- 即在调用`RunLoop`的`run`方法后，由于其`mode`中没有添加任何`item`去维持`RunLoop`的时间循环，`RunLoop`随即还是会退出。
- 所以自己启动`RunLoop`，一定要在添加`item`后：

```
dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    NSLog(@"2");
    
    [self performSelector:@selector(test) withObject:nil afterDelay:2];
    
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"3");
});
```

> 打印结果：14253

#### 3、怎样保证子线程数据回来更新UI的时候不打断用户的滑动操作？

- 当在子线程请求数据的同时滑动浏览当前页面，如果数据请求成功要切回主线程更新UI，那么就会影响当前正在滑动的体验。

- 就可以将更新UI事件放在主线程的`NSDefaultRunLoopMode`上执行即可，这样就会等用户不再滑动页面，主线程`RunLoop`由`UITrackingRunLoopMode`切换到`NSDefaultRunLoopMode`时再去更新UI

```
[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
```
  
  
















