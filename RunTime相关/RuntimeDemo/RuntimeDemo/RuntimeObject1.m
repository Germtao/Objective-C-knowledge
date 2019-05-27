//
//  RuntimeObject.m
//  RuntimeDemo
//
//  Created by QDSG on 2019/5/27.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "RuntimeObject1.h"
#import <objc/runtime.h>

@implementation RuntimeObject1

void testIMP(void) {
    NSLog(@"test invoke...");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    // 如果调用的是test方法，打印日志
    if (sel == @selector(test)) {
        NSLog(@"%@ - resolveInstanceMethod:", NSStringFromClass([self class]));
        
        //  动态添加test方法的实现
        class_addMethod(self, @selector(test), testIMP, "v@:");
        
        return YES;
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
