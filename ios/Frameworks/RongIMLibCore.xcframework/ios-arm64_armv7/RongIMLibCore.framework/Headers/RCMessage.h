/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#ifndef __RCMessage
#define __RCMessage
#import "RCMessageContent.h"
#import "RCReadReceiptInfo.h"
#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>
#import "RCMessageConfig.h"
#import "RCMessagePushConfig.h"
#import "RCGroupReadReceiptInfoV2.h"
/*!
 *  \~chinese
 消息实体类

 @discussion 消息实体类，包含消息的所有属性。
 
 *  \~english
 Message entity class.

 @ discussion message entity class, which contains all the properties of the message.
 */
@interface RCMessage : NSObject <NSCopying, NSCoding>

/*!
 *  \~chinese
 会话类型
 
 *  \~english
 Conversation type
 */
@property (nonatomic, assign) RCConversationType conversationType;

/*!
 *  \~chinese
 会话 ID
 
 *  \~english
 Conversation ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 *  \~chinese
 所属会话的业务标识，长度限制 20 字符
 
 *  \~english
 Business identification of the conversation to which it belongs, with a length limit of 20 characters.
 */
@property (nonatomic, copy) NSString *channelId;

/*!
 *  \~chinese
 消息的 ID

 @discussion 本地存储的消息的唯一值（数据库索引唯一值）
 
 *  \~english
 ID of the message.

 @ discussion Unique value of locally stored message (unique value of database index).
 */
@property (nonatomic, assign) long messageId;

/*!
 *  \~chinese
 消息的方向
 
 *  \~english
 The direction of the message.
 */
@property (nonatomic, assign) RCMessageDirection messageDirection;

/*!
 *  \~chinese
 消息的发送者 ID
 
 *  \~english
 The sender ID of the message
 */
@property (nonatomic, copy) NSString *senderUserId;

/*!
 *  \~chinese
 消息的接收状态
 
 *  \~english
 The receiving status of the message
 */
@property (nonatomic, assign) RCReceivedStatus receivedStatus;

/*!
 *  \~chinese
 消息的发送状态
 
 *  \~english
 The sending status of the message
 */
@property (nonatomic, assign) RCSentStatus sentStatus;

/*!
 *  \~chinese
 消息的接收时间（Unix 时间戳、毫秒）
 
 *  \~english
 The time the message is received (Unix timestamp, milliseconds)
 */
@property (nonatomic, assign) long long receivedTime;

/*!
 *  \~chinese
 消息的发送时间（Unix 时间戳、毫秒）
 
 *  \~english
 The time the message is sent (Unix timestamp, milliseconds)
 */
@property (nonatomic, assign) long long sentTime;

/*!
 *  \~chinese
 消息的类型名
 
 *  \~english
 The type name of the message
 */
@property (nonatomic, copy) NSString *objectName;

/*!
 *  \~chinese
 消息的内容
 
 *  \~english
 The content of the message
 */
@property (nonatomic, strong) RCMessageContent *content;

/*!
 *  \~chinese
 消息的附加字段
 
 *  \~english
 Additional fields of the message
 */
@property (nonatomic, copy) NSString *extra;

/*!
 *  \~chinese
 全局唯一 ID

 @discussion 服务器消息唯一 ID（在同一个 Appkey 下全局唯一）
 
 *  \~english
 Globally unique ID.

 @ discussion server message unique ID (globally unique under the same Appkey).
 */
@property (nonatomic, copy) NSString *messageUId;

/*!
 *  \~chinese
 阅读回执状态
 
 *  \~english
 Reading receipt status
 */
@property (nonatomic, strong) RCReadReceiptInfo *readReceiptInfo;

/*!
 *  \~chinese
 群阅读回执状态
 @discussion 如果是调用 RCGroupReadReceiptV2Manager 中方法实现群已读回执功能，此参数才有效，否则请使用 readReceiptInfo 属性获取阅读回执状态
 @discussion 如果使用 IMKit，请用 readReceiptInfo 属性
 
 *  \~english
 Group reading receipt status.
 @ discussion This parameter is valid only if you call the method in RCGroupReadReceiptV2Manager to implement the group read receipt function. Otherwise, use the readReceiptInfo attribute to obtain the read receipt status.
 @ discussion use the readReceiptInfo attribute if you use IMKit,
 */
@property (nonatomic, strong) RCGroupReadReceiptInfoV2 *groupReadReceiptInfoV2;

/*!
 *  \~chinese
 消息配置
 
 *  \~english
 Message configuration
 */
@property (nonatomic, strong) RCMessageConfig *messageConfig;

/*!
 *  \~chinese
 消息推送配置
 
 *  \~english
 Message push configuration
 */
@property (nonatomic, strong) RCMessagePushConfig *messagePushConfig;

/*!
 *  \~chinese
 是否是离线消息，只在接收消息的回调方法中有效，如果消息为离线消息，则为 YES ，其他情况均为 NO
 
 *  \~english
 Whether it is an offline message is only valid in the callback method that receives the message. If the message is offline, it is YES. Otherwise, it is NO.
 */
@property(nonatomic, assign) BOOL isOffLine;

/*!
 *  \~chinese
 消息是否可以包含扩展信息
 
 @discussion 该属性在消息发送时确定，发送之后不能再做修改
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 
 *  \~english
 Whether the message can contain extended information.

 @ discussion This property is determined when the message is sent and cannot be modified after it is sent.
 @ discussion Extension information only supports single chat and group. Other conversation types cannot set extension information.
*/
@property (nonatomic, assign) BOOL canIncludeExpansion;

/*!
 *  \~chinese
 消息扩展信息列表
 
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 @discussion 默认消息扩展字典 key 长度不超过 32 ，value 长度不超过 64 ，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
 
 *  \~english
 Message extension information list.

 @ discussion Extension information only supports single chat and group. Other conversation types cannot set extension information.
 @ discussion Default message extension dictionary key length does not exceed 32, value length does not exceed 64, the maximum number of extensions for a single setting is 20, and the total number of message extensions cannot exceed 300.
*/
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *expansionDic;

/*!
 *  \~chinese
 RCMessage初始化方法

 @param  conversationType    会话类型
 @param  targetId            会话 ID
 @param  messageDirection    消息的方向
 @param  content             消息的内容
 
 *  \~english
 RCMessage initialization method.

 @ param conversationType conversation type.
 @ param targetId conversation ID.
 @ param messageDirection message direction
 @ param content message content.
 */
- (instancetype)initWithType:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(RCMessageDirection)messageDirection
                     content:(RCMessageContent *)content;


/*!
 *  \~chinese
 RCMessage初始化方法（已废弃，请不要使用该接口构造消息发送）

 @param  conversationType    会话类型
 @param  targetId            会话 ID
 @param  messageDirection    消息的方向
 @param  messageId           消息的 ID（如果是发送该消息初始值请设置为 -1）
 @param  content             消息的内容
 
 *  \~english
 RCMessage initialization method.

 @ param conversationType conversation type.
 @ param targetId conversation ID.
 @ param messageDirection message direction
  @ param messageId message ID
 @ param content message content.
 */
- (instancetype)initWithType:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(RCMessageDirection)messageDirection
                   messageId:(long)messageId
                     content:(RCMessageContent *)content __deprecated_msg("Use initWithType:targetId:direction:content:");
@end
#endif
