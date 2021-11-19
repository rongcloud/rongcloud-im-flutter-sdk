//
//  RCConversationChannelManager.h
//  RongIMLibCore
//
//  Created by RongCloud on 2021/1/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCConversation.h"
#import "RCMessage.h"
#import "RCSearchConversationResult.h"
#import "RCStatusDefine.h"
#import "RCUploadImageStatusListener.h"
#import "RCUploadMediaStatusListener.h"
#import "RCUserInfo.h"
#import "RCSendMessageOption.h"
#import "RCRemoteHistoryMsgOption.h"
#import "RCConversationChannelProtocol.h"
#import "RCHistoryMessageOption.h"
/*!
 * \~chinese
 融云 ConversationChannel 核心类

 @discussion 您需要通过 sharedChannelManager 方法，获取单例对象。
 
 * \~english
 ConversationChannel core class

 @discussion You shall get the single instance object through the sharedChannelManager method.
 */
@interface RCChannelClient : NSObject

/*!
 * \~chinese
 获取核心类单例

 @return 核心单例类
 
 * \~english
 Get a single instance of the core class

 @return single instance of the core class
 */
+ (instancetype)sharedChannelManager;

#pragma mark Delegate
/*!
 * \~chinese
 设置消息接收监听器

 @param delegate    RCChannelClient 消息已读回执监听器

 @discussion
 设置 IMLibCore 的消息接收监听器请参考 RCChannelClient 的 setChannelMessageReceiptDelegate:object:方法。

 @remarks 功能设置
 * \~english
 */
- (void)setChannelMessageReceiptDelegate:(id<RCConversationChannelMessageReceiptDelegate>)delegate;


/*!
 * \~chinese
 设置输入状态的监听器

 @param delegate         RCChannelClient 输入状态的的监听器

 @warning           目前仅支持单聊。

 @remarks 功能设置
 
 * \~english
 Set the listener for the input status for channel client

 @param delegate    Listeners for IMLibCore  channel client input status

 @ warning           currently only support single chat

  @ remarks function setting
 */
- (void)setRCConversationChannelTypingStatusDelegate:(id<RCConversationChannelTypingStatusDelegate>)delegate;

#pragma mark Message Send

/*!
 * \~chinese
 发送消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param channelId          所属会话的业务标识
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock        消息发送成功的回调 [messageId: 消息的 ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode: 发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent ，用于显示；二是 pushData ，用于携带不显示的数据。

 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil ，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。

 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 @warning 如果您使用 IMLibCore，可以使用此方法发送消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送消息，否则不会自动更新 UI。

 @remarks 消息操作
 
 * \~english
 Send a message

  @param conversationType    Type of conversation in which the message is sent
  @param targetId            ID of conversation that sends the message
  @param channelId          Business ID of the session to which it belongs
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param successBlock        Callback for successful message sending [messageId: ID of message]
  @param errorBlock          Callback for failed message sending [nErrorCode: Error code for sending failure.
 MessageId: message ID]
 @ return                    message entity sent

 @ discussion A remote push will be received when the receiver is offline and allows remote push.
  Remote push consists of two parts, one is pushContent, which is used for display, and the other is pushData, which is used to carry data that is not displayed.

  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format is used for remote push.
  For a custom message, you shall set pushContent and pushData to define the push content yourself, otherwise remote push will not be carried out.

  If you use this method to send an image message, you shall upload the image yourself, build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of a successful upload, and then send it by using this method.

  If you use this method to send a file message, you should upload the file yourself, build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of a successful upload, and then send it by using this method.

  @ warning If you use IMLibCore, you can use this method to send messages;
 If you use IMKit, please use the method of the same name in RCIM to send a message, otherwise the UI will not be updated automatically.

  @ remarks message operation
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                 channelId:(NSString *)channelId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 * \~chinese
 发送消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param channelId          所属会话的业务标识
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param option              消息的相关配置
 @param successBlock        消息发送成功的回调 [messageId: 消息的 ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode: 发送失败的错误码,
 messageId: 消息的 ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent，用于显示；二是 pushData，用于携带不显示的数据。

 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。

 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 @warning 如果您使用 IMLibCore，可以使用此方法发送消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送消息，否则不会自动更新 UI。

 @remarks 消息操作
 
 * \~english
 Send a message.

  @param conversationType    Type of conversation in which the message is sent
  @param targetId            ID of conversation that sends the message
  @param channelId          Business ID of the session to which it belongs
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param option              Related configuration of messages.
  @param successBlock        Callback for successful message sending [messageId: ID of message]
 @param errorBlock          Callback for message sending failure  [nErrorCode: Error code for sending failure,
 messageId: ID of the message]
 @ return                    message entity sent

 @ discussion A remote push will be received when the receiver is offline and allows remote push.
  Remote push consists of two parts, one is pushContent, which is used for display, and the other is pushData, which is used to carry data that is not displayed.

  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format is used for remote push.
  For a custom type of message, you shall set pushContent and pushData to define the push content, otherwise remote push will not be carried out.

  If you use this method to send an image message, you shall upload the image yourself, build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of a successful upload, and then send it using this method.

  If you use this method to send a file message, you shall upload the file yourself, build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of a successful upload, and then send it using this method.

  @ warning you can use this method to send messages if you use IMLibCore,
 If you use IMKit, use the method of the same name in RCIM to send a message, otherwise the UI will not be updated automatically.

  @ remarks message operation
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                 channelId:(NSString *)channelId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                    option:(RCSendMessageOption *)option
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 * \~chinese
 发送媒体消息（图片消息或文件消息）

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param channelId          所属会话的业务标识
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的 ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的 ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent，用于显示；二是 pushData，用于携带不显示的数据。

 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。

 如果您需要上传图片到自己的服务器，需要构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 如果您需要上传文件到自己的服务器，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 @warning 如果您使用 IMLibCore，可以使用此方法发送媒体消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送媒体消息，否则不会自动更新 UI。

 @remarks 消息操作

 * \~english
 Send media messages (image messages or file messages)

  @param conversationType    Type of conversation in which the message is sent
  @param targetId            ID of conversation in which the message is sent
  @param channelId          Business ID of the session to which it belongs
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param progressBlock       Callback for message sending progress update [progress: current sending progress, 0< = progress < = 100, messageId: message ID]
  @param successBlock        Callback for successful message sending [messageId: message ID]
  @param errorBlock          callback for failed message sending [errorCode: error code for sending failure. messageId: message ID]
  @param cancelBlock         Callback for the user canceling message sending [messageId: message ID]
  @ return                    message entity sent .

  @ discussion A remote push can be received when the receiver is offline and allows remote push.
  The remote push consists of two parts, one is pushContent for display and the other is pushData for carrying data that is not displayed.

  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format will be used for remote push.
  For a custom type of message, you shall set pushContent and pushData to define the push content, otherwise remote push will not be carried out.

  If you need to upload images to your own server, you should build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of the successful uploading, and then use the RCCoreClient's
 sendMessage:targetId:content:pushContent:pushData:success:error: method or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  If you need to upload files to your own server, you should build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method.
 or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  @ warning If you use IMLibCore, you can use this method to send meida messages;
 If you use IMKit, please use the method of the same name in RCIM to send a media message, otherwise the UI will not be updated automatically.

  @ remarks message operation
 */
- (RCMessage *)sendMediaMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
                         cancel:(void (^)(long messageId))cancelBlock;

/*!
 * \~chinese
 发送媒体消息(上传图片或文件等媒体信息到指定的服务器)

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param channelId          所属会话的业务标识
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param uploadPrepareBlock  媒体文件上传进度更新的 IMKit 监听
 [uploadListener:当前的发送进度监听，SDK 通过此监听更新 IMKit UI]
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的 ID]
 @return                    发送的消息实体

 @discussion 此方法仅用于 IMKit。
 如果您需要上传图片到自己的服务器并使用 IMLibCore，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 如果您需要上传文件到自己的服务器并使用 IMLibCore，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 @remarks 消息操作
 *
 * \~english
 Send media messages (upload media information such as images or files to the specified server)

  @param conversationType    Type of conversation in which the message is sent.
  @param targetId            ID of conversation in which the message is sent
  @param channelId          Business ID of the session to which it belongs
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param uploadPrepareBlock  IMKit listening of media file uploading progress updates.
 [uploadListener: current sending progress listening, which is used by SDK to update IMKit UI]
  @param progressBlock        Callback for message sending progress update [progress: current sending progress, 0< = progress < = 100, messageId: message ID].
  @param successBlock        Callback for successful message sending [ messageId: message ID].
  @param errorBlock          Callback for failed message sending [errorCode: error code for sending failure
 messageId: message ID].
  @param cancelBlock         Callback for the user canceling message sending [messageId: message ID].
  @ return                      message entity sent.

  @ discussion This method is for IMKit only.
  If you need to upload pictures to your own server and use IMLibCore, you should build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method, or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  If you need to upload a file to your own server and use IMLibCore, you should build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method, or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  @ remarks message operation
 */
- (RCMessage *)sendMediaMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                  uploadPrepare:(void (^)(RCUploadMediaStatusListener *uploadListener))uploadPrepareBlock
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
                         cancel:(void (^)(long messageId))cancelBlock;

/*!
 * \~chinese
 插入向外发送的、指定时间的消息（此方法如果 sentTime 有问题会影响消息排序，慎用！！）
（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param sentStatus          发送状态
 @param content             消息的内容
 @param sentTime            消息发送的 Unix 时间戳，单位为毫秒（传 0 会按照本地时间插入）
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。如果 sentTime<=0，则被忽略，会以插入时的时间为准。

 @remarks 消息操作
 
 * \~english
 Insert a message sent outward at a specified time (this method will affect message sorting if there is a problem with sentTime and shall be used with caution!!)
 (The message is only inserted into the local database and is not actually sent to the server and the other party).

  @param conversationType    Conversation type
  @param targetId            Conversation ID.
  @param channelId          Business ID of the session to which it belongs
  @param sentStatus          Sending status.
  @param content             Content of the message.
  @param sentTime            Unix timestamp of the message sent, in milliseconds (0 will be inserted according to local time).
 @ return                    message entity inserted.

 @ discussion This method does not support the chatroom conversation type. If sentTime < = 0, it will be ignored and the time at which it is inserted shall prevail.

  @ remarks message operation
 */
- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                           channelId:(NSString *)channelId
                          sentStatus:(RCSentStatus)sentStatus
                             content:(RCMessageContent *)content
                            sentTime:(long long)sentTime;

/*!
 * \~chinese
 插入接收的消息（此方法如果 sentTime
 有问题会影响消息排序，慎用！！）（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param senderUserId        发送者 ID
 @param receivedStatus      接收状态
 @param content             消息的内容
 @param sentTime            消息发送的 Unix 时间戳，单位为毫秒 （传 0 会按照本地时间插入）
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。

 @remarks 消息操作
 * \~english
 Insert the received message (the message is only inserted into the local database and is not actually sent to the server and the other party).

  @param conversationType    Conversation type
  @param targetId            Conversation ID
  @param channelId          Business ID of the session to which it belongs
  @param senderUserId        Sender ID
  @param receivedStatus      Receiving status
  @param content             Content of the message
  @param sentTime            Unix timestamp of the message sent, in milliseconds (0 will be inserted according to local time).
  @ return                    message entity inserted.

  @ discussion This method does not support the chatroom conversation type.

  @ remarks message operation
 */
- (RCMessage *)insertIncomingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                           channelId:(NSString *)channelId
                        senderUserId:(NSString *)senderUserId
                      receivedStatus:(RCReceivedStatus)receivedStatus
                             content:(RCMessageContent *)content
                            sentTime:(long long)sentTime;

/*!
 * \~chinese
 发送定向消息

 @param conversationType 发送消息的会话类型
 @param targetId         发送消息的会话 ID
 @param channelId          所属会话的业务标识
 @param userIdList       接收消息的用户 ID 列表
 @param content          消息的内容
 @param pushContent      接收方离线时需要显示的远程推送内容
 @param pushData         接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock     消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock       消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]

 @return 发送的消息实体

 @discussion 此方法用于在群组和讨论组中发送消息给其中的部分用户，其它用户不会收到这条消息。
 如果您使用 IMLibCore，可以使用此方法发送定向消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送定向消息，否则不会自动更新 UI。

 @warning 此方法目前仅支持群组和讨论组。

 @remarks 消息操作
 
 * \~english
 Send directed messages.

 @param conversationType         Type of conversation in which the message is sent
 @param targetId         Conversation ID that sends the message
 @param channelId          Business ID of the session to which it belongs
 @param userIdList         List of user ID receiving messages
 @param content         Content of the message
 @param pushContent         Remote push content that needs to be displayed when the receiver is offline
 @param pushData         Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
 @param successBlock         Callback for successful message sending [messageId: message ID]
 @param errorBlock         Callback for failed message sending [errorCode: error code for sending failure,
 messageId: message ID]

 @ return Message entity sent.

 @ discussion This method is used to send messages to some of the users in groups and discussion groups, and other users will not receive this message.
  If you use IMLibCore, you can use this method to send directed messages.
 If you use IMKit, please use the method of the same name in RCIM to send a directed message, otherwise the UI will not be updated automatically.

  @ warning This method currently only supports groups and discussion groups.

  @ remarks message operation
 */
- (RCMessage *)sendDirectionalMessage:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                            channelId:(NSString *)channelId
                         toUserIdList:(NSArray *)userIdList
                              content:(RCMessageContent *)content
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                              success:(void (^)(long messageId))successBlock
                                error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 * \~chinese
 发送定向消息

 @param conversationType 发送消息的会话类型
 @param targetId         发送消息的会话 ID
 @param channelId          所属会话的业务标识
 @param userIdList       接收消息的用户 ID 列表
 @param content          消息的内容
 @param pushContent      接收方离线时需要显示的远程推送内容
 @param pushData         接收方离线时需要在远程推送中携带的非显示数据
 @param option              消息的相关配置
 @param successBlock     消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock       消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]

 @return 发送的消息实体

 @discussion 此方法用于在群组和讨论组中发送消息给其中的部分用户，其它用户不会收到这条消息。
 如果您使用 IMLibCore，可以使用此方法发送定向消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送定向消息，否则不会自动更新 UI。

 @warning 此方法目前仅支持群组和讨论组。

 @remarks 消息操作
 
 * \~english
 Send directed messages.

 @param conversationType         Type of conversation in which the message is sent
 @param targetId         Conversation ID that sends the message
 @param channelId          Business ID of the session to which it belongs
 @param userIdList         List of user ID receiving messages
 @param content         Content of the message
 @param pushContent         Remote push content that needs to be displayed when the receiver is offline
 @param pushData         Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
 @param successBlock         Callback for successful message sending [messageId: message ID]
 @param errorBlock         Callback for failed message sending [errorCode: error code for sending failure,
 messageId: message ID]

 @ return Message entity sent.

 @ discussion This method is used to send messages to some of the users in groups and discussion groups, and other users will not receive this message.
  If you use IMLibCore, you can use this method to send directed messages.
 If you use IMKit, please use the method of the same name in RCIM to send a directed message, otherwise the UI will not be updated automatically.

  @ warning This method currently only supports groups and discussion groups.

  @ remarks message operation
 */
- (RCMessage *)sendDirectionalMessage:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                            channelId:(NSString *)channelId
                         toUserIdList:(NSArray *)userIdList
                              content:(RCMessageContent *)content
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                               option:(RCSendMessageOption *)option
                              success:(void (^)(long messageId))successBlock
                                error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;
#pragma mark Message Read Receipt

/*!
 * \~chinese
 发送某个会话中消息阅读的回执

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param timestamp           该会话中已阅读的最后一条消息的发送时间戳
 @param successBlock        发送成功的回调
 @param errorBlock          发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 此接口只支持单聊, 如果使用 IMLibCore 可以注册监听
 RCLibDispatchReadReceiptNotification 通知,使用 IMKit 直接设置RCIM.h
 中的 enabledReadReceiptConversationTypeList。

 @warning 目前仅支持单聊。

 @remarks 高级功能
 
 * \~english
 Send a message reading receipt in a conversation

 @param conversationType        Conversation type
 @param targetId        Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param timestamp        The sending timestamp of the last message read by the conversation.
 @param successBlock        Callback for successful sending
 @param errorBlock        Callback for sending failure [nErrorCode: error code for failure]

 @ discussion This interface only supports single chat. If you use IMLibCore, you can register to listen to
 RCLibDispatchReadReceiptNotification notification, and use IMKit to set directly
 enabledReadReceiptConversationTypeList in RCIM.h.

  @ warning Currently only support single chat.

  @ remarks advanced functions
 */
- (void)sendReadReceiptMessage:(RCConversationType)conversationType
                      targetId:(NSString *)targetId
                     channelId:(NSString *)channelId
                          time:(long long)timestamp
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 * \~chinese
 发送阅读回执

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param channelId          所属会话的业务标识
 @param messageList      已经阅读了的消息列表
 @param successBlock     发送成功的回调
 @param errorBlock       发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 当用户阅读了需要阅读回执的消息，可以通过此接口发送阅读回执，消息的发送方即可直接知道那些人已经阅读。

 @remarks 高级功能
 
 * \~english
 Send a reading receipt

 @param conversationType        Conversation type
 @param targetId        Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param messageList        List of messages that have been read
 @param successBlock        Callback for successful sending
 @param errorBlock        Callback for failed sending [nErrorCode: Error code of failure]

 @ discussion When a user reads a message that needs to be read, a reading receipt cane be sent through this interface, and the sender of the message can directly know who has read the message.

  @ remarks advanced functions
 */
- (void)sendReadReceiptResponse:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                    messageList:(NSArray<RCMessage *> *)messageList
                        success:(void (^)(void))successBlock
                          error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 * \~chinese
 同步会话阅读状态（把指定会话里所有发送时间早于 timestamp 的消息置为已读）

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param channelId          所属会话的业务标识
 @param timestamp        已经阅读的最后一条消息的 Unix 时间戳(毫秒)
 @param successBlock     同步成功的回调
 @param errorBlock       同步失败的回调[nErrorCode: 失败的错误码]

 @remarks 高级功能
 
 * \~english
 Synchronize conversation reading status (set all messages sent before timestamp in a specified conversation to be read)

 @param conversationType        Conversation type
 @param targetId        Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param timestamp        Unix timestamp of the last message read (in milliseconds)
 @param successBlock        Callback for successful synchronization
 @param errorBlock        Callback for failed synchronization [nErrorCode: Error code for failure].

 @ remarks advanced functions
 */
- (void)syncConversationReadStatus:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                         channelId:(NSString *)channelId
                              time:(long long)timestamp
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode nErrorCode))errorBlock;

#pragma mark - Message Operation

/*!
 * \~chinese
 获取某个会话中指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 
 * \~english
 Get the specified number of latest message entities in a conversation

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param count            Number of messages to be obtained
 @ return             RCMessage object list of message entity

 @ discussion
 This method gets the specified number of latest message entities in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.

  @ remarks message operation
 */
- (NSArray *)getLatestMessages:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId count:(int)count;

/*!
 * \~chinese
 获取会话中，从指定消息之前、指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param oldestMessageId     截止的消息 ID
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，oldestMessageId 之前的、指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 oldestMessageId 对应那条消息，如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId 为 10，count 为 2，会返回 messageId 为 9 和 8 的 RCMessage 对象列表。

 @remarks 消息操作
 
 * \~english
 Get the latest message entity of the specified number before the specified message in the conversation.

 @param conversationType     Conversation type
 @param targetId     Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param oldestMessageId     ID of due message.
 @param count     Number of messages to be obtained.
 @ return                    RCMessage object list of message entity

 @ discussion
 This method gets the specified number of latest message entities in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to oldestMessageId. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.
  E.g.
  If the oldestMessageId is 10 and the count is 2, a list of Message objects with messageId as 9 and 8 will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 * \~chinese
 获取会话中，从指定消息之前、指定数量的、指定消息类型的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param objectName          消息内容的类型名，如果想取全部类型的消息请传 nil
 @param oldestMessageId     截止的消息 ID
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，oldestMessageId 之前的、指定数量和消息类型的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 oldestMessageId 对应的那条消息，如果会话中的消息数量小于参数 count
 的值，会将该会话中的所有消息返回。
 如：oldestMessageId 为 10，count 为 2，会返回 messageId 为 9 和 8 的 RCMessage 对象列表。

 @remarks 消息操作
 
 * \~english
 Get the latest message entity of the specified number and specified message types before the specified message in the conversation.

 @param conversationType          Conversation type
 @param targetId          Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param objectName          Type name of the message content. If you want to get all types of messages, please pass nil
 @param oldestMessageId           ID of due message
 @param count          Number of messages to be obtained.
 @ return                    RCMessage object list of message entity

 @ discussion
 This method gets the specified number of latest message entities in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to oldestMessageId. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.
  For example, if the oldestMessageId is 10 and the count is 2, a list of Message objects with messageId as 9 and 8 will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                     objectName:(NSString *)objectName
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 * \~chinese
 获取会话中，指定消息、指定数量、指定消息类型、向前或向后查找的消息实体列表

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param objectName          消息内容的类型名，如果想取全部类型的消息请传 nil
 @param baseMessageId       当前的消息 ID
 @param isForward           查询方向 true 为向前，false 为向后
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，baseMessageId
 之前或之后的、指定数量、消息类型和查询方向的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 baseMessageId 对应的那条消息，如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 
 *  \~english
 Get a list of forward or backward searched message entities with specified messages, specified number and specified message type in the conversation

 @param conversationType       Conversation type
 @param targetId       Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param objectName       Type name of the message content. If you want to get all types of messages, please pass nil.
 @param baseMessageId       Current message ID.
 @param isForward       Query direction: true indicates forward and false indicates backward.
 @param count       Number of messages to be obtained
 @ return                    object list of message entity RCMessage

 @ discussion
 This method gets the latest message entities before or after baseMessageId with the specified number, message type, and query direction, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to baseMessageId. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                     objectName:(NSString *)objectName
                  baseMessageId:(long)baseMessageId
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 * \~chinese
 获取会话中，指定时间、指定数量、指定消息类型（多个）、向前或向后查找的消息实体列表

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param objectNames         消息内容的类型名称列表
 @param sentTime            当前的消息时间戳
 @param isForward           查询方向 true 为向前，false 为向后
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，sentTime
 之前或之后的、指定数量、指定消息类型（多个）的消息实体列表，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 sentTime 对应的那条消息，如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 
 *  \~english
 Get a list of forward or backward searched message entities with a specified time, a specified number and a specified message type (multiple) in a conversation

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param objectNames         List of type names for message content
 @param sentTime         Current message timestamp
 @param isForward         Query direction: true indicates forward and false indicates backward
 @param count         Number of messages to be obtained.
 @ return                     object list of message entity RCMessage

 @ discussion
 This method gets a list of message entities before and after the sentTime with a specified number and a specified message type (multiple) in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to sentTime. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                    objectNames:(NSArray *)objectNames
                       sentTime:(long long)sentTime
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 * \~chinese
 在会话中搜索指定消息的前 beforeCount 数量和后 afterCount
 数量的消息。返回的消息列表中会包含指定的消息。消息列表时间顺序从新到旧。

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param sentTime            消息的发送时间
 @param beforeCount         指定消息的前部分消息数量
 @param afterCount          指定消息的后部分消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 获取该会话的这条消息及这条消息前 beforeCount 条和后 afterCount 条消息,如前后消息不够则返回实际数量的消息。

 @remarks 消息操作
 
 *  \~english
 Searches the the number of beforeCount and afterCount messages for the specified message in the conversation. The list of returned messages contains the specified message. The message in the list are in chronological order from earliest to most recent.

  @param conversationType    Conversation type
 @param targetId         Conversation ID
 @param sentTime         Time when the message is sent
 @param beforeCount         Specify the number of messages in the first part of the message.
 @param afterCount         Specify the number of messages in the latter part of the message.
 @ return                    object list of message entity RCMessage

 @ discussion
 Get this message, beforeCount messages ahead of this message and afterCount messages after this message in the conversation. If there are not enough messages before and after the message, the actual number of messages will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                       sentTime:(long long)sentTime
                    beforeCount:(int)beforeCount
                     afterCount:(int)afterCount;

/*!
 * \~chinese
 从服务器端清除历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param recordTime          清除消息时间戳，【0 <= recordTime <= 当前会话最后一条消息的 sentTime,0
 清除所有消息，其他值清除小于等于 recordTime 的消息】
 @param successBlock        获取成功的回调
 @param errorBlock          获取失败的回调 [status:清除失败的错误码]

 @discussion
 此方法从服务器端清除历史消息，但是必须先开通历史消息云存储功能。
 例如，您不想从服务器上获取更多的历史消息，通过指定 recordTime 清除成功后只能获取该时间戳之后的历史消息。

 @remarks 消息操作
 
 *  \~english
 Clear historical messages from the server

 @param conversationType          Conversation type
 @param targetId          Conversation ID
 @param recordTime          Clear the message timestamp, [0 < = recordTime < = the sentTime of the last message in the current conversation, 0:
 Clear all messages, other values: clear messages less than or equal to recordTime].
 @param successBlock          Callback for successful acquisition
 @param errorBlock          Callback for failed acquisition [status: error code for clearing failure ]

 @ discussion
 This method clears historical messages from the server, bu the historical message cloud storage function must be activated first.
  For example, if you don't want to get more history messages from the server, you can only get the history messages after the timestamp after the recordTime has been cleared successfully.

  @ remarks message operation
 */
- (void)clearRemoteHistoryMessages:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                         channelId:(NSString *)channelId
                        recordTime:(long long)recordTime
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode status))errorBlock;

/*!
 * \~chinese
 清除历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param recordTime          清除消息时间戳，【0 <= recordTime <= 当前会话最后一条消息的 sentTime,0
 清除所有消息，其他值清除小于等于 recordTime 的消息】
 @param clearRemote         是否同时删除服务端消息
 @param successBlock        获取成功的回调
 @param errorBlock          获取失败的回调 [ status:清除失败的错误码]

 @discussion
 此方法可以清除服务器端历史消息和本地消息，如果清除服务器端消息必须先开通历史消息云存储功能。
 例如，您不想从服务器上获取更多的历史消息，通过指定 recordTime 并设置 clearRemote 为 YES
 清除消息，成功后只能获取该时间戳之后的历史消息。如果 clearRemote 传 NO，
 只会清除本地消息。

 @remarks 消息操作
 
 *  \~english
 Clear historical messages.

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param recordTime         Clear the message timestamp, [0 < = recordTime < = the sentTime of the last message in the current conversation. 0:
 Clear all messages, other values: clear messages less than or equal to recordTime].
 @param clearRemote         Whether to delete server messages at the same time.
 @param successBlock         Callback for successful acquisition.
 @param errorBlock         Callback for failed acquisition [status: error code for clearing failure].

 @ discussion
 This method can clear server-side historical messages and local messages. If you clear messages on the server, you must first activate the historical message cloud storage functions.
  For example, if you don't want to get more historical messages from the server, you can specify the recordTime and set clearRemote to YES to clear the messages, and then you can only get the historical message after the timestamp. If clearRemote passes NO, only local messages are cleared.

  @ remarks message operation
 */
- (void)clearHistoryMessages:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   channelId:(NSString *)channelId
                  recordTime:(long long)recordTime
                 clearRemote:(BOOL)clearRemote
                     success:(void (^)(void))successBlock
                       error:(void (^)(RCErrorCode status))errorBlock;

/*!
 * \~chinese
 从服务器端获取之前的历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param recordTime          截止的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 20
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, isRemaining 是否还有剩余消息 YES
 表示还有剩余，NO 表示无剩余]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime 应传入最早的消息的发送时间戳，count 传入
 1~20 之间的数值。

 @discussion 本地数据库可以查到的消息，该接口不会再返回，所以建议先用 getHistoryMessages
 相关接口取本地历史消息，本地消息取完之后再通过该接口获取远端历史消息

 @remarks 消息操作
 
 *  \~english
 Get previous historical messages from the server.

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param recordTime         Due message sending timestamp, in milliseconds.
 @param count         Number of messages to be obtained, 0 < count < = 20.
 @param successBlock         Callback for successful acquisition [messages: array of obtained historical messages; isRemaining: whether there are any remaining messages; YES indicates that there is still any remaining messages; NO indicates that there is no remaining messages]
 @param errorBlock         Callback for failed acquisition [status: error code for acquisition failure]

 @ discussion
 This method obtains the previous historical messages from the server, but the historical message cloud storage function must be activated first.
  For example, if there are 10 messages in the local conversation, and you want to pull more messages saved on the server, recordTime should pass in the earliest message sending timestamp, and count should pass in a value between 1 and 20.

  @ discussion Messages that can be found in the local database will not be returned by this interface, so it is recommended to first take the local historical messages by using the related interfaces of the getHistoryMessages.
 After the local message is taken, the remote historical messages are obtained through this interface

 @ remarks message operation
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                       channelId:(NSString *)channelId
                      recordTime:(long long)recordTime
                           count:(int)count
                         success:(void (^)(NSArray *messages, BOOL isRemaining))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 * \~chinese
 从服务器端获取之前的历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param option              可配置的参数
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, isRemaining 是否还有剩余消息 YES
 表示还有剩余，NO 表示无剩余]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 例如，本地会话中有 10 条消息，您想拉取更多保存在服务器的消息的话，recordTime 应传入最早的消息的发送时间戳，count 传入
 1~20 之间的数值。

 @remarks 消息操作
 
 *  \~english
 Get previous historical messages from the server

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param option         Configurable parameters
 @param successBlock         Callback for successful acquisition [messages: array of obtained historical messages; isRemaining: whether there are any remaining messages; YES:
 Indicates that there is still any remaining messages; NO: indicates that there is no remaining messages].
 @param errorBlock         Callback for failed acquisition [status: error code for acquisition failure].

 @ discussion
 This method obtains the previous historical messages from the server, but the historical message cloud storage function must be activated first.
  For example, if there are 10 messages in the local conversation, and you want to pull more messages saved on the server, recordTime should pass in the earliest message sending timestamp, and count should pass in a value between 1 and 20.

  @ remarks message operation
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                       channelId:(NSString *)channelId
                          option:(RCRemoteHistoryMsgOption *)option
                         success:(void (^)(NSArray *messages, BOOL isRemaining))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;


/*!
 * \~chinese
 获取历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param option              可配置的参数
 @param complete        获取成功的回调 [messages：获取到的历史消息数组； code : 获取是否成功，0表示成功，非 0 表示失败，此时 messages 数组可能存在断档]

 @discussion 必须开通历史消息云存储功能。
 @discussion count 传入 1~20 之间的数值。
 @discussion 此方法先从本地获取历史消息，本地有缺失的情况下会从服务端同步缺失的部分。
 @discussion 从服务端同步失败的时候会返回非 0 的 errorCode，同时把本地能取到的消息回调上去。

 @remarks 消息操作
 
 *  \~english
 Get historical messages

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param option         Configurable parameters
 @param complete         Callback for successful acquisition [messages: array of obtained historical messages; Code: succeeded or not; 0: successful; non-0: failed. In this case, there may be a message break in the messages array]

 @ discussion The historical message cloud storage function must be activated.
  @ discussion The count passes a value between 1 and 20.
  @ discussion This method first obtains historical messages locally, and synchronizes the missing parts from the server if it is missing locally;
  @ discussion If synchronization fails on the server, a non-0 errorCode will be returned, and the messages that can be accessed locally will be called back.

  @ remarks message operation
 */
- (void)getMessages:(RCConversationType)conversationType
           targetId:(NSString *)targetId
          channelId:(NSString *)channelId
             option:(RCHistoryMessageOption *)option
           complete:(void (^)(NSArray *messages, RCErrorCode code))complete;

/*!
 * \~chinese
 获取会话中@提醒自己的消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识

 @discussion
 此方法从本地获取被@提醒的消息(最多返回 10 条信息)
 @warning 使用 IMKit 注意在进入会话页面前调用，否则在进入会话清除未读数的接口 clearMessagesUnreadStatus: targetId:
 以及 设置消息接收状态接口 setMessageReceivedStatus:receivedStatus:会同步清除被提示信息状态。

 @remarks 高级功能
 
 *  \~english
 Get the @ reminder messages in the conversation.

 @param conversationType         Conversation type
 @param targetId         Conversation ID.
 @param channelId          Business ID of the session to which it belongs

 @ discussion
 This method gets the @ reminder messages locally (a maximum of 10 messages are returned).
 @ warning When the IMKit is used, note that it is called before the conversation page is entered, otherwise the unread interface clearMessagesUnreadStatus: is cleared when the conversation is entered. targetId:
  When the message receiving status interface setMessageReceivedStatus:receivedStatus: is set, it will synchronously clear the prompted information status.

  @ remarks advanced functions
 */
- (NSArray *)getUnreadMentionedMessages:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/**
 * \~chinese
 * 获取会话里第一条未读消息。
 *
 * @param conversationType 会话类型
 * @param targetId   会话 ID
 * @param channelId  所属会话的业务标识
 * @return 第一条未读消息的实体。
 * @remarks 消息操作
 *
 *  \~english
 * Get the first unread message in the conversation.
 *
 * @param conversationType         Conversation type
 * @param targetId         Conversation ID
 * @param channelId          Business ID of the session to which it belongs
 * @ return Entity of the first unread message.
 * @ remarks Message operation
 */
- (RCMessage *)getFirstUnreadMessage:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/*!
 * \~chinese
 删除某个会话中的所有消息

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param successBlock        成功的回调
 @param errorBlock          失败的回调

 @discussion 此方法删除数据库中该会话的消息记录，同时会整理压缩数据库，减少占用空间

 @remarks 消息操作
 
 *  \~english
 Delete all messages in a conversation

 @param conversationType         Conversation type, which does not support chatroom
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param successBlock        Callback for success
 @param errorBlock        Callback for failure

 @ discussion This method deletes the message record of the conversation in the database. At the same time, the compressed database is sorted to reduce the footprint.

 @ remarks Message operation
 */
- (void)deleteMessages:(RCConversationType)conversationType
              targetId:(NSString *)targetId
             channelId:(NSString *)channelId
               success:(void (^)(void))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/**
 * \~chinese
 批量删除某个会话中的指定远端消息（同时删除对应的本地消息）

 @param conversationType 会话类型，不支持聊天室
 @param targetId 目标会话ID
 @param channelId          所属会话的业务标识
 @param messages 将被删除的消息列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调

 @discussion 此方法会同时删除远端和本地消息。
 一次批量操作仅支持删除属于同一个会话的消息，请确保消息列表中的所有消息来自同一会话
 一次最多删除 100 条消息。

 @remarks 消息操作
 
 *  \~english
 Delete specified remote messages in a conversation in batches (while deleting corresponding local messages)

 @param conversationType Conversation type, which does not support chatroom
 @param targetId Target conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param messages List of messages to be deleted
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ discussion This method deletes both remote and local messages.
  One batch operation only supports to delete messages belonging to the same conversation, please make sure that all messages in the message list come from the same conversation and delete at most 100 messages at a time.

  @ remarks message operation
 */
- (void)deleteRemoteMessage:(RCConversationType)conversationType
                   targetId:(NSString *)targetId
                  channelId:(NSString *)channelId
                   messages:(NSArray<RCMessage *> *)messages
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 * \~chinese
 删除某个会话中的所有消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @return                    是否删除成功

 @remarks 消息操作
 
 *  \~english
 Delete all messages in a conversation

 @param conversationType           Conversation type
 @param targetId           Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @ return                    Whether it is deleted successfully.

 @ remarks Message operation
 */
- (BOOL)clearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

#pragma mark - Conversation List
/*!
 * \~chinese
 获取会话列表

 @param conversationTypeList   会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @param channelId          所属会话的业务标识
 @return                        会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 @discussion 当您的会话较多且没有清理机制的时候，强烈建议您使用 getConversationList: count: startTime:
 分页拉取会话列表,否则有可能造成内存过大。

 @remarks 会话列表
 
 *  \~english
 Get conversation list

 @param conversationTypeList  An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray)
 @param channelId          Business ID of the session to which it belongs
  @ return                        List of conversation RCConversation

 @ discussion This method reads the conversation list from the local database.
  The list of returned conversations is in chronological order from earliest to most recent. If a conversation is set top, the top conversation is listed first.
  @ discussion When you have a large number of conversations and do not have a cleaning mechanism, it is strongly recommended that you use getConversationList: count: startTime:
  Pull the list of the conversation page by page, otherwise the memory may be too large.

  @ remarks Conversation list
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList channelId:(NSString *)channelId;

/*!
 * \~chinese
 分页获取会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @param channelId          所属会话的业务标识
 @param count                获取的数量（当实际取回的会话数量小于 count 值时，表明已取完数据）
 @param startTime            会话的时间戳（获取这个时间戳之前的会话列表，0表示从最新开始获取）
 @return                     会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。

 @remarks 会话列表
 
 *  \~english
 Get a list of conversations page by page

 @param conversationTypeList  An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @param channelId          Business ID of the session to which it belongs
 @param count                Number of conversations obtained (when the actual number of conversations retrieved is less than the count value, the data has been fetched).
 @param startTime                Timestamp of the conversation (get the list of conversation before this timestamp, 0 indicates obtaining from the latest one).
 @ return                     List of the conversation RCConversation

 @ discussion This method reads the conversation list from the local database.
  The list of returned conversations is in chronological order from earliest to most recent. If a conversation is set top, the top conversation is listed first.

  @ remarks Conversation list
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList channelId:(NSString *)channelId count:(int)count startTime:(long long)startTime;

/*!
 * \~chinese
 获取单个会话数据

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @return                    会话的对象

 @remarks 会话
 
 *  \~english
 Get single conversation data

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @ return                    Conversation object

 @ remarks Conversation
 */
- (RCConversation *)getConversation:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/*!
 * \~chinese
 获取会话中的消息数量

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @return                    会话中的消息数量

 @discussion -1 表示获取消息数量出错。

 @remarks 会话
 
 *  \~english
 Get the number of messages in the conversation

 @param conversationType            Conversation type
 @param targetId            Conversation ID.
 @param channelId          Business ID of the session to which it belongs
 @ return                   Number of messages in conversation.

 @ discussion - 1 indicates an error in obtaining the number of messages.

  @ remarks Conversation
 */
- (int)getMessageCount:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/*!
 * \~chinese
 删除指定类型的会话

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @param channelId          所属会话的业务标识
 @return                        是否删除成功

 @discussion 此方法会从本地存储中删除该会话，同时删除会话中的消息。

 @remarks 会话
 
 *  \~english
 Delete a conversation of the specified type.

 @param conversationTypeList An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @param channelId          Business ID of the session to which it belongs
 @ return                        Whether it is deleted successfully.

 @ discussion This method deletes the conversation from the local storage and deletes the message in the conversation.

  @ remarks Conversation
 */
- (BOOL)clearConversations:(NSArray *)conversationTypeList channelId:(NSString *)channelId;

/*!
 * \~chinese
 从本地存储中删除会话

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @return                    是否删除成功

 @discussion
 此方法会从本地存储中删除该会话，但是不会删除会话中的消息。如果此会话中有新的消息，该会话将重新在会话列表中显示，并显示最近的历史消息。

 @remarks 会话
 
 *  \~english
 Delete a conversation from the local storage

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @ return                    Whether it is deleted successfully.

 @ discussion
 This method deletes the conversation from the local storage, but does not delete the message in the conversation. If there is a new message in this conversation, the conversation will reappear in the conversation list and the most recent historical message will be displayed.

  @ remarks Conversation
 */
- (BOOL)removeConversation:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/*!
 * \~chinese
 设置会话的置顶状态

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param isTop               是否置顶
 @return                    设置是否成功

 @discussion 会话不存在时设置置顶，会在会话列表生成会话。

 @remarks 会话
 
 *  \~english
 Set the top status of the conversation.

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param isTop            Whether or not set top
 @ return                    Whether it is set successfully

 @ discussion If the conversation is set top when the conversation does not exist, the conversation will be generated in the conversation list
  @ discussion After the conversation is set top, the conversation will be deleted, and the top setting will automatically expire

 @ remarks Conversation
 */
- (BOOL)setConversationToTop:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId isTop:(BOOL)isTop;

/*!
 * \~chinese
 获取置顶的会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                     置顶的会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取置顶的会话列表。

 @remarks 会话列表
 
 *  \~english
 Get a list of top conversations

 @param conversationTypeList An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @param channelId          Business ID of the session to which it belongs
 @ return                      List of top conversation RCConversation.

 @ discussion This method reads the top conversation list from the local database.

  @ remarks Conversation list
 */
- (NSArray<RCConversation *> *)getTopConversationList:(NSArray *)conversationTypeList channelId:(NSString *)channelId;

#pragma mark Draft

/*!
 * \~chinese
 获取会话中的草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @param channelId          所属会话的业务标识
 @return                    该会话中的草稿

 @remarks 会话
 
 *  \~english
 Get draft information in the conversations (temporary messages entered by the user but not sent).

 @param conversationType            Conversations type
 @param targetId             Conversation destination ID
 @param channelId          Business ID of the session to which it belongs
 @ return                    drafts in this conversations

 @ remarks Conversations
 */
- (NSString *)getTextMessageDraft:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/*!
 * \~chinese
 保存草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @param channelId          所属会话的业务标识
 @param content             草稿信息
 @return                    是否保存成功

 @remarks 会话
 
 *  \~english
 Save draft information (temporarily stored messages entered by the user but not sent).

 @param conversationType            Conversation type
 @param targetId            Conversation destination ID
 @param channelId          Business ID of the session to which it belongs
 @param content            Draft information
 @ return               whether it is saved successfully.

 @ remarks Conversation
 */
- (BOOL)saveTextMessageDraft:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                   channelId:(NSString *)channelId
                     content:(NSString *)content;

/*!
 * \~chinese
 删除会话中的草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @param channelId          所属会话的业务标识
 @return                    是否删除成功

 @remarks 会话
 
 *  \~english
 Delete draft information in a conversation (temporarily stored messages entered by the user but not sent).

 @param conversationType            Conversation type
 @param targetId            Conversation destination ID
 @param channelId          Business ID of the session to which it belongs
 @ return                     Whether it is deleted successfully

 @ remarks Conversation
 */
- (BOOL)clearTextMessageDraft:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

#pragma mark Unread Count

/*!
 * \~chinese
 获取所有的未读消息数（聊天室会话除外）
 
 @param channelId          所属会话的业务标识

 @return    所有的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of all unread messages (except chatroom conversations).
 
 @param channelId          Business ID of the session to which it belongs

 @ return    All unread messages

 @ remarks Conversation
 */
- (int)getTotalUnreadCountWithChannelId:(NSString *)channelId;

/*!
 * \~chinese
 获取某个会话内的未读消息数（聊天室会话除外）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @param channelId          所属会话的业务标识
 @return                    该会话内的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of unread messages in a conversation (except for chatroom conversations).

 @param conversationType            Conversation type
 @param targetId            Conversation destination ID
 @param channelId          Business ID of the session to which it belongs
 @ return                Number of unread messages in the conversation

 @ remarks Conversation
 */
- (int)getUnreadCount:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/**
 * \~chinese
 获取某些类型的会话中所有的未读消息数 （聊天室会话除外）

 @param conversationTypes   会话类型的数组
 @param channelId          所属会话的业务标识
 @param isContain           是否包含免打扰消息的未读数
 @return                    该类型的会话中所有的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of all unread messages in certain types of conversations (except chatroom conversations)

 @param conversationTypes           Array of conversation types.
 @param channelId          Business ID of the session to which it belongs
 @param isContain           Does it include the number of the unread Do Not Disturb messages.
 @ return                     Number of all unread messages in this type of conversation.

 @ remarks Conversation
 */
- (int)getUnreadCount:(NSArray *)conversationTypes channelId:(NSString *)channelId containBlocked:(bool)isContain;

/*!
 * \~chinese
 获取某个类型的会话中所有未读的被@的消息数

 @param conversationTypes   会话类型的数组
 @param channelId          所属会话的业务标识
 @return                    该类型的会话中所有未读的被@的消息数

 @remarks 会话
 
 *  \~english
 Get the number of unread @ messages in a certain type of conversation

 @param conversationTypes Array of conversation types
 @param channelId          Business ID of the session to which it belongs
 @ return                    Number of unread @ messages in this type of conversation

 @ remarks Conversation
 */
- (int)getUnreadMentionedCount:(NSArray *)conversationTypes channelId:(NSString *)channelId;

/*!
 * \~chinese
 清除某个会话中的未读消息数

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @return                    是否清除成功

 @remarks 会话
 
 *  \~english
 Clear the number of unread messages in a conversation.

 @param conversationType            Conversation type, which does not support chatroom
 @param targetId             Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @ return                    whether it is cleared successfully.

 @ remarks Conversation
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId;

/*!
 * \~chinese
 清除某个会话中的未读消息数（该会话在时间戳 timestamp 之前的消息将被置成已读。）

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param timestamp           该会话已阅读的最后一条消息的发送时间戳
 @return                    是否清除成功

 @remarks 会话
 
 *  \~english
 Clear the number of unread messages in a conversation (messages for that conversation before the timestamp will be set to read.)

 @param conversationType    Conversation type, which does not support chatroom
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param timestamp            Sending timestamp of the last message read by the conversation
 @ return             Whether it is cleared successfully.

 @ remarks Conversation
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                        channelId:(NSString *)channelId
                             time:(long long)timestamp;

#pragma mark - Message Notification

/*!
 * \~chinese
 设置会话的消息提醒状态

 @param conversationType            会话类型
 @param targetId                    会话 ID
 @param channelId          所属会话的业务标识
 @param isBlocked                   是否屏蔽消息提醒
 @param successBlock                设置成功的回调
 [nStatus:会话设置的消息提醒状态]
 @param errorBlock                  设置失败的回调 [status:设置失败的错误码]

 @discussion
 如果您使用
 IMLibCore，此方法会屏蔽该会话的远程推送；如果您使用IMKit，此方法会屏蔽该会话的所有提醒（远程推送、本地通知、前台提示音）,该接口不支持聊天室。

 @remarks 会话
 
 *  \~english
 Set the message reminder status for the conversation

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param isBlocked            Whether to block message reminders
 @param successBlock            Callback for successful setting
 [nStatus: message reminder status set for the conversation].
 @param errorBlock            Callback for failed setting [ status:  error code for error code for setting failure].

 @ discussion
 If you use the IMLibCore, this method blocks the remote push of the conversation; If you use this method of IMKit, it blocks all reminders (remote push, local notification and foreground tone) of the conversation, and the interface does not support chatroom.

  @ remarks Conversation
 */
- (void)setConversationNotificationStatus:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                                channelId:(NSString *)channelId
                                isBlocked:(BOOL)isBlocked
                                  success:(void (^)(RCConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(RCErrorCode status))errorBlock;


/*!
 * \~chinese
 查询会话的消息提醒状态

 @param conversationType    会话类型（不支持聊天室，聊天室是不接受会话消息提醒的）
 @param targetId            会话 ID
 @param channelId          所属会话的业务标识
 @param successBlock        查询成功的回调 [nStatus:会话设置的消息提醒状态]
 @param errorBlock          查询失败的回调 [status:设置失败的错误码]

 @remarks 会话
 
 *  \~english
 Query the message reminder status of the conversation

 @param conversationType            Conversation type (chatroom is not supported and chatroom does not accept reminders of conversation messages).
 @param targetId            Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param successBlock            Callback for successful query [nStatus: message reminder status set for the conversation]
 @param errorBlock            Callback for failed query [status: error code for setting failure]

 @ remarks Conversation
 */
- (void)getConversationNotificationStatus:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                                channelId:(NSString *)channelId
                                  success:(void (^)(RCConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 * \~chinese
 获取消息免打扰会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @param channelId          所属会话的业务标识
 @return                     消息免打扰会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取消息免打扰会话列表。

 @remarks 会话列表
 
 *  \~english
 Get a list of conversations for Do Not Disturb messages.

 @param conversationTypeList Array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @param channelId          Business ID of the session to which it belongs
 @ return                     List of conversation RCConversation for Do Not Disturb messages

 @ discussion This method reads the list of conversations of Do Not Disturb messages from the local database.

  @ remarks Conversation list
 */
- (NSArray<RCConversation *> *)getBlockedConversationList:(NSArray *)conversationTypeList channelId:(NSString *)channelId;

#pragma mark - input status

/*!
 * \~chinese
 向会话中发送正在输入的状态

 @param conversationType    会话类型
 @param targetId            会话目标  ID
 @param channelId          所属会话的业务标识
 @param objectName         正在输入的消息的类型名

 @discussion
 contentType 为用户当前正在编辑的消息类型名，即 RCMessageContent 中 getObjectName 的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。

 @warning 目前仅支持单聊。

 @remarks 高级功能
 
 *  \~english
 Send the status being entered to the conversation

 @param conversationType         Conversation type
 @param targetId         Conversation destination ID
 @param channelId          Business ID of the session to which it belongs
 @param objectName         Type name of the message being entered

 @ discussion
 contentType is the name of the message type that the user is currently editing, that is, the return value of getObjectName in RCMessageContent.
  E.g. for a text message, pass the type name "RC:TxtMsg".

  @ warning Currently only support single chat.

  @ remarks advanced functions
 */
- (void)sendTypingStatus:(RCConversationType)conversationType
                targetId:(NSString *)targetId
               channelId:(NSString *)channelId
             contentType:(NSString *)objectName;

#pragma mark - Search

/*!
 * \~chinese
 根据关键字搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param channelId          所属会话的业务标识
 @param keyword          关键字
 @param count            最大的查询数量
 @param startTime        查询 startTime 之前的消息（传 0 表示不限时间）

 @return 匹配的消息列表

 @remarks 消息操作
 
 *  \~english
 Search messages in a specified conversation based on keywords.

 @param conversationType Conversation type
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param keyword         Keyword
 @param count         Maximum number of queries
 @param startTime         Query messages before startTime (0 indicates unlimited time).

 @ return Matching message list

 @ remarks Message operation
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                               channelId:(NSString *)channelId
                                 keyword:(NSString *)keyword
                                   count:(int)count
                               startTime:(long long)startTime;


/*!
 * \~chinese
 根据时间，偏移量和个数搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param keyword           关键字，传空默认为是查全部符合条件的消息
 @param startTime      查询 startTime 之后的消息， startTime >= 0
 @param endTime           查询 endTime 之前的消息，endTime > startTime
 @param offset             查询的消息的偏移量，offset >= 0
 @param limit               最大的查询数量，limit 需大于 0，最大值为100，如果大于100，会默认成100。

 @return 匹配的消息列表

 @remarks 消息操作
 
 *  \~english
 Search messages in a specified conversation based on time, offset, and number.

 @param conversationType Conversation type
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param keyword         Keyword, in which empty value indicates to check all messages that meet the criteria by default
 @param startTime         Query the message after startTime, startTime > = 0
 @param endTime         Query the messages before endTime, endTime > startTime.
 @param offset         Offset of the queried message, offset > = 0
 @param limit         For the maximum number of queries, the limit should be greater than 0, and the maximum value should be 100. If it is greater than 100, it will default to 100.

  @ return List of messages matched

 @ remarks Message operation
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                               channelId:(NSString *)channelId
                                 keyword:(NSString *)keyword
                               startTime:(long long)startTime
                                 endTime:(long long)endTime
                                  offset:(int)offset
                                   limit:(int)limit;

/*!
 * \~chinese
 按用户 ID 搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param channelId          所属会话的业务标识
 @param userId           搜索用户 ID
 @param count            最大的查询数量
 @param startTime        查询 startTime 之前的消息（传 0 表示不限时间）

 @return 匹配的消息列表

 @remarks 消息操作
 
 *  \~english
 Search messages in a specified conversation based on keywords.

 @param conversationType Conversation type
 @param targetId         Conversation ID
 @param channelId          Business ID of the session to which it belongs
 @param userId         userId
 @param count         Maximum number of queries
 @param startTime         Query messages before startTime (0 indicates unlimited time).

 @ return Matching message list

 @ remarks Message operation
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                               channelId:(NSString *)channelId
                                  userId:(NSString *)userId
                                   count:(int)count
                               startTime:(long long)startTime;

/*!
 * \~chinese
 根据关键字搜索会话

 @param conversationTypeList 需要搜索的会话类型列表
 @param channelId          所属会话的业务标识
 @param objectNameList       需要搜索的消息类型名列表(即每个消息类方法 getObjectName 的返回值)
 @param keyword              关键字

 @return 匹配的会话搜索结果列表

 @discussion 目前，SDK 内置的文本消息、文件消息、图文消息支持搜索。
 自定义的消息必须要实现 RCMessageContent 的 getSearchableWords 接口才能进行搜索。

 @remarks 消息操作
 
 *  \~english
 Search a conversation based on keywords

 @param conversationTypeList List of conversation types to be searched
 @param channelId          Business ID of the session to which it belongs
 @param objectNameList        List of type names of message to be searched (that is, the return value of each message class method getObjectName)
 @param keyword              Keyword

 @ return Search results list for conversation matched.

 @ discussion Currently, SDK's built-in text messages, file messages, and image and text messages support search
  Custom messages must implement getSearchableWords interface of RCMessageContent before they can be searched

  @ remarks message operation
 */
- (NSArray<RCSearchConversationResult *> *)searchConversations:(NSArray<NSNumber *> *)conversationTypeList
                                                     channelId:(NSString *)channelId
                                                   messageType:(NSArray<NSString *> *)objectNameList
                                                       keyword:(NSString *)keyword;

@end


