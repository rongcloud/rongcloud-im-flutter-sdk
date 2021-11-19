//
//  RCHQVoiceMessage.h
//  RongIMLib
//
//  Created by Zhaoqianyu on 2019/5/16.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

/*!
 *  \~chinese
 高清语音消息类型名
 
 *  \~english
 HD voice message type name
 */
#define RCHQVoiceMessageTypeIdentifier @"RC:HQVCMsg"

NS_ASSUME_NONNULL_BEGIN
/*!
 *  \~chinese
 高清语音消息类
 
 @discussion 高清语音消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 High definition voice message class.

 @ discussion HD voice message class, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCHQVoiceMessage : RCMediaMessageContent <NSCoding>

/*!
 *  \~chinese
 语音消息的时长，以秒为单位
 
 *  \~english
 The duration of the voice message, in seconds
 */
@property (nonatomic, assign) long duration;

/*!
 *  \~chinese
 初始化高清语音消息

 @param localPath 语音的本地路径
 @param duration   语音时长，以秒为单位

 @return          语音消息对象
 
 *  \~english
 Initialize HD voice messages.

 @param localPath Local path of voice
 @param duration Voice duration in seconds

 @ return voice message object
 */
+ (instancetype)messageWithPath:(NSString *)localPath duration:(long)duration;

@end

NS_ASSUME_NONNULL_END
