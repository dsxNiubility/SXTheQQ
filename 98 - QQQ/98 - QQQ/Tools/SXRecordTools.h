//
//  SXRecordTools.h
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/24.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SXRecordTools : NSObject

+ (instancetype)sharedRecorder;

/** 开始录音 */
- (void)startRecord;

/** 停止录音 */
- (void)stopRecordSuccess:(void (^)(NSURL *url,NSTimeInterval time))success andFailed:(void (^)())failed;

/** 播放声音 */
- (void)playData:(NSData *)data completion:(void(^)())completion;

@end
