# 多线程

- [GCD](https://github.com/Germtao/Objective-C-knowledge/tree/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B#gcd)
- `NSOperation`
- `NSThread`
- `多线程与锁`

## GCD

- [`同步/异步` 和 `串行/并发`](https://github.com/Germtao/Objective-C-knowledge/tree/master/%E5%A4%9A%E7%BA%BF%E7%A8%8B/%E5%A4%9A%E7%BA%BF%E7%A8%8B#1-%E5%90%8C%E6%AD%A5%E5%BC%82%E6%AD%A5-%E5%92%8C-%E4%B8%B2%E8%A1%8C%E5%B9%B6%E5%8F%91)
- `dispatch_barrier_async` - 解决**多读单写**的问题
- `dispatch_group`

### 1. 同步/异步 和 串行/并发

- **同步串行** - 同步分派一个任务到串行队列

> dispatch_sync(serial_queue, ^{ // 任务 });

```
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

```
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

```
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
