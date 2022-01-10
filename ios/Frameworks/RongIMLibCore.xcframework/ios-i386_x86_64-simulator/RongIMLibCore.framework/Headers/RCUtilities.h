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
 工具类
 */
@interface RCUtilities : NSObject

/*!
 将 base64 编码的字符串解码并转换为 NSData 数据

 @param string      base64 编码的字符串
 @return            解码后的 NSData 数据

 @discussion 此方法主要用于 iOS6 解码 base64。
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;

/*!
 将 NSData 数据转化并编码为 base64 的字符串

 @param data    未编码的 NSData 数据
 @return        编码后的 base64 字符串

 @discussion 此方法主要用于 iOS6 编码 base64。
 */
+ (NSString *)base64EncodedStringFrom:(NSData *)data;

/*!
 scaleImage

 @param image           image
 @param scaleSize       scaleSize

 @return                scaled image
 */
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/*!
 imageByScalingAndCropSize

 @param image           image
 @param targetSize      targetSize

 @return                image
 */
+ (UIImage *)imageByScalingAndCropSize:(UIImage *)image targetSize:(CGSize)targetSize;

/*!
根据配置压缩图片，如果设置了[RCCoreClient sharedCoreClient].imageCompressConfig ，就按照此设置进行压缩。如果没有设置，就按照RCConfigg.plis文件中的配置进行压缩。
 
 @param image           原图片
 @return          压缩后的图片
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
 获取文字显示的尺寸

 @param text 文字
 @param font 字体
 @param constrainedSize 文字显示的容器大小

 @return 文字显示的尺寸

 @discussion 该方法在计算 iOS 7 以下系统显示的时候默认使用 NSLineBreakByTruncatingTail 模式。
 */
+ (CGSize)getTextDrawingSize:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

/*!
 判断是否是本地路径

 @param path 路径

 @return 是否是本地路径
 */
+ (BOOL)isLocalPath:(NSString *)path;

/*!
 判断是否是网络地址

 @param url 地址

 @return 是否是网络地址
 */
+ (BOOL)isRemoteUrl:(NSString *)url;

/*!
 获取沙盒修正后的文件路径

 @param localPath 本地路径

 @return 修正后的文件路径
 */
+ (NSString *)getCorrectedFilePath:(NSString *)localPath;

/*!
 * 获取文件存储路径
 */
+ (NSString *)getFileStoragePath;

/*!
 excludeBackupKeyForURL

 @param storageURL      storageURL

 @return                BOOL
 */
+ (BOOL)excludeBackupKeyForURL:(NSURL *)storageURL;

/*!
 获取 App 的文件存放路径

 @return    App 的文件存放路径
 */
+ (NSString *)applicationDocumentsDirectory;

/*!
 获取融云 SDK 的文件存放路径

 @return    融云 SDK 的文件存放路径
 */
+ (NSString *)rongDocumentsDirectory;

/*!
 获取融云 SDK 的缓存路径

 @return    融云 SDK 的缓存路径
 */
+ (NSString *)rongImageCacheDirectory;

/*!
 获取当前系统时间

 @return    当前系统时间
 */
+ (NSString *)currentSystemTime;

/*!
 获取当前运营商名称

 @return    当前运营商名称
 */
+ (NSString *)currentCarrier;

/*!
 获取当前网络类型

 @return    当前网络类型
 */
+ (NSString *)currentNetWork;

/*!
 获取当前网络类型

 @return    当前网络类型
 */
+ (NSString *)currentNetworkType;

/*!
 获取系统版本

 @return    系统版本
 */
+ (NSString *)currentSystemVersion;

/*!
 获取设备型号

 @return    设备型号
 */
+ (NSString *)currentDeviceModel;

/*!
 获取非换行的字符串

 @param originalString 原始的字符串

 @return 非换行的字符串

 @discussion 所有换行符将被替换成单个空格
 */
+ (NSString *)getNowrapString:(NSString *)originalString;

/**
 获取消息类型对应的描述

 @param mediaType 消息类型
 @return 描述
 */
+ (NSString *)getMediaTypeString:(RCMediaType)mediaType;

/**
 获取消息内容对应的媒体类型

 @param content 消息内容
 @return 媒体类型，如果是不支持的媒体类型或者消息，将返回 -1
 */
+ (RCMediaType)getMediaType:(RCMessageContent *)content;

/**
 判断一张照片是否是含透明像素的照片

 @param image 原始照片
 @return 是否包含透明像素，YES 包含， NO 不包含
 */
+ (BOOL)isOpaque:(UIImage *)image;

/**
 URL 编码

 @return 编码后的 URL
 */
+ (NSString *)encodeURL:(NSString *)url;

+ (NSData *)compressImage:(UIImage *)sourceImage;

/**
 检查字符串是否符合聊天室属性名称的格式

 @param key 聊天室属性名称
 @return 是否符合聊天室属性名称的格式，YES 符合， NO 不符合

 @discussion Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式
 */
+ (BOOL)checkChatroomKey:(NSString *)key;

/**
生成 22 位的 UUID

@return 22 位的 UUID
*/
+ (NSString *)get22bBitUUID;

/**
生成 UUID

@return UUID
*/
+ (NSString *)getUUID;

/**
生成 DeviceId

@return DeviceId 连接改造使用的
 */
+ (NSString *)getDeviceId:(NSString *)appKey;

/**
获取手机型号

@return  手机型号
 */
+ (NSString *)iphoneType;

+ (void)setModuleName:(NSString *)moduleName version:(NSString *)version;

+ (NSDictionary *)getModuleVersionInfo;

/// 将字典或者数组转换成字符串,能去打印的换行 '\n' 以及空格
/// @param objc 必须是字典或者是数组
+ (NSString *)jsonFromObject:(id)objc;

@end

#endif
