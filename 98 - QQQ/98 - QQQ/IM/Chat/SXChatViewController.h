//
//  SXChatViewController.h
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/23.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SXXMPPTools.h"

@interface SXChatViewController : UIViewController

/** 聊天对象的JID */
@property (nonatomic, strong) XMPPJID *chatJID;

@end
