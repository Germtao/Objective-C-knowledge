//
//  ViewController.m
//  GCD多线程
//
//  Created by TT on 2018/3/2.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self deadlock];
    
//    [self group];
    
    [self groupWait];
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

- (void)group {
    
    // 创建线程组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
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
