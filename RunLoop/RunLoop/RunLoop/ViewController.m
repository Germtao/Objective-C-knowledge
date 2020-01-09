//
//  ViewController.m
//  RunLoop
//
//  Created by QDSG on 2019/6/14.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test1];
}

- (void)test1 {
    NSLog(@"1");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"2");
        
        [self performSelector:@selector(test) withObject:nil afterDelay:2];
        
        [[NSRunLoop currentRunLoop] run];
        
        NSLog(@"3");
    });
    
    NSLog(@"4");
}

- (void)test {
    NSLog(@"5");
}

@end
