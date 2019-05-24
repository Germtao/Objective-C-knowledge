//
//  KVOObject.m
//  KVO_TEST
//
//  Created by QDSG on 2019/5/24.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "KVOObject.h"

@implementation KVOObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _value = 0;
    }
    return self;
}

//- (void)setValue:(int)value {
//    NSLog(@"%d", value);
//}

- (void)increase {
    // 手动触发kvo
    [self willChangeValueForKey:@"value"];
    // 直接为成员变量赋值
    _value += 1;
    [self didChangeValueForKey:@"value"];
}

@end
