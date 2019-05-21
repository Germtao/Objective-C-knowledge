//
//  ViewController.m
//  UITableViewDemo
//
//  Created by QDSG on 2019/5/21.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "ViewController.h"
#import "IndexedTableView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, IndexedTableViewDataSource>
{
    IndexedTableView *_tableView; // 带有索引条的tableView
    UIButton *_button;
    NSMutableArray *_dataSource;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTableView];
    [self createButton];
    [self setupData];
}

- (void)createTableView {
    _tableView = [[IndexedTableView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 60) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // 设置tableview的索引数据源
    _tableView.indexedDataSource = self;
    [self.view addSubview:_tableView];
}

- (void)createButton {
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    _button.backgroundColor = [UIColor redColor];
    [_button setTitle:@"refresh" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)setupData {
    _dataSource = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        [_dataSource addObject:@(i + 1)];
    }
}

#pragma mark - IndexedTableViewDataSource
- (NSArray<NSString *> *)indexTitlesForIndexTableView:(UITableView *)tableView {
    // 奇数次调用返回6个字母，偶数次调用返回11个
    static BOOL changed = NO;
    
    if (changed) {
        changed = NO;
        return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K"];
    } else {
        changed = YES;
        return @[@"A", @"B", @"C", @"D", @"E", @"F"];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"reuseId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [_dataSource[indexPath.row] stringValue];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - Action
- (void)doAction:(UIButton *)sender {
    NSLog(@"reload data...");
    [_tableView reloadData];
}

@end
