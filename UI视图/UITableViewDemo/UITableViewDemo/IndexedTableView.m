//
//  IndexedTableView.m
//  UITableViewDemo
//
//  Created by QDSG on 2019/5/21.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "IndexedTableView.h"
#import "ViewReusePool.h"

@interface IndexedTableView ()
{
    UIView *_containerView;
    ViewReusePool *_reusePool;
}

@end

@implementation IndexedTableView

- (void)reloadData {
    [super reloadData];
    
    // 懒加载
    if (_containerView == nil) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.backgroundColor = [UIColor whiteColor];
        
        // 避免索引条随着table滚动
        [self.superview insertSubview:_containerView aboveSubview:self];
    }
    
    if (_reusePool == nil) {
        _reusePool = [[ViewReusePool alloc] init];
    }
    
    // 标记所有视图为可复用状态
    [_reusePool reset];
    
    // reload字母索引条
    [self reloadIndexedBar];
}

- (void)reloadIndexedBar {
    // 获取字母索引条的显示内容
    NSArray<NSString *> *arrayTitles = nil;
    
    if ([self.indexedDataSource respondsToSelector:@selector(indexTitlesForIndexTableView:)]) {
        arrayTitles = [self.indexedDataSource indexTitlesForIndexTableView:self];
    }
    
    // 判断字母索引是否为空
    if (!arrayTitles || arrayTitles.count <= 0) {
        _containerView.hidden = YES;
        return;
    }
    
    NSUInteger count = arrayTitles.count;
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = self.frame.size.height / count;
    
    for (int i = 0; i < arrayTitles.count; i++) {
        NSString *title = arrayTitles[i];
        
        // 从复用池中取出一个button
        UIButton *button = (UIButton *)[_reusePool dequeueReuseableView];
        if (button == nil) {
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            button.backgroundColor = [UIColor whiteColor];
            
            // 注册button到复用池中
            [_reusePool addUsingView:button];
            NSLog(@"新建一个button...");
        } else {
            NSLog(@"button 重用了...");
        }
        
        // 添加button到父视图控件
        [_containerView addSubview:button];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0, i * buttonHeight, buttonWidth, buttonHeight);
    }
    
    _containerView.hidden = NO;
    _containerView.frame  = CGRectMake(self.frame.origin.x + self.frame.size.width - buttonWidth, self.frame.origin.y, buttonWidth, buttonHeight);
}

@end
