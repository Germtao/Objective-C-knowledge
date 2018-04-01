//
//  ViewController.m
//  GCD多线程
//
//  Created by TT on 2018/3/2.
//  Copyright © 2018年 T AO. All rights reserved.
//  GCD常用的一些函数

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self deadlock];
    
//    [self group];
    
//    [self groupWait];
    
//    [self barrier];
    
    [self dispatchSignal];
}

// MARK: - GCD 分组任务
- (void)groupWait {
    // 创建线程组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_group_async(group, serialQueue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"group-serial - %@", [NSThread currentThread]);
        }
    });
    
    //
    NSLog(@"%ld", dispatch_group_wait(group, DISPATCH_TIME_NOW));
}

#pragma mark - group
#pragma mark - 做完一组操作后再执行后续的代码

- (void)group {
    
    // 两种方式：
    // 01: dispatch_group_async
    [self group01];
    
    // 02: dispatch_group_enter & dispatch_group_leave
//    [self group02];
}

- (void)group01 {
    
    // 创建线程组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t serialQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 组异步执行
    dispatch_group_async(group, serialQueue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"group-serial - %@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"group-02-serial - %@", [NSThread currentThread]);
        }
    });
    
    // 把第三个参数block传入第二个参数队列中去。
    // 而且可以保证第三个参数block执行时，group中的所有任务已经全部完成
    dispatch_group_notify(group, serialQueue, ^{
        NSLog(@"Finished - %@", [NSThread currentThread]);
    });
}

- (void)group02 {
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"group-serial - %@", [NSThread currentThread]);
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"group-serial02 - %@", [NSThread currentThread]);
        
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"Finished02 - %@", [NSThread currentThread]);
    });
}

#pragma mark - barrier

/**
 - 通过dispatch_barrier_async添加的block会等到之前添加所有的block执行完毕再执行
 - 在dispatch_barrier_async之后添加的block会等到dispatch_barrier_async添加的block执行完毕再执行
 */

- (void)barrier {
   
    dispatch_queue_t queue = dispatch_queue_create("testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"第一个 block 完成");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"第二个 block 完成");
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"barrier block 完成");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"第三个 block 完成");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"第四个 block 完成");
    });
}

#pragma mark - 信号量
/**
    当我们多个线程要访问同一个资源的时候，往往会设置一个信号量，
    当信号量大于0的时候，新的线程可以去操作这个资源，操作时信号量-1，操作完后信号量+1，
    当信号量等于0的时候，必须等待，所以通过控制信号量，我们可以控制能够同时进行的并发数
 */

/**
 dispatch_semaphore
 信号量有以下三个函数:
 
 - dispatch_semaphore_create: 创建一个信号量
 - dispatch_semaphore_signal: 信号量 +1
 - dispatch_semaphore_wait: 等待，直到信号量大于0时，即可操作，同时将信号量-1
 */

- (void)dispatchSignal {
    
    // value: 最多几个资源可以访问
    long value = 1;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(value);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 任务1
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");
        
        dispatch_semaphore_signal(semaphore);
    });
    
    // 任务2
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSLog(@"run task 2");
        sleep(1);
        NSLog(@"complete task 2");
        
        dispatch_semaphore_signal(semaphore);
    });
    
    // 任务3
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");
        
        dispatch_semaphore_signal(semaphore);
    });
}

// MARK: - GCD 死锁问题
- (void)deadlock {
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    id block = ^{
        NSLog(@"%@", [NSThread currentThread]);
    };
    
    // 向当前串行队列中同步派发一个任务, 死锁
//    dispatch_sync(mainQueue, block);
    dispatch_async(mainQueue, block);
}


@end
