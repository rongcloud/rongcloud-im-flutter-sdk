//
//  RCWatchKitStatusDelegate.h
//  RongIMLib
//
//  Created by litao on 15/6/4.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef RongIMLib_RCwatchKitStatusDelegate_h
#define RongIMLib_RCwatchKitStatusDelegate_h

/*!
 用于 Apple Watch 的 IMLib 事务监听器

 @discussion 此协议定义了 IMLib 在状态变化和各种活动时的回调，主要用于 Apple
 Watch。
 */
__deprecated_msg("已废弃") @protocol RCWatchKitStatusDelegate <NSObject>

@optional

#pragma mark 连接状态
/*!
 连接状态发生变化的回调

 @param status      SDK  与融云服务器的连接状态
 */
- (void)notifyWatchKitConnectionStatusChanged:(RCConnectionStatus)status;

#pragma mark 消息接收与发送

/*!
 收到消息的回调

 @param receivedMsg     收到的消息实体
 */
- (void)notifyWatchKitReceivedMessage:(RCMessage *)receivedMsg;

/*!
 向外发送消息的回调

 @param message     待发送消息
 */
- (void)notifyWatchKitSendMessage:(RCMessage *)message;

/*!
 发送消息完成的回调

 @param messageId    消息 ID
 @param status       完成的状态吗。0 表示成功，非 0 表示失败
 */
- (void)notifyWatchKitSendMessageCompletion:(long)messageId status:(RCErrorCode)status;

/*!
 上传图片进度更新的回调

 @param progress    进度
 @param messageId   消息 ID
 */
- (void)notifyWatchKitUploadFileProgress:(int)progress messageId:(long)messageId;

#pragma mark 消息与会话操作
/*!
 删除会话的回调

 @param conversationTypeList    会话类型的数组
 */
- (void)notifyWatchKitClearConversations:(NSArray *)conversationTypeList;

/*!
 删除消息的回调

 @param conversationType    会话类型
 @param targetId            会话 ID
 */
- (void)notifyWatchKitClearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 删除消息的回调

 @param messageIds    消息 ID 的数组
 */
- (void)notifyWatchKitDeleteMessages:(NSArray *)messageIds;

/*!
 清除未读消息数的回调

 @param conversationType    会话类型
 @param targetId            会话 ID
 */
- (void)notifyWatchKitClearUnReadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId;

#pragma mark 讨论组

/*!
 创建讨论组的回调

 @param name         讨论组名称
 @param userIdList   成员的用户 ID 列表
 */
- (void)notifyWatchKitCreateDiscussion:(NSString *)name userIdList:(NSArray *)userIdList;

/*!
 创建讨论组成功的回调

 @param discussionId    讨论组的 ID
 */
- (void)notifyWatchKitCreateDiscussionSuccess:(NSString *)discussionId;

/*!
 创建讨论组失败

 @param errorCode   创建失败的错误码
 */
- (void)notifyWatchKitCreateDiscussionError:(RCErrorCode)errorCode;

/*!
 讨论组加人的回调

 @param discussionId    讨论组的 ID
 @param userIdList      添加成员的用户 ID 列表

 @discussion 加人的结果可以通过 notifyWatchKitDiscussionOperationCompletion 获得。
 */
- (void)notifyWatchKitAddMemberToDiscussion:(NSString *)discussionId userIdList:(NSArray *)userIdList;

/*!
 讨论组踢人的回调

 @param discussionId    讨论组 ID
 @param userId          用户 ID

 @discussion 踢人的结果可以通过 notifyWatchKitDiscussionOperationCompletion 获得。
 */
- (void)notifyWatchKitRemoveMemberFromDiscussion:(NSString *)discussionId userId:(NSString *)userId;

/*!
 退出讨论组的回调

 @param discussionId    讨论组 ID

 @discussion 创建的结果可以通过 notifyWatchKitDiscussionOperationCompletion 获得。
 */
- (void)notifyWatchKitQuitDiscussion:(NSString *)discussionId;

/*!
 讨论组操作的回调。tag：100-邀请；101-踢人；102-退出。status：0 成功，非 0 失败

 @param tag       讨论组的操作类型。100 为加人，101 为踢人，102 为退出
 @param status    操作的结果。0表示成功，非0表示失败
 */
- (void)notifyWatchKitDiscussionOperationCompletion:(int)tag status:(RCErrorCode)status;

@end
#endif
