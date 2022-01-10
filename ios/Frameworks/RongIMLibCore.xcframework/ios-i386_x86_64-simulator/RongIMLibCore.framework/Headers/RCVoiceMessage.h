/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCVoiceMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"

/*!
 语音消息的类型名
 */
#define RCVoiceMessageTypeIdentifier @"RC:VcMsg"

/*!
 语音消息类

 @discussion 语音消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 */
@interface RCVoiceMessage : RCMessageContent <NSCoding>

/*!
 wav 格式的音频数据
 */
@property (nonatomic, strong) NSData *wavAudioData;

/*!
 语音消息的时长, 以秒为单位
 */
@property (nonatomic, assign) long duration;


/*!
 初始化语音消息

 @param audioData   wav格式的音频数据
 @param duration    语音消息的时长，以秒为单位
 @return            语音消息对象

 @discussion
 如果您不是使用IMKit中的录音功能，则在初始化语音消息的时候，需要确保以下几点。
 1. audioData 必须是单声道的 wav 格式音频数据；
 2. audioData 的采样率必须是 8000Hz，采样位数（精度）必须为 16 位。

 您可以参考 IMKit 中的录音参数：
 NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                            AVSampleRateKey: @8000.00f,
                            AVNumberOfChannelsKey: @1,
                            AVLinearPCMBitDepthKey: @16,
                            AVLinearPCMIsNonInterleaved: @NO,
                            AVLinearPCMIsFloatKey: @NO,
                            AVLinearPCMIsBigEndianKey: @NO};
 */
+ (instancetype)messageWithAudio:(NSData *)audioData duration:(long)duration;

@end
