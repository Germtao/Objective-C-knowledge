//
//  KVOObject.h
//  KVO_TEST
//
//  Created by QDSG on 2019/5/24.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVOObject : NSObject

@property (nonatomic, assign) int value;

- (void)increase;

@end

NS_ASSUME_NONNULL_END
