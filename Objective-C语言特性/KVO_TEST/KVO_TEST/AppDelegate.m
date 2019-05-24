//
//  AppDelegate.m
//  KVO_TEST
//
//  Created by QDSG on 2019/5/24.
//  Copyright © 2019 unitTao. All rights reserved.
//

#import "AppDelegate.h"
#import "KVOObserver.h"
#import "KVOObject.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    KVOObject *obj = [[KVOObject alloc] init];
    KVOObserver *observer = [[KVOObserver alloc] init];
    
    // 调用kvo方法监听obj的value属性
    [obj addObserver:observer forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
    
    // setter修改value值
    obj.value = 1;
    
    /** 问题 */
    // 1. 通过KVC设置value能否生效？ 能
    [obj setValue:@2 forKey:@"value"];
    
    // 2. 通过成员变量直接赋值value能否生效？ 不能，但是手动可以
    [obj increase];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
