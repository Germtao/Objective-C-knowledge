//
//  GCDViewController.m
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "GCDViewController.h"
#import "UIButton+Extension.h"

@interface GCDViewController ()

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupUI];
    [self moreReadAndSingleWrite];
}

// MARK: - 任务执行顺序
// 串行队列先异步后同步
- (void)serialQueueAsyncFirstAndThenSync {
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue1", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    
    dispatch_async(serialQueue, ^{
        NSLog(@"2");
    });
    
    NSLog(@"3");
    
    dispatch_sync(serialQueue, ^{
        NSLog(@"4");
    });
    
    NSLog(@"5");
}

// performSelector
- (void)queuePerformSelector {
    // 13
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSLog(@"1");
//        [self performSelector:@selector(printLog) withObject:nil afterDelay:0];
//        NSLog(@"3");
//    });
    
    // 132 主线程开启runloop
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"1");
//        [self performSelector:@selector(printLog) withObject:nil afterDelay:0];
//        NSLog(@"3");
//    });
    
    // 132 同步在当前线程（主线程）
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1");
        [self performSelector:@selector(printLog) withObject:nil afterDelay:0];
        NSLog(@"3");
    });
}

// MARK: - 同步分派一个任务到串行队列
- (void)dispatch_sync_serial_queue {
    // 死锁 - 队列引起的循环等待
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [self doSomething];
//    });
    
    // 没问题
    dispatch_sync(dispatch_queue_create("SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL), ^{
        [self doSomething];
    });
}

// MARK: - 异步分派一个任务到串行队列
- (void)dispatch_async_serial_queue {
//    dispatch_async(dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL), ^{
//        // 任务
//        [self doSomething];
//    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self doSomething];
    });
}

// MARK: - 同步分派一个任务到并发队列
- (void)dispatch_sync_concurrent_queue {
//    dispatch_sync(dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT), ^{
//        // 任务
//        [self doSomething];
//    });
    
    NSLog(@"日志 1");
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"日志 2");
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"日志 3");
        });
        NSLog(@"日志 4");
    });
    NSLog(@"日志 5");
}

// MARK: - 异步分派一个任务到并发队列
- (void)dispatch_async_concurrent_queue {
//    dispatch_async(dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT), ^{
//        // 任务
//        [self doSomething];
//    });
    
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

- (void)doSomething {
    NSLog(@"do some thing...");
}

#pragma mark - GCD常用函数
- (void)dispatch_semaphore {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSInteger number = 0;
//    dispatch_async(queue, ^{
//        number = 100;
//        dispatch_semaphore_signal(semaphore);
//    });
//
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//    NSLog(@"semaphore---end, number = %ld", number);
    
    for (NSInteger i = 0; i < 50; i++) {
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            number++;
            sleep(1);
            NSLog(@"执行任务：%ld", number);
            dispatch_semaphore_signal(semaphore);
        });
    }
}

- (void)dispatch_group {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSInteger i = 0; i < 10; i++) {
//        dispatch_group_async(group, queue, ^{
//            NSLog(@"网络请求 - %ld - %@", i, [NSThread currentThread]);
//            sleep(1);
//        });
        
        dispatch_group_enter(group);
        dispatch_async(queue, ^{
            NSLog(@"网络请求 - %ld - %@", i, [NSThread currentThread]);
            sleep(1);
            dispatch_group_leave(group);
        });
    }
    
    // group中的所有任务已经全部完成, 回到主线程刷新UI
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"刷新UI - %@", [NSThread currentThread]);
    });
}

// 多读单写/dispatch_barrier_async
- (void)dispatch_barrier_async {
    // 并行队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue1", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 3; i++) {
        dispatch_async(concurrentQueue, ^{
            // 读操作
            NSLog(@"任务 - %d", i);
        });
    }
    
    dispatch_barrier_async(concurrentQueue, ^{
        // 写操作
        NSLog(@"dispatch_barrier_async");
    });
    
    for (int i = 5; i < 8; i++) {
        dispatch_async(concurrentQueue, ^{
            NSLog(@"任务 - %d", i);
        });
    }
}

- (void)setup {
    
    self.title = @"GCD";
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.view.layer.shadowOffset = CGSizeMake(-10, 0);
    self.navigationController.view.layer.shadowOpacity = 0.15;
    self.navigationController.view.layer.cornerRadius = 10.0;
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"menu"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(openOrCloseMenu)];
    self.navigationItem.leftBarButtonItem = menuItem;
}

- (void)openOrCloseMenu {
    [self.navigationController.parentViewController performSelector:@selector(openOrCloseMenu)];
}

- (void)setupUI {
    UIButton *item0 = [UIButton buttonWithTitle:@"同步串行" tag:0 backgroundColor:[UIColor blackColor] target:self action:@selector(dispatch_sync_serial_queue)];
    UIButton *item1 = [UIButton buttonWithTitle:@"异步串行" tag:1 backgroundColor:[UIColor brownColor] target:self action:@selector(dispatch_async_serial_queue)];
    UIButton *item2 = [UIButton buttonWithTitle:@"同步并行" tag:2 backgroundColor:[UIColor blueColor] target:self action:@selector(dispatch_sync_concurrent_queue)];
    UIButton *item3 = [UIButton buttonWithTitle:@"异步并行" tag:3 backgroundColor:[UIColor purpleColor] target:self action:@selector(dispatch_async_concurrent_queue)];
    
    item0.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 150, 100, 40);
    item1.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 200, 100, 40);
    item2.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 250, 100, 40);
    item3.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 300, 100, 40);
    
    [self.view addSubview:item0];
    [self.view addSubview:item1];
    [self.view addSubview:item2];
    [self.view addSubview:item3];
    
    UIButton *item6 = [UIButton buttonWithTitle:@"dispatch_group" tag:4 backgroundColor:[UIColor purpleColor] target:self action:@selector(dispatch_group)];
    item6.frame = CGRectMake(20, 400, self.view.bounds.size.width - 40, 40);
    [self.view addSubview:item6];
    
    UIButton *item7 = [UIButton buttonWithTitle:@"信号量 - dispatch_semaphore" tag:5 backgroundColor:[UIColor systemPinkColor] target:self action:@selector(dispatch_semaphore)];
    item7.frame = CGRectMake(20, 450, self.view.bounds.size.width - 40, 40);
    [self.view addSubview:item7];
    
    
    UIButton *item4 = [UIButton buttonWithTitle:@"串行队列先异步后同步" tag:4 backgroundColor:[UIColor purpleColor] target:self action:@selector(serialQueueAsyncFirstAndThenSync)];
    item4.frame = CGRectMake(20, self.view.bounds.size.height - 80, self.view.bounds.size.width - 40, 40);
    [self.view addSubview:item4];
    
    UIButton *item5 = [UIButton buttonWithTitle:@"performSelector" tag:5 backgroundColor:[UIColor systemPinkColor] target:self action:@selector(queuePerformSelector)];
    item5.frame = CGRectMake(20, self.view.bounds.size.height - 130, self.view.bounds.size.width - 40, 40);
    [self.view addSubview:item5];
}

- (void)moreReadAndSingleWrite {
    UIButton *item = [UIButton buttonWithTitle:@"多读单写 - barrier" tag:0
                               backgroundColor:[UIColor systemTealColor]
                                        target:self
                                        action:@selector(dispatch_barrier_async)];
    item.frame = CGRectMake(20, 350, self.view.bounds.size.width - 40, 40);
    [self.view addSubview:item];
}

@end
