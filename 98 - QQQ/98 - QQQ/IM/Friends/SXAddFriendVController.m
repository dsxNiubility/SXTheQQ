//
//  SXAddFriendVController.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/23.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXAddFriendVController.h"
#import "SXXMPPTools.h"

@interface SXAddFriendVController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameText;

@end

@implementation SXAddFriendVController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新建联系人";
}

// 在文本框上按回车
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 准备添加好友
    if (textField.text.length > 0) {
        [self addFriendWithName:textField.text];
    }
    
    return YES;
}

// 添加好友
- (void)addFriendWithName:(NSString *)name {
    
    // 你写了域名那更好，你没写系统就自动帮你补上
    NSRange range = [name rangeOfString:@"@"];
    // 如果没找到 NSNotFound，不要写0
    if (range.location == NSNotFound) {
        name = [name stringByAppendingFormat:@"@%@", [SXXMPPTools sharedXMPPTools].xmppStream.myJID.domain];
   
    }
    
    // 如果已经是好友就不需要再次添加
    XMPPJID *jid = [XMPPJID jidWithString:name];
    
    BOOL contains = [[SXXMPPTools sharedXMPPTools].xmppRosterCoreDataStorage userExistsWithJID:jid xmppStream:[SXXMPPTools sharedXMPPTools].xmppStream];
    
    if (contains) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经是好友，无需添加" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [[SXXMPPTools sharedXMPPTools].xmppRoster subscribePresenceToUser:jid];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
