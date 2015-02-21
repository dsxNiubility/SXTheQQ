#import <Foundation/Foundation.h>
#import "XMPPJID.h"

#if TARGET_OS_IPHONE
  #import "DDXML.h"
#endif


/**
 * The XMPPElement provides the base class for XMPPIQ, XMPPMessage & XMPPPresence.
 * XMPPElement 提供了一个XMPPIQ（请求）, XMPPMessage（消息） & XMPPPresence（展现）的基类
 *
 * This class extends NSXMLElement.
 * 扩展了 NSXMLElement
 * The NSXML classes (NSXMLElement & NSXMLNode) provide a full-featured library for working with XML elements.
 * NSXML类(NSXMLElement & NSXMLNode)提供了功能全面的处理XML节点的库，但是iPhone上不能使用，功能灵活，内存消耗大
 * 可以在MAC开发时使用
 * 
 * On the iPhone, the KissXML library provides a drop-in replacement for Apple's NSXML classes.
 * 在iPhone开发时，KissXML第三方库，提供了一个苹果原生类的替代解决方案。
**/

@interface XMPPElement : NSXMLElement <NSCoding, NSCopying>

#pragma mark Common Jabber Methods

- (NSString *)elementID;

- (XMPPJID *)to;
- (XMPPJID *)from;

- (NSString *)toStr;
- (NSString *)fromStr;

#pragma mark To and From Methods

- (BOOL)isTo:(XMPPJID *)to;
- (BOOL)isTo:(XMPPJID *)to options:(XMPPJIDCompareOptions)mask;

- (BOOL)isFrom:(XMPPJID *)from;
- (BOOL)isFrom:(XMPPJID *)from options:(XMPPJIDCompareOptions)mask;

- (BOOL)isToOrFrom:(XMPPJID *)toOrFrom;
- (BOOL)isToOrFrom:(XMPPJID *)toOrFrom options:(XMPPJIDCompareOptions)mask;

- (BOOL)isTo:(XMPPJID *)to from:(XMPPJID *)from;
- (BOOL)isTo:(XMPPJID *)to from:(XMPPJID *)from options:(XMPPJIDCompareOptions)mask;

@end
