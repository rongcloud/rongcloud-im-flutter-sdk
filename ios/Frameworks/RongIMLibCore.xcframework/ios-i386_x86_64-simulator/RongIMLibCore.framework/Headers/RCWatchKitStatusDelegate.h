//
//  RCWatchKitStatusDelegate.h
//  RongIMLib
//
//  Created by litao on 15/6/4.
//  Copyright (c) 2015 RongCloud. All rights reserved.
//

#ifndef RongIMLib_RCwatchKitStatusDelegate_h
#define RongIMLib_RCwatchKitStatusDelegate_h

/*!
 *  \~chinese
 用于 Apple Watch 的 IMLib 事务监听器

 @discussion 此协议定义了 IMLib 在状态变化和各种活动时的回调，主要用于 Apple
 Watch。
 
 *  \~english
 IMLib transaction listener for Apple Watch.

 @ discussion This protocol defines the callback for IMLib in case of state changes and various activities, and is mainly used for Apple.
 Watch .
 */
@protocol RCWatchKitStatusDelegate <NSObject>

@optional

#pragma mark Connection status
/*!
 *  \~chinese
 连接状态发生变化的回调

 @param status      SDK  与融云服务器的连接状态
 
 *  \~english
 Callback for a change in connection status.

 @param status Connection status between SDK and CVM.
 */
- (void)notifyWatchKitConnectionStatusChanged:(RCConnectionStatus)status;

#pragma mark Message Receive

/*!
 *  \~chinese
 收到消息的回调

 @param receivedMsg     收到的消息实体
 
 *  \~english
 Callback for receiving message.

 @param receivedMsg Received message entity.
 */
- (void)notifyWatchKitReceivedMessage:(RCMessage *)receivedMsg;

/*!
 *  \~chinese
 向外发送消息的回调

 @param message     待发送消息
 
 *  \~english
 Callback for sending messages out.

 @param message Message to be sent.
 */
- (void)notifyWatchKitSendMessage:(RCMessage *)message;

/*!
 *  \~chinese
 发送消息完成的回调

 @param messageId    消息 ID
 @param status       完成的状态吗。0 表示成功，非 0 表示失败
 
 *  \~english
 Callback for sending message completely

 @param messageId Message ID.
 @param status The state of completion. 0 indicates success, and non-0 indicates failure.
 */
- (void)notifyWatchKitSendMessageCompletion:(long)messageId status:(RCErrorCode)status;

/*!
 *  \~chinese
 上传图片进度更新的回调

 @param progress    进度
 @param messageId   消息 ID
 
 *  \~english
 Callback for progress update for uploading images.

 @param progress Progress.
 @param messageId Message ID.
 */
- (void)notifyWatchKitUploadFileProgress:(int)progress messageId:(long)messageId;

#pragma mark Message & Conversation
/*!
 *  \~chinese
 删除会话的回调

 @param conversationTypeList    会话类型的数组
 
 *  \~english
 Callback for deleting the conversation.

 @param conversationTypeList An array of conversation types.
 */
- (void)notifyWatchKitClearConversations:(NSArray *)conversationTypeList;

/*!
 *  \~chinese
 删除消息的回调

 @param conversationType    会话类型
 @param targetId            会话 ID
 
 *  \~english
 Callback for deleting the message.

 @param conversationType Conversation type
 @param targetId Conversation ID.
 */
- (void)notifyWatchKitClearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 删除消息的回调

 @param messageIds    消息 ID 的数组
 
 *  \~english
 Callback for deleting the message.

 @param messageIds Array of message ID.
 */
- (void)notifyWatchKitDeleteMessages:(NSArray *)messageIds;

/*!
 *  \~chinese
 清除未读消息数的回调

 @param conversationType    会话类型
 @param targetId            会话 ID
 
 *  \~english
 Callback for clearing the number of unread messages.

 @param conversationType Conversation type
 @param targetId Conversation ID.
 */
- (void)notifyWatchKitClearUnReadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId;

#pragma mark Discussion

/*!
 *  \~chinese
 创建讨论组的回调

 @param name         讨论组名称
 @param userIdList   成员的用户 ID 列表
 
 *  \~english
 Callback for creating a discussion group.

 @param name Discussion Group name.
 @param userIdList User ID list of members.
 */
- (void)notifyWatchKitCreateDiscussion:(NSString *)name userIdList:(NSArray *)userIdList;

/*!
 *  \~chinese
 创建讨论组成功的回调

 @param discussionId    讨论组的 ID
 
 *  \~english
 Callback for creating a discussion group successfully

 @param discussionId ID of the discussion group.
 */
- (void)notifyWatchKitCreateDiscussionSuccess:(NSString *)discussionId;

/*!
 *  \~chinese
 创建讨论组失败

 @param errorCode   创建失败的错误码
 
 *  \~english
 Failed to create discussion group.

 @param errorCode Create a failed error code.
 */
- (void)notifyWatchKitCreateDiscussionError:(RCErrorCode)errorCode;

/*!
 *  \~chinese
 讨论组加人的回调

 @param discussionId    讨论组的 ID
 @param userIdList      添加成员的用户 ID 列表

 @discussion 加人的结果可以通过 notifyWatchKitDiscussionOperationCompletion 获得。
 
 *  \~english
 Callback for discussion group members.

 @param discussionId ID of the discussion group.
 @param userIdList ID list of users who add members.

 @ discussion The added results can be obtained through notifyWatchKitDiscussionOperationCompletion.
 */
- (void)notifyWatchKitAddMemberToDiscussion:(NSString *)discussionId userIdList:(NSArray *)userIdList;

/*!
 *  \~chinese
 讨论组踢人的回调

 @param discussionId    讨论组 ID
 @param userId          用户 ID

 @discussion 踢人的结果可以通过 notifyWatchKitDiscussionOperationCompletion 获得。
 
 *  \~english
 Callback for kicking in the discussion group.

 @param discussionId Discussion group ID.
 @param userId User ID.

 @ discussion The result of  kicking can be obtained through notifyWatchKitDiscussionOperationCompletion.
 */
- (void)notifyWatchKitRemoveMemberFromDiscussion:(NSString *)discussionId userId:(NSString *)userId;

/*!
 *  \~chinese
 退出讨论组的回调

 @param discussionId    讨论组 ID

 @discussion 创建的结果可以通过 notifyWatchKitDiscussionOperationCompletion 获得。
 
 *  \~english
 Callback for exiting the discussion group.

 @param discussionId Discussion group ID.

 @ discussion The results created can be obtained through notifyWatchKitDiscussionOperationCompletion.
 */
- (void)notifyWatchKitQuitDiscussion:(NSString *)discussionId;

/*!
 *  \~chinese
 讨论组操作的回调。tag：100-邀请；101-踢人；102-退出。status：0 成功，非 0 失败

 @param tag       讨论组的操作类型。100 为加人，101 为踢人，102 为退出
 @param status    操作的结果。0表示成功，非0表示失败
 
 *  \~english
 Callback for discussion group operation. Tag:100- invitation; 101-kick; 102-quit. Status:0 for success, non-zero for failure

 @param tag The type of operation for the discussion group. 100 for joining, 101 for kicking and 102 for quitting.
 @param status The result of the operation. 0 indicates success, and non-0 indicates failure.
 */
- (void)notifyWatchKitDiscussionOperationCompletion:(int)tag status:(RCErrorCode)status;

@end
#endif
