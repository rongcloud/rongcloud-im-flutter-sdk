//
//  RCPublicServiceCommandMessage.h
//  RongIMLib
//
//  Created by litao on 15/6/23.
//  Copyright (c) 2015 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>
#import "RCPublicServiceMenuItem.h"

/*!
 *  \~chinese
 公众服务请求消息的类型名
 
 *  \~english
 Type name of the public service request message. 
 */
#define RCPublicServiceCommandMessageTypeIdentifier @"RC:PSCmd"

/*!
 *  \~chinese
 公众服务请求消息类

 @discussion 公众服务请求消息类，此消息不存储，也不计入未读消息数。
 此消息仅用于客户端公共服务账号中的菜单，向服务器发送请求。

 @remarks 通知类消息
 
 *  \~english
 Public service request message class.

 @ discussion Public service request message class, which is not stored and does not count as the number of unread messages.
  This message is only used for menus in the client public service account to send requests to the server.

  @ remarks notification message
 */
@interface RCPublicServiceCommandMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 请求的名称
 
 *  \~english
 Name of the request
 */
@property (nonatomic, copy) NSString *command;

/*!
 *  \~chinese
 请求的内容
 
 *  \~english
 The content of the request
 */
@property (nonatomic, copy) NSString *data;

/*!
 *  \~chinese
 请求的扩展数据
 
 *  \~english
 Requested extended data
 */
@property (nonatomic, copy) NSString *extra;

/*!
 *  \~chinese
 初始化公众服务请求消息

 @param item    公众服务菜单项
 @return        公众服务请求消息对象
 
 *  \~english
 Initialize a public service request message.

 @param item Public service menu items.
 @ return Public Service request message object.
 */
+ (instancetype)messageFromMenuItem:(RCPublicServiceMenuItem *)item;

/*!
 *  \~chinese
 初始化公众服务请求消息

 @param command     请求的名称
 @param data        请求的内容
 @return            公众服务请求消息对象
 
 *  \~english
 Initialize a public service request message

 @param command Name of the request.
 @param data The content of the request.
 @ return Public Service request message object.
 */
+ (instancetype)messageWithCommand:(NSString *)command data:(NSString *)data;

@end
