//
//  MasterViewController.m
//  多线程
//
//  Created by QDSG on 2019/6/12.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "MasterViewController.h"
#import "SubController/MenuViewController.h"
#import "SubController/GCDViewController.h"
#import "SubController/OperationViewController.h"

@interface MasterViewController () <MenuViewControllerDelegate>

@property (nonatomic, strong) MenuViewController *menuVc;

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, strong) UIViewController *currentController;
@property (nonatomic, assign) NSUInteger currentIndex;

/// 记录菜单是否打开
@property (nonatomic, assign) BOOL isMenuOpen;

/// 判断动画是否正在执行
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UISwipeGestureRecognizer * swip;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.swip];
    [self addMenuViewController];
    [self addContentViewControllers];
}

- (void)addMenuViewController {
    self.menuVc = [[MenuViewController alloc] init];
    self.menuVc.delegate = self;
    [self addChildViewController:self.menuVc];
    [self.view addSubview:self.menuVc.view];
}

- (void)addContentViewControllers {
    GCDViewController *gcdVc = [[GCDViewController alloc] init];
    UINavigationController *gcdNav = [[UINavigationController alloc] initWithRootViewController:gcdVc];
    
    OperationViewController *operationVc = [[OperationViewController alloc] init];
    UINavigationController *operationNav = [[UINavigationController alloc] initWithRootViewController:operationVc];
    
    [self setViewControllers:@[gcdNav, operationNav]];
    [self setCurrentController:gcdNav];
}

- (void)setCurrentController:(UIViewController *)currentController {
    if (_currentController == currentController) {
        return;
    }
    
    // 移除旧控制器
    [_currentController willMoveToParentViewController:nil];
    [_currentController.view removeFromSuperview];
    [_currentController removeFromParentViewController];
    
    // 添加新控制器
    _currentController = currentController;
    [self addChildViewController:currentController];
    [self.view addSubview:currentController.view];
}

- (void)openOrCloseMenu {
    
    if (self.isAnimating) { return; }
    
    [self setCurrentController:self.viewControllers[self.currentIndex]];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.isAnimating = YES;
        if (!self.isMenuOpen) {
            [self.maskView removeFromSuperview];
            [self.currentController.view addSubview:self.maskView];
            self.maskView.frame = self.currentController.view.bounds;
            self.currentController.view.transform = CGAffineTransformMakeTranslation(180, 0);
        } else {
            [self.maskView removeFromSuperview];
            [self.menuVc.view addSubview:self.maskView];
            self.maskView.frame = self.menuVc.view.bounds;
            self.currentController.view.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        self.isMenuOpen = !self.isMenuOpen;
        self.isAnimating = NO;
        if (self.isMenuOpen) {
            [self.view removeGestureRecognizer:self.swip];
            self.swip.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.maskView addGestureRecognizer:self.swip];
        } else {
            [self.maskView removeGestureRecognizer:self.swip];
            self.swip.direction = UISwipeGestureRecognizerDirectionRight;
            [self.view addGestureRecognizer:self.swip];
        }
    }];
}

#pragma mark - Menu View Controller Delegate
- (void)menuController:(MenuViewController *)controller didSelectedAtIndex:(NSUInteger)index {
    self.currentIndex = index;
    
    [self openOrCloseMenu];
}

#pragma mark - Lazy Load

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.26];
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseMenu)]];
    }
    return _maskView;
}

- (UISwipeGestureRecognizer *)swip {
    if (!_swip) {
        _swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseMenu)];
        _swip.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _swip;
}

@end
