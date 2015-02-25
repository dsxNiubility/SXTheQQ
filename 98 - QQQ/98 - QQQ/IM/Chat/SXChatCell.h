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


//@property (nonatomic, strong) NSData *audioData;

/** 音频的地址 */
@property (nonatomic, strong) NSString *audioPath;

@end
