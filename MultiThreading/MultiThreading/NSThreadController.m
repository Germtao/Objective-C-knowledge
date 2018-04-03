//
//  NSThreadController.m
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "NSThreadController.h"

NSString *const kImgUrl = @"https://upload-images.jianshu.io/upload_images/1252638-663a7cfca2c1eca8.jpeg";

@interface NSThreadController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NSThreadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self dynamicInstance];
    
    [self staticInstance];
    
    [self implicitInstance];
}

#pragma mark - NSThread 创建线程的三种方法

// 动态实例方法
- (void)dynamicInstance {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(task:) object:@"dynamicCreateThread"];
    thread.threadPriority = 1.0; // 设置优先级（0.0、-1.0、1.0最高级）
    [thread start];
}

// 静态实例方法
- (void)staticInstance {
    [NSThread detachNewThreadSelector:@selector(thread:) toTarget:self withObject:@"staticCreateThread"];
}

// 隐式实例方法
// 后台线程，自动启动
- (void)implicitInstance {
    [self performSelectorInBackground:@selector(backgroundThread:) withObject:@"implicitCreateThread"];
}

#pragma mark - Event

- (void)task:(NSString *)str {
    NSLog(@"动态实例方法 %@", str);
}

- (void)thread:(NSString *)str {
    NSLog(@"静态实例方法 %@", str);
}

- (void)backgroundThread:(NSString *)str {
    NSLog(@"隐式实例方法 %@", str);
}

#pragma mark - 图片异步加载

- (IBAction)dynamicInstanceThread:(UIButton *)sender {
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadImage:) object:kImgUrl];
    [thread start];
}

- (IBAction)staticInstanceThread:(UIButton *)sender {
    [NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:kImgUrl];
}

- (IBAction)implicitInstanceThread:(UIButton *)sender {
    [self performSelectorInBackground:@selector(loadImage:) withObject:kImgUrl];
}

#pragma mark - 加载

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
