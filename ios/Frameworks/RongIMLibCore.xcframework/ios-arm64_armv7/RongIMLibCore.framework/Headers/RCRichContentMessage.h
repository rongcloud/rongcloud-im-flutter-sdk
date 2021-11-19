/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCRichContentMessage.h
//  Created by Gang Li on 10/17/14.

#import "RCMessageContent.h"
#import <UIKit/UIKit.h>

/*!
 *  \~chinese
 图文消息的类型名
 
 *  \~english
 The type name of the image and text message.
 */
#define RCRichContentMessageTypeIdentifier @"RC:ImgTextMsg"

/*!
 *  \~chinese
 图文消息类

 @discussion 图文消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 Image and text message class.

 @ discussion image and text message class, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCRichContentMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 图文消息的标题
 
 *  \~english
 The title of the image-text message.
 */
@property (nonatomic, copy) NSString *title;

/*!
 *  \~chinese
 图文消息的内容摘要
 
 *  \~english
 Content digest of image and text messages
 */
@property (nonatomic, copy) NSString *digest;

/*!
 *  \~chinese
 图文消息图片 URL
 
 *  \~english
 Image URL of image
 */
@property (nonatomic, copy) NSString *imageURL;

/*!
 *  \~chinese
 图文消息中包含的需要跳转到的URL
 
 *  \~english
 The URL contained in the image and text message to which you shall jump to.
 */
@property (nonatomic, copy) NSString *url;

/*!
 *  \~chinese
 初始化图文消息

 @param title       图文消息的标题
 @param digest      图文消息的内容摘要
 @param imageURL    图文消息的图片URL
 @param extra       图文消息的扩展信息
 @return            图文消息对象
 
 *  \~english
 Initialize the image and text message.

 @param title The title of the image-text message.
 @param digest Content digest of image and text messages.
 @param imageURL image URL of image and text messages.
 @param extra Extended information of image and text messages.
 @ return Teletext message object.
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                           extra:(NSString *)extra;

/*!
 *  \~chinese
 初始化图文消息

 @param title       图文消息的标题
 @param digest      图文消息的内容摘要
 @param imageURL    图文消息的图片URL
 @param url         图文消息中包含的需要跳转到的URL
 @param extra       图文消息的扩展信息
 @return            图文消息对象
 
 *  \~english
 Initialize the image and text message.

 @param title The title of the image-text message.
 @param digest Content digest of image and text messages.
 @param imageURL image URL of image and text messages.
 @param url The URL contained in the image and text message to which you shall jump to.
 @param extra Extended information of image and text messages.
 @ return Teletext message object.
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                             url:(NSString *)url
                           extra:(NSString *)extra;

@end
