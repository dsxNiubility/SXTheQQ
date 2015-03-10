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
#import "XMPPMessage+Tools.h"

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

@property(nonatomic,strong) UITableViewCell *nowCell;

@property(nonatomic,strong) NSIndexPath *nowIndexPath;

@property (nonatomic,assign) CGFloat nowHeight;

@property(nonatomic,strong) NSCache *cache;


@end

@implementation SXChatViewController

#pragma mark - ******************** 懒加载
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

- (NSCache *)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc]init];
    }
    return _cache;
}

- (NSFetchedResultsController *)fetchedResultsController {
    // 推荐写法，减少嵌套的层次
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // 先确定需要用到哪个实体
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 每一个聊天界面，只关心聊天对象的消息
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
    
    // 从自己写的工具类里的属性中得到上下文
    NSManagedObjectContext *ctx = [SXXMPPTools sharedXMPPTools].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    
    // 实例化，里面要填上上面的各种参数
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark - ******************** 结果调度器的代理方法
// 内容变化(接收到其他好友的/我发送的消息)的时候，会触发
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    
    [self scrollToBottom];
}

#pragma mark - ******************** 录音方法
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

#pragma mark - ******************** 监听键盘弹出的方法
- (void)keyboardChanged:(NSNotification *)notification {
    // 先打印
    // UIKeyboardFrameEndUserInfoKey ＝》将要变化的大小
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 设置约束
    self.inputViewBottomConstraint.constant = ([UIScreen mainScreen].bounds.size.height - keyboardRect.origin.y);
    
    NSTimeInterval time = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
   [UIView animateWithDuration:time animations:^{
       [self.view layoutIfNeeded];
   }];
    
//    NSLog(@"%f",keyboardRect.size.height);
//    NSLog(@"%@",notification);
    
}

- (void)keyboardDidChanged {
    [self scrollToBottom];
}


#pragma mark - ******************** textView代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 判断按下的是不是回车键。
    if ([text isEqualToString:@"\n"]) {
        
        // 自定义的信息发送方法，传入字符串直接发出去。
        [self sendMessage:textView.text];
        
        self.textView.text = nil;
        
        return NO;
    }
    return YES;
}


#pragma mark - ******************** imgPickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    [self sendMessageWithData:data bodyName:@"image"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ******************** 发送消息方法
/** 发送信息 */
- (void)sendMessage:(NSString *)message
{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    
    [msg addBody:message];
    
    [[SXXMPPTools sharedXMPPTools].xmppStream sendElement:msg];
}

/** 发送二进制文件 */
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



#pragma mark - ******************** 和tableView相关的一系列方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    UITableViewCell *cell = [self cellWithTableView:tableView andIndexPath:indexPath];
    return [self cellWithTableView:tableView andIndexPath:indexPath];
}

/** 计算行高方法 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *row = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    if ([self.cache objectForKey:row]!=nil) {
//        NSLog(@"%f",[[self.cache objectForKey:row] floatValue]);
        return [[self.cache objectForKey:row] floatValue];
    }

    
//    NSLog(@"计算行高 %ld",indexPath.row);
    // 拿到Cell，设置数值
    SXChatCell *cell = [self cellWithTableView:tableView andIndexPath:indexPath];
    
    // 让cell自动布局
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.messageLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height +34;
    
    if (height < 80) {
        [self.cache setObject:@(80) forKey:row];
        return 80;
    }

    [self.cache setObject:@(height) forKey:row];
    return height;
}

/** 预估行高 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

/** 直接返回一个cell */
- (SXChatCell *)cellWithTableView:(UITableView *)tableview andIndexPath:(NSIndexPath *)indexPath
{
    
//    NSLog(@"调用了几次？");
    
    // 取出当前行的消息
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // 判断是发出消息还是接收消息
    NSString *ID = ([message.outgoing intValue] == 1) ? @"SendCell" : @"ReciveCell" ;
    
    SXChatCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    
    // 如果存进去了，就把字符串转化成简洁的节点后保存
    if ([message.message saveAttachmentJID:self.chatJID.bare timestamp:message.timestamp]) {
        message.messageStr = [message.message compactXMLString];
        
        [[SXXMPPTools sharedXMPPTools].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext save:NULL];
    }
    
//    cell.audioData = nil;
    cell.audioPath = nil;
    
    NSString *path = [message.message pathForAttachment:self.chatJID.bare timestamp:message.timestamp];
    
    if ([message.body isEqualToString:@"image"]) {
        
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            NSTextAttachment *attach = [[NSTextAttachment alloc]init];
            
            attach.image = [image scaleImageWithWidth:200];
            
            NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attach];
            
            cell.messageLabel.attributedText = attachStr;
            
            [self.view endEditing:YES];
        
        }else if ([message.body hasPrefix:@"audio"]){
        
            NSString *newstr = [message.body substringFromIndex:6];
            cell.messageLabel.text = newstr;
            
            cell.audioPath = path;
    
    }else{
        cell.messageLabel.text = message.body;
    }
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark - ******************** 界面底部按钮点击方法
- (IBAction)setRecord {
    // 切换焦点，弹出录音按钮
    [self.recordText becomeFirstResponder];
}

- (IBAction)setPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - ******************** 为了方便抽出来的方法
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

@end
