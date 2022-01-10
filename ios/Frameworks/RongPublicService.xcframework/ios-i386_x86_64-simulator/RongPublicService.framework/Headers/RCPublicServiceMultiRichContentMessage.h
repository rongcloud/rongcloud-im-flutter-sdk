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
 公众服务的多图文消息的类型名
 */
#define RCPublicServiceRichContentTypeIdentifier @"RC:PSMultiImgTxtMsg"

/*!
 公众服务的多图文消息类

 @discussion 公众服务的多图文消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 */
@interface RCPublicServiceMultiRichContentMessage : RCMessageContent <NSCoding>

/*!
 多图文消息的内容 RCRichContentItem 数组
 */
@property (nonatomic, strong) NSArray *richContents;

/*!
 多图文消息的附加信息
 */
@property (nonatomic, copy) NSString *extra;

/*!
 多图文消息被选中的项的索引, -1 表示选中全部
 */
@property (nonatomic, assign, readonly) NSInteger selectedItemIndex;

@end
