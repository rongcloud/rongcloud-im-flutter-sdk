/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RongCoreClient.h
//  Created by xugang on 14/12/23.

#ifndef __RongCoreClient
#define __RongCoreClient
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCConversation.h"
#import "RCMessage.h"
#import "RCPushProfile.h"
#import "RCSearchConversationResult.h"
#import "RCStatusDefine.h"
#import "RCUploadImageStatusListener.h"
#import "RCUploadMediaStatusListener.h"
#import "RCUserInfo.h"
#import "RCUserOnlineStatusInfo.h"
#import "RCWatchKitStatusDelegate.h"
#import "RCSendMessageOption.h"
#import "RCRemoteHistoryMsgOption.h"
#import "RCIMClientProtocol.h"
#import "RCTagInfo.h"
#import "RCConversationIdentifier.h"
#import "RCConversationTagInfo.h"
#import "RCTagProtocol.h"
#import "RCImageCompressConfig.h"
#import "RCHistoryMessageOption.h"
#import "RCClearConversationOption.h"
/*!
 @const 收到已读回执的 Notification

 @discussion 收到消息已读回执之后，IMLibCore 会分发此通知。

 Notification 的 object 为 nil，userInfo 为 NSDictionary 对象，
 其中 key 值分别为 @"cType"、@"tId"、@"messageTime",
 对应的 value 为会话类型的 NSNumber 对象 、会话的 targetId 、已阅读的最后一条消息的 sendTime。
 如：
 NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
 NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
 NSString *targetId = [notification.userInfo objectForKey:@"tId"];
 NSString *channelId = [notification.userInfo objectForKey:@"cId"];
 NSString *fromUserId = [notification.userInfo objectForKey:@"fId"];

 收到这个消息之后可以更新这个会话中 messageTime 以前的消息 UI 为已读（底层数据库消息状态已经改为已读）。

 @remarks 事件监听
 */
FOUNDATION_EXPORT NSString *const RCLibDispatchReadReceiptNotification;

#pragma mark - IMLibCore 核心类

/*!
 融云 IMLibCore 核心类

 @discussion 您需要通过 sharedCoreClient 方法，获取单例对象。
 */
@interface RCCoreClient : NSObject

/*!
 获取融云通讯能力库 IMLibCore 的核心类单例

 @return 融云通讯能力库 IMLibCore 的核心单例类

 @discussion 您可以通过此方法，获取 IMLibCore 的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedCoreClient;

#pragma mark - SDK初始化
/*!
 初始化融云 SDK

 @param appKey  从融云开发者平台创建应用后获取到的 App Key
 @discussion 初始化后，SDK 会监听 app 生命周期， 用于判断应用处于前台、后台，根据前后台状态调整链接心跳
 @discussion
 您在使用融云 SDK 所有功能（ 包括显示 SDK 中或者继承于 SDK 的 View ）之前，您必须先调用此方法初始化 SDK。
 在 App 整个生命周期中，您只需要执行一次初始化。

 **升级说明:**
 **从2.4.1版本开始，为了兼容 Swift 的风格与便于使用，将原有的 init: 方法升级为此方法，方法的功能和使用均不变。**

 @warning 如果您使用 IMLibCore，请使用此方法初始化 SDK；
 如果您使用 IMKit，请使用 RCIM 中的同名方法初始化，而不要使用此方法。

 @remarks 连接
 */
- (void)initWithAppKey:(NSString *)appKey;

/*!
设置 deviceToken（已兼容 iOS 13），用于远程推送

@param deviceTokenData     从系统获取到的设备号 deviceTokenData  (不需要处理)

@discussion
deviceToken 是系统提供的，从苹果服务器获取的，用于 APNs 远程推送必须使用的设备唯一值。
您需要将 -application:didRegisterForRemoteNotificationsWithDeviceToken: 获取到的 deviceToken 作为参数传入此方法。

如:

   - (void)application:(UIApplication *)application
   didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
       [[RCCoreClient sharedCoreClient] setDeviceTokenData:deviceToken];
   }
@remarks 功能设置
*/
- (void)setDeviceTokenData:(NSData *)deviceTokenData;

/*!
 设置 deviceToken，用于远程推送

 @param deviceToken     从系统获取到的设备号 deviceToken

 @discussion
 deviceToken 是系统提供的，从苹果服务器获取的，用于 APNs 远程推送必须使用的设备唯一值。
 您需要将 -application:didRegisterForRemoteNotificationsWithDeviceToken: 获取到的
 deviceToken，转换成十六进制字符串，作为参数传入此方法。

 如:

    - (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        NSString *token = [self getHexStringForData:deviceToken];
        [[RCCoreClient sharedCoreClient] setDeviceToken:token];
    }

    - (NSString *)getHexStringForData:(NSData *)data {
        NSUInteger len = [data length];
        char *chars = (char *)[data bytes];
        NSMutableString *hexString = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i < len; i ++) {
            [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
        }
        return hexString;
     }

 @remarks 功能设置
 */
- (void)setDeviceToken:(NSString *)deviceToken;

#pragma mark - 设置导航服务器和上传文件服务器(仅限独立数据中心使用，使用前必须先联系商务开通)

/*!
 设置导航服务器和上传文件服务器信息

 @param naviServer     导航服务器地址，具体的格式参考下面的说明
 @param fileServer     文件服务器地址，具体的格式参考下面的说明
 @return            是否设置成功

 @warning 仅限独立数据中心使用，使用前必须先联系商务开通。必须在 SDK init 之前进行设置。
 @discussion
 naviServer 必须为有效的服务器地址，fileServer 如果想使用默认的，可以传 nil。
 naviServer 和 fileServer 的格式说明：
 1、如果使用 https，则设置为 https://cn.xxx.com:port 或 https://cn.xxx.com 格式，其中域名部分也可以是
 IP，如果不指定端口，将默认使用 443 端口。
 2、如果使用 http，则设置为 cn.xxx.com:port 或 cn.xxx.com 格式，其中域名部分也可以是 IP，如果不指定端口，将默认使用 80
 端口。（iOS 默认只能使⽤ HTTPS 协议。如果您使⽤ http 协议，请参考 iOS 开发
 ⽂档中的 ATS 设置说明。链接如下：https://support.rongcloud.cn/ks/OTQ1 ）

 @remarks 功能设置
 */
- (BOOL)setServerInfo:(NSString *)naviServer fileServer:(NSString *)fileServer;

/**
 设置统计服务器的信息

 @param statisticServer 统计服务器地址，具体的格式参考下面的说明
 @return 是否设置成功

 @warning 仅限独立数据中心使用，使用前必须先联系商务开通。必须在 SDK init 和 setDeviceToken 之前进行设置。
 @discussion
 statisticServer 必须为有效的服务器地址，否则会造成推送等业务不能正常使用。
 格式说明：
 1、如果使用 https，则设置为 https://cn.xxx.com:port 或 https://cn.xxx.com 格式，其中域名部分也可以是
 IP，如果不指定端口，将默认使用 443 端口。
 2、如果使用 http，则设置为 cn.xxx.com:port 或 cn.xxx.com 格式，其中域名部分也可以是 IP，如果不指定端口，将默认使用 80
 端口。（iOS 默认只能使⽤ HTTPS 协议。如果您使⽤ http 协议，请参考 iOS 开发
 ⽂档中的 ATS 设置说明。链接如下：https://support.rongcloud.cn/ks/OTQ1 ）

 @remarks 功能设置
 */
- (BOOL)setStatisticServer:(NSString *)statisticServer;

#pragma mark - 连接与断开服务器

/*!
 与融云服务器建立连接

 @param token                   从您服务器端获取的 token (用户身份令牌)
 @param dbOpenedBlock                本地消息数据库打开的回调
 @param successBlock            连接建立成功的回调 [ userId: 当前连接成功所用的用户 ID]
 @param errorBlock              连接建立失败的回调，触发该回调代表 SDK 无法继续重连 [errorCode: 连接失败的错误码]

 @discussion 调用该接口，SDK 会在连接失败之后尝试重连，直到连接成功或者出现 SDK 无法处理的错误（如 token 非法）。
 如果您不想一直进行重连，可以使用 connectWithToken:timeLimit:dbOpened:success:error: 接口并设置连接超时时间 timeLimit。
 
 @discussion 连接成功后，SDK 将接管所有的重连处理。当因为网络原因断线的情况下，SDK 会不停重连直到连接成功为止，不需要您做额外的连接操作。

 对于 errorBlock 需要特定关心 tokenIncorrect 的情况：
 一是 token 错误，请您检查客户端初始化使用的 AppKey 和您服务器获取 token 使用的 AppKey 是否一致；
 二是 token 过期，是因为您在开发者后台设置了 token 过期时间，您需要请求您的服务器重新获取 token 并再次用新的 token 建立连接。
 在此种情况下，您需要请求您的服务器重新获取 token 并建立连接，但是注意避免无限循环，以免影响 App 用户体验。

 @warning 如果您使用 IMLibCore，请使用此方法建立与融云服务器的连接；
 如果您使用 IMKit，请使用 RCIM 中的同名方法建立与融云服务器的连接，而不要使用此方法。

 此方法的回调并非为原调用线程，您如果需要进行 UI 操作，请注意切换到主线程。
 */
- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock;

/*!
 与融云服务器建立连接

 @param token                   从您服务器端获取的 token (用户身份令牌)
 @param timeLimit               SDK 连接的超时时间，单位: 秒
                        timeLimit <= 0，SDK 会一直连接，直到连接成功或者出现 SDK 无法处理的错误（如 token 非法）。
                        timeLimit > 0，SDK 最多连接 timeLimit 秒，超时时返回 RC_CONNECT_TIMEOUT 错误，并不再重连。
 @param dbOpenedBlock                本地消息数据库打开的回调
 @param successBlock            连接建立成功的回调 [ userId: 当前连接成功所用的用户 ID]
 @param errorBlock              连接建立失败的回调，触发该回调代表 SDK 无法继续重连 [errorCode: 连接失败的错误码]
 
 @discussion 调用该接口，SDK 会在 timeLimit 秒内尝试重连，直到出现下面三种情况之一：
 第一、连接成功，回调 successBlock(userId)。
 第二、超时，回调 errorBlock(RC_CONNECT_TIMEOUT)。
 第三、出现 SDK 无法处理的错误，回调 errorBlock(errorCode)（如 token 非法）。
 
 @discussion 连接成功后，SDK 将接管所有的重连处理。当因为网络原因断线的情况下，SDK 会不停重连直到连接成功为止，不需要您做额外的连接操作。

 对于 errorBlock 需要特定关心 tokenIncorrect 的情况：
 一是 token 错误，请您检查客户端初始化使用的 AppKey 和您服务器获取 token 使用的 AppKey 是否一致；
 二是 token 过期，是因为您在开发者后台设置了 token 过期时间，您需要请求您的服务器重新获取 token 并再次用新的 token 建立连接。
 在此种情况下，您需要请求您的服务器重新获取 token 并建立连接，但是注意避免无限循环，以免影响 App 用户体验。

 @warning 如果您使用 IMLibCore，请使用此方法建立与融云服务器的连接；
 如果您使用 IMKit，请使用 RCIM 中的同名方法建立与融云服务器的连接，而不要使用此方法。

 此方法的回调并非为原调用线程，您如果需要进行 UI 操作，请注意切换到主线程。
 */
- (void)connectWithToken:(NSString *)token
               timeLimit:(int)timeLimit
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock;

/*!
 断开与融云服务器的连接

 @param isReceivePush   App 在断开连接之后，是否还接收远程推送

 @discussion
 因为 SDK 在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的 App 逻辑需要登出，否则一般不需要调用此方法进行手动断开。

 @warning 如果您使用 IMLibCore，请使用此方法断开与融云服务器的连接；
 如果您使用 IMKit，请使用 RCIM 中的同名方法断开与融云服务器的连接，而不要使用此方法。

 isReceivePush 指断开与融云服务器的连接之后，是否还接收远程推送。
 [[RCCoreClient sharedCoreClient] disconnect:YES] 与 [[RCCoreClient sharedCoreClient]
 disconnect] 完全一致；
 [[RCCoreClient sharedCoreClient] disconnect:NO] 与[ [RCCoreClient sharedCoreClient]
 logout] 完全一致。
 您只需要按照您的需求，使用 disconnect: 与 disconnect 以及 logout 三个接口其中一个即可。

 @remarks 连接
 */
- (void)disconnect:(BOOL)isReceivePush;

/*!
 断开与融云服务器的连接，但仍然接收远程推送

 @discussion
 因为 SDK 在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的 App 逻辑需要登出，否则一般不需要调用此方法进行手动断开。

 @warning 如果您使用 IMLibCore，请使用此方法断开与融云服务器的连接；
 如果您使用 IMKit，请使用 RCIM 中的同名方法断开与融云服务器的连接，而不要使用此方法。

 [[RCCoreClient sharedCoreClient] disconnect:YES] 与 [[RCCoreClient sharedCoreClient]
 disconnect] 完全一致；
 [[RCCoreClient sharedCoreClient] disconnect:NO] 与 [[RCCoreClient sharedCoreClient]
 logout] 完全一致。
 您只需要按照您的需求，使用 disconnect: 与 disconnect 以及 logout 三个接口其中一个即可。

 @remarks 连接
 */
- (void)disconnect;

/*!
 断开与融云服务器的连接，并不再接收远程推送

 @discussion
 因为 SDK 在前后台切换或者网络出现异常都会自动重连，会保证连接的可靠性。
 所以除非您的 App 逻辑需要登出，否则一般不需要调用此方法进行手动断开。

 @warning 如果您使用 IMKit，请使用此方法断开与融云服务器的连接；
 如果您使用 IMLibCore，请使用 RCCoreClient 中的同名方法断开与融云服务器的连接，而不要使用此方法。

 [[RCCoreClient sharedCoreClient] disconnect:YES] 与 [[RCCoreClient sharedCoreClient]
 disconnect] 完全一致；
 [[RCCoreClient sharedCoreClient] disconnect:NO] 与 [[RCCoreClient sharedCoreClient]
 logout] 完全一致。
 您只需要按照您的需求，使用 disconnect: 与 disconnect 以及 logout 三个接口其中一个即可。

 @remarks 连接
 */
- (void)logout;

/**
 设置断线重连时是否踢出当前正在重连的设备

 @discussion
 用户没有开通多设备登录功能的前提下，同一个账号在一台新设备上登录的时候，会把这个账号在之前登录的设备上踢出。
 由于 SDK 有断线重连功能，存在下面情况。
 用户在 A 设备登录，A 设备网络不稳定，没有连接成功，SDK 启动重连机制。
 用户此时又在 B 设备登录，B 设备连接成功。
 A 设备网络稳定之后，用户在 A 设备连接成功，B 设备被踢出。
 这个接口就是为这种情况加的。
 设置 enable 为 YES 时，SDK 重连的时候发现此时已有别的设备连接成功，不再强行踢出已有设备，而是踢出重连设备。

 @param enable 是否踢出重连设备

 @remarks 功能设置
 */
- (void)setReconnectKickEnable:(BOOL)enable;

#pragma mark - 连接状态监听

/*!
 设置 IMLibCore 的连接状态监听器

 @param delegate    IMLibCore 连接状态监听器

 @warning 如果您使用 IMLibCore，可以设置并实现此 Delegate 监听连接状态变化；
 如果您使用 IMKit，请使用 RCIM 中的 connectionStatusDelegate 监听连接状态变化，而不要使用此方法，否则会导致 IMKit
 中无法自动更新 UI！

 @remarks 功能设置
 */
- (void)setRCConnectionStatusChangeDelegate:(id<RCConnectionStatusChangeDelegate>)delegate;

/*!
 添加 IMLib 连接状态监听

 @param delegate 代理
 */
- (void)addConnectionStatusChangeDelegate:(id<RCConnectionStatusChangeDelegate>)delegate;

/*!
 移除 IMLib 连接状态监听

 @param delegate 代理
 */
- (void)removeConnectionStatusChangeDelegate:(id<RCConnectionStatusChangeDelegate>)delegate;

/*!
 获取当前 SDK 的连接状态

 @return 当前 SDK 的连接状态

 @remarks 数据获取
 */
- (RCConnectionStatus)getConnectionStatus;

/*!
 获取当前的网络状态

 @return 当前的网路状态

 @remarks 数据获取
 */
- (RCNetworkStatus)getCurrentNetworkStatus;

/*!
 SDK 当前所处的运行状态

 @remarks 数据获取
 */
@property (nonatomic, assign, readonly) RCSDKRunningMode sdkRunningMode;

#pragma mark - Apple Watch 状态监听

/*!
 用于 Apple Watch 的 IMLibCore 事务监听器

 @remarks 功能设置
 */
@property (nonatomic, strong) id<RCWatchKitStatusDelegate> watchKitStatusDelegate __deprecated_msg("已废弃");

/*!
 媒体文件下载拦截器

 @remarks 功能设置
 */
@property (nonatomic, weak) id<RCDownloadInterceptor> downloadInterceptor;

#pragma mark - 阅后即焚监听

/**
 设置 IMLibCore 的阅后即焚监听器

 @param delegate 阅后即焚监听器
 @discussion 可以设置并实现此 Delegate 监听消息焚烧
 @warning 如果您使用 IMKit，请不要使用此监听器，否则会导致 IMKit 中无法自动更新 UI！

 @remarks 功能设置
 */
- (void)setRCMessageDestructDelegate:(id<RCMessageDestructDelegate>)delegate;

#pragma mark - 用户信息

/*!
 当前登录用户的用户信息

 @discussion 用于与融云服务器建立连接之后，设置当前用户的用户信息。

 @warning 如果传入的用户信息中的用户 ID 与当前登录的用户 ID 不匹配，则将会忽略。
 如果您使用 IMLibCore，请使用此字段设置当前登录用户的用户信息；
 如果您使用 IMKit，请使用 RCIM 中的 currentUserInfo 设置当前登录用户的用户信息，而不要使用此字段。

 @remarks 数据获取
 */
@property (nonatomic, strong) RCUserInfo *currentUserInfo;

#pragma mark - 消息接收与发送

/*!
 注册自定义的消息类型

 @param messageClass    自定义消息的类，该自定义消息需要继承于 RCMessageContent

 @discussion
 如果您需要自定义消息，必须调用此方法注册该自定义消息的消息类型，否则 SDK 将无法识别和解析该类型消息。
 @discussion 请在初始化 appkey 之后，token 连接之前调用该方法注册自定义消息

 @warning 如果您使用 IMLibCore，请使用此方法注册自定义的消息类型；
 如果您使用 IMKit，请使用 RCIM 中的同名方法注册自定义的消息类型，而不要使用此方法。

 @remarks 消息操作
 */
- (void)registerMessageType:(Class)messageClass;

#pragma mark 消息发送

/*!
 发送消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock        消息发送成功的回调 [messageId: 消息的 ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode: 发送失败的错误码,
 messageId:消息的ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent ，用于显示；二是 pushData ，用于携带不显示的数据。

 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil ，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。

 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 @warning 如果您使用 IMLibCore，可以使用此方法发送消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送消息，否则不会自动更新 UI。

 @remarks 消息操作
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 发送消息

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param option              消息的相关配置
 @param successBlock        消息发送成功的回调 [messageId: 消息的 ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode: 发送失败的错误码,
 messageId: 消息的 ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent，用于显示；二是 pushData，用于携带不显示的数据。

 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。

 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。

 @warning 如果您使用 IMLibCore，可以使用此方法发送消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送消息，否则不会自动更新 UI。

 @remarks 消息操作
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                    option:(RCSendMessageOption *)option
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 发送媒体消息（图片消息或文件消息）

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的 ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的 ID]
 @return                    发送的消息实体

 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent，用于显示；二是 pushData，用于携带不显示的数据。

 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。

 如果您需要上传图片到自己的服务器，需要构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 如果您需要上传文件到自己的服务器，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 @warning 如果您使用 IMLibCore，可以使用此方法发送媒体消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送媒体消息，否则不会自动更新 UI。

 @remarks 消息操作
 */
- (RCMessage *)sendMediaMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
                         cancel:(void (^)(long messageId))cancelBlock;

/*!
 发送媒体消息(上传图片或文件等媒体信息到指定的服务器)

 @param conversationType    发送消息的会话类型
 @param targetId            发送消息的会话 ID
 @param content             消息的内容
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param uploadPrepareBlock  媒体文件上传进度更新的 IMKit 监听
 [uploadListener:当前的发送进度监听，SDK 通过此监听更新 IMKit UI]
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0
 <= progress <= 100, messageId:消息的ID]
 @param successBlock        消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock          消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]
 @param cancelBlock         用户取消了消息发送的回调 [messageId:消息的 ID]
 @return                    发送的消息实体

 @discussion 此方法仅用于 IMKit。
 如果您需要上传图片到自己的服务器并使用 IMLibCore，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 如果您需要上传文件到自己的服务器并使用 IMLibCore，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。

 @remarks 消息操作
 */
- (RCMessage *)sendMediaMessage:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                        content:(RCMessageContent *)content
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                  uploadPrepare:(void (^)(RCUploadMediaStatusListener *uploadListener))uploadPrepareBlock
                       progress:(void (^)(int progress, long messageId))progressBlock
                        success:(void (^)(long messageId))successBlock
                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock
                         cancel:(void (^)(long messageId))cancelBlock;

/*!
 发送消息
 
 @param message             将要发送的消息实体（需要保证 message 中的 conversationType，targetId，messageContent 是有效值)
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock        消息发送成功的回调 [successMessage: 消息实体]
 @param errorBlock          消息发送失败的回调 [nErrorCode: 发送失败的错误码, errorMessage:消息实体]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent ，用于显示；二是 pushData ，用于携带不显示的数据。
 
 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil ，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。
 
 如果您使用此方法发送图片消息，需要您自己实现图片的上传，构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。
 
 如果您使用此方法发送文件消息，需要您自己实现文件的上传，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用此方法发送。
 
 @warning 如果您使用 IMLibCore，可以使用此方法发送消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送消息，否则不会自动更新 UI。
 
 @remarks 消息操作
 */
- (RCMessage *)sendMessage:(RCMessage *)message
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
              successBlock:(void (^)(RCMessage *successMessage))successBlock
                errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock;

/*!
 发送媒体消息（图片消息或文件消息）
 
 @param message             将要发送的消息实体（需要保证 message 中的 conversationType，targetId，messageContent 是有效值)
 @param pushContent         接收方离线时需要显示的远程推送内容
 @param pushData            接收方离线时需要在远程推送中携带的非显示数据
 @param progressBlock       消息发送进度更新的回调 [progress:当前的发送进度, 0 <= progress <= 100, progressMessage:消息实体]
 @param successBlock        消息发送成功的回调 [successMessage:消息实体]
 @param errorBlock          消息发送失败的回调 [nErrorCode:发送失败的错误码, errorMessage:消息实体]
 @param cancelBlock         用户取消了消息发送的回调 [cancelMessage:消息实体]
 @return                    发送的消息实体
 
 @discussion 当接收方离线并允许远程推送时，会收到远程推送。
 远程推送中包含两部分内容，一是 pushContent，用于显示；二是 pushData，用于携带不显示的数据。
 
 SDK 内置的消息类型，如果您将 pushContent 和 pushData 置为 nil，会使用默认的推送格式进行远程推送。
 自定义类型的消息，需要您自己设置 pushContent 和 pushData 来定义推送内容，否则将不会进行远程推送。
 
 如果您需要上传图片到自己的服务器，需要构建一个 RCImageMessage 对象，
 并将 RCImageMessage 中的 imageUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 如果您需要上传文件到自己的服务器，构建一个 RCFileMessage 对象，
 并将 RCFileMessage 中的 fileUrl 字段设置为上传成功的 URL 地址，然后使用 RCCoreClient 的
 sendMessage:targetId:content:pushContent:pushData:success:error:方法
 或 sendMessage:targetId:content:pushContent:success:error:方法进行发送，不要使用此方法。
 
 @warning 如果您使用 IMLibCore，可以使用此方法发送媒体消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送媒体消息，否则不会自动更新 UI。
 
 @remarks 消息操作
 */
- (RCMessage *)sendMediaMessage:(RCMessage *)message
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, RCMessage *progressMessage))progressBlock
                   successBlock:(void (^)(RCMessage *successMessage))successBlock
                     errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock
                         cancel:(void (^)(RCMessage *cancelMessage))cancelBlock;



/*!
 取消发送中的媒体信息

 @param messageId           媒体消息的 messageId

 @return YES 表示取消成功，NO 表示取消失败，即已经发送成功或者消息不存在。

 @remarks 消息操作
 */
- (BOOL)cancelSendMediaMessage:(long)messageId;

/*!
 插入向外发送的消息（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @return             插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。

 @remarks 消息操作
 */
- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                          sentStatus:(RCSentStatus)sentStatus
                             content:(RCMessageContent *)content;

/*!
 插入向外发送的、指定时间的消息（此方法如果 sentTime 有问题会影响消息排序，慎用！！）
（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @param sentTime            消息发送的 Unix 时间戳，单位为毫秒（传 0 会按照本地时间插入）
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。如果 sentTime<=0，则被忽略，会以插入时的时间为准。

 @remarks 消息操作
 */
- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                          sentStatus:(RCSentStatus)sentStatus
                             content:(RCMessageContent *)content
                            sentTime:(long long)sentTime;

/*!
 插入接收的消息（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param senderUserId        发送者 ID
 @param receivedStatus      接收状态
 @param content             消息的内容
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。

 @remarks 消息操作
 */
- (RCMessage *)insertIncomingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                        senderUserId:(NSString *)senderUserId
                      receivedStatus:(RCReceivedStatus)receivedStatus
                             content:(RCMessageContent *)content;


/*!
 插入接收的消息（此方法如果 sentTime
 有问题会影响消息排序，慎用！！）（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param senderUserId        发送者 ID
 @param receivedStatus      接收状态
 @param content             消息的内容
 @param sentTime            消息发送的 Unix 时间戳，单位为毫秒 （传 0 会按照本地时间插入）
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。

 @remarks 消息操作
 */
- (RCMessage *)insertIncomingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                        senderUserId:(NSString *)senderUserId
                      receivedStatus:(RCReceivedStatus)receivedStatus
                             content:(RCMessageContent *)content
                            sentTime:(long long)sentTime;


/*!
 批量插入接收的消息（该消息只插入本地数据库，实际不会发送给服务器和对方）
 RCMessage 下列属性会被入库，其余属性会被抛弃
 conversationType    会话类型
 targetId            会话 ID
 messageDirection    消息方向
 senderUserId        发送者 ID
 receivedStatus      接收状态；消息方向为接收方，并且 receivedStatus 为 ReceivedStatus_UNREAD 时，该条消息未读
 sentStatus          发送状态
 content             消息的内容
 sentTime            消息发送的 Unix 时间戳，单位为毫秒 ，会影响消息排序
 extra            RCMessage 的额外字段
 
 @discussion 此方法不支持聊天室的会话类型。每批最多处理  500 条消息，超过 500 条返回 NO
 @discussion 消息的未读会累加到回话的未读数上

 @remarks 消息操作
 */
- (BOOL)batchInsertMessage:(NSArray<RCMessage *> *)msgs;

/*!
 根据文件 URL 地址下载文件内容

 @param fileName            指定的文件名称 需要开发者指定文件后缀 (例如 rongCloud.mov)
 @param mediaUrl            文件的 URL 地址
 @param progressBlock       文件下载进度更新的回调 [progress:当前的下载进度, 0 <= progress <= 100]
 @param successBlock        下载成功的回调[mediaPath:下载成功后本地存放的文件路径 文件路径为文件消息的默认地址]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调

 @discussion 用来获取媒体原文件时调用。如果本地缓存中包含此文件，则从本地缓存中直接获取，否则将从服务器端下载。

 @remarks 多媒体下载
*/
- (void)downloadMediaFile:(NSString *)fileName
                 mediaUrl:(NSString *)mediaUrl
                 progress:(void (^)(int progress))progressBlock
                  success:(void (^)(NSString *mediaPath))successBlock
                    error:(void (^)(RCErrorCode errorCode))errorBlock
                   cancel:(void (^)(void))cancelBlock;

/*!
 下载消息内容中的媒体信息

 @param conversationType    消息的会话类型
 @param targetId            消息的会话 ID
 @param mediaType           消息内容中的多媒体文件类型，目前仅支持图片
 @param mediaUrl            多媒体文件的网络 URL
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0
 <= progress <= 100]
 @param successBlock        下载成功的回调
 [mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调

 @discussion 用来获取媒体原文件时调用。如果本地缓存中包含此文件，则从本地缓存中直接获取，否则将从服务器端下载。
 @remarks 多媒体下载
 */
- (void)downloadMediaFile:(RCConversationType)conversationType
                 targetId:(NSString *)targetId
                mediaType:(RCMediaType)mediaType
                 mediaUrl:(NSString *)mediaUrl
                 progress:(void (^)(int progress))progressBlock
                  success:(void (^)(NSString *mediaPath))successBlock
                    error:(void (^)(RCErrorCode errorCode))errorBlock
                   cancel:(void (^)(void))cancelBlock;

/*!
 下载消息内容中的媒体信息

 @param messageId           媒体消息的 messageId
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0 <= progress <= 100]
 @param successBlock        下载成功的回调[mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调

 @discussion 用来获取媒体原文件时调用。如果本地缓存中包含此文件，则从本地缓存中直接获取，否则将从服务器端下载。

 @remarks 多媒体下载
 */
- (void)downloadMediaMessage:(long)messageId
                    progress:(void (^)(int progress))progressBlock
                     success:(void (^)(NSString *mediaPath))successBlock
                       error:(void (^)(RCErrorCode errorCode))errorBlock
                      cancel:(void (^)(void))cancelBlock;

/*!
 取消下载中的媒体信息

 @param messageId 媒体消息的messageId

 @return YES 表示取消成功，NO表示取消失败，即已经下载完成或者消息不存在。

 @remarks 多媒体下载
 */
- (BOOL)cancelDownloadMediaMessage:(long)messageId;

/*!
 取消下载中的媒体信息

 @param mediaUrl 媒体消息 Url

 @return YES 表示取消成功，NO 表示取消失败，即已经下载完成或者消息不存在。

 @remarks 多媒体下载
*/
- (BOOL)cancelDownloadMediaUrl:(NSString *)mediaUrl;

/*!
 发送定向消息

 @param conversationType 发送消息的会话类型
 @param targetId         发送消息的会话 ID
 @param userIdList       接收消息的用户 ID 列表
 @param content          消息的内容
 @param pushContent      接收方离线时需要显示的远程推送内容
 @param pushData         接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock     消息发送成功的回调 [messageId:消息的 ID]
 @param errorBlock       消息发送失败的回调 [errorCode:发送失败的错误码,
 messageId:消息的 ID]

 @return 发送的消息实体

 @discussion 此方法用于在群组和讨论组中发送消息给其中的部分用户，其它用户不会收到这条消息。
 如果您使用 IMLibCore，可以使用此方法发送定向消息；
 如果您使用 IMKit，请使用 RCIM 中的同名方法发送定向消息，否则不会自动更新 UI。

 @warning 此方法目前仅支持群组和讨论组。

 @remarks 消息操作
 */
- (RCMessage *)sendDirectionalMessage:(RCConversationType)conversationType
                             targetId:(NSString *)targetId
                         toUserIdList:(NSArray *)userIdList
                              content:(RCMessageContent *)content
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                              success:(void (^)(long messageId))successBlock
                                error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 发送定向消息

 @param message 消息实体
 @param userIdList       接收消息的用户 ID 列表
 @param pushContent      接收方离线时需要显示的远程推送内容
 @param pushData         接收方离线时需要在远程推送中携带的非显示数据
 @param successBlock     消息发送成功的回调 [successMessage:发送成功的消息]
 @param errorBlock       消息发送失败的回调 [nErrorCode:发送失败的错误码,errorMessage:发送失败的消息]

 @return 发送的消息实体

 @discussion 此方法用于在群组和讨论组中发送消息给其中的部分用户，其它用户不会收到这条消息。

 @warning 此方法目前仅支持群组和讨论组。

 @remarks 消息操作
 */
- (RCMessage *)sendDirectionalMessage:(RCMessage *)message
                         toUserIdList:(NSArray *)userIdList
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                         successBlock:(void (^)(RCMessage *successMessage))successBlock
                           errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock;

/*!
 发送定向消息

 @param message 消息实体
 @param userIdList       接收消息的用户 ID 列表
 @param pushContent      接收方离线时需要显示的远程推送内容
 @param pushData         接收方离线时需要在远程推送中携带的非显示数据
 @param option              消息的相关配置
 @param successBlock     消息发送成功的回调 [successMessage:发送成功的消息]
 @param errorBlock       消息发送失败的回调 [nErrorCode:发送失败的错误码,errorMessage:发送失败的消息]

 @return 发送的消息实体

 @discussion 此方法用于在群组和讨论组中发送消息给其中的部分用户，其它用户不会收到这条消息。

 @warning 此方法目前仅支持群组和讨论组。

 @remarks 消息操作
 */
- (RCMessage *)sendDirectionalMessage:(RCMessage *)message
                         toUserIdList:(NSArray *)userIdList
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                               option:(RCSendMessageOption *)option
                         successBlock:(void (^)(RCMessage *successMessage))successBlock
                           errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock;

#pragma mark 消息接收监听
/*!
 设置 IMLibCore 的消息接收监听器

 @param delegate    IMLibCore 消息接收监听器
 @param userData    用户自定义的监听器 Key 值，可以为 nil

 @discussion
 设置 IMLibCore 的消息接收监听器请参考 RCCoreClient 的 setReceiveMessageDelegate:object:方法。

 @warning 如果您使用 IMLibCore，可以设置并实现此 Delegate 监听消息接收；
 如果您使用 IMKit，请使用 RCIM 中的 receiveMessageDelegate 监听消息接收，而不要使用此方法，否则会导致 IMKit
 中无法自动更新 UI！

 @remarks 功能设置
 */
- (void)setReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate object:(id)userData;

/*!
 添加 IMLib 接收消息监听

 @param delegate 代理
 */
- (void)addReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate;

/*!
 移除 IMLib 接收消息监听

 @param delegate 代理
 */
- (void)removeReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate;

#pragma mark - 消息入库前预处理监听
/*!
 设置消息拦截器

 @discussion 可以设置并实现此拦截器来进行消息的拦截处理

 @remarks 功能设置
 */
@property (nonatomic, weak) id<RCMessageInterceptor> messageInterceptor;

#pragma mark - 发送消息被拦截监听

/*!
 设置发送消息被拦截的监听器

 @discussion 可以设置并实现此拦截器来处理发送消息被拦截时的处理

 @remarks 功能设置
 */
@property (nonatomic, weak) id<RCMessageBlockDelegate> messageBlockDelegate;

#pragma mark - 消息阅读回执

/*!
 发送某个会话中消息阅读的回执

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param timestamp           该会话中已阅读的最后一条消息的发送时间戳
 @param successBlock        发送成功的回调
 @param errorBlock          发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 此接口只支持单聊, 如果使用 IMLibCore 可以注册监听
 RCLibDispatchReadReceiptNotification 通知,使用 IMKit 直接设置RCIM.h
 中的 enabledReadReceiptConversationTypeList。

 @warning 目前仅支持单聊。

 @remarks 高级功能
 */
- (void)sendReadReceiptMessage:(RCConversationType)conversationType
                      targetId:(NSString *)targetId
                          time:(long long)timestamp
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 请求消息阅读回执

 @param message      要求阅读回执的消息
 @param successBlock 请求成功的回调
 @param errorBlock   请求失败的回调[nErrorCode: 失败的错误码]

 @discussion 通过此接口，可以要求阅读了这条消息的用户发送阅读回执。

 @remarks 高级功能
 */
- (void)sendReadReceiptRequest:(RCMessage *)message
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 发送阅读回执

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param messageList      已经阅读了的消息列表
 @param successBlock     发送成功的回调
 @param errorBlock       发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 当用户阅读了需要阅读回执的消息，可以通过此接口发送阅读回执，消息的发送方即可直接知道那些人已经阅读。

 @remarks 高级功能
 */
- (void)sendReadReceiptResponse:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                    messageList:(NSArray<RCMessage *> *)messageList
                        success:(void (^)(void))successBlock
                          error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 同步会话阅读状态（把指定会话里所有发送时间早于 timestamp 的消息置为已读）

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param timestamp        已经阅读的最后一条消息的 Unix 时间戳(毫秒)
 @param successBlock     同步成功的回调
 @param errorBlock       同步失败的回调[nErrorCode: 失败的错误码]

 @remarks 高级功能
 */
- (void)syncConversationReadStatus:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                              time:(long long)timestamp
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode nErrorCode))errorBlock;

#pragma mark - 消息撤回

/*!
 撤回消息

 @param message      需要撤回的消息
 @param pushContent 当下发 push 消息时，在通知栏里会显示这个字段，不设置将使用融云默认推送内容
 @param successBlock 撤回成功的回调 [messageId:撤回的消息 ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]

 @warning 仅支持单聊、群组和讨论组。

 @remarks 高级功能
 */
- (void)recallMessage:(RCMessage *)message
          pushContent:(NSString *)pushContent
              success:(void (^)(long messageId))successBlock
                error:(void (^)(RCErrorCode errorcode))errorBlock;

/*!
 撤回消息

 @param message      需要撤回的消息
 @param successBlock 撤回成功的回调 [messageId:撤回的消息 ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 @remarks 高级功能
 */
- (void)recallMessage:(RCMessage *)message
              success:(void (^)(long messageId))successBlock
                error:(void (^)(RCErrorCode errorcode))errorBlock;

#pragma mark - 消息操作

/*!
 获取某个会话中指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 */
- (NSArray *)getLatestMessages:(RCConversationType)conversationType targetId:(NSString *)targetId count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param oldestMessageId     截止的消息 ID
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，oldestMessageId 之前的、指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 oldestMessageId 对应那条消息，如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId 为 10，count 为 2，会返回 messageId 为 9 和 8 的 RCMessage 对象列表。

 @remarks 消息操作
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 获取会话中，从指定消息之前、指定数量的、指定消息类型的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param objectName          消息内容的类型名，如果想取全部类型的消息请传 nil
 @param oldestMessageId     截止的消息 ID
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，oldestMessageId 之前的、指定数量和消息类型的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 oldestMessageId 对应的那条消息，如果会话中的消息数量小于参数 count
 的值，会将该会话中的所有消息返回。
 如：oldestMessageId 为 10，count 为 2，会返回 messageId 为 9 和 8 的 RCMessage 对象列表。

 @remarks 消息操作
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     objectName:(NSString *)objectName
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 获取会话中，指定消息、指定数量、指定消息类型、向前或向后查找的消息实体列表

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param objectName          消息内容的类型名，如果想取全部类型的消息请传 nil
 @param baseMessageId       当前的消息 ID
 @param isForward           查询方向 true 为向前，false 为向后
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，baseMessageId
 之前或之后的、指定数量、消息类型和查询方向的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 baseMessageId 对应的那条消息，如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     objectName:(NSString *)objectName
                  baseMessageId:(long)baseMessageId
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 获取会话中，指定时间、指定数量、指定消息类型（多个）、向前或向后查找的消息实体列表

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param objectNames         消息内容的类型名称列表
 @param sentTime            当前的消息时间戳
 @param isForward           查询方向 true 为向前，false 为向后
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中，sentTime
 之前或之后的、指定数量、指定消息类型（多个）的消息实体列表，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含 sentTime 对应的那条消息，如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                    objectNames:(NSArray *)objectNames
                       sentTime:(long long)sentTime
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 在会话中搜索指定消息的前 beforeCount 数量和后 afterCount
 数量的消息。返回的消息列表中会包含指定的消息。消息列表时间顺序从新到旧。

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param sentTime            消息的发送时间
 @param beforeCount         指定消息的前部分消息数量
 @param afterCount          指定消息的后部分消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 获取该会话的这条消息及这条消息前 beforeCount 条和后 afterCount 条消息,如前后消息不够则返回实际数量的消息。

 @remarks 消息操作
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                       sentTime:(long long)sentTime
                    beforeCount:(int)beforeCount
                     afterCount:(int)afterCount;

/*!
 从服务器端清除历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param recordTime          清除消息时间戳，【0 <= recordTime <= 当前会话最后一条消息的 sentTime,0
 清除所有消息，其他值清除小于等于 recordTime 的消息】
 @param successBlock        获取成功的回调
 @param errorBlock          获取失败的回调 [status:清除失败的错误码]

 @discussion
 此方法从服务器端清除历史消息，但是必须先开通历史消息云存储功能。
 例如，您不想从服务器上获取更多的历史消息，通过指定 recordTime 清除成功后只能获取该时间戳之后的历史消息。

 @remarks 消息操作
 */
- (void)clearRemoteHistoryMessages:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                        recordTime:(long long)recordTime
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode status))errorBlock;

/*!
 清除历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param recordTime          清除消息时间戳，【0 <= recordTime <= 当前会话最后一条消息的 sentTime,0
 清除所有消息，其他值清除小于等于 recordTime 的消息】
 @param clearRemote         是否同时删除服务端消息
 @param successBlock        获取成功的回调
 @param errorBlock          获取失败的回调 [ status:清除失败的错误码]

 @discussion
 此方法可以清除服务器端历史消息和本地消息，如果清除服务器端消息必须先开通历史消息云存储功能。
 例如，您不想从服务器上获取更多的历史消息，通过指定 recordTime 并设置 clearRemote 为 YES
 清除消息，成功后只能获取该时间戳之后的历史消息。如果 clearRemote 传 NO，
 只会清除本地消息。

 @remarks 消息操作
 */
- (void)clearHistoryMessages:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                  recordTime:(long long)recordTime
                 clearRemote:(BOOL)clearRemote
                     success:(void (^)(void))successBlock
                       error:(void (^)(RCErrorCode status))errorBlock;

/*!
 从服务器端获取之前的历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param recordTime          截止的消息发送时间戳，毫秒
 @param count               需要获取的消息数量， 0 < count <= 20
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, isRemaining 是否还有剩余消息 YES
 表示还有剩余，NO 表示无剩余]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 例如，本地会话中有10条消息，您想拉取更多保存在服务器的消息的话，recordTime 应传入最早的消息的发送时间戳，count 传入
 1~20 之间的数值。

 @discussion 本地数据库可以查到的消息，该接口不会再返回，所以建议先用 getHistoryMessages
 相关接口取本地历史消息，本地消息取完之后再通过该接口获取远端历史消息

 @remarks 消息操作
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                      recordTime:(long long)recordTime
                           count:(int)count
                         success:(void (^)(NSArray *messages, BOOL isRemaining))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 从服务器端获取之前的历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param option              可配置的参数
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组, isRemaining 是否还有剩余消息 YES
 表示还有剩余，NO 表示无剩余]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion
 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 例如，本地会话中有 10 条消息，您想拉取更多保存在服务器的消息的话，recordTime 应传入最早的消息的发送时间戳，count 传入
 1~20 之间的数值。

 @remarks 消息操作
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                          option:(RCRemoteHistoryMsgOption *)option
                         success:(void (^)(NSArray *messages, BOOL isRemaining))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 获取历史消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param option              可配置的参数
 @param complete        获取成功的回调 [messages：获取到的历史消息数组； code : 获取是否成功，0表示成功，非 0 表示失败，此时 messages 数组可能存在断档]

 @discussion 必须开通历史消息云存储功能。
 @discussion count 传入 1~20 之间的数值。
 @discussion 此方法先从本地获取历史消息，本地有缺失的情况下会从服务端同步缺失的部分。
 @discussion 从服务端同步失败的时候会返回非 0 的 errorCode，同时把本地能取到的消息回调上去。

 @remarks 消息操作
 */
- (void)getMessages:(RCConversationType)conversationType
           targetId:(NSString *)targetId
             option:(RCHistoryMessageOption *)option
           complete:(void (^)(NSArray *messages, RCErrorCode code))complete;

/*!
 获取会话中@提醒自己的消息

 @param conversationType    会话类型
 @param targetId            会话 ID

 @discussion
 此方法从本地获取被@提醒的消息(最多返回 10 条信息)
 @warning 使用 IMKit 注意在进入会话页面前调用，否则在进入会话清除未读数的接口 clearMessagesUnreadStatus: targetId:
 以及 设置消息接收状态接口 setMessageReceivedStatus:receivedStatus:会同步清除被提示信息状态。

 @remarks 高级功能
 */
- (NSArray *)getUnreadMentionedMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 获取消息的发送时间（Unix 时间戳、毫秒）

 @param messageId   消息 ID
 @return            消息的发送时间（Unix 时间戳、毫秒）

 @remarks 消息操作
 */
- (long long)getMessageSendTime:(long)messageId;

/*!
 通过 messageId 获取消息实体

 @param messageId   消息 ID（数据库索引唯一值）
 @return            通过消息 ID 获取到的消息实体，当获取失败的时候，会返回 nil。

 @remarks 消息操作
 */
- (RCMessage *)getMessage:(long)messageId;

/*!
 通过全局唯一 ID 获取消息实体

 @param messageUId   全局唯一 ID（服务器消息唯一 ID）
 @return 通过全局唯一ID获取到的消息实体，当获取失败的时候，会返回 nil。

 @remarks 消息操作
 */
- (RCMessage *)getMessageByUId:(NSString *)messageUId;

/**
 * 获取会话里第一条未读消息。
 *
 * @param conversationType 会话类型
 * @param targetId   会话 ID
 * @return 第一条未读消息的实体。
 * @remarks 消息操作
 */
- (RCMessage *)getFirstUnreadMessage:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 删除消息

 @param messageIds  消息 ID 的列表，元素需要为 NSNumber 类型
 @return            是否删除成功

 @remarks 消息操作
 */
- (BOOL)deleteMessages:(NSArray<NSNumber *> *)messageIds;

/*!
 删除某个会话中的所有消息

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param successBlock        成功的回调
 @param errorBlock          失败的回调

 @discussion 此方法删除数据库中该会话的消息记录，同时会整理压缩数据库，减少占用空间

 @remarks 消息操作
 */
- (void)deleteMessages:(RCConversationType)conversationType
              targetId:(NSString *)targetId
               success:(void (^)(void))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/**
 批量删除某个会话中的指定远端消息（同时删除对应的本地消息）

 @param conversationType 会话类型，不支持聊天室
 @param targetId 目标会话ID
 @param messages 将被删除的消息列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调

 @discussion 此方法会同时删除远端和本地消息。
 一次批量操作仅支持删除属于同一个会话的消息，请确保消息列表中的所有消息来自同一会话
 一次最多删除 100 条消息。

 @remarks 消息操作
 */
- (void)deleteRemoteMessage:(RCConversationType)conversationType
                   targetId:(NSString *)targetId
                   messages:(NSArray<RCMessage *> *)messages
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 删除某个会话中的所有消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    是否删除成功

 @remarks 消息操作
 */
- (BOOL)clearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 设置消息的附加信息

 @param messageId   消息 ID
 @param value       附加信息，最大 1024 字节
 @return            是否设置成功

 @discussion 用于扩展消息的使用场景。只能用于本地使用，无法同步到远端。

 @remarks 消息操作
 */
- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value;

/*!
 设置消息的接收状态

 @param messageId       消息 ID
 @param receivedStatus  消息的接收状态
 @return                是否设置成功

 @discussion 用于 UI 展示消息为已读，已下载等状态。

 @remarks 消息操作
 */
- (BOOL)setMessageReceivedStatus:(long)messageId receivedStatus:(RCReceivedStatus)receivedStatus;

/*!
 设置消息的发送状态

 @param messageId       消息 ID
 @param sentStatus      消息的发送状态
 @return                是否设置成功

 @discussion 用于 UI 展示消息为正在发送，对方已接收等状态。

 @remarks 消息操作
 */
- (BOOL)setMessageSentStatus:(long)messageId sentStatus:(RCSentStatus)sentStatus;

/**
 开始焚烧消息（目前仅支持单聊）

 @param message 消息类
 @discussion 仅限接收方调用

 @remarks 高级功能
 */
- (void)messageBeginDestruct:(RCMessage *)message;

/**
 停止焚烧消息（目前仅支持单聊）

 @param message 消息类
 @discussion 仅限接收方调用

 @remarks 高级功能
 */
- (void)messageStopDestruct:(RCMessage *)message;

#pragma mark - 会话列表操作
/*!
 获取会话列表

 @param conversationTypeList   会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                        会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 @discussion 当您的会话较多且没有清理机制的时候，强烈建议您使用 getConversationList: count: startTime:
 分页拉取会话列表,否则有可能造成内存过大。

 @remarks 会话列表
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList;

/*!
 分页获取会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @param count                获取的数量（当实际取回的会话数量小于 count 值时，表明已取完数据）
 @param startTime            会话的时间戳（获取这个时间戳之前的会话列表，0表示从最新开始获取）
 @return                     会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。

 @remarks 会话列表
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList count:(int)count startTime:(long long)startTime;

/*!
 获取单个会话数据

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    会话的对象

 @remarks 会话
 */
- (RCConversation *)getConversation:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 获取会话中的消息数量

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    会话中的消息数量

 @discussion -1 表示获取消息数量出错。

 @remarks 会话
 */
- (int)getMessageCount:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 删除指定类型的会话

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                        是否删除成功

 @discussion 此方法会从本地存储中删除该会话，同时删除会话中的消息。

 @remarks 会话
 */
- (BOOL)clearConversations:(NSArray *)conversationTypeList;

/*!
 从本地存储中删除会话

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    是否删除成功

 @discussion
 此方法会从本地存储中删除该会话，但是不会删除会话中的消息。如果此会话中有新的消息，该会话将重新在会话列表中显示，并显示最近的历史消息。

 @remarks 会话
 */
- (BOOL)removeConversation:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 设置会话的置顶状态

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param isTop               是否置顶
 @return                    设置是否成功

 @discussion 会话不存在时设置置顶，会在会话列表生成会话。
 
 @remarks 会话
 */
- (BOOL)setConversationToTop:(RCConversationType)conversationType targetId:(NSString *)targetId isTop:(BOOL)isTop;

/*!
 获取置顶的会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                     置顶的会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取置顶的会话列表。

 @remarks 会话列表
 */
- (NSArray<RCConversation *> *)getTopConversationList:(NSArray *)conversationTypeList;

/*!
 获取会话的置顶状态

 @param conversationIdentifier 会话信息

 @discussion 此方法会从本地数据库中，读取该会话是否置顶。

 @remarks 会话
 */
- (BOOL)getConversationTopStatus:(RCConversationIdentifier *)conversationIdentifier;

- (void)setRCConversationDelegate:(id<RCConversationDelegate>)delegate;

#pragma mark 会话中的草稿操作
/*!
 获取会话中的草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @return                    该会话中的草稿

 @remarks 会话
 */
- (NSString *)getTextMessageDraft:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 保存草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @param content             草稿信息
 @return                    是否保存成功

 @remarks 会话
 */
- (BOOL)saveTextMessageDraft:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                     content:(NSString *)content;

/*!
 删除会话中的草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @return                    是否删除成功

 @remarks 会话
 */
- (BOOL)clearTextMessageDraft:(RCConversationType)conversationType targetId:(NSString *)targetId;

#pragma mark 未读消息数

/*!
 获取所有的未读消息数（聊天室会话除外）

 @return    所有的未读消息数

 @remarks 会话
 */
- (int)getTotalUnreadCount;

/*!
 获取某个会话内的未读消息数（聊天室会话除外）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @return                    该会话内的未读消息数

 @remarks 会话
 */
- (int)getUnreadCount:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 获取某个会话内的未读消息数（聊天室会话除外）

 @param conversationIdentifier 会话信息
 @param messageClassList            消息类型数组
 @return                    该会话内的未读消息数

 @remarks 会话
 */
- (int)getUnreadCount:(RCConversationIdentifier *)conversationIdentifier messageClassList:(NSArray <Class> *)messageClassList;

/*!
 获取某些会话的总未读消息数 （聊天室会话除外）

 @param conversations       会话列表 （ RCConversation 对象只需要 conversationType 和 targetId，channelId 按需使用）
 @return                    传入会话列表的未读消息数

 @remarks 会话
 */
- (int)getTotalUnreadCount:(NSArray<RCConversation *> *)conversations;

/**
 获取某些类型的会话中所有的未读消息数 （聊天室会话除外）

 @param conversationTypes   会话类型的数组
 @param isContain           是否包含免打扰消息的未读数
 @return                    该类型的会话中所有的未读消息数

 @remarks 会话
 */
- (int)getUnreadCount:(NSArray *)conversationTypes containBlocked:(bool)isContain;

/*!
 获取某个类型的会话中所有的未读消息数（聊天室会话除外）

 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有的未读消息数

 @remarks 会话
 */
- (int)getUnreadCount:(NSArray *)conversationTypes;

/*!
 获取某个类型的会话中所有未读的被@的消息数

 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有未读的被@的消息数

 @remarks 会话
 */
- (int)getUnreadMentionedCount:(NSArray *)conversationTypes;

/*!
 清除某个会话中的未读消息数

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @return                    是否清除成功

 @remarks 会话
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 清除某个会话中的未读消息数（该会话在时间戳 timestamp 之前的消息将被置成已读。）

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param timestamp           该会话已阅读的最后一条消息的发送时间戳
 @return                    是否清除成功

 @remarks 会话
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                             time:(long long)timestamp;

#pragma mark - 会话的消息提醒

/*!
 设置会话的消息提醒状态

 @param conversationType            会话类型
 @param targetId                    会话 ID
 @param isBlocked                   是否屏蔽消息提醒
 @param successBlock                设置成功的回调
 [nStatus:会话设置的消息提醒状态]
 @param errorBlock                  设置失败的回调 [status:设置失败的错误码]

 @discussion
 如果您使用
 IMLibCore，此方法会屏蔽该会话的远程推送；如果您使用IMKit，此方法会屏蔽该会话的所有提醒（远程推送、本地通知、前台提示音）,该接口不支持聊天室。

 @remarks 会话
 */
- (void)setConversationNotificationStatus:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                                isBlocked:(BOOL)isBlocked
                                  success:(void (^)(RCConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询会话的消息提醒状态

 @param conversationType    会话类型（不支持聊天室，聊天室是不接受会话消息提醒的）
 @param targetId            会话 ID
 @param successBlock        查询成功的回调 [nStatus:会话设置的消息提醒状态]
 @param errorBlock          查询失败的回调 [status:设置失败的错误码]

 @remarks 会话
 */
- (void)getConversationNotificationStatus:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                                  success:(void (^)(RCConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 获取消息免打扰会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                     消息免打扰会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取消息免打扰会话列表。

 @remarks 会话列表
 */
- (NSArray<RCConversation *> *)getBlockedConversationList:(NSArray *)conversationTypeList;

#pragma mark - 全局消息提醒

/*!
 全局屏蔽某个时间段的消息提醒

 @param startTime       开始消息免打扰时间，格式为 HH:MM:SS
 @param spanMins        需要消息免打扰分钟数，0 < spanMins < 1440（ 比如，您设置的起始时间是 00：00， 结束时间为
 23：59，则 spanMins 为 23 * 60 + 59 = 1439 分钟。）
 @param successBlock    屏蔽成功的回调
 @param errorBlock      屏蔽失败的回调 [status:屏蔽失败的错误码]

 @discussion 此方法设置的屏蔽时间会在每天该时间段时生效。
 如果您使用 IMLibCore，此方法会屏蔽该会话在该时间段的远程推送；如果您使用
 IMKit，此方法会屏蔽该会话在该时间段的所有提醒（远程推送、本地通知、前台提示音）。

 @remarks 会话
 */
- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(int)spanMins
                          success:(void (^)(void))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 删除已设置的全局时间段消息提醒屏蔽

 @param successBlock    删除屏蔽成功的回调
 @param errorBlock      删除屏蔽失败的回调 [status:失败的错误码]

 @remarks 会话
 */
- (void)removeNotificationQuietHours:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询已设置的全局时间段消息提醒屏蔽

 @param successBlock    屏蔽成功的回调 [startTime:已设置的屏蔽开始时间,
 spansMin:已设置的屏蔽时间分钟数，0 < spansMin < 1440]
 @param errorBlock      查询失败的回调 [status:查询失败的错误码]

 @remarks 会话
 */
- (void)getNotificationQuietHours:(void (^)(NSString *startTime, int spansMin))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - 输入状态提醒

/**
 typing 状态更新的时间，默认是 6s
 
 @remarks 功能设置
 */
@property (nonatomic, assign) NSInteger typingUpdateSeconds;

/*!
 设置输入状态的监听器

 @param delegate         IMLibCore 输入状态的的监听器

 @warning           目前仅支持单聊。

 @remarks 功能设置
 */
- (void)setRCTypingStatusDelegate:(id<RCTypingStatusDelegate>)delegate;

/*!
 向会话中发送正在输入的状态

 @param conversationType    会话类型
 @param targetId            会话目标  ID
 @param objectName         正在输入的消息的类型名

 @discussion
 contentType 为用户当前正在编辑的消息类型名，即 RCMessageContent 中 getObjectName 的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。

 @warning 目前仅支持单聊。

 @remarks 高级功能
 */
- (void)sendTypingStatus:(RCConversationType)conversationType
                targetId:(NSString *)targetId
             contentType:(NSString *)objectName;

#pragma mark - 黑名单

/*!
 将某个用户加入黑名单

 @param userId          需要加入黑名单的用户 ID
 @param successBlock    加入黑名单成功的回调
 @param errorBlock      加入黑名单失败的回调 [status:失败的错误码]

 @discussion 将对方加入黑名单后，对方再发消息时，就会提示“您的消息已经发出, 但被对方拒收”。但您仍然可以给对方发送消息。

 @remarks 高级功能
 */
- (void)addToBlacklist:(NSString *)userId
               success:(void (^)(void))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/*!
 将某个用户移出黑名单

 @param userId          需要移出黑名单的用户 ID
 @param successBlock    移出黑名单成功的回调
 @param errorBlock      移出黑名单失败的回调[status:失败的错误码]

 @remarks 高级功能
 */
- (void)removeFromBlacklist:(NSString *)userId
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询某个用户是否已经在黑名单中

 @param userId          需要查询的用户 ID
 @param successBlock    查询成功的回调
 [bizStatus:该用户是否在黑名单中。0 表示已经在黑名单中，101 表示不在黑名单中]
 @param errorBlock      查询失败的回调 [status:失败的错误码]

 @remarks 高级功能
 */
- (void)getBlacklistStatus:(NSString *)userId
                   success:(void (^)(int bizStatus))successBlock
                     error:(void (^)(RCErrorCode status))errorBlock;

/*!
 查询已经设置的黑名单列表

 @param successBlock    查询成功的回调
 [blockUserIds:已经设置的黑名单中的用户 ID 列表]
 @param errorBlock      查询失败的回调 [status:失败的错误码]

 @remarks 高级功能
 */
- (void)getBlacklist:(void (^)(NSArray *blockUserIds))successBlock error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - 推送业务数据统计

/*!
 统计App启动的事件

 @param launchOptions   App的启动附加信息

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在 AppDelegate 的-application:didFinishLaunchingWithOptions:中，
 调用此方法并将 launchOptions  传入即可。

 @remarks 高级功能
 */
- (void)recordLaunchOptionsEvent:(NSDictionary *)launchOptions;

/*!
 统计本地通知的事件

 @param notification   本体通知的内容

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate 的-application:didReceiveLocalNotification:中，
 调用此方法并将 launchOptions 传入即可。

 @remarks 高级功能
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)recordLocalNotificationEvent:(UILocalNotification *)notification;
#pragma clang diagnostic pop

/*!
 统计收到远程推送的事件

 @param userInfo    远程推送的内容
 
 @discussion 此方法用于统计融云推送服务的到达率。
 如果您需要统计推送服务的到达率，需要在 App  中实现通知扩展，并在 NotificationService  的 -didReceiveNotificationRequest: withContentHandler: 中
 先初始化 appkey 再调用此方法并将推送内容 userInfo 传入即可。

 @discussion 如果有单独的统计服务地址，还需要在初始化之后设置独立的统计服务地址
 
 如：
 
 - (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
     self.contentHandler = contentHandler;
     self.bestAttemptContent = [request.content mutableCopy];
     
     NSDictionary *userInfo = self.bestAttemptContent.userInfo;
     [[RCCoreClient sharedCoreClient] initWithAppKey:RONGCLOUD_IM_APPKEY];
     if (RONGCLOUD_STATS_SERVER.length > 0) {
        [[RCCoreClient sharedCoreClient] setStatisticServer:RONGCLOUD_STATS_SERVER];
     }
     [[RCCoreClient sharedCoreClient] recordReceivedRemoteNotificationEvent:userInfo];
     
     self.contentHandler(self.bestAttemptContent);
 }

 @remarks 高级功能
 */
- (void)recordReceivedRemoteNotificationEvent:(NSDictionary *)userInfo;

/*!
 统计远程推送的点击事件

 @param userInfo    远程推送的内容

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在 AppDelegate 的-application:didReceiveRemoteNotification:中，
 调用此方法并将 launchOptions 传入即可。

 @remarks 高级功能
 */
- (void)recordRemoteNotificationEvent:(NSDictionary *)userInfo;

/*!
 获取点击的启动事件中，融云推送服务的扩展字段

 @param launchOptions   App 的启动附加信息
 @return 收到的融云推送服务的扩展字段，nil 表示该启动事件不包含来自融云的推送服务

 @discussion 此方法仅用于获取融云推送服务的扩展字段。

 @remarks 高级功能
 */
- (NSDictionary *)getPushExtraFromLaunchOptions:(NSDictionary *)launchOptions;

/*!
 获取点击的远程推送中，融云推送服务的扩展字段

 @param userInfo    远程推送的内容
 @return 收到的融云推送服务的扩展字段，nil 表示该远程推送不包含来自融云的推送服务

 @discussion 此方法仅用于获取融云推送服务的扩展字段。

 @remarks 高级功能
 */
- (NSDictionary *)getPushExtraFromRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - 工具类方法

/*!
 获取当前 IMLibCore SDK的版本号

 @return 当前 IMLibCore SDK 的版本号，如: @"2.0.0"

 @remarks 数据获取
 */
+ (NSString *)getVersion;

/*!
 获取当前手机与服务器的时间差

 @return 时间差
 @discussion 消息发送成功后，SDK 会与服务器同步时间，消息所在数据库中存储的时间就是服务器时间。

 @remarks 数据获取
 */
- (long long)getDeltaTime;

/*!
 将AMR格式的音频数据转化为 WAV 格式的音频数据，数据开头携带 WAVE 文件头

 @param data    AMR 格式的音频数据，必须是 AMR-NB 的格式
 @return        WAV 格式的音频数据

 @remarks 数据获取
 */
- (NSData *)decodeAMRToWAVE:(NSData *)data;

/*!
 将 AMR 格式的音频数据转化为 WAV 格式的音频数据，数据开头不携带 WAV 文件头

 @param data    AMR 格式的音频数据，必须是 AMR-NB 的格式
 @return        WAV 格式的音频数据

 @remarks 数据获取
 */
- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data;

#pragma mark - 语音消息设置
/**
 语音消息采样率，默认 8KHz

 @discussion
 2.9.12 之前的版本只支持 8KHz。如果设置为 16KHz，老版本将无法播放 16KHz 的语音消息。
 客服会话只支持 8KHz。

 @remarks 功能设置
 */
@property (nonatomic, assign) RCSampleRate sampleRate __deprecated_msg("已废弃，请勿使用。");

/**
  语音消息类型，默认 RCVoiceMessageTypeOrdinary

  @discussion 老版本 SDK 不兼容新版本语音消息
  2.9.19 之前的版本无法播放高音质语音消息；
  2.9.19 及之后的版本可以同时兼容普通音质语音消息和高音质语音消息；
  客服会话类型 (ConversationType_CUSTOMERSERVICE) 不支持高音质语音消息。

  @remarks 功能设置
  */
@property (nonatomic, assign) RCVoiceMessageType voiceMsgType;

#pragma mark - 搜索

/*!
 根据关键字搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param keyword          关键字
 @param count            最大的查询数量
 @param startTime        查询 startTime 之前的消息（传 0 表示不限时间）

 @return 匹配的消息列表

 @remarks 消息操作
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                 keyword:(NSString *)keyword
                                   count:(int)count
                               startTime:(long long)startTime;

/*!
 根据时间，偏移量和个数搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param keyword           关键字，传空默认为是查全部符合条件的消息
 @param startTime      查询 startTime 之后的消息， startTime >= 0
 @param endTime           查询 endTime 之前的消息，endTime > startTime
 @param offset             查询的消息的偏移量，offset >= 0
 @param limit               最大的查询数量，limit 需大于 0，最大值为100，如果大于100，会默认成100。

 @return 匹配的消息列表

 @remarks 消息操作
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                 keyword:(NSString *)keyword
                               startTime:(long long)startTime
                                 endTime:(long long)endTime
                                  offset:(int)offset
                                   limit:(int)limit;

/*!
 按用户 ID 搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param userId           搜索用户 ID
 @param count            最大的查询数量
 @param startTime        查询 startTime 之前的消息（传 0 表示不限时间）

 @return 匹配的消息列表

 @remarks 消息操作
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                  userId:(NSString *)userId
                                   count:(int)count
                               startTime:(long long)startTime;

/*!
 根据关键字搜索会话

 @param conversationTypeList 需要搜索的会话类型列表
 @param objectNameList       需要搜索的消息类型名列表(即每个消息类方法 getObjectName 的返回值)
 @param keyword              关键字

 @return 匹配的会话搜索结果列表

 @discussion 目前，SDK 内置的文本消息、文件消息、图文消息支持搜索。
 自定义的消息必须要实现 RCMessageContent 的 getSearchableWords 接口才能进行搜索。

 @remarks 消息操作
 */
- (NSArray<RCSearchConversationResult *> *)searchConversations:(NSArray<NSNumber *> *)conversationTypeList
                                                   messageType:(NSArray<NSString *> *)objectNameList
                                                       keyword:(NSString *)keyword;

#pragma mark - 日志

/*!
 设置日志级别

 @remarks 高级功能
 */
@property (nonatomic, assign) RCLogLevel logLevel;

/*!
 设置 IMLibCore 日志的监听器

 @param delegate IMLibCore 日志的监听器

 @discussion 您可以通过 logLevel 来控制日志的级别。

 @remarks 功能设置
 */
- (void)setRCLogInfoDelegate:(id<RCLogInfoDelegate>)delegate;

#pragma mark - File Storage

/*!
 文件消息下载路径

 @discussion 默认值为沙盒下的 Documents/MyFile 目录。您可以通过修改 RCConfig.plist 中的 RelativePath 来修改该路径。

 @remarks 数据获取
 */
@property (nonatomic, strong, readonly) NSString *fileStoragePath;

#pragma mark - 第三方平台厂商接口
/*!
 获取Vendor token. 仅供融云第三方服务厂家使用。

 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @remarks 数据获取
 */
- (void)getVendorToken:(void (^)(NSString *vendorToken))successBlock error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 远程推送相关设置

 @remarks 功能设置
 */
@property (nonatomic, strong, readonly) RCPushProfile *pushProfile;

#pragma mark - 历史消息
/**
 设置离线消息在服务端的存储时间（以天为单位）

 @param duration      存储时间，范围【1~7天】
 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @remarks 功能设置
 */
- (void)setOfflineMessageDuration:(int)duration
                          success:(void (^)(void))successBlock
                          failure:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 获取离线消息时间 （以天为单位）

 @return 离线消息存储时间

 @remarks 数据获取
 */
- (int)getOfflineMessageDuration;

/**
 设置集成 SDK 的用户 App 版本信息。便于融云排查问题时，作为分析依据，属于自愿行为。

 @param  appVer   用户 APP 的版本信息。

 @remarks 功能设置
 */
- (void)setAppVer:(NSString *)appVer;

/**
 GIF 消息大小限制，以 KB 为单位，超过这个大小的 GIF 消息不能被发送

 @return GIF 消息大小，以 KB 为单位

 @remarks 数据获取
 */
- (NSInteger)getGIFLimitSize;

/**
 小视频消息时长限制，以 秒 为单位，超过这个时长的小视频消息不能在相册中被选择发送

 @return 小视频消息时长，以 秒 为单位
 */
- (NSTimeInterval)getVideoDurationLimit;

#pragma mark - 会话状态同步，免打扰，置顶

/*!
设置会话状态（包含置顶，消息免打扰）同步的监听器

@param delegate 会话状态同步的监听器

@discussion 可以设置并实现此 delegate 来进行会话状态同步。SDK 会在回调的 conversationStatusChange:方法中通知您会话状态的改变。

@remarks 功能设置
*/
- (void)setRCConversationStatusChangeDelegate:(id<RCConversationStatusChangeDelegate>)delegate;

#pragma mark - 消息扩展
/**
 更新消息扩展信息

 @param expansionDic 要更新的消息扩展信息键值对
 @param messageUId 消息 messageUId
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 消息扩展信息是以字典形式存在。设置的时候从 expansionDic 中读取 key，如果原有的扩展信息中 key 不存在则添加新的 KV 对，如果 key 存在则替换成新的 value。
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 @discussion 扩展信息字典中的 Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 32；Value 最长长度，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
 
 @remarks 高级功能
*/
- (void)updateMessageExpansion:(NSDictionary<NSString *, NSString *> *)expansionDic
                    messageUId:(NSString *)messageUId
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode status))errorBlock;

/**
 删除消息扩展信息中特定的键值对

 @param keyArray 消息扩展信息中待删除的 key 的列表
 @param messageUId 消息 messageUId
 @param successBlock 成功的回调
 @param errorBlock 失败的回调

 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 
 @remarks 高级功能
*/
- (void)removeMessageExpansionForKey:(NSArray<NSString *> *)keyArray
                          messageUId:(NSString *)messageUId
                             success:(void (^)(void))successBlock
                               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 设置 IMLibCore 的消息扩展监听器
 
 @discussion 代理回调在非主线程
 
 @remarks 高级功能
 */
@property (nonatomic, weak) id<RCMessageExpansionDelegate> messageExpansionDelegate;

#pragma mark - 标签
/*!
 添加标签
 
 @param tagInfo 标签信息。只需要设置标签信息的 tagId 和 tagName。
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 最多支持添加 20 个标签
 @remarks 高级功能
 */
- (void)addTag:(RCTagInfo *)tagInfo
       success:(void (^)(void))successBlock
         error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 移除标签
 
 @param tagId 标签 ID
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 */
- (void)removeTag:(NSString *)tagId
          success:(void (^)(void))successBlock
            error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 更新标签信息
 
 @param tagInfo 标签信息。只支持修改标签信息的 tagName
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 */
- (void)updateTag:(RCTagInfo *)tagInfo
          success:(void (^)(void))successBlock
            error:(void (^)(RCErrorCode errorCode))errorBlock;


/*!
 获取标签列表
 
 @return 标签列表
 @remarks 高级功能
 */
- (NSArray<RCTagInfo *> *)getTags;

/*!
 标签变化监听器
 
 @discussion 标签添加移除更新会触发此监听器，用于多端同步
 @discussion 本端添加删除更新标签，不会触发此监听器，在相关调用方法的 block 块直接回调
 
 @remarks 高级功能
 */
@property (nonatomic, weak) id<RCTagDelegate> tagDelegate;

/*!
 添加会话到指定标签
 
 @param tagId 标签 ID
 @param conversationIdentifiers 会话信息列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 每次添加会话个数最大为 1000。最多支持添加 1000 个会话，如果标签添加的会话总数已超过 1000，会自动覆盖早期添加的会话
 @remarks 高级功能
 */
- (void)addConversationsToTag:(NSString *)tagId
      conversationIdentifiers:(NSArray<RCConversationIdentifier *> *)conversationIdentifiers
                      success:(void (^)(void))successBlock
                        error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 从指定标签移除会话
 
 @param tagId 标签 ID
 @param conversationIdentifiers 会话信息列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 每次移除会话个数最大为 1000
 @remarks 高级功能
 */
- (void)removeConversationsFromTag:(NSString *)tagId
           conversationIdentifiers:(NSArray<RCConversationIdentifier *> *)conversationIdentifiers
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 从指定会话中移除标签

 @param conversationIdentifier 会话信息
 @param tagIds 标签 ID 列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 */
- (void)removeTagsFromConversation:(RCConversationIdentifier *)conversationIdentifier
                            tagIds:(NSArray<NSString *> *)tagIds
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 获取会话的所有标签
 
 @param conversationIdentifier 会话信息
 @return  会话所属的标签列表
 
 @remarks 高级功能
 */
- (NSArray<RCConversationTagInfo *> *)getTagsFromConversation:(RCConversationIdentifier *)conversationIdentifier;

/*!
 分页获取标签中会话列表
 
 @param tagId 标签 ID
 @param timestamp            会话的时间戳（获取这个时间戳之前的会话列表，0表示从最新开始获取）
 @param count                获取的数量（当实际取回的会话数量小于 count 值时，表明已取完数据）
 @return                     会话 RCConversation 的列表
 
 @remarks 高级功能
 */
- (NSArray<RCConversation *> *)getConversationsFromTagByPage:(NSString *)tagId
                                                   timestamp:(long long)timestamp
                                                       count:(int)count;

/*!
 获取标签中会话消息未读数
 
 @param tagId 标签 ID
 @param isContain    是否包含免打扰会话
 @return 会话消息未读数
 
 @remarks 高级功能
 */
- (int)getUnreadCountByTag:(NSString *)tagId
            containBlocked:(BOOL)isContain;

/*!
 设置标签中的会话置顶
 
 @param tagId 标签 ID
 @param conversationIdentifier 会话信息
 @param top 是否置顶
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 */
- (void)setConversationToTopInTag:(NSString *)tagId
           conversationIdentifier:(RCConversationIdentifier *)conversationIdentifier
                            isTop:(BOOL)top
                          success:(void (^)(void))successBlock
                            error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 获取标签中的会话置顶状态
 
 @param conversationIdentifier 会话信息
 @param tagId 标签 ID
 @return 置顶状态
 
 @remarks 高级功能
 */
- (BOOL)getConversationTopStatusInTag:(RCConversationIdentifier *)conversationIdentifier tagId:(NSString *)tagId;

/*!
 清除标签对应会话的未读消息数
 
 @param tagId 标签 ID
 @return 是否清除成功
 
 @remarks 高级功能
 */
- (BOOL)clearMessagesUnreadStatusByTag:(NSString *)tagId;

/*!
 删除标签对应的会话
 
 @param tagId 标签 ID
 @param option 可配置的参数
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 */
- (void)clearConversationsByTag:(NSString *)tagId
                         option:(RCClearConversationOption *)option
                        success:(void (^)(void))successBlock
                          error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 会话标签变化监听器
 
 @discussion 会话标签添加移除更新会触发此监听器，用于多端同步
 @discussion 本端操作会话标签，不会触发此监听器，在相关调用方法的 block 块直接回调
 
 @remarks 高级功能
 */
@property (nonatomic, weak) id<RCConversationTagDelegate> conversationTagDelegate;

/*!
 缩略图压缩配置
 
 @remarks 缩略图压缩配置，如果此处设置了配置就按照这个配置进行压缩。如果此处没有设置，会按照 RCConfig.plist 中的配置进行压缩。
 */
@property (nonatomic, strong) RCImageCompressConfig *imageCompressConfig;

/*!
 子模块是否正在使用声音通道，特指 RTCLib
 */
- (BOOL)isAudioHolding;

/*!
 子模块是否正在使用摄像头，特指 RTCLib
 */
- (BOOL)isCameraHolding;

@end

#endif
