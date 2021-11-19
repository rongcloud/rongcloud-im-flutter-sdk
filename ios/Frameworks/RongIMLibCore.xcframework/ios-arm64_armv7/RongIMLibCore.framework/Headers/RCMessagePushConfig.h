//
//  RCMessagePushConfig.h
//  RongIMLib
//
//  Created by RongCloud on 2020/9/15.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCiOSConfig.h"
#import "RCAndroidConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMessagePushConfig : NSObject

/*!
 *  \~chinese
 是否屏蔽通知标题
 YES:  不显示通知标题
 NO: 显示通知标题
 
 @discussion 默认情况下融云单聊消息通知标题为用户名、群聊消息为群名称，设置后不会再显示通知标题。
 @discussion 此属性只针目标用户为 iOS 平台时有效，Android 第三方推送平台的通知标题为必填项，所以暂不支持。
 
 *  \~english
 Whether to block the notification title.
 YES:  Do not display notification title.
 NO: Show notification title.

 @ discussion By default, the notification title of RongCloud single chat message is user name, and the group chat message is group name. After setting, the notification title will no longer be displayed.
  @ discussion This attribute is valid only when the target user is iOS platform. The notification title of Android third-party push platform is required, so it is not supported for the time being.
 */
@property (nonatomic, assign) BOOL disablePushTitle;

/*!
 *  \~chinese
 推送标题
 如果没有设置，会使用下面的默认标题显示规则
 默认标题显示规则：
    内置消息：单聊通知标题显示为发送者名称，群聊通知标题显示为群名称。
    自定义消息：默认不显示标题。
 
 *  \~english
 Push title.
 If it is not set, the following default title is used to display the rule.
 The default title display rules:
     Built-in message: The single chat notification title is displayed as the sender name, and the group chat notification title is displayed as the group name.
     Custom message: the title is not displayed by default.
 */
@property (nonatomic, copy) NSString *pushTitle;

/*!
 *  \~chinese
 推送内容
 优先使用 MessagePushConfig 的 pushContent，如果没有，则使用 sendMessage 或者 sendMediaMessage 的 pushContent。
 
 *  \~english
 Push content
 Give priority to pushContent for MessagePushConfig, if not, use pushContent for sendMessage or sendMediaMessage.
 */
@property (nonatomic, copy) NSString *pushContent;

/*!
 *  \~chinese
 远程推送附加信息
 优先使用 MessagePushConfig 的 pushData，如果没有，则使用 sendMessage 或者 sendMediaMessage 的 pushData。
 
 *  \~english
 Remotely push additional information.
 Give priority to pushData for MessagePushConfig, if not, use pushData for sendMessage or sendMediaMessage.
 */
@property (nonatomic, copy) NSString *pushData;

/*!
 *  \~chinese
 是否强制显示通知详情
 当目标用户通过 RCPushProfile 中的 updateShowPushContentStatus 设置推送不显示消息详情时，可通过此参数，强制设置该条消息显示推送详情。
 
 *  \~english
 Whether to force the display of notification details.
 When the target user does not display the message details through the updateShowPushContentStatus setting in RCPushProfile, you can use this parameter to force the message to display the push details.
 */
@property (nonatomic, assign) BOOL forceShowDetailContent;

/*!
 *  \~chinese
 推送模板 ID，设置后根据目标用户通过 SDK RCPushProfile 中的 setPushLauguageCode 设置的语言环境，匹配模板中设置的语言内容进行推送，未匹配成功时使用默认内容进行推送，模板内容在“开发者后台-自定义推送文案”中进行设置。
 注：RCMessagePushConfig 中的 Title 和 PushContent 优先级高于模板 ID（templateId）中对应的标题和推送内容。
 
 *  \~english
 After the ID of the push template is set, the language content set in the template is matched according to the locale set by the target user through the setPushLauguageCode in SDK RCPushProfile. If the match is not successful, the default content is pushed. The template content is set in "developer backend-Custom push copy".
  Note: The Title and PushContent in RCMessagePushConfig take precedence over the corresponding title and push content in the template ID (templateId).
 */
@property (nonatomic, copy) NSString *templateId;

/*!
 *  \~chinese
 iOS 平台相关配置
 
 *  \~english
 Configuration related to iOS platform
 */
@property (nonatomic, strong) RCiOSConfig *iOSConfig;

/*!
 *  \~chinese
 Android 平台相关配置
 
 *  \~english
 Configuration related to Android platform
 */
@property (nonatomic, strong) RCAndroidConfig *androidConfig;

/*!
 *  \~chinese
 将数组转成 messagePushConfig 的 iOSConfig 和 AndroidConfig
 
 *  \~english
 Convert arrays to iOSConfig and AndroidConfig of messagePushConfig.
 */
- (instancetype)arrayToConfig:(NSArray *)array;

/*!
 *  \~chinese
 将 iOSConfig 和  AndroidConfig 转成数组
 
 *  \~english
 Convert iOSConfig and AndroidConfig to an array.
 */
- (NSArray *)encodeIOSAndAndroidConfig;

@end

NS_ASSUME_NONNULL_END
