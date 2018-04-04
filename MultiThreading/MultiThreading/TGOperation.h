//
//  TGOperation.h
//  MultiThreading
//
//  Created by TT on 2018/4/3.
//  Copyright © 2018年 T AO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TGOperationDelegate <NSObject>

- (void)loadImageDidFinished:(UIImage *)image;

@end

@interface TGOperation : NSOperation

@property (nonatomic, weak) id <TGOperationDelegate> delegate;

@property (nonatomic, copy) NSString *imgUrl;

@end
