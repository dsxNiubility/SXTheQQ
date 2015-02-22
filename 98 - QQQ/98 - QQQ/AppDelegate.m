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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusWithNotification:) name:SXLoginResultNotification object:nil];
    
    // 根据系统偏好中的内容 & 登录情况，决定显示那一个视图控制器
#warning failed没有测试
    
    // 那个errormessage在哪填写了
    // 为什么非要在主线程发送通知
    if (![[SXXMPPTools sharedXMPPTools] connectionWithFailed:nil]) {
        [self setupWindowViewControllerWithName:@"Login"];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

/** 登陆状态改变调用 */
- (void)loginStatusWithNotification:(NSNotification *)no {
    NSLog(@"接收到通知 %@", [NSThread currentThread]);
    
    if ([no.object intValue]) {
        [self setupWindowViewControllerWithName:@"Main"];
    }else{
        [self setupWindowViewControllerWithName:@"Login"];
    }

}


/** 设置window根控制器的方法 */
- (void)setupWindowViewControllerWithName:(NSString *)name {
    // 根据name加载Storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:name bundle:nil];
    
    // 切换视图控制器
    self.window.rootViewController = sb.instantiateInitialViewController;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    [[SXXMPPTools sharedXMPPTools] disconnect];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 重新连接
    [[SXXMPPTools sharedXMPPTools] connectionWithFailed:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的密码可能在其他的计算机上被修改，请重新登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
