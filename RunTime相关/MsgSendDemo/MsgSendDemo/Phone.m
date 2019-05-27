//
//  Phone.m
//  MsgSendDemo
//
//  Created by QDSG on 2019/5/27.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "Phone.h"

@implementation Phone

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"self = %@", NSStringFromClass([self class]));
        NSLog(@"super = %@", NSStringFromClass([super class]));
    }
    return self;
}

@end
