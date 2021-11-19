/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCUtilities.h
//  Created by Heq.Shinoda on 14-5-15.

#ifndef __RCUtilities
#define __RCUtilities

#import "RCMessage.h"
#import <UIKit/UIKit.h>

/*!
 *  \~chinese
 工具类
 
 *  \~english
 Tool class 
 */
@interface RCUtilities : NSObject

/*!
 *  \~chinese
 将 base64 编码的字符串解码并转换为 NSData 数据

 @param string      base64 编码的字符串
 @return            解码后的 NSData 数据

 @discussion 此方法主要用于 iOS6 解码 base64。
 
 *  \~english
 Decode and convert base64-encoded strings into NSData data.

 @param string Base64 encoded string.
 @ return decoded NSData data.

 @ discussion This method is mainly used for iOS6 decoding base64.
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;

/*!
 *  \~chinese
 将 NSData 数据转化并编码为 base64 的字符串

 @param data    未编码的 NSData 数据
 @return        编码后的 base64 字符串

 @discussion 此方法主要用于 iOS6 编码 base64。
 
 *  \~english
 Convert and encode NSData data into base64 strings.

 @param data Unencoded NSData data.
 @ return encoded base64 string.

 @ discussion This method is mainly used for iOS6 encoding base64.
 */
+ (NSString *)base64EncodedStringFrom:(NSData *)data;

/*!
 *  \~chinese
 scaleImage

 @param image           image
 @param scaleSize       scaleSize

 @return                scaled image
 
 *  \~english
 ScaleImage.

 @param image Image.
 @param scaleSize ScaleSize.

 @ return scaled image.
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/*!
 *  \~chinese
 imageByScalingAndCropSize

 @param image           image
 @param targetSize      targetSize

 @return                image
 
 *  \~english
 ImageByScalingAndCropSize.

 @param image Image.
 @param targetSize TarGetize.

 @ return image.
 */
+ (UIImage *)imageByScalingAndCropSize:(UIImage *)image targetSize:(CGSize)targetSize;

/*!
 *  \~chinese
根据配置压缩图片，如果设置了[RCCoreClient sharedCoreClient].imageCompressConfig ，就按照此设置进行压缩。如果没有设置，就按照RCConfigg.plis文件中的配置进行压缩。
 
 @param image           原图片
 @return          压缩后的图片
 
 *  \~english
 Compress the image according to the configuration, and compress the image according to this setting if [RCCoreClient sharedCoreClient]. ImageCompressConfig, is set. If it is not set, compress it according to the configuration in the RCConfigg.plis file.
  
  @param image           Original image.
 @ return compressed image.
 */
+ (UIImage *)generateThumbnailByConfig:(UIImage *)image;

/*!
 generate thumbnail from image

 @param image           image
 @param targetSize      targetSize

 @return                image
 */
+ (UIImage *)generateThumbnail:(UIImage *)image targetSize:(CGSize)targetSize;

/*!
 generate thumbnail from image

 @param image           image
 @param targetSize      targetSize
 @param percent         percent

 @return                image
 */
+ (UIImage *)generateThumbnail:(UIImage *)image targetSize:(CGSize)targetSize percent:(CGFloat)percent;
/*!
 compressedImageWithMaxDataLength

 @param image               image
 @param maxDataLength       maxDataLength

 @return                    nsdate
 */
+ (NSData *)compressedImageWithMaxDataLength:(UIImage *)image maxDataLength:(CGFloat)maxDataLength;

/*!
 compressedImageAndScalingSize

 @param image           image
 @param targetSize      targetSize
 @param maxDataLen      maxDataLen

 @return                image nsdata
 */
+ (NSData *)compressedImageAndScalingSize:(UIImage *)image targetSize:(CGSize)targetSize maxDataLen:(CGFloat)maxDataLen;

/*!
 compressedImageAndScalingSize

 @param image           image
 @param targetSize      targetSize
 @param percent         percent

 @return                image nsdata
 */
+ (NSData *)compressedImageAndScalingSize:(UIImage *)image targetSize:(CGSize)targetSize percent:(CGFloat)percent;
/*!
 compressedImage

 @param image           image
 @param percent         percent

 @return                image nsdata
 */
+ (NSData *)compressedImage:(UIImage *)image percent:(CGFloat)percent;

/*!
 *  \~chinese
 获取文字显示的尺寸

 @param text 文字
 @param font 字体
 @param constrainedSize 文字显示的容器大小

 @return 文字显示的尺寸

 @discussion 该方法在计算 iOS 7 以下系统显示的时候默认使用 NSLineBreakByTruncatingTail 模式。
 
 *  \~english
 Get the size of the text display.

 @param text Words.
 @param font Font.
 @param constrainedSize Container size for text display.

 @ return The size of  text display.

 @ discussion This method uses NSLineBreakByTruncatingTail mode by default when the system display below iOS 7 is calculated.
 */
+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

/*!
 *  \~chinese
 判断是否是本地路径

 @param path 路径

 @return 是否是本地路径
 
 *  \~english
 Determine whether it is a local path.

 @param path Path.

 @ return Whether it  is a local path.
 */
+ (BOOL)isLocalPath:(NSString *)path;

/*!
 *  \~chinese
 判断是否是网络地址

 @param url 地址

 @return 是否是网络地址
 
 *  \~english
 Determine whether it is a network address.

 @param url Address.

 @ return Whether it is a network address.
 */
+ (BOOL)isRemoteUrl:(NSString *)url;

/*!
 *  \~chinese
 获取沙盒修正后的文件路径

 @param localPath 本地路径

 @return 修正后的文件路径
 
 *  \~english
 Get the revised file path of sandboxes

 @param localPath Local path.

 @ return revised file path.
 */
+ (NSString *)getCorrectedFilePath:(NSString *)localPath;

/*!
 *  \~chinese
 * 获取文件存储路径
 
 *  \~english
 * Obtain the file storage path
 */
+ (NSString *)getFileStoragePath;

/*!
 excludeBackupKeyForURL

 @param storageURL      storageURL

 @return                BOOL
 */
+ (BOOL)excludeBackupKeyForURL:(NSURL *)storageURL;

/*!
 *  \~chinese
 获取 App 的文件存放路径

 @return    App 的文件存放路径
 
 *  \~english
 Get the file storage path of App.

 @ return App's file storage path.
 */
+ (NSString *)applicationDocumentsDirectory;

/*!
 *  \~chinese
 获取融云 SDK 的文件存放路径

 @return    融云 SDK 的文件存放路径
 
 *  \~english
 Get the file storage path of the RongCloud SDK.

 @ return the file storage path of RongCloud SDK.
 */
+ (NSString *)rongDocumentsDirectory;

/*!
 *  \~chinese
 获取融云 SDK 的缓存路径

 @return    融云 SDK 的缓存路径
 
 *  \~english
 Get the cache path of RongCloud SDK.

 @ return the cache path of RongCloud SDK.
 */
+ (NSString *)rongImageCacheDirectory;

/*!
 *  \~chinese
 获取当前系统时间

 @return    当前系统时间
 
 *  \~english
 Get the current system time.

 @ return current system time.
 */
+ (NSString *)currentSystemTime;

/*!
 *  \~chinese
 获取当前运营商名称

 @return    当前运营商名称
 
 *  \~english
 Get the current operator name.

 @ return current operator name.
 */
+ (NSString *)currentCarrier;

/*!
 *  \~chinese
 获取当前网络类型

 @return    当前网络类型
 
 *  \~english
 Get the current network type.

 @ return current network type.
 */
+ (NSString *)currentNetWork;

/*!
 *  \~chinese
 获取当前网络类型

 @return    当前网络类型
 
 *  \~english
 Get the current network type.

 @ return current network type.
 */
+ (NSString *)currentNetworkType;

/*!
 *  \~chinese
 获取系统版本

 @return    系统版本
 
 *  \~english
 Get system version.

 @ return system version.
 */
+ (NSString *)currentSystemVersion;

/*!
 *  \~chinese
 获取设备型号

 @return    设备型号
 
 *  \~english
 Get the device model.

 @ return device model.
 */
+ (NSString *)currentDeviceModel;

/*!
 *  \~chinese
 获取非换行的字符串

 @param originalString 原始的字符串

 @return 非换行的字符串

 @discussion 所有换行符将被替换成单个空格
 
 *  \~english
 Get a string that is not a newline.

 @param originalString Original string.

 @ return non-newline string.

 @ discussion All newline characters will be replaced with a single space.
 */
+ (NSString *)getNowrapString:(NSString *)originalString;

/**
 *  \~chinese
 获取消息类型对应的描述

 @param mediaType 消息类型
 @return 描述
 
 *  \~english
 Get the description corresponding to the message type.

 @param mediaType Message type.
 @ return description.
 */
+ (NSString *)getMediaTypeString:(RCMediaType)mediaType;

/**
 *  \~chinese
 获取消息内容对应的媒体类型

 @param content 消息内容
 @return 媒体类型，如果是不支持的媒体类型或者消息，将返回 -1
 
 *  \~english
 Get the media type corresponding to the message content.

 @param content Message content.
 @ return media type. If it is an unsupported media type or message,-1 will be returned.
 */
+ (RCMediaType)getMediaType:(RCMessageContent *)content;

/**
 *  \~chinese
 判断一张照片是否是含透明像素的照片

 @param image 原始照片
 @return 是否包含透明像素，YES 包含， NO 不包含
 
 *  \~english
 Determine whether a image is a image with transparent pixels.

 @param image Original image.
 Whether @ return contains transparent pixels, YES does, and NO does not.
 */
+ (BOOL)isOpaque:(UIImage *)image;

/**
 *  \~chinese
 URL 编码

 @return 编码后的 URL
 
 *  \~english
 URL coding.

 @ return encoded URL.
 */
+ (NSString *)encodeURL:(NSString *)url;

+ (NSData *)compressImage:(UIImage *)sourceImage;

/**
 *  \~chinese
 检查字符串是否符合聊天室属性名称的格式

 @param key 聊天室属性名称
 @return 是否符合聊天室属性名称的格式，YES 符合， NO 不符合

 @discussion Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式
 
 *  \~english
 Check whether the string matches the format of the chat room attribute name.

 @param key Chat room attribute name.
 Whether @ return conforms to the format of chat room attribute names, YES does, but NO does not.

 @ discussion Key supports the combination of uppercase and lowercase letters, numbers and some special symbols + =-_.
 */
+ (BOOL)checkChatroomKey:(NSString *)key;

/**
 *  \~chinese
生成 22 位的 UUID

@return 22 位的 UUID
 
 *  \~english
 Generate 22-bit UUID.

 @ return 22-bit UUID.
*/
+ (NSString *)get22bBitUUID;

/**
 *  \~chinese
生成 UUID

@return UUID
 
 *  \~english
 Generate UUID.

 @ return UUID.
*/
+ (NSString *)getUUID;

/**
 *  \~chinese
生成 DeviceId

@return DeviceId 连接改造使用的
 
 *  \~english
 Generate DeviceId.

 @ return DeviceId connection transformation.
 */
+ (NSString *)getDeviceId:(NSString *)appKey;

/**
 *  \~chinese
获取手机型号

@return  手机型号
 
 *  \~english
 Get the phone model.

 @ return mobile phone model
 */
+ (NSString *)iphoneType;

@end

#endif
