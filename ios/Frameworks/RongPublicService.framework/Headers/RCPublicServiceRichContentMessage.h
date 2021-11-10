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
 公众服务图文消息的类型名
 */
#define RCSingleNewsMessageTypeIdentifier @"RC:PSImgTxtMsg"

/*!
 公众服务图文消息类

 @discussion 公众服务图文消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 */
@interface RCPublicServiceRichContentMessage : RCMessageContent <NSCoding>

/*!
 公众服务图文信息条目 RCRichContentItem 内容
 */
@property (nonatomic, strong) RCRichContentItem *richContent;

@end
