//
//  AppDelegate.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/21.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "AppDelegate.h"
#import "SXXMPPTools.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey:SXLoginUserNameKey];
//    [defaults removeObjectForKey:SXLoginPasswordKey];
//    [defaults removeObjectForKey:SXLoginHostnameKey];
//    [defaults synchronize];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    // 注册通知，监听连接登录的状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatus) name:SXLoginResultNotification object:nil];
    
    // 根据系统偏好中的内容 & 登录情况，决定显示那一个视图控制器
#warning failed没有测试
    
    // 那个errormessage在哪填写了
    // 为什么非要在主线程发送通知
    if (![[SXXMPPTools sharedXMPPTools] connectionWithFailed:nil]) {
        // 显示登录视图控制器
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
        self.window.rootViewController = sb.instantiateInitialViewController;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

/** 登陆状态改变调用 */
- (void)loginStatus {
    NSLog(@"接收到通知 %@", [NSThread currentThread]);
    
    // 成功
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 切换视图控制器
    self.window.rootViewController = sb.instantiateInitialViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
