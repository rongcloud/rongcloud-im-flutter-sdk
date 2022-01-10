//
//  RCiOSConfig.h
//  RongIMLib
//
//  Created by 孙浩 on 2020/9/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCiOSConfig : NSObject

/*!
 iOS 平台通知栏分组 ID
 相同的 thread-id 推送分为一组
 iOS10 开始支持
 */
@property (nonatomic, copy) NSString *threadId;

/*!
 iOS 标识推送的类型
 如果不设置后台默认取消息类型字符串，如 RC:TxtMsg
 */
@property (nonatomic, copy) NSString *category;

/*!
 iOS 平台通知覆盖 ID
 apnsCollapseId 相同时，新收到的通知会覆盖老的通知，最大 64 字节
 iOS10 开始支持
 */
@property (nonatomic, copy) NSString *apnsCollapseId;

/*!
 iOS 富文本推送内容
 */
@property (nonatomic, copy) NSString *richMediaUri;

@end

NS_ASSUME_NONNULL_END
