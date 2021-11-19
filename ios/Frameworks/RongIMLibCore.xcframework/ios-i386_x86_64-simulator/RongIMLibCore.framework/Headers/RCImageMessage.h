/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCImageMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMediaMessageContent.h"
#import <UIKit/UIKit.h>

/*!
 *  \~chinese
 图片消息的类型名
 
 *  \~english
 The type name of the image message
 */
#define RCImageMessageTypeIdentifier @"RC:ImgMsg"

/*!
 *  \~chinese
 图片消息类

 @discussion 图片消息类，此消息会进行存储并计入未读消息数。
 
 @discussion 如果想发送原图，请设置属性 full 为 YES。
 
 @remarks 内容类消息
 
 *  \~english
 Image message class.

 @ discussion image message class, which is stored and counted as unread messages.
  
  @ discussion If you want to send the original image, set the property full to YES.
  
  @ remarks content class message.
 */
@interface RCImageMessage : RCMediaMessageContent <NSCoding>

/*!
 *  \~chinese
 图片消息的 URL 地址

 @discussion 发送方此字段为图片的本地路径，接收方此字段为网络 URL 地址。
 
 *  \~english
 URL address of the image message.

 @ discussion sender this field is the local path of the image, and receiver this field is the network URL address.
 */
@property (nonatomic, copy) NSString *imageUrl;

/*!
 *  \~chinese
 图片的本地路径
 
 *  \~english
 The local path of the image.
 */
@property (nonatomic, copy) NSString *localPath;

/*!
 *  \~chinese
 图片消息的缩略图
 
 *  \~english
 A thumbnail of a image message.
 */
@property (nonatomic, strong) UIImage *thumbnailImage;

/*!
 *  \~chinese
 是否发送原图

 @discussion 在发送图片的时候，是否发送原图，默认值为 NO。
 
 *  \~english
 Whether to send the original image or not.

 @ discussion Whether to send the original image or not when sending the image. The default value is NO.
 */
@property (nonatomic, getter=isFull) BOOL full;

/*!
 *  \~chinese
 图片消息的附加信息
 
 *  \~english
 Additional information for image messages.
 */
@property (nonatomic, copy) NSString *extra;

/*!
 *  \~chinese
 图片消息的原始图片信息
 
 *  \~english
 The original image information of the image message.
 */
@property (nonatomic, strong) UIImage *originalImage;

/*!
 *  \~chinese
 图片消息的原始图片信息
 
 *  \~english
 The original image information of the image message.
 */
@property (nonatomic, strong, readonly) NSData *originalImageData;

/*!
 *  \~chinese
 初始化图片消息

 @discussion 如果想发送原图，请设置属性 full 为 YES。
 
 @param image   原始图片
 @return        图片消息对象
 
 *  \~english
 Initialize image message.

 @ discussion If you want to send the original image, set the property full to YES.
  
  @param image   Original image.
 @ return image message object.
 */
+ (instancetype)messageWithImage:(UIImage *)image;

/*!
 *  \~chinese
 初始化图片消息
 
 @discussion 如果想发送原图，请设置属性 full 为 YES。

 @param imageURI    图片的本地路径
 @return            图片消息对象
 
 *  \~english
 Initialize image message.

 @ discussion If you want to send the original image, set the property full to YES.

  @param imageURI    The local path of the image.
 @ return image message object.
 */
+ (instancetype)messageWithImageURI:(NSString *)imageURI;

/*!
 *  \~chinese
 初始化图片消息
 
 @discussion 如果想发送原图，请设置属性 full 为 YES。

 @param imageData    图片的原始数据
 @return            图片消息对象
 
 *  \~english
 Initialize image message.

 @ discussion If you want to send the original image, set the property full to YES.

  @param imageData    The original data of the image.
 @ return image message object
 */
+ (instancetype)messageWithImageData:(NSData *)imageData;

@end
