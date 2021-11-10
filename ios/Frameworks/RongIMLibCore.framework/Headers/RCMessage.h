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
 消息实体类

 @discussion 消息实体类，包含消息的所有属性。
 */
@interface RCMessage : NSObject <NSCopying, NSCoding>

/*!
 会话类型
 */
@property (nonatomic, assign) RCConversationType conversationType;

/*!
 会话 ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 所属会话的业务标识，长度限制 20 字符
 */
@property (nonatomic, copy) NSString *channelId;

/*!
 消息的 ID

 @discussion 本地存储的消息的唯一值（数据库索引唯一值）
 */
@property (nonatomic, assign) long messageId;

/*!
 消息的方向
 */
@property (nonatomic, assign) RCMessageDirection messageDirection;

/*!
 消息的发送者 ID
 */
@property (nonatomic, copy) NSString *senderUserId;

/*!
 消息的接收状态
 */
@property (nonatomic, assign) RCReceivedStatus receivedStatus;

/*!
 消息的发送状态
 */
@property (nonatomic, assign) RCSentStatus sentStatus;

/*!
 消息的接收时间（Unix 时间戳、毫秒）
 */
@property (nonatomic, assign) long long receivedTime;

/*!
 消息的发送时间（Unix 时间戳、毫秒）
 */
@property (nonatomic, assign) long long sentTime;

/*!
 消息的类型名
 */
@property (nonatomic, copy) NSString *objectName;

/*!
 消息的内容
 */
@property (nonatomic, strong) RCMessageContent *content;

/*!
 消息的附加字段
 */
@property (nonatomic, copy) NSString *extra;

/*!
 全局唯一 ID

 @discussion 服务器消息唯一 ID（在同一个 Appkey 下全局唯一）
 */
@property (nonatomic, copy) NSString *messageUId;

/*!
 阅读回执状态
 */
@property (nonatomic, strong) RCReadReceiptInfo *readReceiptInfo;

/*!
 群阅读回执状态
 @discussion 如果是调用 RCGroupReadReceiptV2Manager 中方法实现群已读回执功能，此参数才有效，否则请使用 readReceiptInfo 属性获取阅读回执状态
 @discussion 如果使用 IMKit，请用 readReceiptInfo 属性
 */
@property (nonatomic, strong) RCGroupReadReceiptInfoV2 *groupReadReceiptInfoV2;

/*!
 消息配置
 */
@property (nonatomic, strong) RCMessageConfig *messageConfig;

/*!
 消息推送配置
 */
@property (nonatomic, strong) RCMessagePushConfig *messagePushConfig;

/*!
 是否是离线消息，只在接收消息的回调方法中有效，如果消息为离线消息，则为 YES ，其他情况均为 NO
 */
@property(nonatomic, assign) BOOL isOffLine;

/*!
 消息是否可以包含扩展信息
 
 @discussion 该属性在消息发送时确定，发送之后不能再做修改
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
*/
@property (nonatomic, assign) BOOL canIncludeExpansion;

/*!
 消息扩展信息列表
 
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 @discussion 默认消息扩展字典 key 长度不超过 32 ，value 长度不超过 64 ，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
*/
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *expansionDic;

/*!
 RCMessage初始化方法

 @param  conversationType    会话类型
 @param  targetId            会话 ID
 @param  messageDirection    消息的方向
 @param  content             消息的内容
 */
- (instancetype)initWithType:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(RCMessageDirection)messageDirection
                     content:(RCMessageContent *)content;


/*!
 RCMessage初始化方法（已废弃，请不要使用该接口构造消息发送）

 @param  conversationType    会话类型
 @param  targetId            会话 ID
 @param  messageDirection    消息的方向
 @param  messageId           消息的 ID（如果是发送该消息初始值请设置为 -1）
 @param  content             消息的内容
 */
- (instancetype)initWithType:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   direction:(RCMessageDirection)messageDirection
                   messageId:(long)messageId
                     content:(RCMessageContent *)content __deprecated_msg("已废弃，请使用 initWithType:targetId:direction:content:");
@end
#endif
