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

#pragma mark - 多读单写/dispatch_barrier_async
- (void)dispatch_barrier_async {
    
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
    UIButton *item2 = [UIButton buttonWithTitle:@"同步并发" tag:2 backgroundColor:[UIColor blueColor] target:self action:@selector(dispatch_sync_concurrent_queue)];
    UIButton *item3 = [UIButton buttonWithTitle:@"异步并发" tag:3 backgroundColor:[UIColor purpleColor] target:self action:@selector(dispatch_async_concurrent_queue)];
    
    item0.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 150, 100, 40);
    item1.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 200, 100, 40);
    item2.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 250, 100, 40);
    item3.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 300, 100, 40);
    
    [self.view addSubview:item0];
    [self.view addSubview:item1];
    [self.view addSubview:item2];
    [self.view addSubview:item3];
}

- (void)moreReadAndSingleWrite {
    UIButton *item = [UIButton buttonWithTitle:@"多读单写" tag:0
                               backgroundColor:[UIColor cyanColor]
                                        target:self
                                        action:@selector(dispatch_barrier_async)];
    item.frame = CGRectMake((self.view.bounds.size.width - 100) * 0.5, 400, 100, 40);
    [self.view addSubview:item];
}

@end
