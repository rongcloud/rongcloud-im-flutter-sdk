//
//  RCIMClientProtocol.h
//  RongIMLib
//
//  Created by LiFei on 2020/4/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#ifndef RCIMClientProtocol_h
#define RCIMClientProtocol_h

@class RCMessage;
@class RCConversationStatusInfo;

#pragma mark - RCIMClientReceiveMessageDelegate

/*!
 *  \~chinese
 IMlib消息接收的监听器

 @discussion
 设置IMLib的消息接收监听器请参考RCIMClient的setReceiveMessageDelegate:object:方法。

 @warning 如果您使用IMlib，可以设置并实现此Delegate监听消息接收；
 如果您使用IMKit，请使用RCIM中的RCIMReceiveMessageDelegate监听消息接收，而不要使用此监听器，否则会导致IMKit中无法自动更新UI！
 
 *  \~english
 Listeners for IMlib message reception.

 @ discussion
 To set the message receiving listener for IMLib, please refer to the setReceiveMessageDelegate:object: method of RCIMClient.

  @ warning If you use IMlib, you can set and implement this Delegate to listen to message reception.
 If you use IMKit, use RCIMReceiveMessageDelegate in RCIM to listen to message reception instead of using this listener, otherwise you will not be able to update UI automatically in IMKit!
 */
@protocol RCIMClientReceiveMessageDelegate <NSObject>

/*!
 *  \~chinese
 接收消息的回调方法

 @param message     当前接收到的消息
 @param nLeft       还剩余的未接收的消息数，left>=0
 @param object      消息监听设置的key值

 @discussion 如果您设置了IMlib消息监听之后，SDK在接收到消息时候会执行此方法。
 其中，left为还剩余的、还未接收的消息数量。比如刚上线一口气收到多条消息时，通过此方法，您可以获取到每条消息，left会依次递减直到0。
 您可以根据left数量来优化您的App体验和性能，比如收到大量消息时等待left为0再刷新UI。
 object为您在设置消息接收监听时的key值。
 
 *  \~english
 Callback method for receiving messages.

 @param message Messages currently received.
 @param nLeft The number of unreceived messages left, left > = 0.
 @param object The key value of the message listening setting.

 @ discussion If you have set IMlib message listening, SDK will execute this method when it receives a message.
  Where left is the number of messages that have not yet been received. For example, when you receive multiple messages upon being online, you can get each message in this way, and the left will decrease to 0 in turn.
  You can optimize your App experience and performance based on the number of left, e.g.  waiting for left to be 0 before refreshing UI when you receive a large number of messages.
  Object is the key value that you set when the message is received and listeninged.
 */
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object;

@optional

/**
 *  \~chinese
 接收消息的回调方法

 @param message 当前接收到的消息
 @param nLeft 还剩余的未接收的消息数，left>=0
 @param object 消息监听设置的key值
 @param offline 是否是离线消息
 @param hasPackage SDK 拉取服务器的消息以包(package)的形式批量拉取，有 package 存在就意味着远端服务器还有消息尚未被 SDK
 拉取
 @discussion 和上面的 - (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object 功能完全一致，额外把
 offline 和 hasPackage 参数暴露，开发者可以根据 nLeft、offline、hasPackage 来决定何时的时机刷新 UI ；建议当 hasPackage=0
 并且 nLeft=0 时刷新 UI
 @warning 如果使用此方法，那么就不能再使用 RCIM 中 - (void)onReceived:(RCMessage *)message left:(int)nLeft
 object:(id)object 的使用，否则会出现重复操作的情形
 
 *  \~english
 Callback method for receiving messages.

 @param message Messages currently received.
 @param nLeft The number of unreceived messages left, left > = 0.
 @param object The key value of the message listening setting.
 @param offline Is it an offline message?
 @param hasPackage Messages from the SDK pull server are pulled in batches in the form of packet (package). The presence of package means that there are still messages on the remote server that have not been SDK.
 Pull.
 @ discussion It is exactly the same as the above-(void) onReceived: (RCMessage *) message left: (int) nLeft object: (id) object function, add.
 Offline and hasPackage parameters are exposed, and developers can decide when to refresh UI based on nLeft, offline and hasPackage. It is recommended that when hasPackage=0.
 And refresh UI when nLeft=0.
 @ warning If you use this method, you can no longer use-(void) onReceived: (RCMessage *) message left: (int) nLeft in RCIM.
 The use of object: (id) object, otherwise the operation will be repeated.
 */
- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object
           offline:(BOOL)offline
        hasPackage:(BOOL)hasPackage;

/*!
 *  \~chinese
 消息被撤回的回调方法

 @param messageId 被撤回的消息ID

 @discussion 被撤回的消息会变更为RCRecallNotificationMessage，App需要在UI上刷新这条消息。
 
 *  \~english
 Callback method for recalled message.

 @param messageId recalled message ID.

 @ discussion The message that is recalled will be changed to the RCrecallNotificationMessage and App shall refresh it on the UI.
 */
- (void)onMessageRecalled:(long)messageId __deprecated_msg("Use messageDidRecall:");;

/*!
 *  \~chinese
 消息被撤回的回调方法

 @param message 被撤回的消息

 @discussion 被撤回的消息会变更为RCRecallNotificationMessage，App需要在UI上刷新这条消息。
 @discussion 和上面的 - (void)onMessageRecalled:(long)messageId 功能完全一致，只能选择其中一个使用。
 
 *  \~english
 Callback method in which the message is recalled.

 @param message recalled news.

 @ discussion The message that is recalled will be changed to the RCrecallNotificationMessage and App shall refresh this message on the UI.
  @ discussion It is exactly the same as the-(void) onMessageRecalled: (long) messageId function above, so you can only choose one to use.
 */
- (void)messageDidRecall:(RCMessage *)message;

/*!
 *  \~chinese
 请求消息已读回执（收到需要阅读时发送回执的请求，收到此请求后在会话页面已经展示该 messageUId 对应的消息或者调用
 getHistoryMessages 获取消息的时候，包含此 messageUId 的消息，需要调用 sendMessageReadReceiptResponse
 接口发送消息阅读回执）

 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 
 *  \~english
 Request message read receipt (received a request to send a receipt when you shall read, after receiving this request, the corresponding message of the messageUId has been displayed on the conversation page or called.
 When getHistoryMessages Get the message, you shall call sendMessageReadReceiptResponse to include the message of this messageUId.
 Interface to send messages to read receipt).

 @param messageUId Message ID requesting read receipt.
 @param conversationType ConversationType.
 @param targetId TargetId.
 */
- (void)onMessageReceiptRequest:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     messageUId:(NSString *)messageUId;


/*!
 *  \~chinese
 消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
 @param messageUId       请求已读回执的消息ID
 @param conversationType conversationType
 @param targetId         targetId
 @param userIdList 已读userId列表
 
 *  \~english
 Message read receipt response (if you receive the read receipt response, you can update the number of readings of the message according to messageUId).
 @param messageUId Message ID requesting read receipt.
 @param conversationType ConversationType.
 @param targetId TargetId.
 @param userIdList Read userId list.
 */
- (void)onMessageReceiptResponse:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                      messageUId:(NSString *)messageUId
                      readerList:(NSMutableDictionary *)userIdList;


@end

#pragma mark - RCConnectionStatusChangeDelegate

/*!
 *  \~chinese
 IMLib连接状态的的监听器

 @discussion
 设置IMLib的连接状态监听器，请参考RCIMClient的setRCConnectionStatusChangeDelegate:方法。

 @warning 如果您使用IMLib，可以设置并实现此Delegate监听连接状态变化；
 如果您使用IMKit，请使用RCIM中的RCIMConnectionStatusDelegate监听消息接收，而不要使用此监听器，否则会导致IMKit中无法自动更新UI！
 
 *  \~english
 Listeners for IMLib connection status

 @ discussion
 To set the connection status listener of IMLib, please refer to the setRCConnectionStatusChangeDelegate: method of RCIMClient.

  @ warning If you use IMLib, you can set and implement this Delegate to listen to connection status changes.
 If you use IMKit, use RCIMConnectionStatusDelegate in RCIM to listen to message reception instead of using this listener, otherwise you will not be able to update UI automatically in IMKit!
 */
@protocol RCConnectionStatusChangeDelegate <NSObject>

/*!
 *  \~chinese
 IMLib连接状态的的监听器

 @param status  SDK与融云服务器的连接状态

 @discussion 如果您设置了IMLib消息监听之后，当SDK与融云服务器的连接状态发生变化时，会回调此方法。
 
 *  \~english
 Listeners for IMLib connection status

 @param status Connection status between SDK and CVM.

 @ discussion If you set IMLib message listening, this method will be called back when the connection status between SDK and the cloud server changes.
 */
- (void)onConnectionStatusChanged:(RCConnectionStatus)status;

@end

#pragma mark - RCTypingStatusDelegate

/*!
 *  \~chinese
 IMLib输入状态的的监听器

 @discussion 设置IMLib的输入状态监听器，请参考RCIMClient的 setRCTypingStatusDelegate:方法。

 @warning
 如果您使用IMLib，可以设置并实现此Delegate监听消息输入状态；如果您使用IMKit，请直接设置RCIM中的
 enableTypingStatus，而不要使用此监听器，否则会导致IMKit中无法自动更新UI！
 
 *  \~english
 Listeners for IMLib input status

 @ discussion Set the input status listener of IMLib. Please refer to the setRCTypingStatusDelegate: method of RCIMClient.

  @ warning
 If you use IMLib, you can set and implement this Delegate listening message input status; if you use IMKit, please directly set the.
 EnableTypingStatus, instead of using this listener, otherwise the UI cannot be updated automatically in IMKit!
 */
@protocol RCTypingStatusDelegate <NSObject>

/*!
 *  \~chinese
 用户输入状态变化的回调

 @param conversationType        会话类型
 @param targetId                会话目标ID
 @param userTypingStatusList 正在输入的RCUserTypingStatus列表（nil标示当前没有用户正在输入）

 @discussion
 当客户端收到用户输入状态的变化时，会回调此接口，通知发生变化的会话以及当前正在输入的RCUserTypingStatus列表。

 @warning 目前仅支持单聊。
 
 *  \~english
 Callback for user input status change.

 @param conversationType Conversation type
 @param targetId conversation destination ID.
 @param userTypingStatusList List of RCUserTypingStatus being entered (nil indicates that no user is currently entering).

 @ discussion
 When the client receives a change in the status of the user's input, it calls back this interface to notify the changed conversation and the RCUserTypingStatus list currently being entered.

  @ warning Currently only support single chat.
 */
- (void)onTypingStatusChanged:(RCConversationType)conversationType
                     targetId:(NSString *)targetId
                       status:(NSArray *)userTypingStatusList;

@end

#pragma mark - RCLogInfoDelegate
/*!
 *  \~chinese
 IMLib日志的监听器

 @discussion
 设置IMLib日志的监听器，请参考RCIMClient的setRCLogInfoDelegate:方法。

 @discussion 您可以通过logLevel来控制日志的级别。
 
 *  \~english
 Listeners for IMLib logs.

 @ discussion
 To set the listener for IMLib logs, please refer to the setRCLogInfoDelegate: method of RCIMClient.

  @ discussion You can control the level of logs through logLevel.
 */
@protocol RCLogInfoDelegate <NSObject>

/*!
 *  \~chinese
 IMLib日志的回调

 @param logInfo 日志信息
 
 *  \~english
 Callback for IMLib log.

 @param logInfo Log information.
 */
- (void)didOccurLog:(NSString *)logInfo;

@end

#pragma mark - RCMessageDestructDelegate

/**
 *  \~chinese
 IMLib阅后即焚监听器
 @discussion 设置代理请参考 RCIMClient 的 setRCMessageDestructDelegate: 方法。
 
 *  \~english
 IMLib burns listener after reading.
 @ discussion Set the proxy. Please refer to RCIMClient's setRCMessageDestructDelegate:. Method.
 */
@protocol RCMessageDestructDelegate <NSObject>

/**
 *  \~chinese
 消息正在焚烧

 @param message 消息对象
 @param remainDuration 剩余焚烧时间
 
 *  \~english
 The news is burning.

 @param message Message object.
 @param remainDuration Remaining burning time.
 */
- (void)onMessageDestructing:(RCMessage *)message remainDuration:(long long)remainDuration;

@end

#pragma mark - RCConversationDelegate

@protocol RCConversationDelegate <NSObject>

- (void)conversationDidSync;

@end

#pragma mark - RCConversationStatusChangeDelegate

/**
 *  \~chinese
 IMLib 会话状态同步监听器
 @discussion 设置代理请参考 RCIMClient 的 setRCConversationStatusChangeDelegate: 方法。
 
 *  \~english
 IMLib conversation state synchronization listener.
 @ discussion For proxy setting, please refer to RCIMClient's setRCConversationStatusChangeDelegate:. Method.
 */
@protocol RCConversationStatusChangeDelegate <NSObject>

/**
 *  \~chinese
 IMLib 会话状态同步的回调

 @param conversationStatusInfos 改变过的会话状态的数组
 
 *  \~english
 Callback for IMLib conversation state synchronization.

 @param conversationStatusInfos An array of changed conversation states.
 */
- (void)conversationStatusDidChange:(NSArray<RCConversationStatusInfo *> *)conversationStatusInfos;

@end

#pragma mark - RCMessageExpansionDelegate
/**
 *  \~chinese
 消息扩展内容变化回调
 @discussion 设置代理请参考 RCIMClient 的 messageExpansionDelegate 方法
 @discussion 代理回调在非主线程
 
 *  \~english
 Callback for message extension content change.
 @ discussion To set the proxy, please refer to the messageExpansionDelegate method of RCIMClient.
 @ discussion Proxy callback on non-main thread.
 */
@protocol RCMessageExpansionDelegate <NSObject>
/**
 *  \~chinese
 消息扩展信息更改的回调

 @param expansionDic 消息扩展信息中更新的键值对
 @param message 消息

 @discussion expansionDic 只包含更新的键值对，不是全部的数据。如果想获取全部的键值对，请使用 message 的 expansionDic 属性。
 
 *  \~english
 Callback for message extension information change.

 @param expansionDic Updated key-value pairs in message extension information.
 @param message Message.

 @ discussion expansionDic contains only updated key-value pairs, not all data. If you want to get all the key-value pairs, use the expansionDic property of message.
*/
- (void)messageExpansionDidUpdate:(NSDictionary<NSString *, NSString *> *)expansionDic
                              message:(RCMessage *)message;

/**
 *  \~chinese
 消息扩展信息删除的回调

 @param keyArray 消息扩展信息中删除的键值对 key 列表
 @param message 消息

 *  \~english
 Callback for message extension information deletion.

 @param keyArray The key list of key-value pairs deleted in the message extension information.
 @param message Message.
*/
- (void)messageExpansionDidRemove:(NSArray<NSString *> *)keyArray
                            message:(RCMessage *)message;

@end

#pragma mark - RCMessageInterceptor

/**
 *  \~chinese
 消息拦截器
 
 *  \~english
 Message interceptor
 */
@protocol RCMessageInterceptor <NSObject>

@optional

/**
 *  \~chinese
 上传多媒体内容之前的回调
 
 @param message 待上传的多媒体消息
 @return 处理后的消息
 @discussion 如果返回的 message 或 message.content 为 nil，该条消息不会上传到服务，状态设置为 SentStatus_FAILED， 并回调失败
 
 *  \~english
 Callback before uploading multimedia content.

 @param message Multimedia messages to be uploaded.
 @ return processed message.
 @ discussion If the returned message or message.content is nil, the message will not be uploaded to the service, the status is set to SentStatus_FAILED, and the callback fails.
 */
- (RCMessage *)mediaMessageWillUpload:(RCMessage *)message;

/**
 *  \~chinese
 消息保存到数据库，发送到服务前调用此回调
 
 @param message 待发送的消息
 @return 处理后的消息
 @discussion 如果返回的 message 或 message.content 为 nil，该条消息不会上传到服务，状态设置为 SentStatus_FAILED， 并回调失败
 
 *  \~english
 The message is saved to the database and this callback is called before it is sent to the service.

 @param message Messages to be sent.
 @ return processed message.
 @ discussion If the returned message or message.content is nil, the message will not be uploaded to the service, the status is set to SentStatus_FAILED, and the callback fails.
 */
- (RCMessage *)messageWillSendAfterDB:(RCMessage *)message;

/**
 *  \~chinese
 接收到消息准备入库前的回调，开发者可以通过此回调对消息进行自定义处理。
 
 @param message 待入库的消息
 @return 处理后的消息，SDK 会将返回的消息入库并通过 RCIMClientReceiveMessageDelegate 的 onReceived 方法回调给上层
 @discussion 如果返回的 message 或 message.content 为 nil, RCIMClientReceiveMessageDelegate 的 onReceived 方法会将待入库的消息回调给上层
 
 *  \~english
 After receiving the callback before the message is ready for storage, the developer can customize the processing of the message through this callback.
  
  @param message Messages waiting for storage.
 @ return For the processed messages, SDK will store the returned messages into the library and call back to the upper layer through the onReceived method of RCIMClientReceiveMessageDelegate.
 @ discussion If the returned message or the onReceived method whose message.content is nil, RCIMClientReceiveMessageDelegate will call back the message to be stored in the upper layer.
 */
- (RCMessage *)messageDidReceiveBeforeDB:(RCMessage *)message;

@end

#pragma mark - RCDownloadInterceptor

/**
 *  \~chinese
 媒体文件下载拦截器
 
 *  \~english
 Media file download interceptor
 */
@protocol RCDownloadInterceptor <NSObject>

/**
 *  \~chinese
 下载前的回调
 
 @param request request 请求
 @return request 请求，返回值不能为 nil，否则无法正常下载
 
 *  \~english
 Callback before download.

 @param request Request request.
 @ return request, the returned value cannot be nil, otherwise it cannot be downloaded normally.
 */
- (NSMutableURLRequest *)onDownloadRequest:(NSMutableURLRequest *)request;

@end

#endif /* RCIMClientProtocol_h */
