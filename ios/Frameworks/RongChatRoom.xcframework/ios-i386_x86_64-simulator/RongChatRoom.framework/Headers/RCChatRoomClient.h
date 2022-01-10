//
//  RCChatRoomClient.h
//  RongIMLib
//
//  Created by 张改红 on 2020/7/28.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCChatRoomInfo.h"
#import "RCChatRoomProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCChatRoomClient : NSObject

+ (instancetype)sharedChatRoomClient;

#pragma mark - 聊天室操作

/*!
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

 @warning 没有加入过的聊天室(或杀死 app 重新打开)，调用该接口会把该聊天室本地的消息与 KV 清除
 
 @remarks 聊天室
 */
- (void)joinChatRoom:(NSString *)targetId
        messageCount:(int)messageCount
             success:(void (^)(void))successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

/*!
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

 @warning 没有加入过的聊天室(或杀死 app 重新打开)，调用该接口会把该聊天室本地的消息与 KV 清除
 
 @remarks 聊天室
 */
- (void)joinExistChatRoom:(NSString *)targetId
             messageCount:(int)messageCount
                  success:(void (^)(void))successBlock
                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 退出聊天室

 @param targetId                聊天室 ID
 @param successBlock            退出聊天室成功的回调
 @param errorBlock              退出聊天室失败的回调
 [status:退出聊天室失败的错误码]

 @remarks 聊天室
 */
- (void)quitChatRoom:(NSString *)targetId
             success:(void (^)(void))successBlock
               error:(void (^)(RCErrorCode status))errorBlock;

/*!
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
 */
- (void)getChatRoomInfo:(NSString *)targetId
                  count:(int)count
                  order:(RCChatRoomMemberOrder)order
                success:(void (^)(RCChatRoomInfo *chatRoomInfo))successBlock
                  error:(void (^)(RCErrorCode status))errorBlock;

/*!
 设置 IMLib 的聊天室状态监听器

 @param delegate IMLib 聊天室状态监听器

 @remarks 聊天室
 */
- (void)setChatRoomStatusDelegate:(id<RCChatRoomStatusDelegate>)delegate;

/*!
 从服务器端获取聊天室的历史消息
 @param targetId            聊天室ID
 @param recordTime          起始的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 200
 @param order               拉取顺序，RC_Timestamp_Desc:倒序，RC_Timestamp_ASC:正序
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, syncTime:下次拉取消息的时间戳]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取聊天室的历史消息，但是必须先开通聊天室消息云存储功能。
 指定开始时间,比如2016年9月1日10点(1472695200000),
 默认是0(正序:从存储的第一条消息开始拉取,倒序:从存储的最后一条消息开始拉取)
 */
- (void)getRemoteChatroomHistoryMessages:(NSString *)targetId
                              recordTime:(long long)recordTime
                                   count:(int)count
                                   order:(RCTimestampOrder)order
                                 success:(void (^)(NSArray *messages, long long syncTime))successBlock
                                   error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - 聊天室状态存储 (使用前必须先联系商务开通)
/*!
设置聊天室 KV 状态变化监听器

@param delegate 聊天室 KV 状态变化的监听器

@discussion 可以设置并实现此 delegate 来进行聊天室状态变化的监听 。SDK 会在回调中通知您聊天室状态的改变。

@remarks 功能设置
*/
- (void)setRCChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate;

/*!
 添加聊天室 KV 状态变化监听

 @param delegate 代理
 */
- (void)addChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate;

/*!
 移除聊天室 KV 状态变化监听

 @param delegate 代理
 */
- (void)removeChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate;

/*!
 获取聊天室 KV 状态变化监听
 
 @return 所有聊天室 KV 状态变化的监听器
 */
- (NSArray <id<RCChatRoomKVStatusChangeDelegate>> *)allChatRoomKVStatusChangeDelegates;



/**
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
 批量设置聊天室自定义属性

 @param chatroomId   聊天室 ID
 @param entries   聊天室属性，key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 128 个字符，value 聊天室属性对应的值，最大长度 4096 个字符，最多一次设置 10 条
 @param isForce   是否强制覆盖
 @param autoDelete   用户掉线或退出时，是否自动删除该 Key、Value 值
 @param successBlock 成功回调
 @param errorBlock   失败回调，当 nErrorCode 为 RC_KV_STORE_NOT_ALL_SUCCESS（23428）的时候，entries 才会有值（key 为设置失败的 key，value 为该 key 对应的错误码）

 @discussion 必须先开通聊天室状态存储功能
 
 @remarks 聊天室
 */
- (void)setChatRoomEntries:(NSString *)chatroomId
                   entries:(NSDictionary *)entries
                   isForce:(BOOL)isForce
                autoDelete:(BOOL)autoDelete
                   success:(void (^)(void))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, NSDictionary *entries))errorBlock;

/**
 获取聊天室单个属性

 @param chatroomId 聊天室 ID
 @param key 聊天室属性名称
 @param successBlock 成功回调
 @param errorBlock 失败回调

 @discussion 必须先开通聊天室状态存储功能

 @remarks 聊天室
 */
- (void)getChatRoomEntry:(NSString *)chatroomId
                     key:(NSString *)key
                 success:(void (^)(NSDictionary *entry))successBlock
                   error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 获取聊天室所有自定义属性

 @param chatroomId 聊天室 ID
 @param successBlock 成功回调
 @param errorBlock 失败回调

 @discussion 必须先开通聊天室状态存储功能

 @remarks 聊天室
 */
- (void)getAllChatRoomEntries:(NSString *)chatroomId
                      success:(void (^)(NSDictionary *entry))successBlock
                        error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
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
 */
- (void)removeChatRoomEntry:(NSString *)chatroomId
                        key:(NSString *)key
           sendNotification:(BOOL)sendNotification
          notificationExtra:(NSString *)notificationExtra
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
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
 */
- (void)forceRemoveChatRoomEntry:(NSString *)chatroomId
                             key:(NSString *)key
                sendNotification:(BOOL)sendNotification
               notificationExtra:(NSString *)notificationExtra
                         success:(void (^)(void))successBlock
                           error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 批量删除聊天室自定义属性

 @param chatroomId   聊天室 ID
 @param keys   聊天室属性名称，最多一次删除 10 条
 @param isForce   是否强制覆盖
 @param successBlock 成功回调
 @param errorBlock   失败回调，当 nErrorCode 为 RC_KV_STORE_NOT_ALL_SUCCESS（23428）的时候，entries 才会有值（key 为设置失败的 key，value 为该 key 对应的错误码）

 @discussion 必须先开通聊天室状态存储功能
 
 @remarks 聊天室
 */
- (void)removeChatRoomEntries:(NSString *)chatroomId
                         keys:(NSArray *)keys
                      isForce:(BOOL)isForce
                      success:(void (^)(void))successBlock
                        error:(void (^)(RCErrorCode nErrorCode, NSDictionary *entries))errorBlock;

#pragma mark - 聊天室成员变化监听器

/*!
 设置聊天室成员变化的监听器

 @discussion 可以设置并实现此拦截器来监听聊天室成员的加入或退出

 @remarks 功能设置
 */
@property (nonatomic, weak) id<RCChatRoomMemberDelegate> memberDelegate;

@end

NS_ASSUME_NONNULL_END
