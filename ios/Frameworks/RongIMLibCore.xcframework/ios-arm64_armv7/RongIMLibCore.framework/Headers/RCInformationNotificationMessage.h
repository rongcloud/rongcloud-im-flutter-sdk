/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCInformationNotificationMessage.h
//  Created by xugang on 14/12/4.

#import "RCMessageContent.h"

/*!
 *  \~chinese
 通知消息的类型名
 
 *  \~english
 The type name of the notification message
 */
#define RCInformationNotificationMessageIdentifier @"RC:InfoNtf"

/*!
 *  \~chinese
 通知消息类

 @discussion 通知消息类，此消息会进行存储，但不计入未读消息数。
 
 @remarks 通知类消息
 
 *  \~english
 Notification message class.

 @ discussion notification message class that this message is stored but does not count as the number of unread messages.
  
  @ remarks notification message
 */
@interface RCInformationNotificationMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 通知的内容
 
 *  \~english
 The content of the notice
 */
@property (nonatomic, copy) NSString *message;

/*!
 *  \~chinese
 初始化通知消息

 @param message 通知的内容
 @param extra   通知的附加信息
 @return        通知消息对象
 
 *  \~english
 Initialize notification message.

 @param message The content of the notice.
 @param extra Additional information for notification.
 @ return Notification message object.
 */
+ (instancetype)notificationWithMessage:(NSString *)message extra:(NSString *)extra;

@end
