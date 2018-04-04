//
//  GCDController.m
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "GCDController.h"

NSString *const kImgUrl1 = @"https://upload-images.jianshu.io/upload_images/1252638-663a7cfca2c1eca8.jpeg";

NSString *const kImgUrl2 = @"https://upload-images.jianshu.io/upload_images/27219-114abab0a4bc26df.jpeg";

@interface GCDController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation GCDController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载图片

- (void)loadImageWithUrl:(NSString *)imgUrl {
    
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
    UIImage *image = [UIImage imageWithData:imgData];
    
    if (imgData != nil) {
        [self performSelectorOnMainThread:@selector(refreshUI:) withObject:image waitUntilDone:NO];
    }
}

- (void)refreshUI:(UIImage *)image {
    self.imageView1.image = image;
}

#pragma mark - GCD创建线程

// 后台执行线程创建
- (IBAction)backgroundThread:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self loadImageWithUrl:kImgUrl1];
    });
}

// UI执行线程创建(只是为了测试，长时间加载内容不放在主线程)
- (IBAction)UIThread:(UIButton *)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadImageWithUrl:kImgUrl2];
    });
}

// 一次性执行（常用来写 单例）
- (IBAction)onceThread:(UIButton *)sender {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadImageWithUrl:kImgUrl1];
    });
}

// 并发地执行循环迭代
- (IBAction)concurrentThread:(UIButton *)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    size_t count = 10;
    dispatch_apply(count, queue, ^(size_t index) {
        NSLog(@"循环执行第%li次", index);
        
        [self loadImageWithUrl:kImgUrl2];
    });
}

// 延迟执行
- (IBAction)delayThread:(UIButton *)sender {
    
    double delaySeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self loadImageWithUrl:kImgUrl1];
    });
}

// 自定义
- (IBAction)customThread:(UIButton *)sender {
    
    dispatch_queue_t urls_queue = dispatch_queue_create("germtao.app.com", NULL);
    dispatch_async(urls_queue, ^{
        [self loadImageWithUrl:kImgUrl2];
    });
}

#pragma mark - 对比多任务执行

// 先后执行（串行队列）
- (IBAction)serialQueue:(UIButton *)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        UIImage *img1 = [self loadImageWith:kImgUrl1];
        UIImage *img2 = [self loadImageWith:kImgUrl2];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView1.image = img1;
            self.imageView2.image = img2;
        });
    });
}

- (IBAction)parallelQueue:(UIButton *)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        dispatch_group_t group = dispatch_group_create();
        
        __block UIImage *img1 = nil;
        __block UIImage *img2 = nil;
        
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            img1 = [self loadImageWith:kImgUrl2];
        });
        
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            img2 = [self loadImageWith:kImgUrl1];
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            self.imageView1.image = img1;
            self.imageView2.image = img2;
        });
    });
    
}

- (UIImage *)loadImageWith:(NSString *)imgUrl {
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
    UIImage *image = [UIImage imageWithData:imgData];
    return image;
}

@end
