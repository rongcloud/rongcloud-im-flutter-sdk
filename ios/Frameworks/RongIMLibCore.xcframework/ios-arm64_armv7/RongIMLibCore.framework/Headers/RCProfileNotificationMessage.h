/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCProfileNotificationMessage.h
//  Created by xugang on 14/11/28.

#import "RCMessageContent.h"

/*!
 *  \~chinese
 公众服务账号信息变更消息的类型名
 
 *  \~english
 The type name of the public service account information change message.
 */
#define RCProfileNotificationMessageIdentifier @"RC:ProfileNtf"

/*!
 *  \~chinese
 公众服务账号信息变更消息类

 @discussion 公众服务账号信息变更消息类，此消息会进行存储，但不计入未读消息数。
 
 @remarks 通知类消息
 
 *  \~english
 Public service account information change message class.

 @ discussion public service account information change message class, which will be stored, but will not be counted as the number of unread messages.
  
  @ remarks notification message
 */
@interface RCProfileNotificationMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 公众服务账号信息变更的操作名
 
 *  \~english
 The operation name of the change of public service account information.
 */
@property (nonatomic, copy) NSString *operation;

/*!
 *  \~chinese
 信息变更的数据，可以为任意格式，如 json 数据。
 
 *  \~english
 Data with changed information, which can be in any format, e.g. json data.
 */
@property (nonatomic, copy) NSString *data;

/*!
 *  \~chinese
 初始化公众服务账号信息变更消息

 @param operation   信息变更的操作名
 @param data        信息变更的数据
 @param extra       信息变更的附加信息
 @return            公众服务账号信息变更消息的对象
 
 *  \~english
 Initialize public service account information change message.

 @param operation Operation name of information change.
 @param data Information changed data.
 @param extra Additional information for information changes.
 @ return the object of the change message for the account information of the public service.
 */
+ (instancetype)notificationWithOperation:(NSString *)operation data:(NSString *)data extra:(NSString *)extra;

@end
