//
//  KVOObserver.m
//  KVO_TEST
//
//  Created by QDSG on 2019/5/24.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "KVOObserver.h"
#import "KVOObject.h"

@implementation KVOObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([object isKindOfClass:[KVOObject class]] &&
        [keyPath isEqualToString:@"value"]) {
        
        // 获取value的新值
        NSNumber *valueNum = [change valueForKey:NSKeyValueChangeNewKey];
        NSLog(@"value is %@", valueNum);
    }
}

@end
