#import "XMPPMessage.h"

@interface XMPPMessage(Tools)

/** 
 将消息的附件保存至缓存目录用户jid对应的文件夹中
 
 如果有附件节点，返回YES
 没有附件，返回NO
 */
- (BOOL)saveAttachmentJID:(NSString *)jid timestamp:(NSDate *)timestamp;

/** 
 附件保存目录
 */
- (NSString *)pathForAttachment:(NSString *)jid timestamp:(NSDate *)timestamp;

@end
