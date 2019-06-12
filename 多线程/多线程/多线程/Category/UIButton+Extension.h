//
//  UIButton+Extension.h
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Extension)

+ (instancetype)buttonWithTitle:(nullable NSString *)title
                            tag:(NSInteger)tag
                backgroundColor:(UIColor *)backgroundColor
                         target:(nonnull id)target
                         action:(nonnull SEL)action;

@end

NS_ASSUME_NONNULL_END
