//
//  SXRegisterUserViewController.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/21.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXRegisterUserViewController.h"

@interface SXRegisterUserViewController ()

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

@end
