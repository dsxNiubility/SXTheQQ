//
//  SXChatCell.h
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/24.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SXChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

/** 音频的二进制数据 */
@property (nonatomic, strong) NSData *audioData;

@end
