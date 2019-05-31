//
//  MyBlock.m
//  BlockDemo
//
//  Created by QDSG on 2019/5/29.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "MyBlock.h"

@implementation MyBlock

// 全局变量
int global_var = 4;

// 静态全局变量
static int static_global_var = 5;

- (void)changeMethod {
    // 基本数据类型的局部变量
    int var = 1;
    
    // 对象类型的局部变量
    __unsafe_unretained id unsafe_obj = nil;
    __strong id strong_obj = nil;
    
    // 静态局部变量
    static int static_var = 3;
    
    void(^changeVarBlock)(void) = ^{
        NSLog(@"局部变量<基本数据类型> var = %d", var);
        NSLog(@"局部变量<__unsafe_unretained 对象类型> var = %@", unsafe_obj);
        NSLog(@"局部变量<__strong 对象类型> var = %@", strong_obj);
        
        NSLog(@"静态局部变量 var = %d", static_var);
        
        NSLog(@"全局变量 var = %d", global_var);
        NSLog(@"静态全局变量 var = %d", static_global_var);
    };
    
    changeVarBlock();
}

- (void)method {
    
    int multiplier = 6;
    int(^Block)(int) = ^int(int num) {
        return num * multiplier;
    };
    multiplier = 4;
    
    Block(2);
    
    NSLog(@"result is %d", Block(2));
}

@end
