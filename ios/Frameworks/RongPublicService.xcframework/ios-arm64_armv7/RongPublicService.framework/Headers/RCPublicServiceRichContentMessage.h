/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceMultiRichContentMessage.h
//  Created by litao on 15/4/15.

#import <RongIMLibCore/RongIMLibCore.h>
#import "RCRichContentItem.h"

/*!
 *  \~chinese
 公众服务图文消息的类型名
 
 *  \~english
 The type name of the public service image and text message. 
 */
#define RCSingleNewsMessageTypeIdentifier @"RC:PSImgTxtMsg"

/*!
 *  \~chinese
 公众服务图文消息类

 @discussion 公众服务图文消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 Public service image and text message category.

 @ discussion Public service image and text message class, this message is stored and counted as the number of unread messages.
  
  @ remarks content class message.
 */
@interface RCPublicServiceRichContentMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 公众服务图文信息条目 RCRichContentItem 内容
 
 *  \~english
 Public service image and text information entry RCRichContentItem content.
 */
@property (nonatomic, strong) RCRichContentItem *richContent;

@end
