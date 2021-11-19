//
//  RCRecallNotificationMessage.h
//  RongIMLib
//
//  Created by litao on 16/7/15.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

/*!
 *  \~chinese
 撤回通知消息的类型名
 
 *  \~english
 The type name of the recall notification message
 */
#define RCRecallNotificationMessageIdentifier @"RC:RcNtf"

/*!
 *  \~chinese
 撤回通知消息类
 @discussion 撤回通知消息，此消息会进行本地存储，但不计入未读消息数。
 
 @remarks 通知类消息
 
 *  \~english
 Recall notification message class
 @ discussion Recall notification message, which is stored locally, but does not count as the number of unread messages.
  
  @ remarks notification message
 */
@interface RCRecallNotificationMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 发起撤回操作的用户 ID
 
 *  \~english
 ID of the user who initiates the recall operation
 */
@property (nonatomic, copy) NSString *operatorId;

/*!
 *  \~chinese
 撤回的时间（毫秒）
 
 *  \~english
 Time to recall (milliseconds)
 */
@property (nonatomic, assign) long long recallTime;

/*!
 *  \~chinese
 原消息的消息类型名
 
 *  \~english
 Message type name of the original message
 */
@property (nonatomic, copy) NSString *originalObjectName;

/*!
 *  \~chinese
 是否是管理员操作
 
 *  \~english
 Whether it is an administrator operation
 */
@property (nonatomic, assign) BOOL isAdmin;

/*!
 *  \~chinese
 撤回的文本消息的内容
 
 *  \~english
 The contents of the recalled text message
*/
@property (nonatomic, copy) NSString *recallContent;

/*!
 *  \~chinese
 撤回动作的时间（毫秒）
 
 *  \~english
 Time to recall the action (milliseconds).
*/
@property (nonatomic, assign) long long recallActionTime;

@end
