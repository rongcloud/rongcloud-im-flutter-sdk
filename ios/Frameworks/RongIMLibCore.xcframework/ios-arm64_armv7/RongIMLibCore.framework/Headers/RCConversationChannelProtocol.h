//
//  RCConversationChannelProtocol.h
//  RongIMLibCore
//
//  Created by Sin on 2021/3/5.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#ifndef RCConversationChannelProtocol_h
#define RCConversationChannelProtocol_h
@protocol RCConversationChannelMessageReceiptDelegate <NSObject>
@optional
/*!
 请求消息已读回执（收到需要阅读时发送回执的请求，收到此请求后在会话页面已经展示该 messageUId 对应的消息或者调用
 getHistoryMessages 获取消息的时候，包含此 messageUId 的消息，需要调用 sendMessageReadReceiptResponse
 接口发送消息阅读回执）

 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param channelId          所属会话的业务标识
 */
- (void)onMessageReceiptRequest:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                     messageUId:(NSString *)messageUId;

/*!
 消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param channelId          所属会话的业务标识
 @param userIdList 已读userId列表
 */
- (void)onMessageReceiptResponse:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                       channelId:(NSString *)channelId
                      messageUId:(NSString *)messageUId
                      readerList:(NSMutableDictionary *)userIdList;

@end

@protocol RCConversationChannelTypingStatusDelegate <NSObject>
/*!
 用户输入状态变化的回调

 @param conversationType        会话类型
 @param targetId                会话目标ID
 @param channelId          所属会话的业务标识
 @param userTypingStatusList 正在输入的RCUserTypingStatus列表（nil标示当前没有用户正在输入）

 @discussion
 当客户端收到用户输入状态的变化时，会回调此接口，通知发生变化的会话以及当前正在输入的RCUserTypingStatus列表。
 */
- (void)onTypingStatusChanged:(RCConversationType)conversationType
                     targetId:(NSString *)targetId
                    channelId:(NSString *)channelId
                       status:(NSArray *)userTypingStatusList;
@end
#endif /* RCConversationChannelProtocol_h */
