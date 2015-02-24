//
//  SXChatViewController.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/23.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXChatViewController.h"
#import "SXChatCell.h"

@interface SXChatViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITextView *textView;

/** 输入视图底部约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomConstraint;

@end

@implementation SXChatViewController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 每一个聊天界面，只关心聊天对象的消息
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
    
    NSManagedObjectContext *ctx = [SXXMPPTools sharedXMPPTools].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

// 内容变化(接收到其他好友的/我发送的消息)的时候，会触发
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    
    [self scrollToBottom];
}


#pragma mark - ******************** 首次加载
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fetchedResultsController performFetch:NULL];
    
    // 设置表格的背景图片
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.jpg"]];
    
    // 监听键盘变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [self scrollToBottom];

}

#pragma mark - ******************** 键盘弹出后
- (void)keyboardChanged:(NSNotification *)notification {
    // 先打印
    // UIKeyboardFrameEndUserInfoKey ＝》将要变化的大小
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 设置约束
    self.inputViewBottomConstraint.constant = keyboardRect.size.height;
}

- (void)keyboardDidChanged {
    [self scrollToBottom];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [self sendMessage:textView.text];
        
        self.textView.text = nil;
        
        return NO;
    }
    return YES;
}

- (void)sendMessage:(NSString *)message
{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    
    [msg addBody:message];
    
    [[SXXMPPTools sharedXMPPTools].xmppStream sendElement:msg];
}



// 滚动到表格的末尾，显示最新的聊天内容
- (void)scrollToBottom {
    
    // 1. indexPath，应该是最末一行的indexPath
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    
    // 数组里面没东西还滚，不是找崩么
    if (count > 3) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
        
        // 2. 将要滚动到的位置
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

#pragma mark - ******************** tbv数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellWithTableView:tableView andIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 拿到Cell，设置数值
    SXChatCell *cell = [self cellWithTableView:tableView andIndexPath:indexPath];
    
    // 让cell自动布局
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.messageLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height +34;
    
    if (height < 80) {
        return 80;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (SXChatCell *)cellWithTableView:(UITableView *)tableview andIndexPath:(NSIndexPath *)indexPath
{
    // 取出当前行的消息
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // 判断是发出消息还是接收消息
    NSString *ID = ([message.outgoing intValue] == 1) ? @"SendCell" : @"ReciveCell" ;
    
    SXChatCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    
    cell.messageLabel.text = message.body;
    
    return cell;
}

@end
