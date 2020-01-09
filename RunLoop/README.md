# RunLoop

- 概念
- 数据结构
- RunLoop的Mode
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

> **RunLoop的Mode**

*`RunLoop`的各个`Mode`数据不共享*

![RunLoop的Mode](https://github.com/Germtao/Objective-C-knowledge/blob/master/RunLoop/RunLoop%20Pics/RunLoop%E7%9A%84Mode.png)

> **CommonMode 的特殊性** - *Timer同时加入两个Mode中*

NSRunLoopCommonModes

  - `CommonMode`不是实际存在的一种Mode
  
  - 是同步`Source/Timer/Observer`到多个Mode中的一种**技术方案**
  
  
















