//
//  TGOperation.m
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import "TGOperation.h"

@implementation TGOperation

- (void)main {
    
    if (self.isCancelled) {
        return;
    }
    
    NSURL *imgURL = [NSURL URLWithString:self.imgUrl];
    NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
    UIImage *image = [UIImage imageWithData:imgData];
    
    if (imgData != nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(loadImageDidFinished:)]) {
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(loadImageDidFinished:) withObject:image waitUntilDone:NO];
        }
    }
}

@end
