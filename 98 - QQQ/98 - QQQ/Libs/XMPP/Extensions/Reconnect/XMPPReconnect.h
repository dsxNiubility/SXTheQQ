#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "XMPPModule.h"

#define _XMPP_RECONNECT_H

// 默认的重新连接时间延迟 2 秒
#define DEFAULT_XMPP_RECONNECT_DELAY 2.0

// 默认的重新连接时间间隔 20 秒
#define DEFAULT_XMPP_RECONNECT_TIMER_INTERVAL 20.0


@protocol XMPPReconnectDelegate;

/**
 * XMPPReconnect handles automatically reconnecting to the xmpp server due to accidental disconnections.
 * 如果出现意外中断，XMPPReconnect模块能够自动重新连接到服务器
 * That is, a disconnection that is not the result of calling disconnect on the xmpp stream.
 * 也就是说，断开连接不是由调用 disconnection 方法造成的
 * 
 * Accidental disconnections may happen for a variety of reasons.
 * 意外中断可能由很多种原因产生
 * The most common are general connectivity issues such as disconnection from a WiFi access point.
 * 最常见的连接问题例如因为Wi-Fi访问点的原因造成的连接中断
 * 
 * However, there are several of issues that occasionaly occur.
 * 然而，有些原因是偶尔发生的
 * There are some routers on the market that disconnect TCP streams after a period of inactivity.
 * 有些路由器会在闲置一段时间后断开TCP流
 * In addition to this, there have been iPhone revisions where the OS networking stack would pull the same crap.
 * 除此之外，对于iPhone的有些版本，如果 OS 网络协议栈重复从网络上获取同样的数据也会断开连接
 * These issue have been largely overcome due to the keepalive implementation in XMPPStream.
 * XMPPStraem已经在很大程度上解决了这些问题以保持网络连接
 * 
 * Regardless of how the disconnect happens, the XMPPReconnect class can help to automatically re-establish
 * 无论是什么原因导致的网络中断，XMPPReconnect能够帮助自动重新建立 xmpp stream 连接
 * the xmpp stream so as to have minimum impact on the user (and hopefully they don't even notice).
 * 以保证让用户受到的影响最小化，甚至希望用户完全没有意识到网络连接中断过
 * 
 * Once a stream has been opened and authenticated, this class will detect any accidental disconnections.
 * 一旦 XmppStream 已经被打开并且验证通过，这个类将检测任何意外的中断
 * If one occurs, an attempt will be made to automatically reconnect after a short delay.
 * 一旦发生中断，经过短暂的延时之后会尝试自动重新连接
 * This delay is configurable via the reconnectDelay property.
 * 该延时在 reconnectDelay 属性中设置
 * At the same time the class will begin monitoring the network for reachability changes.
 * 与此同时，该类还将监控网络连接状态的变化
 * When the reachability of the xmpp host has changed, a reconnect may be tried again.
 * 如果与 xmpp 主机的连接状态发生改变，也会再次重新连接
 * In addition to all this, a timer may optionally be used to attempt a reconnect periodically.
 * 除了以上情况之外，还可以选择一个时钟尝试周期性重新连接
 * The timer is started if the initial reconnect fails.
 * 如果初始的重新连接失败，时钟会被启动
 * This reconnect timer is fully configurable (may be enabled/disabled, and it's timeout may be changed).
 * 该重新连接时钟是完全可配置的，可以启用／仅用，以及改变超时时长
 * 
 * In all cases, prior to attempting a reconnect,
 * 无论哪种情况，都会首先尝试重新建立连接
 * this class will invoke the shouldAttemptAutoReconnect delegate method.
 * 本类会触发 shouldAttemptAutoReconnect 代理方法
 * The delegate may use this opportunity to optionally decline the auto reconnect attempt.
 * 代理会借此代理方法选择性地取消一些自动重新连接的尝试
 * 
 * Auto reconnect may be disabled at any time via the autoReconnect property.
 * 可以在任意时候通过 autoReconnect 属性禁用自动重新连接
 * 
 * Note that auto reconnect will only occur for a stream that has been opened and authenticated.
 * 注意：自动连接仅在(流已经打开，并且认证通过)用户登录，才会自动重新建立连接！
 * So it will do nothing, for example, if there is no internet connectivity when your application
 * first launches, and the xmpp stream is unable to connect to the host.
 * In cases such as this it may be desireable to start monitoring the network for reachability changes.
 * This way when internet connectivity is restored, one can immediately connect the xmpp stream.
 * This is possible via the manualStart method,
 * which will trigger the class into action just as if an accidental disconnect occurred.
**/

@interface XMPPReconnect : XMPPModule
{
	Byte flags;
	Byte config;
	NSTimeInterval reconnectDelay;
	
	dispatch_source_t reconnectTimer;
	NSTimeInterval reconnectTimerInterval;
	
	SCNetworkReachabilityRef reachability;
	
	int reconnectTicket;
	
#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_5
	SCNetworkConnectionFlags previousReachabilityFlags;
#else
	SCNetworkReachabilityFlags previousReachabilityFlags;
#endif
}

/**
 * Whether auto reconnect is enabled or disabled.
 * 
 * The default value is YES (enabled).
 * 
 * Note: Altering this property will only affect future accidental disconnections.
 * For example, if autoReconnect was true, and you disable this property after an accidental disconnection,
 * this will not stop the current reconnect process.
 * In order to stop a current reconnect process use the stop method.
 * 
 * Similarly, if autoReconnect was false, and you enable this property after an accidental disconnection,
 * this will not start a reconnect process.
 * In order to start a reconnect process use the manualStart method.
 * 默认就是自动重新连接的
**/
@property (nonatomic, assign) BOOL autoReconnect;

/**
 * When the accidental disconnection first happens,
 * a short delay may be used before attempting the reconnection.
 * 
 * The default value is DEFAULT_XMPP_RECONNECT_DELAY (defined at the top of this file).
 * 
 * To disable this feature, set the value to zero.
 * 
 * Note: NSTimeInterval is a double that specifies the time in seconds.
 * 重新连接的时间延迟，所有能够自动周期性执行的工作，都是由定时器来调度的
**/
@property (nonatomic, assign) NSTimeInterval reconnectDelay;

/**
 * A reconnect timer may optionally be used to attempt a reconnect periodically.
 * The timer will be started after the initial reconnect delay.
 * 
 * The default value is DEFAULT_XMPP_RECONNECT_TIMER_INTERVAL (defined at the top of this file).
 * 
 * To disable this feature, set the value to zero.
 * 
 * Note: NSTimeInterval is a double that specifies the time in seconds.
**/
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval;

/**
 * Whether you want to reconnect using the legacy method -[XMPPStream oldSchoolSecureConnectWithTimeout:error:]
 * instead of the standard -[XMPPStream connect:].
 *
 * If you initially connect using -oldSchoolSecureConnectWithTimeout:error:, set this to YES to reconnect the same way.
 *
 * The default value is NO (disabled).
 */
@property (nonatomic, assign) BOOL usesOldSchoolSecureConnect;

/**
 * As opposed to using autoReconnect, this method may be used to manually start the reconnect process.
 * This may be useful, for example, if one needs network monitoring in order to setup the inital xmpp connection.
 * Or if one wants autoReconnect but only in very limited situations which they prefer to control manually.
 * 
 * After invoking this method one can expect the class to act as if an accidental disconnect just occurred.
 * That is, a reconnect attempt will be tried after reconnectDelay seconds,
 * and the class will begin monitoring the network for changes in reachability to the xmpp host.
 * 
 * A manual start of the reconnect process will effectively end once the xmpp stream has been opened.
 * That is, if you invoke manualStart and the xmpp stream is later opened,
 * then future disconnections will not result in an auto reconnect process (unless the autoReconnect property applies).
 * 
 * This method does nothing if the xmpp stream is not disconnected.
**/
- (void)manualStart;

/**
 * Stops the current reconnect process.
 * 
 * This method will stop the current reconnect process regardless of whether the
 * reconnect process was started due to the autoReconnect property or due to a call to manualStart.
 * 
 * Stopping the reconnect process does NOT prevent future auto reconnects if the property is enabled.
 * That is, if the autoReconnect property is still enabled, and the xmpp stream is later opened, authenticated and
 * accidentally disconnected, this class will still attempt an automatic reconnect.
 * 
 * Stopping the reconnect process does NOT prevent future calls to manualStart from working.
 * 
 * It only stops the CURRENT reconnect process.
**/
- (void)stop;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPReconnectDelegate
@optional

/**
 * This method may be used to fine tune when we
 * should and should not attempt an auto reconnect.
 * 
 * For example, if on the iPhone, one may want to prevent auto reconnect when WiFi is not available.
**/
#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_5

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags;
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags;

#else

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags;
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags;

#endif

@end
