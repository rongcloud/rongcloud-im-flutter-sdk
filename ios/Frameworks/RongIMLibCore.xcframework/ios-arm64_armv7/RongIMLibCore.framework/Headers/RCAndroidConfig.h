//
//  RCAndroidConfig.h
//  RongIMLib
//
//  Created by RongCloud on 2020/9/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  \~chinese
 华为推送消息级别
 *  \~english
 Huawei push level
 */
typedef NSString *RCImportanceHw NS_STRING_ENUM;

/*!
 *  \~chinese
 华为推送消息级别 NORMAL
 *  \~english
 Huawei push level : NORMAL
 */
FOUNDATION_EXPORT RCImportanceHw const RCImportanceHwNormal;

/*!
 *  \~chinese
 华为推送消息级别 LOW
 *  \~english
 Huawei push level : LOW
  */
FOUNDATION_EXPORT RCImportanceHw const RCImportanceHwLow;



@interface RCAndroidConfig : NSObject

/*!
 *  \~chinese
 Android 平台 Push 唯一标识
 目前支持小米、华为推送平台，默认开发者不需要进行设置，当消息产生推送时，消息的 messageUId 作为 notificationId 使用。
 
 *  \~english
 Unique identification of Android platform Push.
 Currently, Xiaomi and Huawei push platforms are supported. Developers need not set them by default. When a message generates a push, the messageUId of the message is used as a notificationId.
 */
@property (nonatomic, copy) NSString *notificationId;

/*!
 *  \~chinese
 小米的渠道 ID
 该条消息针对小米使用的推送渠道，如开发者集成了小米推送，需要指定 channelId 时，可向 Android 端研发人员获取，channelId 由开发者自行创建。
 
 *  \~english
 Xiaomi's channel ID.
 This message is aimed at the push channel used by Xiaomi. If the developer integrates Xiaomi push and shall specify a channelId, it can be obtained from the developer on the Android side, and the channelId is created by the developer.
 */
@property (nonatomic, copy) NSString *channelIdMi;

/*!
 *  \~chinese
 华为的渠道 ID
 该条消息针对华为使用的推送渠道，如开发者集成了华为推送，需要指定 channelId 时，可向 Android 端研发人员获取，channelId 由开发者自行创建。
 
 *  \~english
 Huawei's channel ID.
 This message is aimed at the push channel used by Huawei. If the developer integrates Huawei push and shall specify a channelId, it can be obtained from the developer on the Android side, and the channelId is created by the developer.
 */
@property (nonatomic, copy) NSString *channelIdHW;

/*!
 *  \~chinese
 OPPO 的渠道 ID
 该条消息针对 OPPO 使用的推送渠道，如开发者集成了 OPPO 推送，需要指定 channelId 时，可向 Android 端研发人员获取，channelId 由开发者自行创建。
 
 *  \~english
 OPPO Channel ID.
 This message is aimed at the push channel used by OPPO. For example, if the developer integrates OPPO push and shall specify the channelId, it can be obtained from the developer on the Android side, and the channelId is created by the developer.
 */
@property (nonatomic, copy) NSString *channelIdOPPO;

/*!
 *  \~chinese
 VIVO 推送通道类型
 开发者集成了 VIVO 推送，需要指定推送类型时，可进行设置。
 目前可选值 "0"(运营消息) 和  "1"(系统消息)
 
 *  \~english
 VIVO push channel type.
 Developers have integrated VIVO push, which can be set when you shall specify the push type.
  Currently available values "0" (operation message) and "1" (system message)
 */
@property (nonatomic, copy) NSString *typeVivo;

/*!
 *  \~chinese
 FCM 通知类型推送时所使用的分组 id
 *  \~english
 Packet id used in FCM notification type push
 */
@property (nonatomic, copy) NSString *fcmCollapseKey;

/*!
 *  \~chinese
 FCM 通知类型的推送所使用的通知图片 url
 *  \~english
 Notification image url used for push of FCM notification type
 */
@property (nonatomic, copy) NSString *fcmImageUrl;

/*!
 *  \~chinese
 华为推送消息级别
 *  \~english
 Huawei push level
 */
@property (nonatomic, copy) RCImportanceHw importanceHW;

@end

NS_ASSUME_NONNULL_END
