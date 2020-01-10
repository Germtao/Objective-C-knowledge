//
//  ThreadViewController.m
//  多线程
//
//  Created by QDSG on 2020/1/10.
//  Copyright © 2020 unitTao. All rights reserved.
//

#import "ThreadViewController.h"

@interface ThreadViewController ()

@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
//    [self createThread];
    [self thread];
}

- (void)thread {
    // 在当前线程，延迟1s执行。响应了OC语言的动态性：延迟到运行时才绑定方法
    [self performSelector:@selector(testThread:) withObject:@"延迟1s - thread" afterDelay:1];
    
    // 回到主线程。
    // waitUntilDone:是否将该回调方法执行完在执行后面的代码，
    // YES：就必须等回调方法执行完成之后才能执行后面的代码，说白了就是阻塞当前的线程；
    // NO：就是不等回调方法结束，不会阻塞当前线程
    [self performSelectorOnMainThread:@selector(testThread:) withObject:@"回到主线程" waitUntilDone:YES];
    
    // 开辟子线程
    [self performSelectorInBackground:@selector(testThread:) withObject:@"开辟子线程"];
    
    // 在指定线程执行
    [self performSelector:@selector(testThread:) onThread:[NSThread currentThread] withObject:@"在当前线程执行" waitUntilDone:YES];
}

- (void)createThread {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(testThread:) object:@"我是参数"];
    // 当使用初始化方法出来的主线程需要start启动
    [thread start];
    // 可以为开辟的子线程起名字
    thread.name = @"NSThread-1";
    // 线程的优先级，由0.0到1.0之间的浮点数指定，其中1.0是最高优先级。
    // 优先级越高，先执行的概率就会越高，但由于优先级是由内核确定的，因此不能保证此值实际上是多少，默认值是0.5
    thread.threadPriority = 1;
    // 取消当前已经启动的线程
    [thread cancel];
    // 通过遍历构造器开辟子线程
    [NSThread detachNewThreadSelector:@selector(testThread:) toTarget:self withObject:@"构造器开辟子线程"];
}

- (void)testThread:(id)obj {
    NSLog(@"%@", obj);
}

- (void)setup {
    
    self.title = @"NSOperation";
    self.view.backgroundColor = [UIColor blueColor];
    
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
