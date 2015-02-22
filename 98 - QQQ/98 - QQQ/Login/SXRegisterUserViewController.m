//
//  SXRegisterUserViewController.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/21.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXRegisterUserViewController.h"
#import "SXXMPPTools.h"

@interface SXRegisterUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *hostNameText;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation SXRegisterUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册新用户";

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)textChanged {
    // 确保三个文本都输入了内容
    self.registerButton.enabled = (self.nameText.text.length > 0
                                   && self.passwordText.text.length > 0
                                   && self.hostNameText.text.length > 0);
}

// 注册用户
- (IBAction)regisgerUser {
    // 保存至用户偏好
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nameText.text forKey:SXLoginUserNameKey];
    [defaults setObject:self.passwordText.text forKey:SXLoginPasswordKey];
    [defaults setObject:self.hostNameText.text forKey:SXLoginHostnameKey];
    
    [defaults synchronize];
    
    // 要向服务器注册用户，首先也需要连接到服务器
    [SXXMPPTools sharedXMPPTools].isRegisterUser = YES;
    
    [[SXXMPPTools sharedXMPPTools] connectionWithFailed:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

@end
