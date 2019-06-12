//
//  MenuViewController.h
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MenuViewController;

@protocol MenuViewControllerDelegate <NSObject>

- (void)menuController:(MenuViewController *)controller didSelectedAtIndex:(NSUInteger)index;

@end

@interface MenuViewController : UIViewController

@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
