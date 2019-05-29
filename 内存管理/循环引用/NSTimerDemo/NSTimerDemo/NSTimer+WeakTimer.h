//
//  NSTimer+WeakTimer.h
//  NSTimerDemo
//
//  Created by QDSG on 2019/5/29.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (WeakTimer)

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)interval
                                            target:(id)aTarget
                                          selector:(SEL)aSelector
                                          userInfo:(id)userInfo
                                           repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
