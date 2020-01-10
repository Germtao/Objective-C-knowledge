//
//  OperationViewController.m
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "OperationViewController.h"
#import "UIButton+Extension.h"

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

@interface OperationViewController ()

@property (nonatomic, assign) NSInteger totalCount;

@property (nonatomic, strong) NSLock *lock;

@end

@implementation OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupUI];
}

// MARK: - NSOperationQueue

// 线程安全
- (void)threadSafe {
    NSLog(@"currentThread --- %@", [NSThread currentThread]); // 打印当前线程
    
    self.totalCount = 30;
    
    self.lock = [[NSLock alloc] init];
    
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *blockOp1 = [NSBlockOperation blockOperationWithBlock:^{
        [self count];
    }];
    
    NSBlockOperation *blockOp2 = [NSBlockOperation blockOperationWithBlock:^{
        [self count];
    }];
    
    [queue1 addOperation:blockOp1];
    [queue2 addOperation:blockOp2];
}

- (void)count {
    while (1) {
        
        // 加锁
        [self.lock lock];
        
        if (self.totalCount > 0) {
            self.totalCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余:%ld 窗口:%@", self.totalCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        
        // 解锁
        [self.lock unlock];
        
        if (self.totalCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

// 添加依赖
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

- (void)setMaxConcurrentOperationCount {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3; // > 1 并行，= 1 串行；开启线程数量是由系统决定的
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

// MARK: - NSOperation 子类

- (void)useInvocationOperation {
//    // 1. 创建 NSInvocationOperation 对象
//    NSInvocationOperation *invocationOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
//
//    // 2. 开始执行操作
//    [invocationOp start];
    
    [NSThread detachNewThreadSelector:@selector(task1) toTarget:self withObject:nil];
}

- (void)task1 {
    NSLog(@"任务1");
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务1 ----- %@", [NSThread currentThread]);
    }
}

- (void)useBlockOperation {
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务2");
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"任务2 ----- %@", [NSThread currentThread]);
        }
    }];
    
    for (int i = 0; i < 3; i++) {
        // 添加额外操作
        [blockOp addExecutionBlock:^{
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2];
                NSLog(@"任务2 ----- %@", [NSThread currentThread]);
            }
        }];
    }
    
    [blockOp start];
}

- (void)useCustomOperation {
    CustomOperation *op = [[CustomOperation alloc] init];
    [op start];
}

- (void)setupUI {
    UIButton *item0 = [UIButton buttonWithTitle:@"NSInvocationOperation" tag:0 backgroundColor:[UIColor blackColor] target:self action:@selector(useInvocationOperation)];
    item0.frame = CGRectMake(30, 150, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item0];
    
    UIButton *item1 = [UIButton buttonWithTitle:@"NSBlockOperation" tag:1 backgroundColor:[UIColor redColor] target:self action:@selector(useBlockOperation)];
    item1.frame = CGRectMake(30, 200, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item1];
    
    UIButton *item2 = [UIButton buttonWithTitle:@"NSBlockOperation" tag:2 backgroundColor:[UIColor cyanColor] target:self action:@selector(useCustomOperation)];
    item2.frame = CGRectMake(30, 250, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item2];
    
    UIButton *item3 = [UIButton buttonWithTitle:@"addOperation" tag:3 backgroundColor:[UIColor systemPinkColor] target:self action:@selector(addOperationToQueue)];
    item3.frame = CGRectMake(30, 350, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item3];
    
    UIButton *item4 = [UIButton buttonWithTitle:@"addOperationWithBlock" tag:4 backgroundColor:[UIColor systemTealColor] target:self action:@selector(addOperationWithBlockToQueue)];
    item4.frame = CGRectMake(30, 400, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item4];
    
    UIButton *item5 = [UIButton buttonWithTitle:@"setMaxConcurrentOperationCount" tag:5 backgroundColor:[UIColor systemPurpleColor] target:self action:@selector(setMaxConcurrentOperationCount)];
    item5.frame = CGRectMake(30, 450, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item5];
    
    UIButton *item6 = [UIButton buttonWithTitle:@"addDependency" tag:6 backgroundColor:[UIColor systemPurpleColor] target:self action:@selector(addDependency)];
    item6.frame = CGRectMake(30, 500, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item6];
    
    UIButton *item7 = [UIButton buttonWithTitle:@"线程安全" tag:7 backgroundColor:[UIColor systemPurpleColor] target:self action:@selector(threadSafe)];
    item7.frame = CGRectMake(30, 550, self.view.bounds.size.width - 30 * 2, 40);
    [self.view addSubview:item7];
}

- (void)setup {
    
    self.title = @"NSOperation";
    self.view.backgroundColor = [UIColor blueColor];
    
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

@end
