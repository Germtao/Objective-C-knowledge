//
//  ViewReusePool.h
//  UITableViewDemo
//
//  Created by QDSG on 2019/5/21.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 实现重用机制的类
@interface ViewReusePool : NSObject

/// 从复用池中取出一个可重用的view
- (UIView *)dequeueReuseableView;

/// 向复用池中添加一个视图
- (void)addUsingView:(UIView *)view;

/// 重置方法, 将当前使用中的视图移动到可重用队列中
- (void)reset;

@end

NS_ASSUME_NONNULL_END
