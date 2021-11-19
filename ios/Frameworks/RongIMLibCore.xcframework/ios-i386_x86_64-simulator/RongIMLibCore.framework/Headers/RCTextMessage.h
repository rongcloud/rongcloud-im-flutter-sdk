/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCTextMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"

/*!
 *  \~chinese
 文本消息的类型名
 
 *  \~english
 The type name of the text message 
 */
#define RCTextMessageTypeIdentifier @"RC:TxtMsg"

/*!
 *  \~chinese
 文本消息类

 @discussion 文本消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 Text message class.

 @ discussion Text message class, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCTextMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 文本消息的内容
 
 *  \~english
 The content of a text message
 */
@property (nonatomic, copy) NSString *content;

/*!
 *  \~chinese
 初始化文本消息

 @param content 文本消息的内容
 @return        文本消息对象
 
 *  \~english
 Initialize text message.

 @param content The content of a text message.
 @ return text message object.
 */
+ (instancetype)messageWithContent:(NSString *)content;

@end
