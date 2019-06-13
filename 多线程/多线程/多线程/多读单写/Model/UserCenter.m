//
//  UserCenter.m
//  多线程
//
//  Created by QDSG on 2019/6/13.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "UserCenter.h"

@interface UserCenter ()

/// 定义一个并发队列
@property (nonatomic, strong) dispatch_queue_t concurrent_queue;

/// 用户数据中心, 可能多个线程需要数据访问
@property (nonatomic, strong) NSMutableDictionary *userCenterDict;

@end

// 多读单写模型
@implementation UserCenter

- (instancetype)init {
    self = [super init];
    if (self) {
        _concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        _userCenterDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    __block id obj;
    
    // 同步读取指定数据
    dispatch_sync(self.concurrent_queue, ^{
        obj = [self.userCenterDict objectForKey:key];
    });
    
    return obj;
}

- (void)setObject:(id)obj forKey:(NSString *)key {
    // 异步栅栏调用数据
    dispatch_barrier_async(self.concurrent_queue, ^{
        [self.userCenterDict setObject:obj forKey:key];
    });
}

@end
