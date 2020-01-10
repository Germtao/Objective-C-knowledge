# 多线程

- 进程和线程
- 多线程
- 同步(Sync)和异步(Async)
- 并发和并行
- 队列（Dispatch Queue）
- iOS中的多线程

    - NSThread
    - NSOperation
    - GCD

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

## 三、同步(Sync)和异步(Async)

- **同步**：

    - 同步添加任务到指定的队列中，在添加的任务执行结束之前，会一直等待，直到队列里面的任务完成之后再继续执行，即会阻塞线程。
    - 只能在当前线程中执行任务（是当前线程，不一定是主线程），不具备开启新线程的能力。
    
- **异步**：

    - 线程会立即返回，无需等待就会继续执行下面的任务，不阻塞当前线程。
    - 可以在新的线程中执行任务，具备开启新线程的能力（并不一定开启新线程）。
    - 如果不是添加到主队列上，异步会在子线程中执行任务。

---

## 四、并发和并行

- **并发**：

    - 指的是一种**现象**，一种经常出现，无可避免的现象。它描述的是**多个任务同时发生，需要被处理**这一现象。它的侧重点在于**发生**。
    - 比如：有很多人排队等待检票，这一现象就可以理解为并发。
    
- **并行**：

    - 指的是一种**技术**，一个同时处理多个任务的技术。它描述了**一种能够同时处理多个任务的能力**，侧重点在于**运行**。
    - 比如：景点开放了多个检票窗口，同一时间内能服务多个游客，这种情况可以理解为并行。
    
- **串行**：

    - 表示任务必须按顺序来，一个一个执行，前一个执行完了才能执行后一个。
    
**多线程**就是采用了**并行**这种技术，从而提高执行效率，因为有多个线程，所以计算机的多个CPU可以同时工作，同时处理不同线程内的指令。

---

## 五、队列（Dispatch Queue）

- **串行队列**：

    - 先进先出，也就是先进入队列的任务先出队列，每次只执行一个任务。
    
- **并行队列**：

    - 先进先出，但可以形成多个任务并发。
    
- **主队列**：

    - 一个特殊的串行队列，而且队列中的任务一定会在主线程中执行。

---

## 六、iOS中的多线程

### 1、NSThread

- 轻量级别的多线程技术，每个NSThread对象对应一个线程，最原始的线程。

- 优点：

    - 轻量级最低，使用更加面向对象，简单易用，可直接操作线程对象。

- 缺点：

    - 手动管理所有的线程活动，如生命周期、线程同步、睡眠等。
    
```
NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(testThread:) object:@"我是参数"];
// 当使用初始化方法出来的主线程需要start启动
[thread start];
// 可以为开辟的子线程起名字
thread.name = @"NSThread-1";
// 线程的优先级，由0.0到1.0之间的浮点数指定，其中1.0是最高优先级。
// 优先级越高，先执行的概率就会越高，但由于优先级是由内核确定的，因此不能保证此值实际上是多少，默认值是0.5
thread.threadPriority = 1;
// 取消当前已经启动的线程
[thread cancel];
```

```
// 通过遍历构造器开辟子线程
[NSThread detachNewThreadSelector:@selector(testThread:) toTarget:self withObject:@"构造器开辟子线程"];
```
```
- (void)testThread:(id)obj {
    NSLog(@"%@", obj);
}
```
---

### 2、NSOperation

- 自带线程管理的抽象类。

- 优点：

    - 自带线程周期管理，基于GCD，但比GCD多一些更简单实用的功能，使用更加面向对象。
    - 比 GCD 更简单易用、代码可读性也更高。
        
        - 可以添加任务依赖，方便控制执行顺序。
        - 可以设定操作执行的优先级。
        - 可以控制任务执行状态：`isReady`、`isExecuting`、`isFinished`、`isCancelled`。
        - 可以设置最大并行量。
    
- 缺点：

    - 面向对象的抽象类，只能实现它或者使用它定义好的两个子类：`NSInvocationOperation` 和 ` NSBlockOperation`。
    
#### 2.1、NSInvocationOperation

```
- (void)useInvocationOperation {
    // 1. 创建 NSInvocationOperation 对象
    NSInvocationOperation *invocationOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];

    // 2. 开始执行操作
    [invocationOp start];
}

- (void)task1 {
    NSLog(@"任务1");
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务1 ----- %@", [NSThread currentThread]);
    }
}
```

> 打印结果：
>  2020-01-10 15:25:54.581264+0800 多线程[27385:5931439] 任务1
> 2020-01-10 15:25:56.581754+0800 多线程[27385:5931439] 任务1 ----- <NSThread: 0x600003172100>{number = 1, name = main}
> 2020-01-10 15:25:58.582752+0800 多线程[27385:5931439] 任务1 ----- <NSThread: 0x600003172100>{number = 1, name = main}

```
- (void)useInvocationOperation {
    [NSThread detachNewThreadSelector:@selector(task1) toTarget:self withObject:nil];
}

- (void)task1 {
    NSLog(@"任务1");
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务1 ----- %@", [NSThread currentThread]);
    }
}
```

> 打印结果：
> 2020-01-10 15:27:23.347318+0800 多线程[27409:5932600] 任务1
> 2020-01-10 15:27:25.347816+0800 多线程[27409:5932600] 任务1 ----- <NSThread: 0x600001c024c0>{number = 7, name = (null)}
> 2020-01-10 15:27:27.349225+0800 多线程[27409:5932600] 任务1 ----- <NSThread: 0x600001c024c0>{number = 7, name = (null)}

**综上所述**：在没有使用`NSOperationQueue`的情况下，使用子类`NSInvocationOperation`执行一个操作。

- 在主线程中使用，操作是在当前线程执行的，并没有开启新线程。
- 在其他线程中使用，操作是在当前线程执行的，并没有开启新线程。

#### 2.2、NSBlockOperation

```
- (void)useBlockOperation {
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务2");
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务2 ----- %@", [NSThread currentThread]);
        }
    }];
    [blockOp start];
}
```

> 打印结果：
> 2020-01-10 15:37:17.718294+0800 多线程[27558:5938313] 任务2
> 2020-01-10 15:37:19.719564+0800 多线程[27558:5938313] 任务2 ----- <NSThread: 0x600003bef9c0>{number = 1, name = main}
> 2020-01-10 15:37:21.720853+0800 多线程[27558:5938313] 任务2 ----- <NSThread: 0x600003bef9c0>{number = 1, name = main}

**添加一些额外操作后看看**：

```
for (int i = 0; i < 3; i++) {
    // 添加额外操作
    [blockOp addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务2 ----- %@", [NSThread currentThread]);
        }
    }];
}
```

> 打印结果：
> 2020-01-10 15:45:48.660238+0800 多线程[27706:5943843] 任务2
> 2020-01-10 15:45:50.661238+0800 多线程[27706:5943931] 任务2 ----- <NSThread: 0x60000027a740>{number = 6, name = (null)}
> 2020-01-10 15:45:50.661238+0800 多线程[27706:5943935] 任务2 ----- <NSThread: 0x600000227040>{number = 3, name = (null)}
> 2020-01-10 15:45:50.661253+0800 多线程[27706:5943843] 任务2 ----- <NSThread: 0x60000022ee00>{number = 1, name = main}
> 2020-01-10 15:45:50.661238+0800 多线程[27706:5943933] 任务2 ----- <NSThread: 0x60000027d6c0>{number = 5, name = (null)}
> 2020-01-10 15:45:52.662560+0800 多线程[27706:5943935] 任务2 ----- <NSThread: 0x600000227040>{number = 3, name = (null)}
> 2020-01-10 15:45:52.662566+0800 多线程[27706:5943931] 任务2 ----- <NSThread: 0x60000027a740>{number = 6, name = (null)}
> 2020-01-10 15:45:52.662561+0800 多线程[27706:5943933] 任务2 ----- <NSThread: 0x60000027d6c0>{number = 5, name = (null)}
> 2020-01-10 15:45:52.662561+0800 多线程[27706:5943843] 任务2 ----- <NSThread: 0x60000022ee00>{number = 1, name = main}

**综上所述**：

一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。

#### 2.3、使用自定义继承自`NSOperation`子类

```
@interface CustomOperation : NSOperation

@end

@implementation CustomOperation

// 重写main
- (void)main {
    if (!self.isCancelled) {
        NSLog(@"任务3");
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务3 ----- %@", [NSThread currentThread]);
        }
    }
}

@end

- (void)useCustomOperation {
    CustomOperation *op = [[CustomOperation alloc] init];
    [op start];
}
```
> 打印结果：
> 2020-01-10 15:56:12.788357+0800 多线程[27862:5949986] 任务3
> 2020-01-10 15:56:14.789676+0800 多线程[27862:5949986] 任务3 ----- <NSThread: 0x600002c0ad40>{number = 1, name = main}
> 2020-01-10 15:56:16.790990+0800 多线程[27862:5949986] 任务3 ----- <NSThread: 0x600002c0ad40>{number = 1, name = main}

- 操作是在当前线程执行的，并没有开启新线程。

#### 2.4、NSOperationQueue

`NSOperationQueue`一共有两种队列：

- **主队列**：

    - 凡是添加到主队列中的操作，都会放到主线程中执行（注：不包括操作使用`addExecutionBlock:`添加的额外操作，额外操作可能在其他线程执行）。

```
// 主队列获取方法
NSOperationQueue *queue = [NSOperationQueue mainQueue];
```

- **自定义队列（非主队列）**：

    - 添加到这种队列中的操作，就会自动放到子线程中执行。
    - 同时包含了：串行、并行功能。

```
// 自定义队列创建方法
NSOperationQueue *queue = [[NSOperationQueue alloc] init];
```

- 两种方式把创建好的操作加入到队列中去：

1. `- (void)addOperation:(NSOperation *)op;`
    
```
- (void)addOperationToQueue {
    // 1. 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2. 创建操作
    NSInvocationOperation *invocationOp1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOpTask1) object:nil];
    NSInvocationOperation *invocationOp2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOpTask2) object:nil];
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockTask1 ----- %@", [NSThread currentThread]);
        }
    }];
    [blockOp addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockTask2 ----- %@", [NSThread currentThread]);
        }
    }];
    [blockOp addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockTask3 ----- %@", [NSThread currentThread]);
        }
    }];
    
    // 3. 使用 addOperation: 添加所有操作到队列中
    [queue addOperation:invocationOp1];
    [queue addOperation:invocationOp2];
    [queue addOperation:blockOp];
}

- (void)invocationOpTask1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"invocationOpTask1 ----- %@", [NSThread currentThread]);
    }
}

- (void)invocationOpTask2 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"invocationOpTask2 ----- %@", [NSThread currentThread]);
    }
}
```

> 打印结果：
> 2020-01-10 16:14:39.256158+0800 多线程[28193:5962558] blockTask1 ----- <NSThread: 0x600003e90080>{number = 7, name = (null)}
> 2020-01-10 16:14:39.256165+0800 多线程[28193:5962554] invocationOpTask2 ----- <NSThread: 0x600003e6c580>{number = 8, name = (null)}
> 2020-01-10 16:14:39.256271+0800 多线程[28193:5962559] blockTask3 ----- <NSThread: 0x600003e03840>{number = 9, name = (null)}
> 2020-01-10 16:14:39.256277+0800 多线程[28193:5962560] blockTask2 ----- <NSThread: 0x600003e900c0>{number = 10, name = (null)}
> 2020-01-10 16:14:39.256280+0800 多线程[28193:5962499] invocationOpTask1 ----- <NSThread: 0x600003e41040>{number = 5, name = (null)}
> 2020-01-10 16:14:41.261604+0800 多线程[28193:5962560] blockTask2 ----- <NSThread: 0x600003e900c0>{number = 10, name = (null)}
> 2020-01-10 16:14:41.261600+0800 多线程[28193:5962554] invocationOpTask2 ----- <NSThread: 0x600003e6c580>{number = 8, name = (null)}
> 2020-01-10 16:14:41.261600+0800 多线程[28193:5962558] blockTask1 ----- <NSThread: 0x600003e90080>{number = 7, name = (null)}
> 2020-01-10 16:14:41.261610+0800 多线程[28193:5962499] invocationOpTask1 ----- <NSThread: 0x600003e41040>{number = 5, name = (null)}
> 2020-01-10 16:14:41.261600+0800 多线程[28193:5962559] blockTask3 ----- <NSThread: 0x600003e03840>{number = 9, name = (null)}

**综上所述**：使用`addOperation:`将操作加入到操作队列后能够**开启新线程**，并**并行**执行。

2. `- (void)addOperationWithBlock:(void (^)(void))block;`

```
- (void)addOperationWithBlockToQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 ----- %@", [NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2 ----- %@", [NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3 ----- %@", [NSThread currentThread]);
        }
    }];
}
```

> 打印结果：
> 2020-01-10 16:41:56.401134+0800 多线程[28408:5973878] 2 ----- <NSThread: 0x600003b8ef40>{number = 6, name = (null)}
> 2020-01-10 16:41:56.401137+0800 多线程[28408:5973879] 1 ----- <NSThread: 0x600003b83ec0>{number = 4, name = (null)}
> 2020-01-10 16:41:56.401134+0800 多线程[28408:5973882] 3 ----- <NSThread: 0x600003b83f00>{number = 3, name = (null)}
> 2020-01-10 16:41:58.406510+0800 多线程[28408:5973879] 1 ----- <NSThread: 0x600003b83ec0>{number = 4, name = (null)}
> 2020-01-10 16:41:58.406509+0800 多线程[28408:5973878] 2 ----- <NSThread: 0x600003b8ef40>{number = 6, name = (null)}
> 2020-01-10 16:41:58.406512+0800 多线程[28408:5973882] 3 ----- <NSThread: 0x600003b83f00>{number = 3, name = (null)}

**综上所述**：使用`addOperationWithBlock:`将操作加入到操作队列后能够**开启新线程**，并**并行**执行。

- 设置maxConcurrentOperationCount：

```
- (void)setMaxConcurrentOperationCount {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1; // > 1 并行，= 1 串行；开启线程数量是由系统决定的
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1 ----- %@", [NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"2 ----- %@", [NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"3 ----- %@", [NSThread currentThread]);
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"4 ----- %@", [NSThread currentThread]);
        }
    }];
}
```
**1、maxConcurrentOperationCount = 1**

> 打印结果：
> 2020-01-10 16:56:47.519974+0800 多线程[28689:5984540] 1 ----- <NSThread: 0x60000149c180>{number = 3, name = (null)}
> 2020-01-10 16:56:49.523232+0800 多线程[28689:5984540] 1 ----- <NSThread: 0x60000149c180>{number = 3, name = (null)}
> 2020-01-10 16:56:51.528742+0800 多线程[28689:5984540] 2 ----- <NSThread: 0x60000149c180>{number = 3, name = (null)}
> 2020-01-10 16:56:53.533423+0800 多线程[28689:5984540] 2 ----- <NSThread: 0x60000149c180>{number = 3, name = (null)}
> 2020-01-10 16:56:55.536091+0800 多线程[28689:5984540] 3 ----- <NSThread: 0x60000149c180>{number = 3, name = (null)}
> 2020-01-10 16:56:57.541492+0800 多线程[28689:5984540] 3 ----- <NSThread: 0x60000149c180>{number = 3, name = (null)}
> 2020-01-10 16:56:59.543677+0800 多线程[28689:5984535] 4 ----- <NSThread: 0x6000014b0c40>{number = 5, name = (null)}
> 2020-01-10 16:57:01.545282+0800 多线程[28689:5984535] 4 ----- <NSThread: 0x6000014b0c40>{number = 5, name = (null)}

**2、maxConcurrentOperationCount = 3**

> 打印结果：
> 2020-01-10 17:00:23.880552+0800 多线程[28731:5986297] 1 ----- <NSThread: 0x600001ed0340>{number = 5, name = (null)}
> 2020-01-10 17:00:23.880553+0800 多线程[28731:5986300] 2 ----- <NSThread: 0x600001ef6800>{number = 3, name = (null)}
> 2020-01-10 17:00:23.880552+0800 多线程[28731:5986295] 3 ----- <NSThread: 0x600001edb680>{number = 6, name = (null)}
> 2020-01-10 17:00:25.885401+0800 多线程[28731:5986295] 3 ----- <NSThread: 0x600001edb680>{number = 6, name = (null)}
> 2020-01-10 17:00:25.885401+0800 多线程[28731:5986300] 2 ----- <NSThread: 0x600001ef6800>{number = 3, name = (null)}
> 2020-01-10 17:00:25.885401+0800 多线程[28731:5986297] 1 ----- <NSThread: 0x600001ed0340>{number = 5, name = (null)}
> 2020-01-10 17:00:27.885770+0800 多线程[28731:5986299] 4 ----- <NSThread: 0x600001e2d100>{number = 7, name = (null)}
> 2020-01-10 17:00:29.888657+0800 多线程[28731:5986299] 4 ----- <NSThread: 0x600001e2d100>{number = 7, name = (null)}

**综上所述**：开启线程数量是由系统决定的。

- `NSOperation`操作依赖：能添加操作之间的依赖关系

    - `- (void)addDependency:(NSOperation *)op;`
        - 添加依赖，使当前操作依赖于操作`op`的完成。
    - `- (void)removeDependency:(NSOperation *)op;`
        - 移除依赖，取消当前操作对操作`op`的依赖。
    - `@property (readonly, copy) NSArray<NSOperation *> *dependencies;`
        - 在当前操作开始执行之前完成执行的所有操作对象数组。
        
```
- (void)addDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *blockOp1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockOp1 ----- %@", [NSThread currentThread]);
        }
    }];
    
    NSBlockOperation *blockOp2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"blockOp2 ----- %@", [NSThread currentThread]);
        }
    }];
    
    [blockOp2 addDependency:blockOp1];
    
    [queue addOperation:blockOp1];
    [queue addOperation:blockOp2];
}
```
        
> 打印结果：
> 2020-01-10 17:13:13.588357+0800 多线程[29325:5998600] blockOp1 ----- <NSThread: 0x6000025c0180>{number = 7, name = (null)}
> 2020-01-10 17:13:15.589582+0800 多线程[29325:5998600] blockOp1 ----- <NSThread: 0x6000025c0180>{number = 7, name = (null)}
> 2020-01-10 17:13:17.594448+0800 多线程[29325:5998680] blockOp2 ----- <NSThread: 0x6000025c43c0>{number = 8, name = (null)}
> 2020-01-10 17:13:19.600297+0800 多线程[29325:5998680] blockOp2 ----- <NSThread: 0x6000025c43c0>{number = 8, name = (null)}

---

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




