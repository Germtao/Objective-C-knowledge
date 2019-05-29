//
//  NSTimer+WeakTimer.m
//  NSTimerDemo
//
//  Created by QDSG on 2019/5/29.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "NSTimer+WeakTimer.h"

#pragma mark - 中间对象
@interface TimerWeakObject : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer *timer;

- (void)fire:(NSTimer *)timer;

@end

@implementation TimerWeakObject

- (void)fire:(NSTimer *)timer {
    if (self.target) {
        if ([self.target respondsToSelector:self.selector]) {
            [self.target performSelector:self.selector withObject:timer.userInfo];
        }
    } else {
        [self.timer invalidate];
    }
}

@end

@implementation NSTimer (WeakTimer)

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)interval
                                         target:(id)aTarget
                                       selector:(SEL)aSelector
                                       userInfo:(id)userInfo
                                        repeats:(BOOL)repeats {
    TimerWeakObject *weakObject = [[TimerWeakObject alloc] init];
    weakObject.target = aTarget;
    weakObject.selector = aSelector;
    weakObject.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:weakObject selector:@selector(fire:) userInfo:userInfo repeats:repeats];
    
    return weakObject.timer;
}

@end
