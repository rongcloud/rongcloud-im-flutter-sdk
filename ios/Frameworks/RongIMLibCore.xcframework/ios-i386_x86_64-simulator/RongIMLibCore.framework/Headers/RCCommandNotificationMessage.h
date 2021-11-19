/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCCommandNotificationMessage.h
//  Created by xugang on 14/11/28.

#import "RCMessageContent.h"

/*!
 *  \~chinese
 命令提醒消息的类型名
 *  \~english
 The type name of the command reminder message.
 */
#define RCCommandNotificationMessageIdentifier @"RC:CmdNtf"

/*!
 *  \~chinese
 命令提醒消息类

 @discussion 命令消息类，此消息会进行存储，但不计入未读消息数。
 与 RCCommandMessage 的区别是，此消息会进行存储并在界面上显示。
 
 @remarks 通知类消息
 
 *  \~english
 Command reminder message class.

 @ discussion Command message class, which is stored but does not count as unread messages.
  Unlike RCCommandMessage, this message is stored and displayed on the interface.
  
  @ remarks notification message.
 */
@interface RCCommandNotificationMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 命令提醒的名称
 
 *  \~english
 The name of the command reminder
 */
@property (nonatomic, copy) NSString *name;

/*!
 *  \~chinese
 命令提醒消息的扩展数据

 @discussion 命令提醒消息的扩展数据，可以为任意字符串，如存放您定义的 json 数据。

 *  \~english
 Extended data for command reminder messages.

 @ discussion The extended data of the command reminder message can be any string, such as storing the json data you defined.
 */
@property (nonatomic, copy) NSString *data;

/*!
 *  \~chinese
 初始化命令提醒消息

 @param name    命令的名称
 @param data    命令的扩展数据
 @return        命令提醒消息对象
 
 *  \~english
 Initialization command reminder message.

 @param name The name of the command.
 @param data Extended data for the command.
 @ return Command reminder message object.
 */
+ (instancetype)notificationWithName:(NSString *)name data:(NSString *)data;

@end
