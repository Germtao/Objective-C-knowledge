# 多线程

- [GCD](https://github.com/Germtao/Objective-C-knowledge/tree/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B#gcd)
- [NSOperation](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B/README.md#nsoperation)
- [NSThread](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B/README.md#nsthread)
- [多线程与锁](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B/README.md#%E5%A4%9A%E7%BA%BF%E7%A8%8B%E4%B8%8E%E9%94%81)

## GCD

   用来实现一些`简单的线程同步`, 包括一些`子线程的分派`, 实现一些类似于`多读单写`问题的解决方案.

- [同步/异步和串行/并发](https://github.com/Germtao/Objective-C-knowledge/tree/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B#1-%E5%90%8C%E6%AD%A5%E5%BC%82%E6%AD%A5-%E5%92%8C-%E4%B8%B2%E8%A1%8C%E5%B9%B6%E5%8F%91)
- [dispatch_barrier_async - 解决**多读单写**的问题](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B/README.md#2-dispatch_barrier_async)
- [dispatch_group](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B/README.md#2-dispatch_group)

### 1. 同步/异步 和 串行/并发

- **同步串行** - 同步分派一个任务到串行队列

> dispatch_sync(serial_queue, ^{ // 任务 });

```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 死锁
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self doSomething];
    });
}
```
> 死锁原因

![死锁原因](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/GCD%20Pics/%E6%AD%BB%E9%94%81%E5%8E%9F%E5%9B%A0.png)

- **异步串行** - 异步分派一个任务到串行队列

`dispatch_async(serial_queue, ^{ // 任务 });`

- **同步并发** - 同步分派一个任务到并发队列

`dispatch_sync(CONCURRENT_QUEUE, ^{ // 任务 });`

> 全局并发队列

```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"日志-1");
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"日志-2");
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"日志-3");
        });
        NSLog(@"日志-4");
    });
    NSLog(@"日志-5");
}

/**结果：12345*/
```

- **异步并发** - 异步分派一个任务到并发队列

`dispatch_async(CONCURRENT_QUEUE, ^{ // 任务 });`

```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 异步提交一个任务到并发队列, 默认是不开启线程runloop的
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1");
        
        // performSelctor 方法需要runloop, 如果没有, 方法失效
        [self performSelector:@selector(printLog) withObject:nil afterDelay:0];
        
        NSLog(@"3");
    });
}

- (void)printLog {
    NSLog(@"2");
}

/** 结果：13 */
```

### 2. dispatch_barrier_async

> 问题：怎样使用`GCD`实现多读单写？

![怎样实现多读单写](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/GCD%20Pics/GCD%E5%AE%9E%E7%8E%B0%E5%A4%9A%E8%AF%BB%E5%8D%95%E5%86%99.png)

```Objective-C
@interface UserCenter ()

/// 定义一个并发队列
@property (nonatomic, strong) dispatch_queue_t concurrent_queue;

/// 用户数据中心, 可能多个线程需要数据访问
@property (nonatomic, strong) NSMutableDictionary *userCenterDict;

@end

// 多读单写模型
@implementation UserCenter

- (instancetype)init {
    self = [super init];
    if (self) {
        _concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        _userCenterDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    __block id obj;
    
    // 同步读取指定数据
    dispatch_sync(self.concurrent_queue, ^{
        obj = [self.userCenterDict objectForKey:key];
    });
    
    return obj;
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    // 异步栅栏调用数据
    dispatch_barrier_async(self.concurrent_queue, ^{
        [self.userCenterDict setObject:obj forKey:key];
    });
}
```

### 3. dispatch_group

> 问题：所有图片下载完成后, 合成一张完整的图片？

```Objective-C
@interface GroupObject ()

/// 定义一个并发队列
@property (nonatomic, strong) dispatch_queue_t concurrent_queue;

@property (nonatomic, strong) NSMutableArray <NSURL *> *arrayURLs;

@end

@implementation GroupObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.concurrent_queue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
        self.arrayURLs = [NSMutableArray array];
    }
    return self;
}

- (void)handle {
    // 创建一个group
    dispatch_group_t group = dispatch_group_create();
    
    // 遍历各个元素执行操作
    for (NSURL *url in self.arrayURLs) {
        // 异步组分派到并发队列中
        dispatch_group_async(group, self.concurrent_queue, ^{
            // 根据url去下载图片
            NSLog(@"url is %@", url);
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 当组中所有任务执行完毕后, 会调用该block
        NSLog(@"所有图片下载完毕...");
    });
}

@end
```
---

## NSOperation

  需要和`NSOperationQueue`配合使用来实现多线程方案. 比如第三方框架 `AFNetworking、SDWebImage`等均有使用NSOperation.

- 可以添加任务依赖

- 可以控制任务执行状态

  - isReady - 任务是否处于就绪状态
  - isExecuting - 任务是否处于正在执行中状态
  - isFinished - 任务是否处于已执行完成状态, 通过`KVO`的方式通知对应的`NSOpreationQueue`来移除`NSOperation`.
  - isCancelled - 任务是否处于已取消状态
  
> 如果只重写`main`方法, 底层控制变更任务完成状态, 以及任务退出。如果重写了`start`方法, 自行控制任务状态。
  
- 可以控制最大并发量

---

## NSThread

  实现一个常驻线程.

![启动流程](https://github.com/Germtao/Objective-C-knowledge/blob/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/NSThread%20Pics/%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B.png)

--- 

## 多线程与锁

> iOS中都有哪些锁？

- `@synchronized`
- `atomic`
- `OSSpinLock`
- `NSRecursiveLock`
- `NSLock`
- `dispatch_semaphore_t`

#### @synchronized

一般在创建单例对象的时候使用.
    
#### atomic

- 修饰属性的关键字
- 对被修饰属性进行原子操作（不负责使用）

```Objective-C
    @property (atomic) NSMutableArray *array;

    self.array = [NSMutableArray array]; // ✔️: 保证线程安全

    [self.array addObject:obj]; // ✘: 不保证线程安全
```
    
#### OSSpinLock

**自旋锁**:

- `循环等待`询问, 不释放当前资源
-  用于轻量级数据访问, 简单的`int`值的`+1/-1`操作

#### NSLock

以下代码产生**死锁**:
    
```Objective-C
    - (void)method_A {
        [lock lock];
        [self method_B];
        [lock unlock];
    }

    - (void)method_B {
        [lock lock];
        // 逻辑操作
        [lock unlock];
    }
```

#### NSRecursiveLock

**递归锁**: 解决NSLock死锁问题, 主要就是解决锁重录的问题.
    
```Objective-C
    - (void)method_A {
        [recursiveLock lock];
        [self method_B];
        [recursiveLock unlock];
    }

    - (void)method_B {
        [recursiveLock lock];
        // 逻辑操作
        [recursiveLock unlock];
    }
```

#### dispatch_semaphore_t

常用的几个方法: 

- `dispatch_semaphore_create();`

```Objective-C
    struct semaphore {
        int value;
        List <thread>;
    }
```

- `dispatch_semaphore_wait();`

```Objective-C
    S.value = S.value - 1;
    if S.value < 0 then Block(S.list); // 阻塞是一个主动行为
```

- `dispatch_semaphore_signal(semaphore);`

```Objective-C
    S.value = S.value + 1;
    if S.value <= 0 then weakup(S.list); // 唤醒是一个被动行为
```

--- 










