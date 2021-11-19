//
//  RCCommandMessage.h
//  RongIMLib
//
//  Created by RongCloud on 15/12/2.
//  Copyright © 2015 RongCloud. All rights reserved.
//
#import "RCMessageContent.h"

/*!
 *  \~chinese
 命令消息的类型名
 *  \~english
 The type name of the command message
 */
#define RCCommandMessageIdentifier @"RC:CmdMsg"

/*!
 *  \~chinese
 命令消息类

 @discussion 命令消息类，此消息不存储不计入未读消息数。
 与 RCCommandNotificationMessage 的区别是，此消息不存储，也不会在界面上显示。
 
 @remarks 通知类消息
 
 *  \~english
 Command message class.

 @ discussion command message class, this message is not stored and does not count as unread messages.
  Unlike RCCommandNotificationMessage, this message is not stored and will not be displayed on the interface.
  
  @ remarks notification message
 */
@interface RCCommandMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
命令的名称
 *  \~english
 The name of the command
*/
@property (nonatomic, copy) NSString *name;

/*!
 *  \~chinese
 命令的扩展数据

 @discussion 命令的扩展数据，可以为任意字符串，如存放您定义的json数据。
 
 *  \~english
 Extended data for the command.

 @ discussion The extended data of the command can be any string, such as storing the json data you define.
 */
@property (nonatomic, copy) NSString *data;

/*!
 *  \~chinese
 初始化命令消息

 @param name    命令的名称
 @param data    命令的扩展数据
 @return        命令消息对象
 
 *  \~english
 Initialize command message.

 @param name The name of the command.
 @param data Extended data for the command.
 @ return command message object.
 */
+ (instancetype)messageWithName:(NSString *)name data:(NSString *)data;

@end
