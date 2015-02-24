//
//  SXChatViewController.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/23.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXChatViewController.h"
#import "SXChatCell.h"
#import "UIImage+Scale.h"
#import "SXRecordTools.h"

@interface SXChatViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITextView *textView;

/** 输入视图底部约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomConstraint;

/** 录音文本 */
@property (nonatomic, strong) UITextField *recordText;
/** 输入视图 */
@property (weak, nonatomic) IBOutlet UIView *inputMessageView;

@end

@implementation SXChatViewController

#pragma mark - 录音部分
- (UITextField *)recordText {
    if (_recordText == nil) {
        _recordText = [[UITextField alloc] init];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        _recordText.inputView = btn;
        
        [btn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
        
        [self.inputMessageView addSubview:_recordText];
    }
    return _recordText;
}

- (void)startRecord {
    NSLog(@"开始录音");
    [[SXRecordTools sharedRecorder] startRecord];
}

- (void)stopRecord {
    NSLog(@"停止录音");
    [[SXRecordTools sharedRecorder] stopRecordSuccess:^(NSURL *url, NSTimeInterval time) {
        
        // 发送声音数据
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self sendMessageWithData:data bodyName:[NSString stringWithFormat:@"audio:%.1f秒", time]];

    } andFailed:^{
        
         [[[UIAlertView alloc] initWithTitle:@"提示" message:@"时间太短" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    }];
}

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
- (IBAction)setRecord {
    // 切换焦点，弹出录音按钮
    [self.recordText becomeFirstResponder];
}

- (IBAction)setPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    [self sendMessageWithData:data bodyName:@"image"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 发送二进制文件
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    
    [message addBody:name];
    
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    
    // 包含子节点
    [message addChild:attachment];
    
    // 发送消息
    [[SXXMPPTools sharedXMPPTools].xmppStream sendElement:message];
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
    
    cell.audioData = nil;
    
    if ([message.body isEqualToString:@"image"]) {
        
        XMPPMessage *msg = message.message;
        
        for (XMPPElement *node in msg.children) {
            
            NSString *base64str = node.stringValue;
            
            NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
            
            UIImage *image = [[UIImage alloc]initWithData:data];
            
            NSTextAttachment *attach = [[NSTextAttachment alloc]init];
            
            attach.image = [image scaleImageWithWidth:200];
            
            NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attach];
            
            cell.messageLabel.attributedText = attachStr;
            
            [self.view endEditing:YES];
//            [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillChangeFrameNotification object:nil];
        }
        
    }else if ([message.body hasPrefix:@"audio"]){
        
        XMPPMessage *msg = message.message;
        
        for (XMPPElement *node in msg.children) {
            
            NSString *base64str = node.stringValue;
            
            NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
            
            NSString *newstr = [message.body substringFromIndex:6];
            cell.messageLabel.text = newstr;
            
            cell.audioData = data;
        }
        
    
    }else{
        cell.messageLabel.text = message.body;
    }
    
    return cell;
}

@end
