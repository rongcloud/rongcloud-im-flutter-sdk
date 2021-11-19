/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceMultiRichContentMessage.h
//  Created by litao on 15/4/13.

#import <RongIMLibCore/RongIMLibCore.h>

/*!
 *  \~chinese
 公众服务的多图文消息的类型名
 
 *  \~english
 The type name of the multiple image and text message for the public service. 
 */
#define RCPublicServiceRichContentTypeIdentifier @"RC:PSMultiImgTxtMsg"

/*!
 *  \~chinese
 公众服务的多图文消息类

 @discussion 公众服务的多图文消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 Multiple image and text message class of public service.

 @ discussion The multiple image and text message class of the public service, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCPublicServiceMultiRichContentMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 多图文消息的内容 RCRichContentItem 数组
 
 *  \~english
 RCRichContentItem array of the contents of multi-image and text messages.
 */
@property (nonatomic, strong) NSArray *richContents;

/*!
 *  \~chinese
 多图文消息的附加信息
 
 *  \~english
 Additional information for multiple image and text messages.
 */
@property (nonatomic, copy) NSString *extra;

/*!
 *  \~chinese
 多图文消息被选中的项的索引, -1 表示选中全部
 
 *  \~english
 The index of the selected item of the multiple image and text message, -1 indicates that all are selected.
 */
@property (nonatomic, assign, readonly) NSInteger selectedItemIndex;

@end
