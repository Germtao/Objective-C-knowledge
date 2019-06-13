//
//  GroupObject.m
//  多线程
//
//  Created by QDSG on 2019/6/13.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "GroupObject.h"

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
