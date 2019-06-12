//
//  GCDViewController.m
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup {
    
    self.title = @"GCD";
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.view.layer.shadowOffset = CGSizeMake(-10, 0);
    self.navigationController.view.layer.shadowOpacity = 0.15;
    self.navigationController.view.layer.cornerRadius = 10.0;
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"menu"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(openOrCloseMenu)];
    self.navigationItem.leftBarButtonItem = menuItem;
}

- (void)openOrCloseMenu {
    [self.navigationController.parentViewController performSelector:@selector(openOrCloseMenu)];
}

@end
