//
//  SXChatCell.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/24.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXChatCell.h"
#import "SXRecordTools.h"

@implementation SXChatCell

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 如果有音频数据，直接播放音频
    if (self.audioPath != nil) {
        // 播放音频
        self.messageLabel.textColor = [UIColor redColor];
        
        // 如果单例的块代码中包含self，一定使用weakSelf
        __weak SXChatCell *weakSelf = self;
        [[SXRecordTools sharedRecorder] playPath:self.audioPath completion:^{
            weakSelf.messageLabel.textColor = [UIColor whiteColor];
        }];
    }
}

@end
