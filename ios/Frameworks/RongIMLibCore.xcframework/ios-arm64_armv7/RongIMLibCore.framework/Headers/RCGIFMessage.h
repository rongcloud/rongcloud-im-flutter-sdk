//
//  RCGIFMessage.h
//  RongIMLib
//
//  Created by liyan on 2018/12/20.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  \~chinese
 GIF 消息的类型名
 
 *  \~english
 Type name of the GIF message
 */
#define RCGIFMessageTypeIdentifier @"RC:GIFMsg"
/*!
 *  \~chinese
 GIF 消息
 @discussion  GIF 消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 
 *  \~english
 GIF message.
 @ discussion GIF message class, which is stored and counted as unread messages.
  
  @ remarks content class message.
 */
@interface RCGIFMessage : RCMediaMessageContent

/*!
 *  \~chinese
 GIF 图的大小，单位字节
 
 *  \~english
 The size of the GIF graph, in bytes
 */
@property (nonatomic, assign) long long gifDataSize;

/*!
 *  \~chinese
 GIF 图的宽
 
 *  \~english
 The width of GIF graphs
 */
@property (nonatomic, assign) long width;

/*!
 *  \~chinese
 GIF 图的高
 
 *  \~english
 The height of GIF graph
 */
@property (nonatomic, assign) long height;

/*!
 *  \~chinese
 初始化 GIF 消息

 @param gifImageData    GIF 图的数据
 @param width           GIF 的宽
 @param height          GIF 的高

 @return                GIF 消息对象
 
 *  \~english
 Initialize GIF messages.

 @param gifImageData Data of GIF diagram.
 @param width Width of GIF.
 @param height The height of GIF.

 @ return GIF message object.
 */
+ (instancetype)messageWithGIFImageData:(NSData *)gifImageData width:(long)width height:(long)height;

/*!
 *  \~chinese
 初始化 GIF 消息

 @param gifURI          GIF 的本地路径
 @param width           GIF 的宽
 @param height          GIF 的高

 @return                GIF 消息对象
 
 *  \~english
 Initialize GIF messages.

 @param gifURI Local path to GIF.
 @param width Width of GIF.
 @param height The height of GIF.

 @ return GIF message object.
 */
+ (instancetype)messageWithGIFURI:(NSString *)gifURI width:(long)width height:(long)height;

@end

NS_ASSUME_NONNULL_END
