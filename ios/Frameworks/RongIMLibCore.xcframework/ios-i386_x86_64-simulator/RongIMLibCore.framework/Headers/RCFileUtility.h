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
 *  \~chinese
 设置文件媒体类型

 @return    文件类型
 
 *  \~english
 Set file media type.

 @ return file type.
 */
+ (NSString *)getMimeType:(RCMediaType)fileType;

/*!
 *  \~chinese
 获取上传文件名称

 @return    文件媒体类型
 
 *  \~english
 Get the name of the uploaded file.

 @ return file media type.
 */
+ (NSString *)generateKey:(NSString *)mimeType;

/*!
 *  \~chinese
 生成下载的文件路径

 @return    文件名称
 
 *  \~english
 Generate the downloaded file path.

 @ return file name.
 */
+ (NSString *)getFileName:(NSString *)imgUrl
         conversationType:(RCConversationType)conversationType
                mediaType:(RCMediaType)mediaType
                 targetId:(NSString *)targetId;

/*!
 *  \~chinese
 根据文件 URL 获取 MD5 key

 @return  key
 
 *  \~english
 Get MD5 key according to file URL.

 @ return key.
 */
+ (NSString *)getFileKey:(NSString *)fileUri;

/*!
 *  \~chinese
 根据文件类型获取文件夹名称

 @return 文件夹名称
 
 *  \~english
 Gets folder name according to file type.

 @ return folder name
 */
+ (NSString *)getMediaDir:(RCMediaType)fileType;

/*!
 *  \~chinese
 根据会话类型获取存储的文件夹名称

 @return 文件夹名称
 
 *  \~english
 Get the stored folder name based on the conversation type.

 @ return folder name.
 */
+ (NSString *)getCateDir:(RCConversationType)categoryId;

/*!
 *  \~chinese
 文件是否存在

 @return 是否存在
 
 *  \~english
 Whether the file exists.

 @ return exist or not
*/
+ (BOOL)isFileExist:(NSString *)fileName;

/*!
 *  \~chinese
 存储数据到指定路径

 @param filePath 文件存储路径
 @param content  存储数据
 @return 存储成功与否的结果
 
 *  \~english
 Store data to the specified path.

 @param filePath  File storage path.
 @param content  Store data.
 @ return store the result of success or not.
 */
+ (BOOL)saveFile:(NSString *)filePath content:(NSData *)content;

/*!
 *  \~chinese
 文件唯一存储地址
 
 *  \~english
 Unique storage address of the file.
 */
+ (NSString *)getUniqueFileName:(NSString *)baseFileName;

/*!
 *  \~chinese
 根据文件名获取文件类型

 @param fileName 文件名，需要带扩展名
 
 *  \~english
 Get the file type based on the file name.

 @param fileName File name with extension name
 */
+ (NSString *)getTypeName:(NSString *)fileName;

/*!
 *  \~chinese
 根据文件 URL 获取文件本地存储路径

 @return 文件本地存储路径
 
 *  \~english
 Get the local storage path of the file according to the file URL.

 @ return file local storage path.
 */
+ (NSString *)getFileLocalPath:(NSString *)fileUri;

/*!
 *  \~chinese
 关联文件远端 URL 和本地路径
 *
 *  \~english
 Associate file remote URL and local path.
 */
+ (void)setFileLocalPath:(NSString *)localPath fileUri:(NSString *)fileUri;
/*!
 *  \~chinese
 获取小视频文件缓存路径
 
 *  \~english
 Get the cache path of small video File.
 */
+ (NSString *)getSightCachePath:(NSString *)sightUrl;
@end
#endif
