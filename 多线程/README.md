# 多线程

- 进程和线程
- 多线程

---

## 一、进程和线程

#### 1、进程

- 是指在系统中正在运行的一个应用程序，每个进程之间是独立的，每个进程均运行在其专用且受保护的内存空间内。

#### 2、线程

- `线程` 是 `进程` 的基本执行单位，一个`进程（程序）`的所有任务都在`线程`中执行，每一个`进程`至少要有一个`线程`。

- 线程的串行：在同一时间内，一个`线程`只能执行一个任务。按顺序执行（串行）

#### 3、联系 & 区别

- `进程` 是CPU分配资源和调度的单位
- `线程` 是CPU调用（执行任务）的最小单位
- 一个程序可以对应多个`进程`，一个`进程`可以对应多个`线程`，但至少要有一个`线程`
- 同一`进程`内的`线程`共享进程的资源

--- 

## 二、多线程

#### 1、概念

- 一个`进程`中可以开启`多条线程`，每条`线程`可以`并行（同时）`执行不同的任务

#### 2、并发执行

- 在同一时间里，CPU只能处理1条线程，只有1条线程在工作（执行）。
- 多线程并发（同时）执行，其实是CPU快速地在多条线程之间调度（切换），如果CPU调度线程的时间足够快，就造成了多线程并发执行的假象。

#### 3、优、缺点

- 优点：

    - 能适当提高程序的执行效率
    - 能适当提高资源利用率（CPU、内存利用率）

- 缺点：

    - 开启线程需要占用一定的内存空间（默认情况下，主线程占用1M，子线程占用512KB），如果开启大量的线程，会占用大量的内存空间，降低程序的性能。
    - 线程越多，CPU在调度线程上的开销就越大。
    - 程序设计更加复杂：比如线程之间的通信、多线程的数据共享。
    
---

## 多线程比较

### 1. NSThread

每个NSThread对象对应一个线程，最原始的线程。

- 优点：轻量级最低，使用更加面向对象，简单易用，可直接操作线程对象。
- 缺点：手动管理所有的线程活动，如生命周期、线程同步、睡眠等。

### 2. NSOperation

自带线程管理的抽象类。

- 优点：自带线程周期管理，基于GCD，但比GCD多一些更简单实用的功能，使用更加面向对象。
- 缺点：面向对象的抽象类，只能实现它或者使用它定义好的两个子类：`NSInvocationOperation` 和 ` NSBlockOperation`。

### 3. GCD

Grand Central Dispatch (GCD)是Apple开发的一个多核编程的解决方法。

- 优点：最高效，避开并发陷阱。充分利用设备的多核（自动），旨在替代NSThread等线程技术。
- 缺点：基于C实现。

### 4. 方案选择

- 简单而安全的选择`NSOperation`实现多线程即可。
- 处理大量并发数据，又追求性能效率的选择`GCD`。
- 在做些小测试上基本选择`NSThread`，当然也可以基于此造个轮子。

## 使用方法

## NSThread
### 1. NSThread 创建线程的三种方法：

- 动态实例方法

```
// 动态实例方法
- (void)dynamicInstance {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(task:) object:@"dynamicCreateThread"];
    thread.threadPriority = 1.0; // 设置优先级（0.0、-1.0、1.0最高级）
    // 手动启动
    [thread start];
}
```

- 静态实例方法

```
// 静态实例方法, 自动启动
- (void)staticInstance {
    [NSThread detachNewThreadSelector:@selector(thread:) toTarget:self withObject:@"staticCreateThread"];
}
```

- 隐式实例化

```
// 后台线程，自动启动
- (void)implicitInstance {
    [self performSelectorInBackground:@selector(backgroundThread:) withObject:@"implicitCreateThread"];
}
```

- 事件处理

```
- (void)task:(NSString *)str {
NSLog(@"动态实例方法 %@", str);
}

- (void)thread:(NSString *)str {
NSLog(@"静态实例方法 %@", str);
}

- (void)backgroundThread:(NSString *)str {
NSLog(@"隐式实例方法 %@", str);
}
```

- 运行结果

```
动态实例方法 dynamicCreateThread
静态实例方法 staticCreateThread
隐式实例方法 implicitCreateThread
```

### 2. NSThread的其他拓展方法

`NSThread` 除了以上三种实例方法外，还有其他一些比较常用的方法：

```
// 取消线程
- (void)cancel;
// 启动线程
- (void)start;
// 强制停止线程
+ (void)exit;

// 判断某个线程的状态的属性
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isCancelled) BOOL cancelled;

// 设置和获取线程名字
-(void)setName:(NSString *)n;
-(NSString *)name;

// 设置优先级（取值范围 0.0 ~ 1.0 之间 最高是1.0 默认优先级是0.5）
+ (double)threadPriority;
+ (BOOL)setThreadPriority:(double)p;

// 获取当前线程信息
+ (NSThread *)currentThread;
// 获取主线程信息
+ (NSThread *)mainThread;

// 判断是否为主线程(对象方法)
- (BOOL)isMainThread;
// 判断是否为主线程(类方法)
+ (BOOL)isMainThread;

// 阻塞线程（延迟执行）
+ (void)sleepForTimeInterval:(NSTimeInterval)time;
+ (void)sleepUntilDate:(NSDate *)date;
```

### 3. NSThread线程安全

线程安全，解决方法采用线程加锁，需了解`互斥锁`

1. 互斥锁使用格式：

`@synchronized (self) {// 需要锁定的代码 }`

注意：锁定一份代码只用一把锁，用多把锁是无效的

2. 互斥锁的优缺点：

- 优点：能有效防止因多线程抢夺资源造成的数据安全问题
- 缺点：需要消耗大量的CPU资源

3. 互斥锁注意点：

锁：必须是全局唯一的（通常用self）

- 注意加锁的位置
- 注意加锁的前提条件，多线程共享同一块资源
- 注意加锁是需要代价的，需要耗费性能的
- 加锁的结果：线程同步（按顺序执行）

补充:
我们知道, 属性中有atomic和nonatomic属性

- atomic : setter方法线程安全, 需要消耗大量的资源
- nonatomic : setter方法非线程安全, 适合内存小的移动设备

### 4. 线程间的通信

线程间通信：任务从子线程回到主线程。

```
/**
参数：回到主线程要调用那个方法、前面方法需要传递的参数、是否等待（YES执行完再执行下面代码，NO可先执行下面代码）
*/
// 在指定线程上执行操作
[self performSelector:@selector(run) onThread:thread withObject:nil waitUntilDone:YES];
// 在主线程上执行操作
[self performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES];
// 在当前线程执行操作
[self performSelector:@selector(run) withObject:nil];
```

## NSOperation

主要的实现方式：结合`NSOperation`和`NSOperationQueue`实现多线程编程。

- NSOperation是一个抽象类，不能直接使用，所以需实例化NSOperation的子类，绑定执行的操作。
- 创建NSOperationQueue队列，将NSOperation实例添加进来。
- 系统会自动将NSOperationQueue队列中检测取出和执行NSOperation的操作。

### 使用NSOperation的子类实现创作线程

1. `NSInvocationOperation`：使用这个类来初始化一个操作，它包括指定对象的调用`selector`。

```
// NSInvocationOperation
- (void)createInvocationOperation {
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocation:) object:@"invocationOperation"];
    [invocation start]; // 在当前线程主线程执行

    // NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // [queue addOperation:invocation];
}
```

2. `NSBlockOperation`：使用这个类来用一个或多个block初始化操作,操作本身可以包含多个块。当所有block被执行操作将被视为完成。

```
// NSBlockOperation
- (void)createBlockOperation {
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation")
    }];
    [block start];

    // NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // [queue addOperation:block];
}
```

执行结果：

```
invocationOperation
blockOperation
```

3. 自定义NSOperation子类实现main方法




