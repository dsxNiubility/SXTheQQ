#import <Foundation/Foundation.h>

enum XMPPJIDCompareOptions
{
	XMPPJIDCompareUser     = 1, // 001
	XMPPJIDCompareDomain   = 2, // 010
	XMPPJIDCompareResource = 4, // 100
	
	XMPPJIDCompareBare     = 3, // 011
	XMPPJIDCompareFull     = 7, // 111
};
typedef enum XMPPJIDCompareOptions XMPPJIDCompareOptions;


@interface XMPPJID : NSObject <NSCoding, NSCopying>
{
	__strong NSString *user;
	__strong NSString *domain;
	__strong NSString *resource;
}

+ (XMPPJID *)jidWithString:(NSString *)jidStr;
+ (XMPPJID *)jidWithString:(NSString *)jidStr resource:(NSString *)resource;
+ (XMPPJID *)jidWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resource;

@property (strong, readonly) NSString *user;
@property (strong, readonly) NSString *domain;
@property (strong, readonly) NSString *resource;

/**
 * Terminology (from RFC 6120):
 * 术语
 * 
 * The term "bare JID" refers to an XMPP address of the form <localpart@domainpart> (for an account at a server)
 * or of the form <domainpart> (for a server).
 * 纯 JID(bare JID)
 * <localpart@domainpart> 格式表示在一个服务器上的账号
 * <domainpart> 格式表示服务器
 * 
 * The term "full JID" refers to an XMPP address of the form
 * <localpart@domainpart/resourcepart> (for a particular authorized client or device associated with an account)
 * or of the form <domainpart/resourcepart> (for a particular resource or script associated with a server).
 * 全 JID（full JID）
 * <localpart@domainpart/resourcepart>  格式表示与一个账号关联的特定授权的客户端或者设备
 * <domainpart/resourcepart>    格式表示与一个服务器关联的特定的资源或者脚本
 * 
 * Thus a bareJID is one that does not have a resource.
 * And a fullJID is one that does have a resource.
 * 
 * For convenience, there are also methods that that check for a user component as well.
**/

- (XMPPJID *)bareJID;
- (XMPPJID *)domainJID;

- (NSString *)bare;
- (NSString *)full;

- (BOOL)isBare;
- (BOOL)isBareWithUser;

- (BOOL)isFull;
- (BOOL)isFullWithUser;

/**
 * A server JID does not have a user component.
**/
- (BOOL)isServer;

/**
 * Returns a new jid with the given resource.
**/
- (XMPPJID *)jidWithNewResource:(NSString *)resource;

/**
 * When you know both objects are JIDs, this method is a faster way to check equality than isEqual:.
**/
- (BOOL)isEqualToJID:(XMPPJID *)aJID;
- (BOOL)isEqualToJID:(XMPPJID *)aJID options:(XMPPJIDCompareOptions)mask;

@end
