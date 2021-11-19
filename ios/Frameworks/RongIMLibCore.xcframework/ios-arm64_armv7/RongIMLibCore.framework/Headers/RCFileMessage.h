//
//  RCFileMessage.h
//  RongIMLib
//
//  Created by RongCloud on 16/5/23.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

/*!
 *  \~chinese
 文件消息的类型名
 
 *  \~english
 The type name of the file message
 */
#define RCFileMessageTypeIdentifier @"RC:FileMsg"
/*!
 *  \~chinese
 文件消息类
 
 @discussion 文件消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 File message class.

 @ discussion file message class, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCFileMessage : RCMediaMessageContent <NSCoding>

/*!
 *  \~chinese
 文件名
 
 *  \~english
 File name
 */
@property (nonatomic, copy) NSString *name;

/*!
 *  \~chinese
 文件大小，单位为 Byte
 
 *  \~english
 File size in Byte
 */
@property (nonatomic, assign) long long size;

/*!
 *  \~chinese
 文件类型
 
 *  \~english
 File type
 */
@property (nonatomic, copy) NSString *type;

/*!
 *  \~chinese
 文件的网络地址
 
 *  \~english
 The network address of the file
 */
@property (nonatomic, copy) NSString *fileUrl;

/*!
 *  \~chinese
 文件的本地路径
 
 *  \~english
 Local path to the file
 */
@property (nonatomic, copy) NSString *localPath;

/*!
 *  \~chinese
 初始化文件消息

 @param localPath 文件的本地路径
 @return          文件消息对象
 
 *  \~english
 Initialize file message.

 @param localPath Local path to the file.
 @ return file message object.
 */
+ (instancetype)messageWithFile:(NSString *)localPath;

@end
