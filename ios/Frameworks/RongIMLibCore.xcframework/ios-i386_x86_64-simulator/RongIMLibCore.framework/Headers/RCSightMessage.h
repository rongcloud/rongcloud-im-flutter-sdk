//
//  RCSightMessage.h
//  RongIMLib
//
//  Created by LiFei on 2016/12/1.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>
#import <UIKit/UIKit.h>

/*!
 *  \~chinese
 小视频消息的类型名
 
 *  \~english
 The type name of the small video message.
 */
#define RCSightMessageTypeIdentifier @"RC:SightMsg"
@class AVAsset;
/**
 *  \~chinese
 小视频消息类

 @discussion 小视频消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 Small video message class.

 @ discussion small video message class, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCSightMessage : RCMediaMessageContent <NSCoding>

/*!
 *  \~chinese
 本地 URL 地址
 
 *  \~english
 Local URL address
 */
@property (nonatomic, copy) NSString *localPath;

/*!
 *  \~chinese
 网络 URL 地址
 
 *  \~english
 Network URL address
 */
@property (nonatomic, readonly) NSString *sightUrl;

/**
 *  \~chinese
 视频时长，以秒为单位
 
 *  \~english
 Video duration (in seconds)
 */
@property (nonatomic, assign, readonly) NSUInteger duration;

/**
 *  \~chinese
 小视频文件名
 
 *  \~english
 Small video file name
 */
@property (nonatomic, copy) NSString *name;

/**
 *  \~chinese
 文件大小
 
 *  \~english
 File size
 */
@property (nonatomic, assign, readonly) long long size;

/*!
 *  \~chinese
 缩略图
 
 *  \~english
 Thumbnail image
 */
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;

/**
 *  \~chinese
 创建小视频消息的便利构造方法

 @param path 视频文件本地路径
 @param image 视频首帧缩略图
 @param duration 视频时长， 以秒为单位
 @return 视频消息实例变量
 
 *  \~english
 A convenient construction method for creating small video messages.

 @param path Local path of video file.
 @param image Thumbnail of the first frame of the video.
 @param duration Video duration (in seconds).
 @ return video message instance variable.
 */
+ (instancetype)messageWithLocalPath:(NSString *)path thumbnail:(UIImage *)image duration:(NSUInteger)duration;

@end
