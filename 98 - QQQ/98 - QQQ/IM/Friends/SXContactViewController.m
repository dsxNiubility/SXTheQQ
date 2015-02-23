//
//  SXContactViewController.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/23.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXContactViewController.h"
#import "SXXMPPTools.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "SXChatViewController.h"

@interface SXContactViewController ()<NSFetchedResultsControllerDelegate>

/** 结果调度器 */
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SXContactViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return  _fetchedResultsController;
    }
    
    // 指定查询的实体
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 在线状态排序
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
    // 显示的名称排序
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    // 添加排序
    request.sortDescriptors = @[sort1,sort2];
    
    // 添加谓词过滤器
    request.predicate = [NSPredicate predicateWithFormat:@"!(subscription CONTAINS 'none')"];
    
    // 添加上下文
    NSManagedObjectContext *ctx = [SXXMPPTools sharedXMPPTools].xmppRosterCoreDataStorage.mainThreadManagedObjectContext;
    
    // 实例化结果控制器
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    
    // 设置他的代理
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"上下文改变");
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 查询数据
    [self.fetchedResultsController performFetch:NULL];
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
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"%zd %@ %@ %@", user.section, user.sectionName, user.sectionNum, user.jidStr);
    
    // subscription
    // 如果是none表示对方还没有确认
    // to   我关注对方
    // from 对方关注我
    // both 互粉
    
    NSString *str = [user.jidStr stringByAppendingFormat:@" | %@",user.subscription];
    
    cell.textLabel.text = str ;
    cell.detailTextLabel.text = [self userStatusWithSection:user.section];
    
    return cell;
}

- (NSString *)userStatusWithSection:(NSInteger)section {
    // section
    // 0 在线
    // 1 离开
    // 2 离线
    switch (section) {
        case 0:
            return @"在线";
            break;
        case 1:
            return @"离开";
            break;
        case 2:
            return @"离线";
            break;
        default:
            return @"未知";
            break;
    }
}

#pragma mark - ******************** 即将跳转方法
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SXChatViewController class]]) {
        SXChatViewController *chatVC = segue.destinationViewController;
        
        // 也可以直接用点语法
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        
        XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexpath];
        
        chatVC.chatJID = user.jid;
    }
}

#pragma mark - ******************** 开启编辑模式删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath]; // $$$$$
        
        XMPPJID *jid = user.jid;
        
        // 应该提示一下用户
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要删除?" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
            [[SXXMPPTools sharedXMPPTools].xmppRoster removeUser:jid];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
