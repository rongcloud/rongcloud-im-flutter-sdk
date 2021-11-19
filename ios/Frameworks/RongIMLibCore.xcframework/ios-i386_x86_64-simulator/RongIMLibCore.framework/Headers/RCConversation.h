/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCConversation.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 会话类

 @discussion 会话类，包含会话的所有属性。
 
 *  \~english
 Conversation class.

 @ discussion Conversation class, which contains all the properties of the conversation.
 */
@interface RCConversation : NSObject <NSCoding>

/*!
 *  \~chinese
 会话类型
 *  \~english
 Conversation type
 */
@property (nonatomic, assign) RCConversationType conversationType;

/*!
 *  \~chinese
 会话 ID
 *  \~english
 Conversation ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 *  \~chinese
 该会话的业务标识，长度限制 20 字符
 *  \~english
 The business identity of the conversation, with a length limit of 20 characters.
 */
@property (nonatomic, copy) NSString *channelId;

/*!
 *  \~chinese
 会话的标题
 *  \~english
 Title of the conversation
 */
@property (nonatomic, copy) NSString *conversationTitle;

/*!
 *  \~chinese
 会话中的未读消息数量
 *  \~english
 Number of unread messages in the conversation
 */
@property (nonatomic, assign) int unreadMessageCount;

/*!
 *  \~chinese
 是否置顶，默认值为 NO

 @discussion
 如果设置了置顶，在 IMKit 的 RCConversationListViewController 中会将此会话置顶显示。
 
 *  \~english
 Whether to set the top. default value is NO.

 @ discussion
 If the top is set, the conversation is displayed at the top in the RCConversationListViewController of IMKit.
 */
@property (nonatomic, assign) BOOL isTop;

/*!
 *  \~chinese
 会话中最后一条消息的接收状态
 *  \~english
 The receiving status of the last message in the conversation
 */
@property (nonatomic, assign) RCReceivedStatus receivedStatus;

/*!
 *  \~chinese
 会话中最后一条消息的发送状态
 *  \~english
 The sending status of the last message in the conversation
 */
@property (nonatomic, assign) RCSentStatus sentStatus;

/*!
 *  \~chinese
 会话中最后一条消息的接收时间（Unix时间戳、毫秒）
 *  \~english
 Time of receipt of the last message in the conversation (Unix timestamp, milliseconds)
 */
@property (nonatomic, assign) long long receivedTime;

/*!
 *  \~chinese
 会话中最后一条消息的发送时间（Unix时间戳、毫秒）
 *
 *  \~english
 Time when the last message in the conversation is sent (Unix timestamp, milliseconds)
 */
@property (nonatomic, assign) long long sentTime;

/*!
 *  \~chinese
 会话中存在的草稿
 *  \~english
 Drafts that exist in the conversation
 */
@property (nonatomic, copy) NSString *draft;

/*!
 *  \~chinese
 会话中最后一条消息的类型名
 *  \~english
 The type name of the last message in the conversation
 */
@property (nonatomic, copy) NSString *objectName;

/*!
 *  \~chinese
 会话中最后一条消息的发送者用户 ID
 *  \~english
 User ID, the sender of the last message in the conversation.
 */
@property (nonatomic, copy) NSString *senderUserId;

/*!
 *  \~chinese
 会话中最后一条消息的消息 ID
 *  \~english
 Message ID of the last message in the conversation.
 */
@property (nonatomic, assign) long lastestMessageId;

/*!
 *  \~chinese
 会话中最后一条消息的内容
 *  \~english
 The content of the last message in the conversation
 */
@property (nonatomic, strong) RCMessageContent *lastestMessage;

/*!
 *  \~chinese
 会话中最后一条消息的方向
 *  \~english
 The direction of the last message in the conversation
 */
@property (nonatomic, assign) RCMessageDirection lastestMessageDirection;

/*!
 *  \~chinese
 会话中最后一条消息的 json Dictionary

 @discussion 此字段存放最后一条消息内容中未编码的 json 数据。
 SDK 内置的消息，如果消息解码失败，默认会将消息的内容存放到此字段；如果编码和解码正常，此字段会置为 nil。
 
 *  \~english
 The json Dictionary of the last message in the conversation.

 @ discussion This field stores the unencoded json data in the content of the last message.
  The message built into SDK. If the message decoding fails, the default will store the contents of the message in this field; if the encoding and decoding are normal, this field will be set to nil.
 */
@property (nonatomic, strong) NSDictionary *jsonDict;

/*!
 *  \~chinese
 最后一条消息的全局唯一 ID

 @discussion 服务器消息唯一 ID（在同一个Appkey下全局唯一）
 
 *  \~english
 Globally unique ID of the last message.

 @ discussion Server message unique ID (globally unique under the same Appkey).
 */
@property (nonatomic, copy) NSString *lastestMessageUId;

/*!
 *  \~chinese
 会话中是否存在被 @ 的消息

 @discussion 在清除会话未读数（clearMessagesUnreadStatus:targetId:）的时候，会将此状态置成 NO。
 
 *  \~english
 Whether there is a @ message in the conversation.

 @ discussion set this state to NO when clearing the conversation unread (clearMessagesUnreadStatus:targetId:).
 */
@property (nonatomic, assign, readonly) BOOL hasUnreadMentioned;

/*!
 *  \~chinese
会话中 @ 消息的个数

@discussion 在清除会话未读数（clearMessagesUnreadStatus:targetId:）的时候，会将此值置成 0。
 
 *  \~english
 The number of @ messages in the conversation.

 @ discussion Set this value to 0 when it clears the conversation unread (clearMessagesUnreadStatus:targetId:).
*/
@property (nonatomic, assign) int mentionedCount;

/*!
 *  \~chinese
会话是否是免打扰状态
 
 *  \~english
 Whether the conversation is in a do not Disturb state.
*/
@property (nonatomic, assign) RCConversationNotificationStatus blockStatus;

@end
