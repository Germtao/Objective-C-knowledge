//
//  MenuViewController.m
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "MenuViewController.h"
#import "UIButton+Extension.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addMenuItems];
}

- (void)addMenuItems {
    UIButton *item0 = [UIButton buttonWithTitle:@"GCD"
                                            tag:0
                                backgroundColor:[UIColor orangeColor]
                                         target:self
                                         action:@selector(menuItemsSelected:)];
    
    UIButton *item1 = [UIButton buttonWithTitle:@"NSOperation"
                                            tag:1
                                backgroundColor:[UIColor blueColor]
                                         target:self
                                         action:@selector(menuItemsSelected:)];
    
    UIButton *item2  = [UIButton buttonWithTitle:@"NSThread"
                                             tag:2
                                 backgroundColor:[UIColor redColor]
                                          target:self
                                          action:@selector(menuItemsSelected:)];
    
    item0.frame = CGRectMake(0, 100, 180, 40);
    item1.frame = CGRectMake(0, 140, 180, 40);
    item2.frame = CGRectMake(0, 180, 180, 40);
    [self.view addSubview:item0];
    [self.view addSubview:item1];
    [self.view addSubview:item2];
}

- (void)menuItemsSelected:(UIButton *)sender {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(menuController:didSelectedAtIndex:)]) {
        [self.delegate menuController:self didSelectedAtIndex:sender.tag];
    }
}

@end
