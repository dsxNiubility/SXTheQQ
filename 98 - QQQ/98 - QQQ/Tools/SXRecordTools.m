
//  SXRecordTools.m
//  98 - QQQ
//
//  Created by 董 尚先 on 15/2/24.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXRecordTools.h"
#import <AVFoundation/AVFoundation.h>


@interface SXRecordTools ()<AVAudioPlayerDelegate>

/** 录音器 */
@property(nonatomic,strong) AVAudioRecorder *recorder;

/** 录音地址 */
@property(nonatomic,strong) NSURL *recordURL;

/** 播放器 */
@property(nonatomic,strong) AVAudioPlayer *player;

@property(nonatomic,copy) void (^palyCompletion)();
@end

@implementation SXRecordTools

+ (instancetype)sharedRecorder {
    static SXRecordTools *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // 设置音频的会话分类 必须要写
        [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
        
        // 录音设置的字典
        NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithFloat: 8000.0], AVSampleRateKey,                    // 采样率，数值越大，文件越大
                                        [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,     // 文件个数
                                        [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,                     // 声道
                                        [NSNumber numberWithInt: AVAudioQualityLow], AVEncoderAudioQualityKey,  // 音质
                                        nil];
        
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"record.caf"];
        _recordURL = [NSURL fileURLWithPath:path];
        _recorder = [[AVAudioRecorder alloc]initWithURL:_recordURL settings:recordSettings error:NULL];
        
        // 准备
        [_recorder prepareToRecord];
    }
    return self;
}

/** 开始录音 */
- (void)startRecord{
    [self.recorder record];
}

/** 停止录音 */
- (void)stopRecordSuccess:(void (^)(NSURL *url,NSTimeInterval time))success andFailed:(void (^)())failed
{
    // 只有在这里才能取到currentTime
    NSTimeInterval time = self.recorder.currentTime;
    [self.recorder stop];
    
    if (time < 1.5) {
        if (failed) {
            failed();
        }
    }else{
        if (success) {
            success(self.recordURL,time);
        }
    }
}

#pragma mark - ******************** 完成播放时的代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.palyCompletion) {
        self.palyCompletion();
    }
}

- (void)playData:(NSData *)data completion:(void(^)())completion
{
    // 判断是否正在播放
    if (self.player.isPlaying) {
        [self.player stop];
    }
    
    // 记录块代码
    self.palyCompletion = completion;
    
    // 监听播放器播放状态
    self.player = [[AVAudioPlayer alloc]initWithData:data error:NULL];
    
    self.player.delegate = self;
    
    [self.player play];
}


@end
