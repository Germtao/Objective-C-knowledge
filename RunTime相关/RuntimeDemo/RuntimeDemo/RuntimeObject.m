//
//  RuntimeObject.m
//  RuntimeDemo
//
//  Created by QDSG on 2019/5/27.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "RuntimeObject.h"
#import <objc/runtime.h>

@implementation RuntimeObject

+ (void)load {
    // 获取test方法
    Method test = class_getInstanceMethod(self, @selector(test));
    
    // 获取otherTest方法
    Method otherTest = class_getInstanceMethod(self, @selector(otherTest));
    
    // 交换两个方法的实现
    method_exchangeImplementations(test, otherTest);
}

- (void)test {
    NSLog(@"%@ - test", NSStringFromClass([self class]));
}

- (void)otherTest {
    // 实际上调用的test方法
    [self otherTest];
    NSLog(@"%@ - otherTest", NSStringFromClass([self class]));
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    // 如果调用的是test方法，打印日志
    if (sel == @selector(test)) {
        NSLog(@"%@ - resolveInstanceMethod:", NSStringFromClass([self class]));
        return NO;
    } else {
        return [super resolveInstanceMethod:sel];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"%@ - forwardingTargetForSelector:", NSStringFromClass([self class]));
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(test)) {
        NSLog(@"%@ - methodSignatureForSelector:", NSStringFromClass([self class]));
        // v - 返回值 void, @ - 第一个参数类型是id(即 self), : - 第二个参数类型是SEL(即@selector())
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    } else {
        return [super methodSignatureForSelector:aSelector];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"%@ - forwardInvocation:", NSStringFromClass([self class]));
}

@end
