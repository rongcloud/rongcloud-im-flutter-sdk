//
//  RCChatRoomClient.h
//  RongIMLib
//
//  Created by RongCloud on 2020/7/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCChatRoomInfo.h"
#import "RCChatRoomProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCChatRoomClient : NSObject

+ (instancetype)sharedChatRoomClient;

#pragma mark - Chatroom Operation

/*!
 *  \~chinese
 加入聊天室（如果聊天室不存在则会创建）

 @param targetId        聊天室 ID
 @param messageCount    进入聊天室时获取历史消息的数量，-1 <= messageCount <= 50
 @param successBlock    加入聊天室成功的回调
 @param errorBlock      加入聊天室失败的回调
 [status: 加入聊天室失败的错误码]

 @discussion
 可以通过传入的 messageCount 设置加入聊天室成功之后需要获取的历史消息数量。
 -1 表示不获取任何历史消息，0 表示不特殊设置而使用SDK默认的设置（默认为获取 10 条），0 < messageCount <= 50
 为具体获取的消息数量,最大值为 50。注：如果是 7.x 系统获取历史消息数量不要大于 30

 @remarks 聊天室
 *
 * \~english
 *
 Join a chatroom (it will be created if the chatroom does not exist).
 
 @param targetId Chatroom ID.
 @param messageCount The number of historical messages obtained when entering the chatroom,-1 < = messageCount < = 50.
 @param successBlock Callback for successful joining of the chatroom
 @param errorBlock Callback for failing to join chatroom.
 [status: Error code for failure to join chatroom].

 @ discussion
 You can use the passed messageCount to set the number of historical messages that shall be obtained after joining the chatroom successfully.
  -1 means that no history messages are obtained. 0 means to use the default setting of SDK without special settings (default value is to get 10 messages). 0 < messageCount < = 50.
 For the number of messages specifically obtained, the maximum value is 50. Note: if it is a 7.x system, the number of historical messages should not be greater than 30.

 @ remarks chatroom.
 */
- (void)joinChatRoom:(NSString *)targetId
        messageCount:(int)messageCount
             success:(void (^)(void))successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 加入已经存在的聊天室（如果聊天室不存在返回错误 23410，人数超限返回错误 23411）

 @param targetId        聊天室 ID
 @param messageCount    进入聊天室时获取历史消息的数量，-1 <= messageCount <= 50
 @param successBlock    加入聊天室成功的回调
 @param errorBlock      加入聊天室失败的回调
 [status: 加入聊天室失败的错误码]

 @warning
 注意：使用 IMKit 库的会话页面，viewDidLoad 会自动调用 joinChatRoom 加入聊天室（聊天室不存在会自动创建）。
 如果您只想加入已存在的聊天室，需要在 push 到会话页面之前调用这个方法并且 messageCount 传 -1，成功之后 push
 到会话页面，失败需要您做相应提示处理。

 @discussion
 可以通过传入的 messageCount 设置加入聊天室成功之后，需要获取的历史消息数量。
 -1 表示不获取任何历史消息，0 表示不特殊设置而使用SDK默认的设置（默认为获取 10 条），0 < messageCount <= 50
 为具体获取的消息数量，最大值为 50。

 @remarks 聊天室
 
 *  \~english
 *
 Join an existing chatroom (return error 23410 if there is no chatroom, and return error 23411 if the number exceeds the limit).

 @param targetId Chatroom ID.
 @param messageCount The number of historical messages obtained when entering the chatroom,-1 < = messageCount < = 50.
 @param successBlock Callback for successful joining of the chatroom
 @param errorBlock Callback for failing to join chatroom.
 [status: Error code for failing to join chatroom].

 @ warning
 Note: using the conversation page of the IMKit library, viewDidLoad will automatically call joinChatRoom to join the chatroom (if the chatroom does not exist, it will be created automatically).
  If you only want to join an existing chatroom, you shall call this method before push to the conversation page and messageCount-1, and push after success.
 When you go to the conversation page, you shall be prompted to deal with the failure.

  @ discussion
 You can use the passed messageCount to set the number of historical messages that shall be obtained after joining the chatroom successfully.
  -1 means that no history messages are obtained. 0 means to use the default setting of SDK without special settings (default value is to get 10 messages). 0 < messageCount < = 50.
 For the number of messages specifically obtained, the maximum value is 50.

  @ remarks chatroom
 */
- (void)joinExistChatRoom:(NSString *)targetId
             messageCount:(int)messageCount
                  success:(void (^)(void))successBlock
                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 退出聊天室

 @param targetId                聊天室 ID
 @param successBlock            退出聊天室成功的回调
 @param errorBlock              退出聊天室失败的回调
 [status:退出聊天室失败的错误码]

 @remarks 聊天室
 *
 *  \~english
 
 Quit the chatroom.

 @param targetId Chatroom ID.
 @param successBlock Callback for successful exit from the chatroom.
 @param errorBlock Callback for failing to exit chatroom.
 [error code for status: 's failure to exit the chatroom].

 @ remarks chatroom.
 */
- (void)quitChatRoom:(NSString *)targetId
             success:(void (^)(void))successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 获取聊天室的信息（包含部分成员信息和当前聊天室中的成员总数）

 @param targetId     聊天室 ID
 @param count 需要获取的成员信息的数量（目前获取到的聊天室信息中仅包含不多于 20 人的成员信息，即 0 <= count <=
 20，传入 0 获取到的聊天室信息将或仅包含成员总数，不包含具体的成员列表）
 @param order        需要获取的成员列表的顺序（最早加入或是最晚加入的部分成员）
 @param successBlock 获取成功的回调 [chatRoomInfo:聊天室信息]
 @param errorBlock   获取失败的回调 [status:获取失败的错误码]

 @discussion
 因为聊天室一般成员数量巨大，权衡效率和用户体验，目前返回的聊天室信息仅包含不多于 20
 人的成员信息和当前成员总数。如果您使用 RC_ChatRoom_Member_Asc
 升序方式查询，将返回最早加入的成员信息列表，按加入时间从旧到新排列；如果您使用 RC_ChatRoom_Member_Desc
 降序方式查询，将返回最晚加入的成员信息列表，按加入时间从新到旧排列。

 @remarks 聊天室
 *
 *  \~english
 *
 Get the information of the chatroom (including some member information and the total number of members in the current chatroom).

 @param targetId chatroom ID.
 @param count The number of member information that shall be obtained (at present, the chatroom information obtained contains only the member information of no more than 20 people, that is, 0 < = count < =.
 20. The chatroom information obtained by passing 0 will contain only the total number of members, not a specific list of members).
 @param order The order of the list of members to be obtained (the earliest or the latest to join).
 @param successBlock Callback for successful getting [chatRoomInfo: chatroom information].
 @param errorBlock Callback for failed getting [status:  error code for failed getting].

 @ discussion
 Because of the large number of chatroom members and the tradeoff between efficiency and user experience, the chatroom information returned so far contains no more than 20%.
 The member information of the person and the total number of current members. If you use RC_ChatRoom_Member_Asc.
 Query in ascending order will return a list of the earliest member information, sorted from old to new by join time; if you use RC_ChatRoom_Member_Desc.
 The query in descending order will return a list of the latest member information, sorted from new to old according to the time of joining.

  @ remarks chatroom
 *
 */
- (void)getChatRoomInfo:(NSString *)targetId
                  count:(int)count
                  order:(RCChatRoomMemberOrder)order
                success:(void (^)(RCChatRoomInfo *chatRoomInfo))successBlock
                  error:(void (^)(RCErrorCode status))errorBlock;

/*!
 * \~chinese
 设置 IMLib 的聊天室状态监听器

 @param delegate IMLib 聊天室状态监听器

 @remarks 聊天室
 *
 * \~english
 
 Set the chatroom status listener for IMLib.

 @param delegate IMLib chatroom status listener.

 @ remarks chatroom
 */
- (void)setChatRoomStatusDelegate:(id<RCChatRoomStatusDelegate>)delegate;

/*!
 * \~chinese
 从服务器端获取聊天室的历史消息
 @param targetId            聊天室ID
 @param recordTime          起始的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 200
 @param order               拉取顺序，RC_Timestamp_Desc:倒序，RC_Timestamp_ASC:正序
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, syncTime:下次拉取消息的时间戳]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取聊天室的历史消息，但是必须先开通聊天室消息云存储功能。
 指定开始时间,比如20169月1日10点(1472695200000),
 默认是0(正序:从存储的第一条消息开始拉取,倒序:从存储的最后一条消息开始拉取)
 
 * \~english
 
 Get the historical message of the chatroom from the server side.
 @param targetId Chatroom ID.
 @param recordTime Initial message sending timestamp, millisecond.
 @param count The number of messages to be obtained. 0 < count < = 200.
 @param order Pull order, RC_Timestamp_Desc: reverse order, RC_Timestamp_ASC: positive order.
 @param successBlock Callback for successful getting [the array of historical messages obtained by messages:, and the timestamp of the next message pulled by syncTime:].
 @param errorBlock Callback for getting failure [status: Get failed error code].

 @ discussion
 This method obtains the historical messages of chatrooms from the server, but must first activate the chatroom message cloud storage feature.
  Specify a start time, such as 10:00 on September 1, 2016 (1472695200000).
 The default value is 0 (positive order: pull from the first message stored, reverse order: pull from the last message stored).
 */
- (void)getRemoteChatroomHistoryMessages:(NSString *)targetId
                              recordTime:(long long)recordTime
                                   count:(int)count
                                   order:(RCTimestampOrder)order
                                 success:(void (^)(NSArray *messages, long long syncTime))successBlock
                                   error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - chatroom state storage function (It must first activate the chatroom state storage function)
/*!
 * \~chinese
设置聊天室 KV 状态变化监听器

@param delegate 聊天室 KV 状态变化的监听器

@discussion 可以设置并实现此 delegate 来进行聊天室状态变化的监听 。SDK 会在回调中通知您聊天室状态的改变。

@remarks 功能设置
 
 * \~english
 
 Set chatroom KV status change listener.

 @param delegate Listeners for KV status changes in chatrooms.

 @ discussion It can set and implement this delegate to listen to chatroom state changes. SDK will notify you of the change in the status of the chatroom in the callback.

 @ remarks function setting
*/
- (void)setRCChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate;


/**
 * \~chinese
 设置聊天室自定义属性

 @param chatroomId   聊天室 ID
 @param key 聊天室属性名称，Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 128 个字符
 @param value 聊天室属性对应的值，最大长度 4096 个字符
 @param sendNotification   是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage
 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
 @param autoDelete   用户掉线或退出时，是否自动删除该 Key、Value 值；自动删除时不会发送通知
 @param notificationExtra   通知的自定义字段，RC:chrmKVNotiMsg 通知消息中会包含此字段，最大长度 2 kb
 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @discussion 必须先开通聊天室状态存储功能
 设置聊天室自定义属性，当 key 不存在时，代表增加属性； 当 key 已经存在时，代表更新属性的值，且只有 key
 的创建者可以更新属性的值。

 @remarks 聊天室
 
 * \~english
 
 Set chatroom custom properties.

 @param chatroomId Chatroom ID.
 @param key Chatroom attribute name. Key supports the combination of uppercase and lowercase letters, numbers and some special symbols + =-_. The maximum length is 128 characters.
 @param value The value corresponding to the chatroom attribute, with a maximum length of 4096 characters.
 @param sendNotification Do you shall send a notification? if you send a notification, other users in the chatroom will receive RCChatroomKVNotificationMessage.
 Notification message, which contains the action type (type), the attribute name (key), the value (value) corresponding to the attribute name, and the custom field (extra).
 @param autoDelete Whether the Key and Value values are automatically deleted when the user is dropped or exited; no notification will be sent when the user is automatically deleted.
 @param notificationExtra The custom field of the notification, which will be included in the RC:chrmKVNotiMsg notification message with a maximum length of 2 kb.
 @ param successBlock callback for success.
 @ param errorBlock callback for failure

 @ discussion It must first activate the chatroom state storage function.
 Set the custom attribute of the chatroom. When key does not exist, it means to add the attribute; when key already exists, it represents the value of the updated attribute, and only key.
 Can update the value of the property.

  @ remarks chatroom
 */
- (void)setChatRoomEntry:(NSString *)chatroomId
                     key:(NSString *)key
                   value:(NSString *)value
        sendNotification:(BOOL)sendNotification
              autoDelete:(BOOL)autoDelete
       notificationExtra:(NSString *)notificationExtra
                 success:(void (^)(void))successBlock
                   error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 * \~chinese
 强制设置聊天室自定义属性

 @param chatroomId   聊天室 ID
 @param key 聊天室属性名称，Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 128 个字符
 @param value 聊天室属性对应的值，最大长度 4096 个字符
 @param sendNotification   是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage
 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
 @param autoDelete   用户掉线或退出时，是否自动删除该 Key、Value 值；自动删除时不会发送通知
 @param notificationExtra   通知的自定义字段，RCChatroomKVNotificationMessage 通知消息中会包含此字段，最大长度 2 kb
 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @discussion 必须先开通聊天室状态存储功能
 强制设置聊天室自定义属性，当 key 不存在时，代表增加属性； 当 key 已经存在时，代表更新属性的值。

 @remarks 聊天室
 
 * \~english
 Force the setting of chatroom custom properties.

 @param chatroomId Chatroom ID.
 @param key Chatroom attribute name. Key supports the combination of uppercase and lowercase letters, numbers and some special symbols + =-_. The maximum length is 128 characters.
 @param value The value corresponding to the chatroom attribute, with a maximum length of 4096 characters.
 @param sendNotification Do you shall send a notification? if you send a notification, other users in the chatroom will receive RCChatroomKVNotificationMessage.
 Notification message, which contains the action type (type), the attribute name (key), the value (value) corresponding to the attribute name, and the custom field (extra).
 @param autoDelete Whether the Key and Value values are automatically deleted when the user is dropped or exited; no notification will be sent when the user is automatically deleted.
 @param notificationExtra The custom field of the notification, which will be included in the RCChatroomKVNotificationMessage notification message with a maximum length of 2 kb.
 @param successBlock callback for success.
 @param errorBlock callback for failure

 @discussion It must first activate the chatroom state storage function.
 Force the chatroom custom property to be set, which means to add the property when the key does not exist, or to update the value of the property when the key already exists.

  @remarks chatroom
 */
- (void)forceSetChatRoomEntry:(NSString *)chatroomId
                          key:(NSString *)key
                        value:(NSString *)value
             sendNotification:(BOOL)sendNotification
                   autoDelete:(BOOL)autoDelete
            notificationExtra:(NSString *)notificationExtra
                      success:(void (^)(void))successBlock
                        error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 * \~chinese
 获取聊天室单个属性

 @param chatroomId 聊天室 ID
 @param key 聊天室属性名称
 @param successBlock 成功回调
 @param errorBlock 失败回调

 @discussion 必须先开通聊天室状态存储功能

 @remarks 聊天室
 
 * \~english
 Get a single attribute of a chatroom.

 @param chatroomId chatroom ID.
 @param key chatroom attribute name.
 @param successBlock Callback for success.
 @param errorBlock Callback for failure

 @ discussion It must first activate the chatroom state storage function.

 @ remarks chatroom.
 */
- (void)getChatRoomEntry:(NSString *)chatroomId
                     key:(NSString *)key
                 success:(void (^)(NSDictionary *entry))successBlock
                   error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 * \~chinese
 获取聊天室所有自定义属性

 @param chatroomId 聊天室 ID
 @param successBlock 成功回调
 @param errorBlock 失败回调

 @discussion 必须先开通聊天室状态存储功能

 @remarks 聊天室
 
 * \~english
 
 Get all attributes of a chatroom.

 @param chatroomId chatroom ID.
 @param successBlock Callback for success.
 @param errorBlock Callback for failure

 @ discussion It must first activate the chatroom state storage function.

 @ remarks chatroom.
 */
- (void)getAllChatRoomEntries:(NSString *)chatroomId
                      success:(void (^)(NSDictionary *entry))successBlock
                        error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 * \~chinese
 删除聊天室自定义属性

 @param chatroomId 聊天室 ID
 @param key 聊天室属性名称
 @param sendNotification   是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage
 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
 @param notificationExtra   通知的自定义字段，RCChatroomKVNotificationMessage 通知消息中会包含此字段，最大长度 2 kb
 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @discussion 必须先开通聊天室状态存储功能
 删除聊天室自定义属性，只有自己设置的属性可以被删除。

 @remarks 聊天室
 
 * \~english
 Delete chatroom custom properties.

 @param chatroomId Chatroom ID.
 @param key Chatroom attribute name.
 @param sendNotification Do you shall send a notification? if you send a notification, other users in the chatroom will receive RCChatroomKVNotificationMessage.
 Notification message, which contains the action type (type), the attribute name (key), the value (value) corresponding to the attribute name, and the custom field (extra).
 @param notificationExtra The custom field of the notification, which will be included in the RCChatroomKVNotificationMessage notification message with a maximum length of 2 kb.
 @ param successBlock Callback for success
 @ param errorBlock Callback for failure

 @ discussion It must first activate the chatroom state storage function.
 The custom properties of the chatroom are deleted and only the properties set by yourself can be deleted.

  @ remarks chatroom
 */
- (void)removeChatRoomEntry:(NSString *)chatroomId
                        key:(NSString *)key
           sendNotification:(BOOL)sendNotification
          notificationExtra:(NSString *)notificationExtra
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 * \~chinese
 强制删除聊天室自定义属性

 @param chatroomId 聊天室 ID
 @param key 聊天室属性名称
 @param sendNotification   是否需要发送通知，如果发送通知，聊天室中的其他用户会接收到 RCChatroomKVNotificationMessage
 通知消息，消息内容中包含操作类型(type)、属性名称(key)、属性名称对应的值(value)和自定义字段(extra)
 @param notificationExtra   通知的自定义字段，RCChatroomKVNotificationMessage 通知消息中会包含此字段，最大长度 2 kb
 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @discussion 必须先开通聊天室状态存储功能
 强制删除聊天室自定义属性。

 @remarks 聊天室
 
 * \~english
 Force deletion of chatroom custom properties.

 @param chatroomId Chatroom ID.
 @param key Chatroom attribute name.
 @param sendNotification Do you shall send a notification? if you send a notification, other users in the chatroom will receive RCChatroomKVNotificationMessage.
 Notification message, which contains the action type (type), the attribute name (key), the value (value) corresponding to the attribute name, and the custom field (extra).
 @param notificationExtra The custom field of the notification, which will be included in the RCChatroomKVNotificationMessage notification message with a maximum length of 2 kb.
 @ param successBlock callback successfully.
 @ param errorBlock failed callback.

 @ discussion It must first activate the chatroom state storage function.
 Force the deletion of chatroom custom properties.

  @ remarks chatroom
 */
- (void)forceRemoveChatRoomEntry:(NSString *)chatroomId
                             key:(NSString *)key
                sendNotification:(BOOL)sendNotification
               notificationExtra:(NSString *)notificationExtra
                         success:(void (^)(void))successBlock
                           error:(void (^)(RCErrorCode nErrorCode))errorBlock;
@end

NS_ASSUME_NONNULL_END
