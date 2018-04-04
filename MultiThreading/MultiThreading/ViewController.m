//
//  ViewController.m
//  MultiThreading
//
//  Created by TT on 2018/4/1.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "ViewController.h"
#import "NSThreadController.h"
#import "NSOperationController.h"
#import "GCDController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)ThreadAction:(UIButton *)sender {

//    NSThreadController *thread = [[NSThreadController alloc] init];
//    thread.title = @"NSThread";
//    [self.navigationController pushViewController:thread animated:YES];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showThread"]) {
        NSThreadController *thread = segue.destinationViewController;
        thread.title = @"NSThread";
    }
    else if ([segue.identifier isEqualToString:@"showOperation"]) {
        NSOperationController *operation = segue.destinationViewController;
        operation.title = @"NSOperation";
    }
}

//- (IBAction)NSOperationAction:(UIButton *)sender {
//
//    NSOperationController *operation = [[NSOperationController alloc] init];
//    operation.title = @"NSOperation";
//    [self.navigationController pushViewController:operation animated:YES];
//}

- (IBAction)GCDAction:(UIButton *)sender {
    
    GCDController *gcd = [[GCDController alloc] init];
    gcd.title = @"GCD";
    [self.navigationController pushViewController:gcd animated:YES];
}

@end
