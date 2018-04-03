//
//  NSOperationController.m
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "NSOperationController.h"

NSString *const ImgUrl = @"https://upload-images.jianshu.io/upload_images/27219-114abab0a4bc26df.jpeg";

@interface NSOperationController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NSOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createInvocationOperation];
    
    [self createBlockOperation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 实例化NSOperation子类

// NSInvocationOperation
- (void)createInvocationOperation {
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocation:) object:@"invocationOperation"];
    [invocation start]; // 在当前线程主线程执行
    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperation:invocation];
}

// NSBlockOperation
- (void)createBlockOperation {
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation");
    }];
    [block start];
    
    // NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // [queue addOperation:block];
}

#pragma mark - event

- (void)invocation:(NSString *)str {
    NSLog(@"%@", str);
}

#pragma mark - 图片异步加载

- (IBAction)invocationOperation:(UIButton *)sender {
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadImage:) object:ImgUrl];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:invocation];
}

- (IBAction)blockOperation:(UIButton *)sender {
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        [self loadImage:ImgUrl];
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:block];
}

- (void)loadImage:(NSString *)url {
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:imgData];
    
    if (imgData != nil) {
        [self performSelectorOnMainThread:@selector(refreshUI:) withObject:image waitUntilDone:YES];
    } else {
        NSLog(@"没有图片");
    }
}

- (void)refreshUI:(UIImage *)image {
    self.imageView.image = image;
}

@end
