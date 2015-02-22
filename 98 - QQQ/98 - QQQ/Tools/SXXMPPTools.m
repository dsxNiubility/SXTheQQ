//
//  SXXMPPTools.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/21.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXXMPPTools.h"


// 用户偏好的键值
// 用户名
NSString *const SXLoginUserNameKey = @"SXLoginUserNameKey";
// 密码
NSString *const SXLoginPasswordKey = @"SXLoginPasswordKey";
// 主机名
NSString *const SXLoginHostnameKey = @"SXLoginHostnameKey";

// 通知字符串定义
NSString *const SXLoginResultNotification = @"SXLoginResultNotification";

@interface SXXMPPTools ()<XMPPStreamDelegate>

/** 存储失败的回掉 */
@property(nonatomic,strong) void (^failed) (NSString * errorMessage);

@end

@implementation SXXMPPTools

@synthesize xmppStream = _xmppStream;

#pragma mark - ******************** 懒加载
- (XMPPStream *)xmppStream
{
    if (_xmppStream == nil) {
        _xmppStream = [[XMPPStream alloc]init];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _xmppStream;
}

#pragma mark - ******************** 单例方法
+ (instancetype)sharedXMPPTools {
    static SXXMPPTools *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - ******************** 连接方法
/** 断开连接 */
- (void)disconnect
{
    // 通知服务器，用户下线
    [self goOffline];
    
    [self.xmppStream disconnect];
}

/** 连接方法有失败block回调 */
- (BOOL)connectionWithFailed:(void (^)(NSString *errorMessage))failed
{
    // 需要指定myJID & hostName
    NSString *hostName = [[NSUserDefaults standardUserDefaults] stringForKey:SXLoginHostnameKey];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:SXLoginUserNameKey];
    
    // 判断hostName & userName 是否有内容
    if (hostName.length == 0 || username.length == 0) {
        // 用户偏好中没有记录
        return NO;
    }
    
    // 保存块代码
    self.failed = failed;
    
    // 设置xmppStream的连接信息
    self.xmppStream.hostName = hostName;
    username = [username stringByAppendingFormat:@"@%@", hostName];
    self.xmppStream.myJID = [XMPPJID jidWithString:username];
    
    // 连接到服务器，如果连接已经存在，则不做任何事情
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:NULL];
    
    return YES;
}

#pragma mark - ******************** 用户的上线和下线
- (void)goOnline {
    XMPPPresence *p = [XMPPPresence presence];
    
    [self.xmppStream sendElement:p];
}

- (void)goOffline {
    XMPPPresence *p = [XMPPPresence presenceWithType:@"unavailable"];
    
    [self.xmppStream sendElement:p];
}

- (void)logout {
    // 所有用户信息是保存在用户偏好，注销应该删除用户偏好记录
    [self clearUserDefaults];
    
    // 下线，并且断开连接
    [self disconnect];
}

#pragma mark - ******************** xmpp流代理方法
/** 连接成功时调用 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接成功");
    
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:SXLoginPasswordKey];
    
    [self.xmppStream authenticateWithPassword:password error:NULL];
}

/** 断开连接时调用 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"断开连接");
    
    // 在主线程更新UI(用户自己断开的不算)
    if (self.failed && error) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"无法连接到服务器");});
    }
}

/** 授权成功时调用 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"授权成功");
    
    // 通知服务器用户上线
    [self goOnline];
    
    // 在主线程利用通知发送广播
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SXLoginResultNotification object:@(YES)];
    });
}

/** 授权失败时调用 */
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"授权失败");
    
    // 断开与服务器的连接
    [self disconnect];
    // 清理用户偏好
    [self clearUserDefaults];
    
    // 在主线程更新UI
    if (self.failed) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"用户名或者密码错误！");});
    }
    
    // 在主线程利用通知发送广播
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SXLoginResultNotification object:@(NO)];
    });
}

/** 清除用户的偏好 */
- (void)clearUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // $$$$$
    
    [defaults removeObjectForKey:SXLoginUserNameKey];
    [defaults removeObjectForKey:SXLoginPasswordKey];
    [defaults removeObjectForKey:SXLoginHostnameKey];
    
    // 刚存完偏好设置，必须同步一下
    [defaults synchronize];
}

@end
