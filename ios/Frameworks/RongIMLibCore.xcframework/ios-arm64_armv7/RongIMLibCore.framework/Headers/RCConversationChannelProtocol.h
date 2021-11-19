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
 *  \~chinese
 请求消息已读回执（收到需要阅读时发送回执的请求，收到此请求后在会话页面已经展示该 messageUId 对应的消息或者调用
 getHistoryMessages 获取消息的时候，包含此 messageUId 的消息，需要调用 sendMessageReadReceiptResponse
 接口发送消息阅读回执）

 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param channelId          所属会话的业务标识
 
 *  \~english
 Request message read receipt (receive a request to send a receipt upon reading. After receiving this request, the corresponding message of the messageUId has been displayed on the conversation page, or when getHistoryMessages is called to get the message, the message with messageUId  will call sendMessageReadReceiptResponse interface to send message tread receipt ).

 @param messageUId Message ID requesting read receipt.
 @param conversationType ConversationType.
 @param targetId TargetId.
 @param channelId Business identity of the conversation to which it belongs.
 */
- (void)onMessageReceiptRequest:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                     messageUId:(NSString *)messageUId;

/*!
 *  \~chinese
 消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param channelId          所属会话的业务标识
 @param userIdList 已读userId列表
 
 *  \~english
 Message read receipt response (if you receive the read receipt response, you can update the number of readings of the message according to messageUId).
 @param messageUId Message ID requesting read receipt.
 @param conversationType ConversationType.
 @param targetId TargetId.
 @param channelId Business identity of the conversation to which it belongs.
 @param userIdList Read userId list.
 */
- (void)onMessageReceiptResponse:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                       channelId:(NSString *)channelId
                      messageUId:(NSString *)messageUId
                      readerList:(NSMutableDictionary *)userIdList;

@end

@protocol RCConversationChannelTypingStatusDelegate <NSObject>
/*!
 *  \~chinese
 用户输入状态变化的回调

 @param conversationType        会话类型
 @param targetId                会话目标ID
 @param channelId          所属会话的业务标识
 @param userTypingStatusList 正在输入的RCUserTypingStatus列表（nil标示当前没有用户正在输入）

 @discussion
 当客户端收到用户输入状态的变化时，会回调此接口，通知发生变化的会话以及当前正在输入的RCUserTypingStatus列表。
 
 *  \~english
 Callback for user input status change.

 @param conversationType Conversation type
 @param targetId conversation destination ID.
 @param channelId Business identity of the conversation to which it belongs.
 @param userTypingStatusList List of RCUserTypingStatus being entered (nil indicates that no user is currently entering).

 @ discussion
 When the client receives a change in the status of the user's input, it calls back this interface to notify the changed conversation and the RCUserTypingStatus list currently being entered.
 */
- (void)onTypingStatusChanged:(RCConversationType)conversationType
                     targetId:(NSString *)targetId
                    channelId:(NSString *)channelId
                       status:(NSArray *)userTypingStatusList;
@end
#endif /* RCConversationChannelProtocol_h */
