//
//  NSThreadController.m
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "NSThreadController.h"

@interface NSThreadController ()

@end

@implementation NSThreadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self dynamicInstance];
    
    [self staticInstance];
    
    [self implicitInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSThread 创建线程的三种方法

// 动态实例方法
- (void)dynamicInstance {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(task:) object:@"dynamicCreateThread"];
    thread.threadPriority = 1.0; // 设置优先级（0.0、-1.0、1.0最高级）
    [thread start];
}

// 静态实例方法
- (void)staticInstance {
    [NSThread detachNewThreadSelector:@selector(thread:) toTarget:self withObject:@"staticCreateThread"];
}

// 隐式实例方法
// 后台线程，自动启动
- (void)implicitInstance {
    [self performSelectorInBackground:@selector(backgroundThread:) withObject:@"implicitCreateThread"];
}

#pragma mark - Event

- (void)task:(NSString *)str {
    NSLog(@"动态实例方法 %@", str);
}

- (void)thread:(NSString *)str {
    NSLog(@"静态实例方法 %@", str);
}

- (void)backgroundThread:(NSString *)str {
    NSLog(@"隐式实例方法 %@", str);
}

@end
