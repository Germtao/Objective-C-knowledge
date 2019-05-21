//
//  IndexedTableView.h
//  UITableViewDemo
//
//  Created by QDSG on 2019/5/21.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IndexedTableViewDataSource <NSObject>

// 获取一个tableView的字母索引条数据的方法
- (NSArray<NSString *> *)indexTitlesForIndexTableView:(UITableView *)tableView;

@end

@interface IndexedTableView : UITableView

@property (nonatomic, weak) id <IndexedTableViewDataSource> indexedDataSource;

@end

NS_ASSUME_NONNULL_END
