/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCRichContentItem.h
//  Created by Dulizhao on 15/4/21.

#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 公众服务图文信息条目类

 @discussion 图文消息类，此消息会进行存储并计入未读消息数。
 
 *  \~english
 Public service image and text information entry class

 @ discussion Image and text message class, which is stored and counted as unread messages.
 */
@interface RCRichContentItem : NSObject

/*!
 *  \~chinese
 图文信息条目的标题
 
 *  \~english
 The title of the image and text information entry.
 */
@property (nonatomic, copy) NSString *title;

/*!
 *  \~chinese
 图文信息条目的内容摘要
 
 *  \~english
 Content digest of image and text information entries.
 */
@property (nonatomic, copy) NSString *digest;

/*!
 *  \~chinese
 图文信息条目的图片 URL
 
 *  \~english
 Image URL of image and text information entry.
 */
@property (nonatomic, copy) NSString *imageURL;

/*!
 *  \~chinese
 图文信息条目中包含的需要跳转到的 URL
 
 *  \~english
 The URL that shall be redirected in the image and text information entry.
 */
@property (nonatomic, copy) NSString *url;

/*!
 *  \~chinese
 图文信息条目的扩展信息
 
 *  \~english
 Extended information of image and text information entries.
 */
@property (nonatomic, copy) NSString *extra;

/*!
 *  \~chinese
 初始化公众服务图文信息条目

 @param title       图文信息条目的标题
 @param digest      图文信息条目的内容摘要
 @param imageURL    图文信息条目的图片 URL
 @param extra       图文信息条目的扩展信息
 @return            图文信息条目对象
 
 *  \~english
 Initialize the public service image and text information entry.

 @param title The title of the image and text information entry.
 @param digest Content digest of image and text information entries.
 @param imageURL image URL of image and text information entry.
 @param extra Extended information of image and text information entries.
 @ return image and text Information entry object.
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                           extra:(NSString *)extra;

/*!
 *  \~chinese
 初始化公众服务图文信息条目

 @param title       图文信息条目的标题
 @param digest      图文信息条目的内容摘要
 @param imageURL    图文信息条目的图片URL
 @param url         图文信息条目中包含的需要跳转到的URL
 @param extra       图文信息条目的扩展信息
 @return            图文信息条目对象
 
 *  \~english
 Initialize the public service image and text information entry.

 @param title The title of the image and text information entry.
 @param digest Content digest of image and text information entries.
 @param imageURL image URL of image and text information entry.
 @param url The URL that shall be redirected in the image and text information entry.
 @param extra Extended information of image and text information entries.
 @ return image and text Information entry object.
 */
+ (instancetype)messageWithTitle:(NSString *)title
                          digest:(NSString *)digest
                        imageURL:(NSString *)imageURL
                             url:(NSString *)url
                           extra:(NSString *)extra;

@end
