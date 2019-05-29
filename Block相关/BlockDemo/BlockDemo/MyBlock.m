//
//  MyBlock.m
//  BlockDemo
//
//  Created by QDSG on 2019/5/29.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "MyBlock.h"

@implementation MyBlock

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
