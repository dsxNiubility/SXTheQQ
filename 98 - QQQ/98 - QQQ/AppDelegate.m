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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SXLoginUserNameKey];
    [defaults removeObjectForKey:SXLoginPasswordKey];
    [defaults removeObjectForKey:SXLoginHostnameKey];
    [defaults synchronize];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    // 根据系统偏好中的内容 & 登录情况，决定显示那一个视图控制器
#warning failed没有测试
    if (![[SXXMPPTools sharedXMPPTools] connectionWithFailed:nil]) {
        // 显示登录视图控制器
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
        self.window.rootViewController = sb.instantiateInitialViewController;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
