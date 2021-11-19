//
//  RCiOSConfig.h
//  RongIMLib
//
//  Created by RongCloud on 2020/9/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCiOSConfig : NSObject

/*!
 *  \~chinese
 iOS 平台通知栏分组 ID
 相同的 thread-id 推送分为一组
 iOS10 开始支持
 
 *  \~english
 Group ID of iOS platform notification bar
 The push with same thread-id is divided into a group.
 IOS10 starts to support.
 */
@property (nonatomic, copy) NSString *threadId;

/*!
 *  \~chinese
 iOS 标识推送的类型
 如果不设置后台默认取消息类型字符串，如 RC:TxtMsg
 
 *  \~english
 Type of pushed iOS identifier
 If you do not set the background to take the message type string by default, such as RC:TxtMsg.
 */
@property (nonatomic, copy) NSString *category;

/*!
 *  \~chinese
 iOS 平台通知覆盖 ID
 apnsCollapseId 相同时，新收到的通知会覆盖老的通知，最大 64 字节
 iOS10 开始支持
 
 *  \~english
 Overriding ID of iOS platform notification
 When the apnsCollapseId is the same, the new notification will overwrite the old notification with maximum of 64 bytes.
 iOS10 starts to support it
 */
@property (nonatomic, copy) NSString *apnsCollapseId;

/*!
 *  \~chinese
 iOS 富文本推送内容
 
 *  \~english
 Content of pushed iOS rich text
 */
@property (nonatomic, copy) NSString *richMediaUri;

@end

NS_ASSUME_NONNULL_END
