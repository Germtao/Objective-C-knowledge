//
//  NSOperationController.m
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "NSOperationController.h"

@interface NSOperationController ()

@end

@implementation NSOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createInvocationOperation];
    
    [self createBlockOperation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 实例化NSOperation子类

// NSInvocationOperation
- (void)createInvocationOperation {
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocation:) object:@"invocationOperation"];
    [invocation start]; // 在当前线程主线程执行
    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperation:invocation];
}

// NSBlockOperation
- (void)createBlockOperation {
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation");
    }];
    [block start];
    
    // NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // [queue addOperation:block];
}

#pragma mark - event

- (void)invocation:(NSString *)str {
    NSLog(@"%@", str);
}

@end
