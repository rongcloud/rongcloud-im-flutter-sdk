//
//  RCReferenceMessage.h
//  RongIMLib
//
//  Created by RongCloud on 2020/2/26.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>
/*!
 *  \~chinese
 引用消息的类型名
 
 *  \~english
 The type name of the reference message
 */
#define RCReferenceMessageTypeIdentifier @"RC:ReferenceMsg"
/*!
 *  \~chinese
引用消息类

@discussion 引用消息类，此消息会进行存储并计入未读消息数。
 
@remarks 内容类消息
 
 *  \~english
 Reference message class.

 @ discussion reference message class, which is stored and counted as unread messages.
  
 @ remarks content class message.
*/
@interface RCReferenceMessage : RCMessageContent
/*!
 *  \~chinese
 引用文本
 
 *  \~english
 Reference text
 */
@property (nonatomic, strong) NSString *content;
/*!
 *  \~chinese
 被引用消息的发送者 ID
 
 *  \~english
 ID of the sender of the referenced message
 */
@property (nonatomic, strong) NSString *referMsgUserId;

/*!
 *  \~chinese
 被引用消息体
 
 *  \~english
 Referenced message body
 */
@property (nonatomic, strong) RCMessageContent *referMsg;

/*!
 *  \~chinese
 被引用消息的 messageUId。服务器消息唯一 ID（在同一个 Appkey 下全局唯一）
 
 *  \~english
 messageUId of refered
 */
@property (nonatomic, strong) NSString *referMsgUid;

@end
