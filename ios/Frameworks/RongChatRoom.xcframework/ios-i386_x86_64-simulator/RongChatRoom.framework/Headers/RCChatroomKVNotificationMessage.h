//
//  RCChatroomKVNotificationMessage.h
//  RongIMLib
//
//  Created by RongCloud on 2019/10/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * \~chinese
 聊天室自定义属性通知消息的类型名
 * \~english
 The type name of the custom property notification message of chatroom
 */
#define RCChatroomKVNotificationMessageTypeIdentifier @"RC:chrmKVNotiMsg"

typedef NS_ENUM(NSInteger, RCChatroomKVNotificationType) {
    /*!
     * \~chinese
     设置 KV 的操作
     * \~english
     Set the operation of KV.
     */
    RCChatroomKVNotificationTypeSet = 1,
    /*!
     * \~chinese
     删除 KV 的操作
     * \~english
     Delete KV operation.
     */
    RCChatroomKVNotificationTypeRemove = 2
};

/**
 * \~chinese
聊天室自定义属性通知消息

@discussion 不要随意构造此类消息发送，调用设置或者删除接口时会自动构建。
@discussion 此消息不存储不计入未读消息数。
 
@remarks 通知类消息
 
 * \~english
 Custom attribute notification message of chatroom

 @ discussion do not construct this kind of message for sending at will, which will be built automatically when you call the interface to set or delete.
 @ discussion This message is not stored and does not count as unread messages.
  
 @ remarks notification message
*/
@interface RCChatroomKVNotificationMessage : RCMessageContent

/*!
 * \~chinese
 聊天室操作的类型
 * \~english
 Types of chatroom operations
*/
@property (nonatomic, assign) RCChatroomKVNotificationType type;

/*!
 * \~chinese
 聊天室属性名称
 * \~english
 Chatroom attribute name
 */
@property (nonatomic, copy) NSString *key;

/*!
 * \~chinese
 聊天室属性对应的值
 * \~english
 The value corresponding to the chatroom attribute
 */
@property (nonatomic, copy) NSString *value;

/*!
 * \~chinese
 通知消息的自定义字段，最大长度 2 kb
 * \~english
 Custom field of notification message with a maximum length of 2 kb.
 */
@property (nonatomic, copy) NSString *extra;

/*!
 * \~chinese
初始化聊天室自定义属性通知消息

@param key 聊天室属性名称
@param value 聊天室属性对应的值（删除 key 时不用传）
@param extra 通知消息的自定义字段
@return 聊天室自定义属性通知消息的对象
 
 * \~english
 Initialize chatroom custom property notification message.

 @param key Chatroom attribute name.
 @param value The value corresponding to the chatroom attribute (you need not pass it when deleting key).
 @param extra Custom fields for notification messages.
 @ return chatroom custom attribute notification message object.
*/
+ (instancetype)notificationWithType:(RCChatroomKVNotificationType)type
                                 key:(NSString *)key
                               value:(NSString *_Nullable)value
                               extra:(NSString *)extra;

@end

NS_ASSUME_NONNULL_END
