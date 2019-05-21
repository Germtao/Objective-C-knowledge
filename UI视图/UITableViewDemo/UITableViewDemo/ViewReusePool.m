//
//  ViewReusePool.m
//  UITableViewDemo
//
//  Created by QDSG on 2019/5/21.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "ViewReusePool.h"

@interface ViewReusePool ()

/// 等待使用的队列
@property (nonatomic, strong) NSMutableSet *waitUsedQueue;

/// 正在使用的队列
@property (nonatomic, strong) NSMutableSet *usingQueue;

@end

@implementation ViewReusePool

- (instancetype)init {
    self = [super init];
    if (self) {
        self.waitUsedQueue = [NSMutableSet set];
        self.usingQueue = [NSMutableSet set];
    }
    return self;
}

- (UIView *)dequeueReuseableView {
    UIView *view = [self.waitUsedQueue anyObject];
    if (view == nil) {
        return nil;
    } else {
        // 进行队列移动
        [self.waitUsedQueue removeObject:view];
        [self.usingQueue addObject:view];
        return view;
    }
}

- (void)addUsingView:(UIView *)view {
    if (view == nil) {
        return;
    }
    
    // 添加视图到使用中的队列
    [self.usingQueue addObject:view];
}

- (void)reset {
    UIView *view = nil;
    
    while ((view = [self.usingQueue anyObject])) {
        // 从使用中队列移除
        [self.usingQueue removeObject:view];
        // 加入等待使用队列中
        [self.waitUsedQueue addObject:view];
    }
}

@end
