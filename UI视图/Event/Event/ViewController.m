//
//  ViewController.m
//  Event
//
//  Created by QDSG on 2019/5/22.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "ViewController.h"
#import "CustomButton.h"

@interface ViewController ()

@property (nonatomic, strong) CustomButton *cornerButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cornerButton = [[CustomButton alloc] initWithFrame:CGRectMake(100, 100, 120, 120)];
    self.cornerButton.backgroundColor = [UIColor greenColor];
    [self.cornerButton addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cornerButton];
}

- (void)doAction:(UIButton *)sender {
    NSLog(@"corner button clicked...");
}

@end
