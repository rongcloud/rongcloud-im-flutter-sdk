/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCFileUtility.h

#ifndef __RCFileUtility
#define __RCFileUtility

#import "RCStatusDefine.h"

@interface RCFileUtility : NSObject

/*!
 设置文件媒体类型

 @return    文件类型
 */
+ (NSString *)getMimeType:(RCMediaType)fileType;

/*!
 获取上传文件名称

 @return    文件媒体类型
 */
+ (NSString *)generateKey:(NSString *)mimeType;

/*!
 生成下载的文件路径

 @return    文件名称
 */
+ (NSString *)getFileName:(NSString *)imgUrl
         conversationType:(RCConversationType)conversationType
                mediaType:(RCMediaType)mediaType
                 targetId:(NSString *)targetId;

/*!
 根据文件 URL 获取 MD5 key

 @return  key
 */
+ (NSString *)getFileKey:(NSString *)fileUri;

/*!
 根据文件类型获取文件夹名称

 @return 文件夹名称
 */
+ (NSString *)getMediaDir:(RCMediaType)fileType;

/*!
 根据会话类型获取存储的文件夹名称

 @return 文件夹名称
 */
+ (NSString *)getCateDir:(RCConversationType)categoryId;

/*!
 文件是否存在

 @return 是否存在
*/
+ (BOOL)isFileExist:(NSString *)fileName;

/*!
 存储数据到指定路径

 @param filePath 文件存储路径
 @param content  存储数据
 @return 存储成功与否的结果
 */
+ (BOOL)saveFile:(NSString *)filePath content:(NSData *)content;

/*!
 文件唯一存储地址
 */
+ (NSString *)getUniqueFileName:(NSString *)baseFileName;

/*!
 根据文件名获取文件类型

 @param fileName 文件名，需要带扩展名
 */
+ (NSString *)getTypeName:(NSString *)fileName;

/*!
 根据文件 URL 获取文件本地存储路径

 @return 文件本地存储路径
 */
+ (NSString *)getFileLocalPath:(NSString *)fileUri;

/*!
 关联文件远端 URL 和本地路径
 */
+ (void)setFileLocalPath:(NSString *)localPath fileUri:(NSString *)fileUri;
/*!
 获取小视频文件缓存路径
 */
+ (NSString *)getSightCachePath:(NSString *)sightUrl;
@end
#endif
