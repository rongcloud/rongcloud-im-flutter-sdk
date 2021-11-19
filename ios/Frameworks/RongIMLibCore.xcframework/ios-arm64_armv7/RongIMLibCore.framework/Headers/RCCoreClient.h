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
/*!
 *  \~chinese
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
 
 *  \~english
 @const Receive the Notification of read receipt
@ discussion  IMLibCore distributes this notification after receiving the read receipt of the message.

 The object of Notification is nil and userInfo is the object of NSDictionary
where key values are @ "cType", @ "tId" and @ "messageTime" respectively
and the corresponding value is the NSNumber object of the conversation type, the targetId of the conversation, and the sendTime of the last message read.
 E.g.
 NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
 NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
 NSString *targetId = [notification.userInfo objectForKey:@"tId"];
 NSString *channelId = [notification.userInfo objectForKey:@"cId"];
 NSString *fromUserId = [notification.userInfo objectForKey:@"fId"];

After this message is received, you can update the previous messageTime message UI in this conversation to read (the underlying database message status has been changed to read).

 @ remarks event listener
 */
FOUNDATION_EXPORT NSString *const RCLibDispatchReadReceiptNotification;

#pragma mark - IMLibCore Core Class

/*!
 *  \~chinese
 融云 IMLibCore 核心类

 @discussion 您需要通过 sharedCoreClient 方法，获取单例对象。
 
 *  \~english
 RongCloud IMLibCore core class

 @discussion You shall get the single instance object through the sharedCoreClient method.
 */
@interface RCCoreClient : NSObject

/*!
 *  \~chinese
 获取融云通讯能力库 IMLibCore 的核心类单例

 @return 融云通讯能力库 IMLibCore 的核心单例类

 @discussion 您可以通过此方法，获取 IMLibCore 的单例，访问对象中的属性和方法.
 
 *  \~english
 Get a single instance of the core class of RongCloud communication capability library IMLibCore

 @ return Core single instance class of RongCloud communication capability library IMLibCore.

 @ discussion You can use this method to get the single instance of IMLibCore and access to the properties and methods in the object.
 */
+ (instancetype)sharedCoreClient;

#pragma mark - SDK init
/*!
 *  \~chinese
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
 
 *  \~english
 Initialize RongCloud SDK.

 @param appKey  The App Key obtained after the application is created by RongCloud developer platform
 @discussion After initialization, SDK listens to the app life cycle to determine whether the application is in the foreground or background, and adjusts the link heartbeat according to the foreground and background status.
 @ discussion
 You must call this method to initialize the SDK before you can use all the features of the RongCloud SDK (including displaying View in SDK or inheriting from SDK).
  You only shall perform initialization once throughout the App lifecycle.

  ** Upgrade instructions:**
 *””From version 2.4.1, to be compatible with the style of Swift and easy to use, the original init: method is upgraded to this method, and the function and use of the method remain unchanged. **

  @ warning If you are using IMLibCore, please use this method to initialize SDK
 If you are using IMKit, use the method of the same name in RCIM instead of using this method.

  @ remarks Connection
 */
- (void)initWithAppKey:(NSString *)appKey;

/*!
 *  \~chinese
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
 
 *  \~english
 Set deviceToken (compatible with iOS 13) for remote push

 @param deviceTokenData Device number deviceTokenData obtained from the system (no processing required)

 @ discussion
 DeviceToken is the unique device value the that must be used for APNs remote push, and is provided by the system and obtained from the Apple server.
 You shall pass the deviceToken obtained by the application:didRegisterForRemoteNotificationsWithDeviceToken: into this method as a parameter.

 E.g.:

    - (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
        [[RCCoreClient sharedCoreClient] setDeviceTokenData:deviceToken];
    }
 @remarks Function setting
*/
- (void)setDeviceTokenData:(NSData *)deviceTokenData;

/*!
 *  \~chinese
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
 
 *  \~english
 Set deviceToken for remote push

  @param deviceToken  The device number deviceToken obtained from the system

 @ discussion
 DeviceToken is the unique device value the that must be used for APNs remote push, and is provided by the system and obtained from the Apple server.
  You shall pass the deviceToken  obtained by the application:didRegisterForRemoteNotificationsWithDeviceToken: Obtained
 deviceToken, which is converted to a hexadecimal string and passed in to this method as a parameter.

  E.g.:

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

  @remarks function setting
 */
- (void)setDeviceToken:(NSString *)deviceToken;

#pragma mark - set navi server & file server (contact us before use)

/*!
 *  \~chinese
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
 
 *  \~english
 Set navigation server and upload file server information

 @param naviServer   Address of navigation server. For the specific format, please refer to the instructions below
 @param fileServer   Address of the file server. For the specific format, please refer to the instructions below
 @ return             whether it is set successfully

 @ warning It can only be used at an independent data center and you must contact the business to activate it before using it. It must be set before SDK init.
  @ discussion
 naviServer must be a valid server address, and fileServer can pass nil if you want to use the default.
  Format description for naviServer and fileServer:
  1. If you use https, it is set to https://cn.xxx.com:port or https://cn.xxx.com format, and the domain name can also be IP. If a port is not specified, port 443 will be used by default.
  2. If http is used, it is set to cn.xxx.com:port or cn.xxx.com format, and the domain name can also be IP. If the port is not specified, port 80 will be used by default. (iOS can only use the HTTPS protocol by default. If you use the http protocol, please refer to description of the ATS settings in the iOS development documentation. The link is as follows: https://support.rongcloud.cn/ks/OTQ1)

 @ remarks function setting
 */
- (BOOL)setServerInfo:(NSString *)naviServer fileServer:(NSString *)fileServer;

/**
 *  \~chinese
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
 
 *  \~english
 Set the statistics server information

 @param statisticServer  Address of the statistics server. For the specific format, please refer to the instructions below
 @ return Whether it is set successfully

 @ warning It can only be used at an independent data center and you must contact the business to activate it before using it. It must be set before SDK init and setDeviceToken.
  @ discussion
 statisticServer must have a valid server address, otherwise services such as push cannot be used properly.
  Format description:
  1. If you use https, it is set to https://cn.xxx.com:port or https://cn.xxx.com format, and the domain name can also be IP. If a port is not specified, port 443 will be used by default.
  2. If http is used, it is set to cn.xxx.com:port or cn.xxx.com format, and the domain name can also be IP. If the port is not specified, 80 will be used by default. (iOS can only use the HTTPS protocol by default. If you use the http protocol, please refer to description of the ATS settings in the iOS development documentation. The link is as follows: https://support.rongcloud.cn/ks/OTQ1)

 @ remarks function setting
 */
- (BOOL)setStatisticServer:(NSString *)statisticServer;

#pragma mark - Connect & disconnect

/*!
 *  \~chinese
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
 
 *  \~english
 Establish a connection with the RongCloud server.

 @param token                   Token (user identity token) obtained from your server.
 @param dbOpenedBlock                Callback for opening the local message database.
 @param successBlock            Callback for successful connection establishment [userId: The user ID used for the current successful connection].
 @param errorBlock Callback for failed connection establishment. Triggering this callback means that SDK cannot continue to reconnect [errorCode: Error code for connection failure].

 @ discussion After this interface is called, SDK will try to reconnect after the connection fails, until the connection is successful or an error that SDK cannot handle (such as illegal token) occurs.
  If you don't want to keep reconnecting, you can use connectWithToken:timeLimit:dbOpened:success:error: interface and set the connection timeout timeLimit
  
  @ discussion After the connection is successful, SDK will take over all reconnection processing When the connection is disconnected due to network reasons, SDK will keep reconnecting until the connection is successful, and there is no need for you to do any additional connection operations.

  For situations where errorBlock shall be specifically concerned about tokenIncorrect:
  One is the token error. Please check whether the AppKey used by the client initialization is consistent with the AppKey used by your server to obtain the token.
 Second, the token expires because you set the token expiration time in the developer background, and you shall request your server to retrieve the token and establish a connection with the new token again.
  In this case, you shall ask your server to retrieve the token and establish a connection, but be careful to avoid an infinite loop so as not to ensure a good App user experience.

  @ warning If you use IMLibCore, please use this method to establish a connection with the RongCloud server;
  If you use IMKit, please use the method of the same name in RCIM to establish a connection to the RongCloud server instead of using this method.

  The callback for this method is not the original calling thread. If you shall perform a UI operation, please be careful to switch to the main thread.
 */
- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Establish a connection with the RongCloud server.

  @param token                   Token (user identity token) obtained from your server.
  @param timeLimit               Timeout of SDK connection, unit: (in seconds)
 TimeLimit < = 0 the SDK SDK will continue to connect until the connection is successful or an error (such as illegal token) that cannot be handled by the SDK occurs.
                         TimeLimit > 0, SDK can be connected for a maximum of timeLimit seconds. A RC_CONNECT_TIMEOUT error is returned when the timeout occurs, and the connection will not be reconnected
  @param dbOpenedBlock                Callback for opening the local message database.
 @param successBlock Callback for successful connection establishment [userId: The user ID used for the current successful connection].
 @param errorBlock Callback for failed connection establishment. Triggering this callback means that SDK cannot continue to reconnect [errorCode: Error code for connection failure]

 @ discussion If this interface is called, SDK will try to reconnect within the timeLimit seconds until one of the following three situations occurs:
  First, if the connection is successful, call back successBlock (userId).
  Second, call back errorBlock (RC_CONNECT_TIMEOUT) after timeout.
  Third, if there is an error that cannot be handled by SDK, callback errorBlock (errorCode) (such as token is illegal).
  
  @ discussion After the connection is successful, SDK will take over all reconnection processing When the connection is disconnected due to network reasons, SDK will keep reconnecting until the connection is successful, and there is no need for you to do any additional connection operations.

  For situations where errorBlock shall be specifically concerned about tokenIncorrect:
  One is the token error. Please check whether the AppKey used by the client initialization is consistent with the AppKey used by your server to obtain the token.
 Second, the token expires because you set the token expiration time in the developer background, and you shall request your server to retrieve the token and establish a connection with the new token again.
  In this case, you shall ask your server to retrieve the token and establish a connection, but be careful to avoid an infinite loop so as not to ensure a good App user experience.

  @ warning If you use IMLibCore, please use this method to establish a connection with the RongCloud server;
  If you use IMKit, please use the method of the same name in RCIM to establish a connection to the RongCloud server instead of using this method.

  The callback for this method is not the original calling thread. If you shall perform a UI operation, please be careful to switch to the main thread.
 */
- (void)connectWithToken:(NSString *)token
               timeLimit:(int)timeLimit
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Disconnect from the RongCloud server

  @param isReceivePush  Does app still receive remote push after being disconnected

 @ discussion
 The system can automatically reconnect to ensure reliability of the connection because SDK switches between the foreground and background or the network is abnormal.
  Unless your App logic requires logout, generally you don't need to call this method for manual disconnection.

  @ warning If you use IMLibCore, please use this method to disconnect from the RongCloud server.
 If you use IMKit, please use the method of the same name in RCIM to disconnect from the RongCloud server instead of using this method.

  isReceivePush refers to whether remote push will be received after the connection with the RongCloud server is disconnected.
  [[RCCoreClient sharedCoreClient] disconnect:YES]  and  [[RCCoreClient sharedCoreClient]
  disconnect] are exactly the same;
  [[RCCoreClient sharedCoreClient] disconnect:NO]  and [ [RCCoreClient sharedCoreClient]
  logout] are exactly the same.
  You just need to use one of disconnect:, disconnect and logout interfaces on demand.

  @ remarks Connection
 */
- (void)disconnect:(BOOL)isReceivePush;

/*!
 *  \~chinese
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
 
 *  \~english
 Disconnect from the RongCloud server, but still receive remote push

 @ discussion
 The system can automatically reconnect to ensure reliability of the connection because SDK switches between the foreground and background or the network is abnormal.
  Unless your App logic requires logout, generally you don't need to call this method for manual disconnection.

  @ warning If you use IMLibCore, please use this method to disconnect from the RongCloud server.
 If you use IMKit, please use the method of the same name in RCIM to disconnect from the RongCloud server instead of using this method.

  [[RCCoreClient sharedCoreClient] disconnect:YES]  and [[RCCoreClient sharedCoreClient]
  disconnect] are exactly same;
  [[RCCoreClient sharedCoreClient] disconnect:NO] and [[RCCoreClient sharedCoreClient]
  logout] are exactly same.
  You just shall use one of disconnect: Disconnect and logout interface on demand.

  @ remarks Connection
 */
- (void)disconnect;

/*!
 *  \~chinese
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
 
 *  \~english
 Disconnect from the RongCloud server and do not receive remote push

 @ discussion
 The system can automatically reconnect to ensure reliability of the connection because SDK switches between the foreground and background or the network is abnormal.
  Unless your App logic requires logout, generally you don't need to call this method for manual disconnection.

  @ warning If you use IMKit, please use this method to disconnect from the RongCloud server；
 If you use IMLibCore, please use the method of the same name in RCCoreClient to disconnect from the RongCloud server instead of using this method.

  [[RCCoreClient sharedCoreClient] disconnect:YES]  and [[RCCoreClient sharedCoreClient]
  disconnect]  are exactly same;
  [[RCCoreClient sharedCoreClient] disconnect:NO] and [[RCCoreClient sharedCoreClient]
  logout] are exactly same.
  You just shall use one of disconnect: Disconnect and logout interface on demand.

  @ remarks Connection
 */
- (void)logout;

/**
 *  \~chinese
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
 
 *  \~english
 Set whether to kick out the reconnected device upon disconnection and reconnection.

 @ discussion
 If the user does not enable the multi-device login function, when the same account logs in on a new device, the account will be kicked out of the previously logged-in device.
  Due to the disconnection and reconnection function of SDK, the following conditions exist:
  When the user logs in on device A, the network of device A is unstable, and the connection is not successful, SDK will start the reconnection mechanism.
  At this time, the user logs in on the B device, and the B device is connected successfully.
  After the A device network is stable, the user connects to the A device successfully, and the B device is kicked out.
  This interface is added for this case. I
  If If enable is set as YES, when SDK is reconnected and it is found that other devices have been successfully connected at this time, the reconnected devices will be kicked out instead of forcibly kicking out the existing devices.

  @param enable Whether to kick out the reconnected equipment

 @ remarks function setting
 */
- (void)setReconnectKickEnable:(BOOL)enable;

#pragma mark - RCConnectionStatusChangeDelegate

/*!
 *  \~chinese
 设置 IMLibCore 的连接状态监听器

 @param delegate    IMLibCore 连接状态监听器

 @warning 如果您使用 IMLibCore，可以设置并实现此 Delegate 监听连接状态变化；
 如果您使用 IMKit，请使用 RCIM 中的 connectionStatusDelegate 监听连接状态变化，而不要使用此方法，否则会导致 IMKit
 中无法自动更新 UI！

 @remarks 功能设置
 
 *  \~english
 Set the connection status listener for IMLibCore

 @param delegate   IMLibCore connection status listener.

 @ warning If you use IMLibCore, you can set and implement this Delegate to listen toconnection status changes.
 If you use IMKit, please use connectionStatusDelegate in RCIM to listen to connection status changes, and do not use this method, otherwise it will cause that UI cannot be automatically updated in IMKit!

  @ remarks function setting
 */
- (void)setRCConnectionStatusChangeDelegate:(id<RCConnectionStatusChangeDelegate>)delegate;

/*!
 *  \~chinese
 获取当前 SDK 的连接状态

 @return 当前 SDK 的连接状态

 @remarks 数据获取
 
 *  \~english
 Get the connection status of the current SDK

 @ return connection status of the current SDK

 @ remarks data acquisition
 */
- (RCConnectionStatus)getConnectionStatus;

/*!
 *  \~chinese
 获取当前的网络状态

 @return 当前的网路状态

 @remarks 数据获取
 
 *  \~english
 Get the current network status

 @ return current network status

 @ remarks data acquisition
 */
- (RCNetworkStatus)getCurrentNetworkStatus;

/*!
 *  \~chinese
 SDK 当前所处的运行状态

 @remarks 数据获取
 
 *  \~english
 Current running status of SDK

 @ remarks data acquisition
 */
@property (nonatomic, assign, readonly) RCSDKRunningMode sdkRunningMode;

#pragma mark - Apple Watch Delegate

/*!
 *  \~chinese
 用于 Apple Watch 的 IMLibCore 事务监听器

 @remarks 功能设置
 
 *  \~english
 IMLibCore transaction listener for Apple Watch.

 @ remarks function setting
 */
@property (nonatomic, strong) id<RCWatchKitStatusDelegate> watchKitStatusDelegate;

/*!
 *  \~chinese
 媒体文件下载拦截器

 @remarks 功能设置
 
 *  \~english
 Media file downloading interceptor

 @ remarks function setting
 */
@property (nonatomic, weak) id<RCDownloadInterceptor> downloadInterceptor;

#pragma mark - RCMessageDestructDelegate

/**
 *  \~chinese
 设置 IMLibCore 的阅后即焚监听器

 @param delegate 阅后即焚监听器
 @discussion 可以设置并实现此 Delegate 监听消息焚烧
 @warning 如果您使用 IMKit，请不要使用此监听器，否则会导致 IMKit 中无法自动更新 UI！

 @remarks 功能设置
 
 *  \~english
 Set burn-after-reading listener of IMLibCore.

 @param delegate  Burn-after-reading listener
 @ discussion you can set and implement this Delegate to listen to message burning.
 @ warning Please do not use this listener if you use IMKit, otherwise UI cannot be automatically updated in IMKit!

  @ remarks function setting
 */
- (void)setRCMessageDestructDelegate:(id<RCMessageDestructDelegate>)delegate;

#pragma mark - currentUserInfo

/*!
 *  \~chinese
 当前登录用户的用户信息

 @discussion 用于与融云服务器建立连接之后，设置当前用户的用户信息。

 @warning 如果传入的用户信息中的用户 ID 与当前登录的用户 ID 不匹配，则将会忽略。
 如果您使用 IMLibCore，请使用此字段设置当前登录用户的用户信息；
 如果您使用 IMKit，请使用 RCIM 中的 currentUserInfo 设置当前登录用户的用户信息，而不要使用此字段。

 @remarks 数据获取
 
 *  \~english
 User information of the currently logged in user.

 @ discussion is used to set the user information of the current user after a connection is established with the RongCloud server.

  @ warning It will be ignored if the user ID in the passed user information does not match the current login user ID.
  If you use IMLibCore, this field is used to set the user information for the currently logged in user.
 If you use IMKit, use currentUserInfo in RCIM to set the user information for the current login user instead of using this field.

  @ remarks data acquisition
 */
@property (nonatomic, strong) RCUserInfo *currentUserInfo;

#pragma mark - Message Receive & Send

/*!
 *  \~chinese
 注册自定义的消息类型

 @param messageClass    自定义消息的类，该自定义消息需要继承于 RCMessageContent

 @discussion
 如果您需要自定义消息，必须调用此方法注册该自定义消息的消息类型，否则 SDK 将无法识别和解析该类型消息。
 @discussion 请在初始化 appkey 之后，token 连接之前调用该方法注册自定义消息

 @warning 如果您使用 IMLibCore，请使用此方法注册自定义的消息类型；
 如果您使用 IMKit，请使用 RCIM 中的同名方法注册自定义的消息类型，而不要使用此方法。

 @remarks 消息操作
 
 *  \~english
 Register a custom message type

 @param messageClass  Class of a custom message that needs to be inherited from RCMessageContent

 @ discussion
 If you need a custom message, you must call this method to register the type of the custom message, otherwise SDK will not be able to recognize and parse that type of message.
  @ discussion Please call this method to register custom messages after appkey initialization and before token connection.

 @ warning If you use IMLibCore, please use this method to register custom message types;
 If you use IMKit, please use the method of the same name in RCIM to register the custom message type instead of using this method.

  @ remarks message operation
 */
- (void)registerMessageType:(Class)messageClass;

#pragma mark Message Send

/*!
 *  \~chinese
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
 
 *  \~english
 Send a message

  @param conversationType    Type of conversation in which the message is sent
  @param targetId            ID of conversation that sends the message
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param successBlock        Callback for successful message sending [messageId: ID of message]
  @param errorBlock          Callback for failed message sending [nErrorCode: Error code for sending failure.
 MessageId: message ID]
 @ return                    message entity sent

 @ discussion A remote push will be received when the receiver is offline and allows remote push.
  Remote push consists of two parts, one is pushContent, which is used for display, and the other is pushData, which is used to carry data that is not displayed.

  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format is used for remote push.
  For a custom message, you shall set pushContent and pushData to define the push content yourself, otherwise remote push will not be carried out.

  If you use this method to send an image message, you shall upload the image yourself, build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of a successful upload, and then send it by using this method.

  If you use this method to send a file message, you should upload the file yourself, build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of a successful upload, and then send it by using this method.

  @ warning If you use IMLibCore, you can use this method to send messages;
 If you use IMKit, please use the method of the same name in RCIM to send a message, otherwise the UI will not be updated automatically.

  @ remarks message operation
 */
- (RCMessage *)sendMessage:(RCConversationType)conversationType
                  targetId:(NSString *)targetId
                   content:(RCMessageContent *)content
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Send a message.

  @param conversationType    Type of conversation in which the message is sent
  @param targetId            ID of conversation that sends the message
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param option              Related configuration of messages.
  @param successBlock        Callback for successful message sending [messageId: ID of message]
 @param errorBlock          Callback for message sending failure  [nErrorCode: Error code for sending failure,
 messageId: ID of the message]
 @ return                    message entity sent

 @ discussion A remote push will be received when the receiver is offline and allows remote push.
  Remote push consists of two parts, one is pushContent, which is used for display, and the other is pushData, which is used to carry data that is not displayed.

  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format is used for remote push.
  For a custom type of message, you shall set pushContent and pushData to define the push content, otherwise remote push will not be carried out.

  If you use this method to send an image message, you shall upload the image yourself, build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of a successful upload, and then send it using this method.

  If you use this method to send a file message, you shall upload the file yourself, build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of a successful upload, and then send it using this method.

  @ warning you can use this method to send messages if you use IMLibCore,
 If you use IMKit, use the method of the same name in RCIM to send a message, otherwise the UI will not be updated automatically.

  @ remarks message operation
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
 *  \~chinese
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
 
 *  \~english
 Send media messages (image messages or file messages)

  @param conversationType    Type of conversation in which the message is sent
  @param targetId            ID of conversation in which the message is sent
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param progressBlock       Callback for message sending progress update [progress: current sending progress, 0< = progress < = 100, messageId: message ID]
  @param successBlock        Callback for successful message sending [messageId: message ID]
  @param errorBlock          callback for failed message sending [errorCode: error code for sending failure. messageId: message ID]
  @param cancelBlock         Callback for the user canceling message sending [messageId: message ID]
  @ return                    message entity sent .

  @ discussion A remote push can be received when the receiver is offline and allows remote push.
  The remote push consists of two parts, one is pushContent for display and the other is pushData for carrying data that is not displayed.

  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format will be used for remote push.
  For a custom type of message, you shall set pushContent and pushData to define the push content, otherwise remote push will not be carried out.

  If you need to upload images to your own server, you should build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of the successful uploading, and then use the RCCoreClient's
 sendMessage:targetId:content:pushContent:pushData:success:error: method or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  If you need to upload files to your own server, you should build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method.
 or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  @ warning If you use IMLibCore, you can use this method to send meida messages;
 If you use IMKit, please use the method of the same name in RCIM to send a media message, otherwise the UI will not be updated automatically.

  @ remarks message operation
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
 *  \~chinese
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
 
 *  \~english
 Send media messages (upload media information such as images or files to the specified server)

  @param conversationType    Type of conversation in which the message is sent.
  @param targetId            ID of conversation in which the message is sent
  @param content             Content of the message
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param uploadPrepareBlock  IMKit listening of media file uploading progress updates.
 [uploadListener: current sending progress listening, which is used by SDK to update IMKit UI]
  @param progressBlock        Callback for message sending progress update [progress: current sending progress, 0< = progress < = 100, messageId: message ID].
  @param successBlock        Callback for successful message sending [ messageId: message ID].
  @param errorBlock          Callback for failed message sending [errorCode: error code for sending failure
 messageId: message ID].
  @param cancelBlock         Callback for the user canceling message sending [messageId: message ID].
  @ return                      message entity sent.

  @ discussion This method is for IMKit only.
  If you need to upload pictures to your own server and use IMLibCore, you should build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method, or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  If you need to upload a file to your own server and use IMLibCore, you should build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method, or the sendMessage:targetId:content:pushContent:success:error: method for sending, and do not use this method.

  @ remarks message operation
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
 *  \~chinese
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
 
 *  \~english
 Send a message.

  @param message             The message entity to be sent (you shall ensure that the conversationType, targetId and messageContent in message are valid values)
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline.
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
  @param successBlock        Callback for successful message sending [successMessage: Message entity].
 @param errorBlock Callback for failed message sending [nErrorCode: Error code for send failure, errorMessage: message entity].
 @ return sent message entity.

 @ discussion Receive a remote push when the receiver is offline and allows remote push.
  Remote push consists of two parts, one is pushContent, which is used for display, and the other is pushData, which is used to carry data that is not displayed.
  
  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format is used for remote push.
  For a custom type of message, you shall set pushContent and pushData to define the push content, otherwise remote push will not be carried out.
  
  If you use this method to send an image message, you shall upload the image yourself, build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of a successful upload, and then send it using this method.
  
  If you use this method to send a file message, you shall upload the file yourself, build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of a successful upload, and then send it using this method.
  
  @ warning you can use this method to send messages if you use IMLibCore,
 If you use IMKit, use the method of the same name in RCIM to send a message, otherwise the UI will not be updated automatically.
  
  @ remarks message operation
 */
- (RCMessage *)sendMessage:(RCMessage *)message
               pushContent:(NSString *)pushContent
                  pushData:(NSString *)pushData
              successBlock:(void (^)(RCMessage *successMessage))successBlock
                errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Send media messages (images messages or file messages)

  @param message             Message entity to be sent (you shall ensure that the conversationType, targetId and messageContent in message are valid values)
  @param pushContent         Remote push content that needs to be displayed when the receiver is offline
  @param pushData            Non-display data that the receiver needs to carry in the remote push when the receiver is offline
  @param progressBlock       Callback for message sending progress update [current sending progress of progress:, 0 < = progress < = 100, progressMessage: message entity]
  @param successBlock        Callback for successful message sending [successMessage: message entity]
  @param errorBlock          Callback for failed message sending [nErrorCode: error code for sending failure, errorMessage: message entity]
  @param cancelBlock         User canceled callback for message sending [cancelMessage: message entity].
 @ return                     message entity sent

 @ discussion A remote push can be received when the receiver is offline and allows remote push.
  The remote push consists of two parts, one is pushContent for display and the other is pushData for carrying data that is not displayed.
  
  Type of SDK built-in message. If you set pushContent and pushData to nil, the default push format will be used for remote push.
  For a custom type of message, you shall set pushContent and pushData to define the push content, otherwise remote push will not be carried out.
  
  If you shall upload images to your own server, you shall build a RCImageMessage object, set the imageUrl field in RCImageMessage to the URL address of the successful uploading, and then use the RCCoreClient's
 SendMessage:targetId:content:pushContent:pushData:success:error: method or the sendMessage:targetId:content:pushContent:success:error: method, and do not use this method.
  
  If you shall upload files to your own server, build a RCFileMessage object, set the fileUrl field in RCFileMessage to the URL address of the successful upload, and then use the RCCoreClient's sendMessage:targetId:content:pushContent:pushData:success:error: method.
 Or the sendMessage:targetId:content:pushContent:success:error: method, and do not use this method.
  
  @ warning you can use this method to send media messages if you use IMLibCore,
 If you use IMKit, use the method of the same name in RCIM to send media messages, otherwise UI will not be updated automatically.
  
  @ remarks message operation
 */
- (RCMessage *)sendMediaMessage:(RCMessage *)message
                    pushContent:(NSString *)pushContent
                       pushData:(NSString *)pushData
                       progress:(void (^)(int progress, RCMessage *progressMessage))progressBlock
                   successBlock:(void (^)(RCMessage *successMessage))successBlock
                     errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock
                         cancel:(void (^)(RCMessage *cancelMessage))cancelBlock;



/*!
 *  \~chinese
 取消发送中的媒体信息

 @param messageId           媒体消息的 messageId

 @return YES 表示取消成功，NO 表示取消失败，即已经发送成功或者消息不存在。

 @remarks 消息操作
 
 *  \~english
 Cancel media messages in transmission

 MessageId of media messages.

 @ return YES: canceled successfully, NO: failed to cancel, that is, the message has been sent successfully or the message does not exist.

  @ remarks message operation
 */
- (BOOL)cancelSendMediaMessage:(long)messageId;

/*!
 *  \~chinese
 插入向外发送的消息（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param sentStatus          发送状态
 @param content             消息的内容
 @return             插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。

 @remarks 消息操作
 
 *  \~english
 Insert an outgoing message (the message is only inserted into the local database and is not actually sent to the server and the other party).

 @param conversationType    Conversation type
 @param targetId            Conversation ID
 @param sentStatus          Sending status.
 @param content             Content of the message.
 @ return              message entity inserted .

 @ discussion This method does not support the chatroom conversation type.

  @ remarks message operation
 */
- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                          sentStatus:(RCSentStatus)sentStatus
                             content:(RCMessageContent *)content;

/*!
 *  \~chinese
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
 
 *  \~english
 Insert a message sent outward at a specified time (this method will affect message sorting if there is a problem with sentTime and shall be used with caution!!)
 (The message is only inserted into the local database and is not actually sent to the server and the other party).

  @param conversationType    Conversation type
  @param targetId            Conversation ID.
  @param sentStatus          Sending status.
  @param content             Content of the message.
  @param sentTime            Unix timestamp of the message sent, in milliseconds (0 will be inserted according to local time).
 @ return                    message entity inserted.

 @ discussion This method does not support the chatroom conversation type. If sentTime < = 0, it will be ignored and the time at which it is inserted shall prevail.

  @ remarks message operation
 */
- (RCMessage *)insertOutgoingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                          sentStatus:(RCSentStatus)sentStatus
                             content:(RCMessageContent *)content
                            sentTime:(long long)sentTime;

/*!
 *  \~chinese
 插入接收的消息（该消息只插入本地数据库，实际不会发送给服务器和对方）

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param senderUserId        发送者 ID
 @param receivedStatus      接收状态
 @param content             消息的内容
 @return                    插入的消息实体

 @discussion 此方法不支持聊天室的会话类型。

 @remarks 消息操作
 
 *  \~english
 Insert the received message (the message is only inserted into the local database and is not actually sent to the server and the other party).

  @param conversationType    Conversation type
  @param targetId            Conversation ID
  @param senderUserId        Sender ID
  @param receivedStatus      Receiving status
  @param content             Content of the message
  @ return                    message entity inserted.

  @ discussion This method does not support the chatroom conversation type.

  @ remarks message operation
 */
- (RCMessage *)insertIncomingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                        senderUserId:(NSString *)senderUserId
                      receivedStatus:(RCReceivedStatus)receivedStatus
                             content:(RCMessageContent *)content;


/*!
 *  \~chinese
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
 
 *  \~english
 Insert the received message (this method will affect message sorting if there is a problem with sentTime and shall be used with caution!!) (The message is only inserted into the local database and is not actually sent to the server and the other party).

  @param conversationType    Conversation type
  @param targetId            Conversation ID.
  @param senderUserId        Sender ID.
  @param receivedStatus      Receiving status
  @param content             Content of the message.
  @param sentTime            Unix timestamp of the message sent, in milliseconds (0 will be inserted according to local time).
  @ return                    message entity inserted.

  @ discussion This method does not support the chatroom conversation type.

  @ remarks message operation
 */
- (RCMessage *)insertIncomingMessage:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                        senderUserId:(NSString *)senderUserId
                      receivedStatus:(RCReceivedStatus)receivedStatus
                             content:(RCMessageContent *)content
                            sentTime:(long long)sentTime;


/*!
 *  \~chinese
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
 
 *  \~english
 Insert received messages (the messages are only inserted into the local database and will not actually be sent to the server and the other party) in batches
 RCMessage The following properties will be stored into the database, and the residual properties will be discarded
 conversationType  Conversation type
 targetId            Conversation ID
 messageDirection    Message direction
 senderUserId        Sender ID
 receivedStatus      receiving status; When the message is directed to the receiver and receivedStatus is ReceivedStatus_UNREAD, the message is not read
 sentStatus          Sending status
 content             Content of message.
 sentTime            Unix timestamp for sending a message with the unit as milliseconds, which will affect message sorting
 extra            Additional fields for RCMessage

 @ discussion This method does not support the chatroom conversation type. A maximum of 500 messages are processed for each batch, and NO is returned for more than 500 messages.
 @ discussion The unread messages will accumulate to the number of unread replies.
 @ remarks message operation
 */
- (BOOL)batchInsertMessage:(NSArray<RCMessage *> *)msgs;

/*!
 *  \~chinese
 根据文件 URL 地址下载文件内容

 @param fileName            指定的文件名称 需要开发者指定文件后缀 (例如 rongCloud.mov)
 @param mediaUrl            文件的 URL 地址
 @param progressBlock       文件下载进度更新的回调 [progress:当前的下载进度, 0 <= progress <= 100]
 @param successBlock        下载成功的回调[mediaPath:下载成功后本地存放的文件路径 文件路径为文件消息的默认地址]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调

 @discussion 用来获取媒体原文件时调用。如果本地缓存中包含此文件，则从本地缓存中直接获取，否则将从服务器端下载。

 @remarks 多媒体下载
 
 *  \~english
 Download the contents of the file according to the URL address of the file.

  @param fileName            The specified file name requires the developer to specify a file suffix (for example, rongCloud.mov)
  @param mediaUrl            URL address of the file.
  @param progressBlock            Callback for file download progress update [progress: current download progress, 0 < = progress < = 100]
  @param successBlock            Callback after a successful download [mediaPath: the file path stored locally after a successful download is the default address of the file message]
  @param errorBlock            Callback for download failure [errorCode: error code for download failure]
  @param cancelBlock            Callback for download canceled by user.

 @ discussion Call when get the media source file. If this file is included in the local cache, it is obtained directly from the local cache, otherwise it will be downloaded from the server side.

  @ remarks multimedia downloading
*/
- (void)downloadMediaFile:(NSString *)fileName
                 mediaUrl:(NSString *)mediaUrl
                 progress:(void (^)(int progress))progressBlock
                  success:(void (^)(NSString *mediaPath))successBlock
                    error:(void (^)(RCErrorCode errorCode))errorBlock
                   cancel:(void (^)(void))cancelBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Download the media information in the message content.

 @param conversationType    Conversation type of the message.
 @param targetId            Conversation ID of the message.
 @param mediaType            Type of the multimedia file in the message content. Currently, only images are supported.
 @param mediaUrl            Network URL of multimedia file.
 @param progressBlock            callback for message download progress update [progress: current download progress:, 0< = progress < = 100]
 @param successBlock            Callback for successful download
 [mediaPath: path of files stored locally after successful download].
 @param errorBlock            Callback for download failure [errorCode: error code for download failure]
 @param cancelBlock            Callback for download canceled by user

 @ discussion Call when get the media source file. If this file is included in the local cache, it is obtained directly from the local cache, otherwise it will be downloaded from the server side.
  @ remarks multimedia downloading
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
 *  \~chinese
 下载消息内容中的媒体信息

 @param messageId           媒体消息的 messageId
 @param progressBlock       消息下载进度更新的回调 [progress:当前的下载进度, 0 <= progress <= 100]
 @param successBlock        下载成功的回调[mediaPath:下载成功后本地存放的文件路径]
 @param errorBlock          下载失败的回调[errorCode:下载失败的错误码]
 @param cancelBlock         用户取消了下载的回调

 @discussion 用来获取媒体原文件时调用。如果本地缓存中包含此文件，则从本地缓存中直接获取，否则将从服务器端下载。

 @remarks 多媒体下载
 
 *  \~english
 Download the media information in the message content.

 @param messageId           MessageId of media messages
 @param progressBlock           callback for message download progress update [progress: current download progress, 0 < = progress < = 100]
 @param successBlock           Callback for successful download [mediaPath: path of files stored locally after successful download].
 @param errorBlock           callback for download failure [errorCode: error code for download failure ]
 @param cancelBlock           Callback for download canceled by user.

 @ discussion Call when get the media source file. If this file is included in the local cache, it is obtained directly from the local cache, otherwise it will be downloaded from the server side.

  @ remarks multimedia downloading
 */
- (void)downloadMediaMessage:(long)messageId
                    progress:(void (^)(int progress))progressBlock
                     success:(void (^)(NSString *mediaPath))successBlock
                       error:(void (^)(RCErrorCode errorCode))errorBlock
                      cancel:(void (^)(void))cancelBlock;

/*!
 *  \~chinese
 取消下载中的媒体信息

 @param messageId 媒体消息的messageId

 @return YES 表示取消成功，NO表示取消失败，即已经下载完成或者消息不存在。

 @remarks 多媒体下载
 
 *  \~english
 Cancel the media information in downloading

 @param messageId MessageId of media messages

 @ return YES: canceled successfully, NO: failed to cancel, that is, the message has been sent successfully or the message does not exist.

  @ remarks multimedia downloading
 */
- (BOOL)cancelDownloadMediaMessage:(long)messageId;

/*!
 *  \~chinese
 取消下载中的媒体信息

 @param mediaUrl 媒体消息 Url

 @return YES 表示取消成功，NO 表示取消失败，即已经下载完成或者消息不存在。

 @remarks 多媒体下载
 
 *  \~english
 Cancel the media information in downloading

 @param mediaUrl Url of media message

 @ return YES: canceled successfully, NO: failed to cancel, that is, the message has been downloaded successfully or the message does not exist.

  @ remarks multimedia downloading
*/
- (BOOL)cancelDownloadMediaUrl:(NSString *)mediaUrl;

/*!
 *  \~chinese
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
 
 *  \~english
 Send directed messages.

 @param conversationType         Type of conversation in which the message is sent
 @param targetId         Conversation ID that sends the message
 @param userIdList         List of user ID receiving messages
 @param content         Content of the message
 @param pushContent         Remote push content that needs to be displayed when the receiver is offline
 @param pushData         Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
 @param successBlock         Callback for successful message sending [messageId: message ID]
 @param errorBlock         Callback for failed message sending [errorCode: error code for sending failure,
 messageId: message ID]

 @ return Message entity sent.

 @ discussion This method is used to send messages to some of the users in groups and discussion groups, and other users will not receive this message.
  If you use IMLibCore, you can use this method to send directed messages.
 If you use IMKit, please use the method of the same name in RCIM to send a directed message, otherwise the UI will not be updated automatically.

  @ warning This method currently only supports groups and discussion groups.

  @ remarks message operation
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
 *  \~chinese
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
 
 *  \~english
 Send directed messages.

 @param message       Message entity
 @param userIdList       List of user ID receiving messages.
 @param pushContent       Remote push content that needs to be displayed when the receiver is offline.
 @param pushData       Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
 @param successBlock       Callback for successful message sending [successMessage: message sent successfully].
 @param errorBlock       callback for failed message sending [nErrorCode: error code for sending failure, errorMessage: message failed in sending]

 @ return message entity sent

 @ discussion This method is used to send messages to some of the users in groups and discussion groups, and other users will not receive this message.

  @ warning This method currently only supports groups and discussion groups.

  @ remarks message operation
 */
- (RCMessage *)sendDirectionalMessage:(RCMessage *)message
                         toUserIdList:(NSArray *)userIdList
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                         successBlock:(void (^)(RCMessage *successMessage))successBlock
                           errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Send directed messages

 @param message       Message entity
 @param userIdList       List of user ID receiving messages
 @param pushContent       Remote push content that needs to be displayed when the receiver is offline.
 @param pushData       Non-display data that the receiver needs to carry in the remote push when the receiver is offline.
 @param option       Related configuration of messages.
 @param successBlock       Callback for successful message sending [successMessage: message sent successfully]
 @param errorBlock       callback for failed message sending [nErrorCode: error code for sending failure, errorMessage: message failed in sending].

 @ return message entity sent.

 @ discussion This method is used to send messages to some of the users in groups and discussion groups, and other users will not receive this message.
  

  @ warning This method currently only supports groups and discussion groups.

  @ remarks message operation
 */
- (RCMessage *)sendDirectionalMessage:(RCMessage *)message
                         toUserIdList:(NSArray *)userIdList
                          pushContent:(NSString *)pushContent
                             pushData:(NSString *)pushData
                               option:(RCSendMessageOption *)option
                         successBlock:(void (^)(RCMessage *successMessage))successBlock
                           errorBlock:(void (^)(RCErrorCode nErrorCode, RCMessage *errorMessage))errorBlock;

#pragma mark RCIMClientReceiveMessageDelegate
/*!
 *  \~chinese
 设置 IMLibCore 的消息接收监听器

 @param delegate    IMLibCore 消息接收监听器
 @param userData    用户自定义的监听器 Key 值，可以为 nil

 @discussion
 设置 IMLibCore 的消息接收监听器请参考 RCCoreClient 的 setReceiveMessageDelegate:object:方法。

 userData 为您自定义的任意数据，SDK 会在回调的 onReceived:left:object:方法中传入作为 object 参数。
 您如果有设置多个监听，会只有最终的一个监听器起作用，您可以通过该 userData 值区分您设置的监听器。如果不需要直接设置为
 nil 就可以。

 @warning 如果您使用 IMLibCore，可以设置并实现此 Delegate 监听消息接收；
 如果您使用 IMKit，请使用 RCIM 中的 receiveMessageDelegate 监听消息接收，而不要使用此方法，否则会导致 IMKit
 中无法自动更新 UI！

 @remarks 功能设置
 
 *  \~english
 Set the message receiving listener for IMLibCore

 @param delegate       IMLibCore message receiving listener
 @param userData       Key value of user-defined listener, which can be nil

 @ discussion
 For how to set the message receiving listener for IMLibCore, please refer to the setReceiveMessageDelegate:object: method of RCCoreClient.

  UserData is any data you customized, and SDK will be passed as an object parameter in the onReceived:left:object: method of the callback.
  If you set multiple listeners, only the final listener will work. You can distinguish the listeners you set by this userData value. If it is not required, it is directly set as Nil.

  @ warning If you use IMLibCore, you can set and enable this Delegate to listen to message receiving;
 If you use IMKit, please use receiveMessageDelegate in RCIM to listen to message receiving instead of using this method, otherwise it will cause that the UI cannot be automatically updated in IMKit!

  @ remarks function setting
 */
- (void)setReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate object:(id)userData;

#pragma mark - RCMessageInterceptor
/*!
 *  \~chinese
 设置消息拦截器

 @discussion 可以设置并实现此拦截器来进行消息的拦截处理

 @remarks 功能设置
 
 *  \~english
 Set message interceptor

 @ discussion it can set and enable this interceptor to intercept messages

 @ remarks function setting
 */
@property (nonatomic, weak) id<RCMessageInterceptor> messageInterceptor;

#pragma mark - Message Read Receipt

/*!
 *  \~chinese
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
 
 *  \~english
 Send a message reading receipt in a conversation

 @param conversationType        Conversation type
 @param targetId        Conversation ID
 @param timestamp        The sending timestamp of the last message read by the conversation.
 @param successBlock        Callback for successful sending
 @param errorBlock        Callback for sending failure [nErrorCode: error code for failure]

 @ discussion This interface only supports single chat. If you use IMLibCore, you can register to listen to
 RCLibDispatchReadReceiptNotification notification, and use IMKit to set directly
 enabledReadReceiptConversationTypeList in RCIM.h.

  @ warning Currently only support single chat.

  @ remarks advanced functions
 */
- (void)sendReadReceiptMessage:(RCConversationType)conversationType
                      targetId:(NSString *)targetId
                          time:(long long)timestamp
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 *  \~chinese
 请求消息阅读回执

 @param message      要求阅读回执的消息
 @param successBlock 请求成功的回调
 @param errorBlock   请求失败的回调[nErrorCode: 失败的错误码]

 @discussion 通过此接口，可以要求阅读了这条消息的用户发送阅读回执。

 @remarks 高级功能
 
 *  \~english
 Request message reading receipt

 @param message        Request to read the message of the receipt
 @param successBlock        Callback for successful request
 @param errorBlock        Callback for failed request [nErrorCode: Error code for failure]

 @ discussion With this interface, the user who has read this message can be asked to send a reading receipt.

  @ remarks advanced functions
 */
- (void)sendReadReceiptRequest:(RCMessage *)message
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 *  \~chinese
 发送阅读回执

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param messageList      已经阅读了的消息列表
 @param successBlock     发送成功的回调
 @param errorBlock       发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 当用户阅读了需要阅读回执的消息，可以通过此接口发送阅读回执，消息的发送方即可直接知道那些人已经阅读。

 @remarks 高级功能
 
 *  \~english
 Send a reading receipt

 @param conversationType        Conversation type
 @param targetId        Conversation ID
 @param messageList        List of messages that have been read
 @param successBlock        Callback for successful sending
 @param errorBlock        Callback for failed sending [nErrorCode: Error code of failure]

 @ discussion When a user reads a message that needs to be read, a reading receipt cane be sent through this interface, and the sender of the message can directly know who has read the message.

  @ remarks advanced functions
 */
- (void)sendReadReceiptResponse:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                    messageList:(NSArray<RCMessage *> *)messageList
                        success:(void (^)(void))successBlock
                          error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 *  \~chinese
 同步会话阅读状态（把指定会话里所有发送时间早于 timestamp 的消息置为已读）

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param timestamp        已经阅读的最后一条消息的 Unix 时间戳(毫秒)
 @param successBlock     同步成功的回调
 @param errorBlock       同步失败的回调[nErrorCode: 失败的错误码]

 @remarks 高级功能
 
 *  \~english
 Synchronize conversation reading status (set all messages sent before timestamp in a specified conversation to be read)

 @param conversationType        Conversation type
 @param targetId        Conversation ID
 @param timestamp        Unix timestamp of the last message read (in milliseconds)
 @param successBlock        Callback for successful synchronization
 @param errorBlock        Callback for failed synchronization [nErrorCode: Error code for failure].

 @ remarks advanced functions
 */
- (void)syncConversationReadStatus:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                              time:(long long)timestamp
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode nErrorCode))errorBlock;

#pragma mark - Message Recall

/*!
 *  \~chinese
 撤回消息

 @param message      需要撤回的消息
 @param pushContent 当下发 push 消息时，在通知栏里会显示这个字段，不设置将使用融云默认推送内容
 @param successBlock 撤回成功的回调 [messageId:撤回的消息 ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]

 @warning 仅支持单聊、群组和讨论组。

 @remarks 高级功能
 
 *  \~english
 Recall the message

 @param message      Messages to be recalled
 @param pushContent  When a push message is distributed, this field will be displayed in the notification bar. If it is not set, the default content will be pushed by RongCloud.
 @param successBlock  Callback for successful recall [messageId: ID of message recalled, the message has been changed to a new message].
 @param errorBlock   Callback for failed recall [errorCode: error code for recall failure]

 @ warning Only single chat, groups and discussion groups are supported.

  @ remarks advanced functions
 */
- (void)recallMessage:(RCMessage *)message
          pushContent:(NSString *)pushContent
              success:(void (^)(long messageId))successBlock
                error:(void (^)(RCErrorCode errorcode))errorBlock;

/*!
 *  \~chinese
 撤回消息

 @param message      需要撤回的消息
 @param successBlock 撤回成功的回调 [messageId:撤回的消息 ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 @remarks 高级功能
 
 *  \~english
 Recall the message

 @param message      Messages to be recalled
 @param successBlock  Callback for successful recall [messageId: ID of message recalled, the message has been changed to a new message]
 @param errorBlock   Callback for failed ecall [errorCode: error code for recall failure]
 @ remarks advanced function
 */
- (void)recallMessage:(RCMessage *)message
              success:(void (^)(long messageId))successBlock
                error:(void (^)(RCErrorCode errorcode))errorBlock;

#pragma mark - Message Operation

/*!
 *  \~chinese
 获取某个会话中指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param count               需要获取的消息数量
 @return                    消息实体 RCMessage 对象列表

 @discussion
 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 如果会话中的消息数量小于参数 count 的值，会将该会话中的所有消息返回。

 @remarks 消息操作
 
 *  \~english
 Get the specified number of latest message entities in a conversation

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param count            Number of messages to be obtained
 @ return             RCMessage object list of message entity

 @ discussion
 This method gets the specified number of latest message entities in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.

  @ remarks message operation
 */
- (NSArray *)getLatestMessages:(RCConversationType)conversationType targetId:(NSString *)targetId count:(int)count;

/*!
 *  \~chinese
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
 
 *  \~english
 Get the latest message entity of the specified number before the specified message in the conversation.

 @param conversationType     Conversation type
 @param targetId     Conversation ID
 @param oldestMessageId     ID of due message.
 @param count     Number of messages to be obtained.
 @ return                    RCMessage object list of message entity

 @ discussion
 This method gets the specified number of latest message entities in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to oldestMessageId. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.
  E.g.
  If the oldestMessageId is 10 and the count is 2, a list of Message objects with messageId as 9 and 8 will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 *  \~chinese
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
 
 *  \~english
 Get the latest message entity of the specified number and specified message types before the specified message in the conversation.

 @param conversationType          Conversation type
 @param targetId          Conversation ID
 @param objectName          Type name of the message content. If you want to get all types of messages, please pass nil
 @param oldestMessageId           ID of due message
 @param count          Number of messages to be obtained.
 @ return                    RCMessage object list of message entity

 @ discussion
 This method gets the specified number of latest message entities in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to oldestMessageId. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.
  For example, if the oldestMessageId is 10 and the count is 2, a list of Message objects with messageId as 9 and 8 will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     objectName:(NSString *)objectName
                oldestMessageId:(long)oldestMessageId
                          count:(int)count;

/*!
 *  \~chinese
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
 
 *  \~english
 Get a list of forward or backward searched message entities with specified messages, specified number and specified message type in the conversation

 @param conversationType       Conversation type
 @param targetId       Conversation ID
 @param objectName       Type name of the message content. If you want to get all types of messages, please pass nil.
 @param baseMessageId       Current message ID.
 @param isForward       Query direction: true indicates forward and false indicates backward.
 @param count       Number of messages to be obtained
 @ return                    object list of message entity RCMessage

 @ discussion
 This method gets the latest message entities before or after baseMessageId with the specified number, message type, and query direction, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to baseMessageId. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     objectName:(NSString *)objectName
                  baseMessageId:(long)baseMessageId
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 *  \~chinese
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
 
 *  \~english
 Get a list of forward or backward searched message entities with a specified time, a specified number and a specified message type (multiple) in a conversation

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param objectNames         List of type names for message content
 @param sentTime         Current message timestamp
 @param isForward         Query direction: true indicates forward and false indicates backward
 @param count         Number of messages to be obtained.
 @ return                     object list of message entity RCMessage

 @ discussion
 This method gets a list of message entities before and after the sentTime with a specified number and a specified message type (multiple) in the conversation, and the returned message entities are in chronological order from earliest to most recent.
  The returned message does not contain the message corresponding to sentTime. If the number of messages in the conversation is less than the value of the parameter count, all messages in the conversation will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                    objectNames:(NSArray *)objectNames
                       sentTime:(long long)sentTime
                      isForward:(BOOL)isForward
                          count:(int)count;

/*!
 *  \~chinese
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
 
 *  \~english
 Searches the the number of beforeCount and afterCount messages for the specified message in the conversation. The list of returned messages contains the specified message. The message in the list are in chronological order from earliest to most recent.

  @param conversationType    Conversation type
 @param targetId         Conversation ID
 @param sentTime         Time when the message is sent
 @param beforeCount         Specify the number of messages in the first part of the message.
 @param afterCount         Specify the number of messages in the latter part of the message.
 @ return                    object list of message entity RCMessage

 @ discussion
 Get this message, beforeCount messages ahead of this message and afterCount messages after this message in the conversation. If there are not enough messages before and after the message, the actual number of messages will be returned.

  @ remarks message operation
 */
- (NSArray *)getHistoryMessages:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                       sentTime:(long long)sentTime
                    beforeCount:(int)beforeCount
                     afterCount:(int)afterCount;

/*!
 *  \~chinese
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
 
 *  \~english
 Clear historical messages from the server

 @param conversationType          Conversation type
 @param targetId          Conversation ID
 @param recordTime          Clear the message timestamp, [0 < = recordTime < = the sentTime of the last message in the current conversation, 0:
 Clear all messages, other values: clear messages less than or equal to recordTime].
 @param successBlock          Callback for successful acquisition
 @param errorBlock          Callback for failed acquisition [status: error code for clearing failure ]

 @ discussion
 This method clears historical messages from the server, bu the historical message cloud storage function must be activated first.
  For example, if you don't want to get more history messages from the server, you can only get the history messages after the timestamp after the recordTime has been cleared successfully.

  @ remarks message operation
 */
- (void)clearRemoteHistoryMessages:(RCConversationType)conversationType
                          targetId:(NSString *)targetId
                        recordTime:(long long)recordTime
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Clear historical messages.

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param recordTime         Clear the message timestamp, [0 < = recordTime < = the sentTime of the last message in the current conversation. 0:
 Clear all messages, other values: clear messages less than or equal to recordTime].
 @param clearRemote         Whether to delete server messages at the same time.
 @param successBlock         Callback for successful acquisition.
 @param errorBlock         Callback for failed acquisition [status: error code for clearing failure].

 @ discussion
 This method can clear server-side historical messages and local messages. If you clear messages on the server, you must first activate the historical message cloud storage functions.
  For example, if you don't want to get more historical messages from the server, you can specify the recordTime and set clearRemote to YES to clear the messages, and then you can only get the historical message after the timestamp. If clearRemote passes NO, only local messages are cleared.

  @ remarks message operation
 */
- (void)clearHistoryMessages:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                  recordTime:(long long)recordTime
                 clearRemote:(BOOL)clearRemote
                     success:(void (^)(void))successBlock
                       error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Get previous historical messages from the server.

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param recordTime         Due message sending timestamp, in milliseconds.
 @param count         Number of messages to be obtained, 0 < count < = 20.
 @param successBlock         Callback for successful acquisition [messages: array of obtained historical messages; isRemaining: whether there are any remaining messages; YES indicates that there is still any remaining messages; NO indicates that there is no remaining messages]
 @param errorBlock         Callback for failed acquisition [status: error code for acquisition failure]

 @ discussion
 This method obtains the previous historical messages from the server, but the historical message cloud storage function must be activated first.
  For example, if there are 10 messages in the local conversation, and you want to pull more messages saved on the server, recordTime should pass in the earliest message sending timestamp, and count should pass in a value between 1 and 20.

  @ discussion Messages that can be found in the local database will not be returned by this interface, so it is recommended to first take the local historical messages by using the related interfaces of the getHistoryMessages.
 After the local message is taken, the remote historical messages are obtained through this interface

 @ remarks message operation
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                      recordTime:(long long)recordTime
                           count:(int)count
                         success:(void (^)(NSArray *messages, BOOL isRemaining))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Get previous historical messages from the server

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param option         Configurable parameters
 @param successBlock         Callback for successful acquisition [messages: array of obtained historical messages; isRemaining: whether there are any remaining messages; YES:
 Indicates that there is still any remaining messages; NO: indicates that there is no remaining messages].
 @param errorBlock         Callback for failed acquisition [status: error code for acquisition failure].

 @ discussion
 This method obtains the previous historical messages from the server, but the historical message cloud storage function must be activated first.
  For example, if there are 10 messages in the local conversation, and you want to pull more messages saved on the server, recordTime should pass in the earliest message sending timestamp, and count should pass in a value between 1 and 20.

  @ remarks message operation
 */
- (void)getRemoteHistoryMessages:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                          option:(RCRemoteHistoryMsgOption *)option
                         success:(void (^)(NSArray *messages, BOOL isRemaining))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
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
 
 *  \~english
 Get historical messages

 @param conversationType         Conversation type
 @param targetId         Conversation ID
 @param option         Configurable parameters
 @param complete         Callback for successful acquisition [messages: array of obtained historical messages; Code: succeeded or not; 0: successful; non-0: failed. In this case, there may be a message break in the messages array]

 @ discussion The historical message cloud storage function must be activated.
  @ discussion The count passes a value between 1 and 20.
  @ discussion This method first obtains historical messages locally, and synchronizes the missing parts from the server if it is missing locally;
  @ discussion If synchronization fails on the server, a non-0 errorCode will be returned, and the messages that can be accessed locally will be called back.

  @ remarks message operation
 */
- (void)getMessages:(RCConversationType)conversationType
           targetId:(NSString *)targetId
             option:(RCHistoryMessageOption *)option
           complete:(void (^)(NSArray *messages, RCErrorCode code))complete;

/*!
 *  \~chinese
 获取会话中@提醒自己的消息

 @param conversationType    会话类型
 @param targetId            会话 ID

 @discussion
 此方法从本地获取被@提醒的消息(最多返回 10 条信息)
 @warning 使用 IMKit 注意在进入会话页面前调用，否则在进入会话清除未读数的接口 clearMessagesUnreadStatus: targetId:
 以及 设置消息接收状态接口 setMessageReceivedStatus:receivedStatus:会同步清除被提示信息状态。

 @remarks 高级功能
 
 *  \~english
 Get the @ reminder messages in the conversation.

 @param conversationType         Conversation type
 @param targetId         Conversation ID.

 @ discussion
 This method gets the @ reminder messages locally (a maximum of 10 messages are returned).
 @ warning When the IMKit is used, note that it is called before the conversation page is entered, otherwise the unread interface clearMessagesUnreadStatus: is cleared when the conversation is entered. targetId:
  When the message receiving status interface setMessageReceivedStatus:receivedStatus: is set, it will synchronously clear the prompted information status.

  @ remarks advanced functions
 */
- (NSArray *)getUnreadMentionedMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 获取消息的发送时间（Unix 时间戳、毫秒）

 @param messageId   消息 ID
 @return            消息的发送时间（Unix 时间戳、毫秒）

 @remarks 消息操作
 
 *  \~english
 Get the sending time of message(Unix timestamp, in milliseconds).

 @param messageId         Message ID
  @ return            sending time of message (Unix timestamp, in milliseconds).

 @ remarks message operation
 */
- (long long)getMessageSendTime:(long)messageId;

/*!
 *  \~chinese
 通过 messageId 获取消息实体

 @param messageId   消息 ID（数据库索引唯一值）
 @return            通过消息 ID 获取到的消息实体，当获取失败的时候，会返回 nil。

 @remarks 消息操作
 
 *  \~english
 Get the message entity through messageId

 @param messageId         Message ID (unique value of database index)
 @ return            For message entity obtained through the message ID, when it fails to fetch, nil is returned.

  @ remarks message operation
 */
- (RCMessage *)getMessage:(long)messageId;

/*!
 *  \~chinese
 通过全局唯一 ID 获取消息实体

 @param messageUId   全局唯一 ID（服务器消息唯一 ID）
 @return 通过全局唯一ID获取到的消息实体，当获取失败的时候，会返回 nil。

 @remarks 消息操作
 
 *  \~english
 Get message entities through globally unique ID.

 @param messageUId         Globally unique ID (unique ID of server message)
 @ return For the message entity obtained through the globally unique ID, when it fails to fetch, nil is returned.

  @ remarks message operation
 */
- (RCMessage *)getMessageByUId:(NSString *)messageUId;

/**
 *  \~chinese
 * 获取会话里第一条未读消息。
 *
 * @param conversationType 会话类型
 * @param targetId   会话 ID
 * @return 第一条未读消息的实体。
 * @remarks 消息操作
 *
 *  \~english
 * Get the first unread message in the conversation.
 *
 * @param conversationType         Conversation type
 * @param targetId         Conversation ID
 * @ return Entity of the first unread message.
 * @ remarks Message operation
 */
- (RCMessage *)getFirstUnreadMessage:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 删除消息

 @param messageIds  消息 ID 的列表，元素需要为 NSNumber 类型
 @return            是否删除成功

 @remarks 消息操作
 
 *  \~english
 Delete message

 @param messageIds         List of message ID, the element shall be the type of NSNumber
 @ return            Whether it is deleted successfully

 @ remarks Message operation
 */
- (BOOL)deleteMessages:(NSArray<NSNumber *> *)messageIds;

/*!
 *  \~chinese
 删除某个会话中的所有消息

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param successBlock        成功的回调
 @param errorBlock          失败的回调

 @discussion 此方法删除数据库中该会话的消息记录，同时会整理压缩数据库，减少占用空间

 @remarks 消息操作
 
 *  \~english
 Delete all messages in a conversation

 @param conversationType         Conversation type, which does not support chatroom
 @param targetId         Conversation ID
 @param successBlock        Callback for success
 @param errorBlock        Callback for failure

 @ discussion This method deletes the message record of the conversation in the database. At the same time, the compressed database is sorted to reduce the footprint.

 @ remarks Message operation
 */
- (void)deleteMessages:(RCConversationType)conversationType
              targetId:(NSString *)targetId
               success:(void (^)(void))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/**
 *  \~chinese
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
 
 *  \~english
 Delete specified remote messages in a conversation in batches (while deleting corresponding local messages)

 @param conversationType Conversation type, which does not support chatroom
 @param targetId Target conversation ID
 @param messages List of messages to be deleted
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ discussion This method deletes both remote and local messages.
  One batch operation only supports to delete messages belonging to the same conversation, please make sure that all messages in the message list come from the same conversation and delete at most 100 messages at a time.

  @ remarks message operation
 */
- (void)deleteRemoteMessage:(RCConversationType)conversationType
                   targetId:(NSString *)targetId
                   messages:(NSArray<RCMessage *> *)messages
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 删除某个会话中的所有消息

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    是否删除成功

 @remarks 消息操作
 
 *  \~english
 Delete all messages in a conversation

 @param conversationType           Conversation type
 @param targetId           Conversation ID
 @ return                    Whether it is deleted successfully.

 @ remarks Message operation
 */
- (BOOL)clearMessages:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 设置消息的附加信息

 @param messageId   消息 ID
 @param value       附加信息，最大 1024 字节
 @return            是否设置成功

 @discussion 用于扩展消息的使用场景。只能用于本地使用，无法同步到远端。

 @remarks 消息操作
 
 *  \~english
 Set additional information for messages

 @param messageId       Conversation ID
 @param value          Additional information, up to 1024 bytes
 @ return            Whether it is set successfully

 @ discussion It is used to extend the usage scenario of messages. It can only be used locally and cannot be synchronized to the remote end.

  @ remarks message operation
 */
- (BOOL)setMessageExtra:(long)messageId value:(NSString *)value;

/*!
 *  \~chinese
 设置消息的接收状态

 @param messageId       消息 ID
 @param receivedStatus  消息的接收状态
 @return                是否设置成功

 @discussion 用于 UI 展示消息为已读，已下载等状态。

 @remarks 消息操作
 
 *  \~english
 Set the receiving status of the message

 @param messageId       Message ID
 @param receivedStatus       Receiving status of the message
 @return                Whether it is set successfully

 @ discussion It is used for UI to show statuses such as read message, downloaded and so on.

  @ remarks message operation
 */
- (BOOL)setMessageReceivedStatus:(long)messageId receivedStatus:(RCReceivedStatus)receivedStatus;

/*!
 *  \~chinese
 设置消息的发送状态

 @param messageId       消息 ID
 @param sentStatus      消息的发送状态
 @return                是否设置成功

 @discussion 用于 UI 展示消息为正在发送，对方已接收等状态。

 @remarks 消息操作
 
 *  \~english
 Set the sending status of the message

 @param messageId       Message ID.
 @param sentStatus       The sending status of the message.
 @ return                Whether it is set successfully.

 @ discussion It is used for UI to show message status such as in sending, received by other party and so on.

  @ remarks message operation
 */
- (BOOL)setMessageSentStatus:(long)messageId sentStatus:(RCSentStatus)sentStatus;

/**
 *  \~chinese
 开始焚烧消息（目前仅支持单聊）

 @param message 消息类
 @discussion 仅限接收方调用

 @remarks 高级功能
 
 *  \~english
 Start to burn messages (Currently only support single chat.)

 @param message Message class
 @ discussion Only for receiver calls

 @ remarks Advanced functions
 */
- (void)messageBeginDestruct:(RCMessage *)message;

/**
 *  \~chinese
 停止焚烧消息（目前仅支持单聊）

 @param message 消息类
 @discussion 仅限接收方调用

 @remarks 高级功能
 
 *  \~english
 Stop burnning messages (currently only support single chat).

 @param message Message class
 @ discussion Only for receiver calls

 @ remarks Advanced functions
 */
- (void)messageStopDestruct:(RCMessage *)message;

#pragma mark - Conversation List
/*!
 *  \~chinese
 获取会话列表

 @param conversationTypeList   会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                        会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。
 @discussion 当您的会话较多且没有清理机制的时候，强烈建议您使用 getConversationList: count: startTime:
 分页拉取会话列表,否则有可能造成内存过大。

 @remarks 会话列表
 
 *  \~english
 Get conversation list

 @param conversationTypeList  An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray)
  @ return                        List of conversation RCConversation

 @ discussion This method reads the conversation list from the local database.
  The list of returned conversations is in chronological order from earliest to most recent. If a conversation is set top, the top conversation is listed first.
  @ discussion When you have a large number of conversations and do not have a cleaning mechanism, it is strongly recommended that you use getConversationList: count: startTime:
  Pull the list of the conversation page by page, otherwise the memory may be too large.

  @ remarks Conversation list
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList;

/*!
 *  \~chinese
 分页获取会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @param count                获取的数量（当实际取回的会话数量小于 count 值时，表明已取完数据）
 @param startTime            会话的时间戳（获取这个时间戳之前的会话列表，0表示从最新开始获取）
 @return                     会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取会话列表。
 返回的会话列表按照时间从前往后排列，如果有置顶的会话，则置顶的会话会排列在前面。

 @remarks 会话列表
 
 *  \~english
 Get a list of conversations page by page

 @param conversationTypeList  An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @param count                Number of conversations obtained (when the actual number of conversations retrieved is less than the count value, the data has been fetched).
 @param startTime                Timestamp of the conversation (get the list of conversation before this timestamp, 0 indicates obtaining from the latest one).
 @ return                     List of the conversation RCConversation

 @ discussion This method reads the conversation list from the local database.
  The list of returned conversations is in chronological order from earliest to most recent. If a conversation is set top, the top conversation is listed first.

  @ remarks Conversation list
 */
- (NSArray *)getConversationList:(NSArray *)conversationTypeList count:(int)count startTime:(long long)startTime;

/*!
 *  \~chinese
 获取单个会话数据

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    会话的对象

 @remarks 会话
 
 *  \~english
 Get single conversation data

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @ return                    Conversation object

 @ remarks Conversation
 */
- (RCConversation *)getConversation:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 获取会话中的消息数量

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    会话中的消息数量

 @discussion -1 表示获取消息数量出错。

 @remarks 会话
 
 *  \~english
 Get the number of messages in the conversation

 @param conversationType            Conversation type
 @param targetId            Conversation ID.
 @ return                   Number of messages in conversation.

 @ discussion - 1 indicates an error in obtaining the number of messages.

  @ remarks Conversation
 */
- (int)getMessageCount:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 删除指定类型的会话

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                        是否删除成功

 @discussion 此方法会从本地存储中删除该会话，同时删除会话中的消息。

 @remarks 会话
 
 *  \~english
 Delete a conversation of the specified type.

 @param conversationTypeList An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @ return                        Whether it is deleted successfully.

 @ discussion This method deletes the conversation from the local storage and deletes the message in the conversation.

  @ remarks Conversation
 */
- (BOOL)clearConversations:(NSArray *)conversationTypeList;

/*!
 *  \~chinese
 从本地存储中删除会话

 @param conversationType    会话类型
 @param targetId            会话 ID
 @return                    是否删除成功

 @discussion
 此方法会从本地存储中删除该会话，但是不会删除会话中的消息。如果此会话中有新的消息，该会话将重新在会话列表中显示，并显示最近的历史消息。

 @remarks 会话
 
 *  \~english
 Delete a conversation from the local storage

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @ return                    Whether it is deleted successfully.

 @ discussion
 This method deletes the conversation from the local storage, but does not delete the message in the conversation. If there is a new message in this conversation, the conversation will reappear in the conversation list and the most recent historical message will be displayed.

  @ remarks Conversation
 */
- (BOOL)removeConversation:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 设置会话的置顶状态

 @param conversationType    会话类型
 @param targetId            会话 ID
 @param isTop               是否置顶
 @return                    设置是否成功

 @discussion 会话不存在时设置置顶，会在会话列表生成会话。
 
 @remarks 会话
 
 *  \~english
 Set the top status of the conversation.

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param isTop            Whether or not set top
 @ return                    Whether it is set successfully

 @ discussion If the conversation is set top when the conversation does not exist, the conversation will be generated in the conversation list
  @ discussion After the conversation is set top, the conversation will be deleted, and the top setting will automatically expire

 @ remarks Conversation
 */
- (BOOL)setConversationToTop:(RCConversationType)conversationType targetId:(NSString *)targetId isTop:(BOOL)isTop;

/*!
 *  \~chinese
 获取置顶的会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                     置顶的会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取置顶的会话列表。

 @remarks 会话列表
 
 *  \~english
 Get a list of top conversations

 @param conversationTypeList An array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @ return                      List of top conversation RCConversation.

 @ discussion This method reads the top conversation list from the local database.

  @ remarks Conversation list
 */
- (NSArray<RCConversation *> *)getTopConversationList:(NSArray *)conversationTypeList;

- (void)setRCConversationDelegate:(id<RCConversationDelegate>)delegate;

#pragma mark Draft
/*!
 *  \~chinese
 获取会话中的草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @return                    该会话中的草稿

 @remarks 会话
 
 *  \~english
 Get draft information in the conversations (temporary messages entered by the user but not sent).

 @param conversationType            Conversations type
 @param targetId             Conversation destination ID
 @ return                    drafts in this conversations

 @ remarks Conversations
 */
- (NSString *)getTextMessageDraft:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 保存草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @param content             草稿信息
 @return                    是否保存成功

 @remarks 会话
 
 *  \~english
 Save draft information (temporarily stored messages entered by the user but not sent).

 @param conversationType            Conversation type
 @param targetId            Conversation destination ID
 @param content            Draft information
 @ return               whether it is saved successfully.

 @ remarks Conversation
 */
- (BOOL)saveTextMessageDraft:(RCConversationType)conversationType
                    targetId:(NSString *)targetId
                     content:(NSString *)content;

/*!
 *  \~chinese
 删除会话中的草稿信息（用户输入但未发送的暂存消息）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @return                    是否删除成功

 @remarks 会话
 
 *  \~english
 Delete draft information in a conversation (temporarily stored messages entered by the user but not sent).

 @param conversationType            Conversation type
 @param targetId            Conversation destination ID
 @ return                     Whether it is deleted successfully

 @ remarks Conversation
 */
- (BOOL)clearTextMessageDraft:(RCConversationType)conversationType targetId:(NSString *)targetId;

#pragma mark Unread Count

/*!
 *  \~chinese
 获取所有的未读消息数（聊天室会话除外）

 @return    所有的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of all unread messages (except chatroom conversations).

 @ return    All unread messages

 @ remarks Conversation
 */
- (int)getTotalUnreadCount;

/*!
 *  \~chinese
 获取某个会话内的未读消息数（聊天室会话除外）

 @param conversationType    会话类型
 @param targetId            会话目标 ID
 @return                    该会话内的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of unread messages in a conversation (except for chatroom conversations).

 @param conversationType            Conversation type
 @param targetId            Conversation destination ID
 @ return                Number of unread messages in the conversation

 @ remarks Conversation
 */
- (int)getUnreadCount:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 获取某些会话的总未读消息数 （聊天室会话除外）

 @param conversations       会话列表 （ RCConversation 对象只需要 conversationType 和 targetId，channelId 按需使用）
 @return                    传入会话列表的未读消息数

 @remarks 会话
 
 *  \~english
 Get the total number of unread messages for some conversations (except chatroom conversations)

 @param conversations       Conversation list (RCConversation object only requires conversationType and targetId, and channelId is used on demand)
 @ return                   Number of unread messages passed into the conversation list

 @ remarks Conversation
 */
- (int)getTotalUnreadCount:(NSArray<RCConversation *> *)conversations;

/**
 *  \~chinese
 获取某些类型的会话中所有的未读消息数 （聊天室会话除外）

 @param conversationTypes   会话类型的数组
 @param isContain           是否包含免打扰消息的未读数
 @return                    该类型的会话中所有的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of all unread messages in certain types of conversations (except chatroom conversations)

 @param conversationTypes           Array of conversation types.
 @param isContain           Does it include the number of the unread Do Not Disturb messages.
 @ return                     Number of all unread messages in this type of conversation.

 @ remarks Conversation
 */
- (int)getUnreadCount:(NSArray *)conversationTypes containBlocked:(bool)isContain;

/*!
 *  \~chinese
 获取某个类型的会话中所有的未读消息数（聊天室会话除外）

 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有的未读消息数

 @remarks 会话
 
 *  \~english
 Get the number of all unread messages in a certain type of conversation (except chatroom conversation)

 @param conversationTypes  Array of conversation types
 @ return                    the number of all unread messages in this type of conversation

 @ remarks Conversation
 */
- (int)getUnreadCount:(NSArray *)conversationTypes;

/*!
 *  \~chinese
 获取某个类型的会话中所有未读的被@的消息数

 @param conversationTypes   会话类型的数组
 @return                    该类型的会话中所有未读的被@的消息数

 @remarks 会话
 
 *  \~english
 Get the number of unread @ messages in a certain type of conversation

 @param conversationTypes Array of conversation types
 @ return                    Number of unread @ messages in this type of conversation

 @ remarks Conversation
 */
- (int)getUnreadMentionedCount:(NSArray *)conversationTypes;

/*!
 *  \~chinese
 清除某个会话中的未读消息数

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @return                    是否清除成功

 @remarks 会话
 
 *  \~english
 Clear the number of unread messages in a conversation.

 @param conversationType            Conversation type, which does not support chatroom
 @param targetId             Conversation ID
 @ return                    whether it is cleared successfully.

 @ remarks Conversation
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType targetId:(NSString *)targetId;

/*!
 *  \~chinese
 清除某个会话中的未读消息数（该会话在时间戳 timestamp 之前的消息将被置成已读。）

 @param conversationType    会话类型，不支持聊天室
 @param targetId            会话 ID
 @param timestamp           该会话已阅读的最后一条消息的发送时间戳
 @return                    是否清除成功

 @remarks 会话
 
 *  \~english
 Clear the number of unread messages in a conversation (messages for that conversation before the timestamp will be set to read.)

  @param conversationType    Conversation type, which does not support chatroom
 @param targetId            Conversation ID
 @param timestamp            Sending timestamp of the last message read by the conversation
 @ return             Whether it is cleared successfully.

 @ remarks Conversation
 */
- (BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType
                         targetId:(NSString *)targetId
                             time:(long long)timestamp;

#pragma mark - Conversation Notification

/*!
 *  \~chinese
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
 
 *  \~english
 Set the message reminder status for the conversation

 @param conversationType            Conversation type
 @param targetId            Conversation ID
 @param isBlocked            Whether to block message reminders
 @param successBlock            Callback for successful setting
 [nStatus: message reminder status set for the conversation].
 @param errorBlock            Callback for failed setting [ status:  error code for error code for setting failure].

 @ discussion
 If you use the IMLibCore, this method blocks the remote push of the conversation; If you use this method of IMKit, it blocks all reminders (remote push, local notification and foreground tone) of the conversation, and the interface does not support chatroom.

  @ remarks Conversation
 */
- (void)setConversationNotificationStatus:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                                isBlocked:(BOOL)isBlocked
                                  success:(void (^)(RCConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 查询会话的消息提醒状态

 @param conversationType    会话类型（不支持聊天室，聊天室是不接受会话消息提醒的）
 @param targetId            会话 ID
 @param successBlock        查询成功的回调 [nStatus:会话设置的消息提醒状态]
 @param errorBlock          查询失败的回调 [status:设置失败的错误码]

 @remarks 会话
 
 *  \~english
 Query the message reminder status of the conversation

 @param conversationType            Conversation type (chatroom is not supported and chatroom does not accept reminders of conversation messages).
 @param targetId            Conversation ID
 @param successBlock            Callback for successful query [nStatus: message reminder status set for the conversation]
 @param errorBlock            Callback for failed query [status: error code for setting failure]

 @ remarks Conversation
 */
- (void)getConversationNotificationStatus:(RCConversationType)conversationType
                                 targetId:(NSString *)targetId
                                  success:(void (^)(RCConversationNotificationStatus nStatus))successBlock
                                    error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 获取消息免打扰会话列表

 @param conversationTypeList 会话类型的数组(需要将 RCConversationType 转为 NSNumber 构建 NSArray)
 @return                     消息免打扰会话 RCConversation 的列表

 @discussion 此方法会从本地数据库中，读取消息免打扰会话列表。

 @remarks 会话列表
 
 *  \~english
 Get a list of conversations for Do Not Disturb messages.

 @param conversationTypeList Array of conversation types (it is required to convert RCConversationType to NSNumber to build NSArray).
 @ return                     List of conversation RCConversation for Do Not Disturb messages

 @ discussion This method reads the list of conversations of Do Not Disturb messages from the local database.

  @ remarks Conversation list
 */
- (NSArray<RCConversation *> *)getBlockedConversationList:(NSArray *)conversationTypeList;

#pragma mark - Global Message Notification

/*!
 *  \~chinese
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
 
 *  \~english
 Globally block message reminders for a certain period of time.

 @param startTime       Start message Do Not Disturb time in HH:MM:SS format.
 @param spanMins       Minutes required for message Do Not Disturb, 0 < spanMins < 1440 (for example, set the start time to be 00: 00 and the end time to be 23: 59, then the spanMins is  23 * 60 + 59 = 1439 minutes).
  @param successBlock    Callback for successful masking
 @param errorBlock      Callback for masking failure [status: error code for masking failure].

 @ discussion The masking time set by this method takes effect at that time of day.
  If you use the IMLibCore, this method blocks the remote push of the conversation in this period; If you use IMKit, this method blocks all reminders (remote push, local notification and foreground tone) of the conversation in this period.

  @ remarks Conversation
 */
- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(int)spanMins
                          success:(void (^)(void))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 删除已设置的全局时间段消息提醒屏蔽

 @param successBlock    删除屏蔽成功的回调
 @param errorBlock      删除屏蔽失败的回调 [status:失败的错误码]

 @remarks 会话
 
 *  \~english
 Delete the set message reminder masking in a global time period.

 @param successBlock     Callback for successful masking deletion
 @param errorBlock     Callback for failed masking deletion[status: error code for failure]

 @ remarks Conversation
 */
- (void)removeNotificationQuietHours:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 查询已设置的全局时间段消息提醒屏蔽

 @param successBlock    屏蔽成功的回调 [startTime:已设置的屏蔽开始时间,
 spansMin:已设置的屏蔽时间分钟数，0 < spansMin < 1440]
 @param errorBlock      查询失败的回调 [status:查询失败的错误码]

 @remarks 会话
 
 *  \~english
 Query the set message reminder masking in a global time period.

 @param successBlock    Callback for successful masking [startTime: set start time of masking,
 spansMin: set minutes of masking, 0 < spansMin < 1440]
 @param errorBlock      callback for failed query [status: error code of failed query]

 @ remarks Conversation
 */
- (void)getNotificationQuietHours:(void (^)(NSString *startTime, int spansMin))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - Typing status

/**
 *  \~chinese
 typing 状态更新的时间，默认是 6s
 
 @remarks 功能设置
 
 *  \~english
 Time when the typing status is updated and the default value is 6s

 @ remarks Function setting
 */
@property (nonatomic, assign) NSInteger typingUpdateSeconds;

/*!
 *  \~chinese
 设置输入状态的监听器

 @param delegate         IMLibCore 输入状态的的监听器

 @warning           目前仅支持单聊。

 @remarks 功能设置
 
 *  \~english
 Set the listener for the input status

 @param delegate    Listeners for IMLibCore input status

 @ warning           currently only support single chat

  @ remarks function setting
 */
- (void)setRCTypingStatusDelegate:(id<RCTypingStatusDelegate>)delegate;

/*!
 *  \~chinese
 向会话中发送正在输入的状态

 @param conversationType    会话类型
 @param targetId            会话目标  ID
 @param objectName         正在输入的消息的类型名

 @discussion
 contentType 为用户当前正在编辑的消息类型名，即 RCMessageContent 中 getObjectName 的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。

 @warning 目前仅支持单聊。

 @remarks 高级功能
 
 *  \~english
 Send the status being entered to the conversation

 @param conversationType         Conversation type
 @param targetId         Conversation destination ID
 @param objectName         Type name of the message being entered

 @ discussion
 contentType is the name of the message type that the user is currently editing, that is, the return value of getObjectName in RCMessageContent.
  E.g. for a text message, pass the type name "RC:TxtMsg".

  @ warning Currently only support single chat.

  @ remarks advanced functions
 */
- (void)sendTypingStatus:(RCConversationType)conversationType
                targetId:(NSString *)targetId
             contentType:(NSString *)objectName;

#pragma mark - Disallow List

/*!
 *  \~chinese
 将某个用户加入黑名单

 @param userId          需要加入黑名单的用户 ID
 @param successBlock    加入黑名单成功的回调
 @param errorBlock      加入黑名单失败的回调 [status:失败的错误码]

 @discussion 将对方加入黑名单后，对方再发消息时，就会提示“您的消息已经发出, 但被对方拒收”。但您仍然可以给对方发送消息。

 @remarks 高级功能
 
 *  \~english
 Add a user to the blacklist

 @param userId          ID of users to be added to the blacklist
 @param successBlock          Callback for successfully adding to the blacklist
 @param errorBlock          Callback for failure to add to the blacklist [status: error code for failure]

 @ discussion After the other party is added to the blacklist, when the other party sends another message, it will prompt "your message has been sent, but it has been rejected.” But you can still send messages to each other.

  @ remarks advanced functions
 */
- (void)addToBlacklist:(NSString *)userId
               success:(void (^)(void))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 将某个用户移出黑名单

 @param userId          需要移出黑名单的用户 ID
 @param successBlock    移出黑名单成功的回调
 @param errorBlock      移出黑名单失败的回调[status:失败的错误码]

 @remarks 高级功能
 
 *  \~english
 Remove a user from the blacklist

 @param userId          ID of users to be removed from the blacklist
 @param successBlock          Callback for successful removal from the blacklist
 @param errorBlock          Callback for failed removal from blacklist [status: error code for failure]

 @ remarks Advanced functions
 */
- (void)removeFromBlacklist:(NSString *)userId
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 查询某个用户是否已经在黑名单中

 @param userId          需要查询的用户 ID
 @param successBlock    查询成功的回调
 [bizStatus:该用户是否在黑名单中。0 表示已经在黑名单中，101 表示不在黑名单中]
 @param errorBlock      查询失败的回调 [status:失败的错误码]

 @remarks 高级功能
 
 *  \~english
 Query whether a user is already in the blacklist.

 @param userId          ID of the user to be queried
 @param successBlock          Callback for successful query
 [bizStatus: whether the user is in the blacklist 0 indicates it is already in the blacklist, 101 indicates it is not in the blacklist]
 @param errorBlock      Callback for failed query [status: error code forfailure]

 @ remarks Advanced functions
 */
- (void)getBlacklistStatus:(NSString *)userId
                   success:(void (^)(int bizStatus))successBlock
                     error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 查询已经设置的黑名单列表

 @param successBlock    查询成功的回调
 [blockUserIds:已经设置的黑名单中的用户 ID 列表]
 @param errorBlock      查询失败的回调 [status:失败的错误码]

 @remarks 高级功能
 
 *  \~english
 Query the list of blacklists set

 @param successBlock   Callback for successful query
 [blockUserIds: ID list of users in the blacklist set]
 @param errorBlock    Callback for failed query [status: error code for failure]

 @ remarks Advanced functions
 */
- (void)getBlacklist:(void (^)(NSArray *blockUserIds))successBlock error:(void (^)(RCErrorCode status))errorBlock;

#pragma mark - Push Data Countly

/*!
 *  \~chinese
 统计App启动的事件

 @param launchOptions   App的启动附加信息

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在 AppDelegate 的-application:didFinishLaunchingWithOptions:中，
 调用此方法并将 launchOptions  传入即可。

 @remarks 高级功能
 
 *  \~english
 Count the events started by app

 @param launchOptions   Additional information about app startup

 @ discussion This method is used to count the click rate of RongCloud push service.
  If you need to count the click rate of the push service, you only need to call this method in -application:didFinishLaunchingWithOptions: of AppDelegate and pass in the launchOptions.

  @ remarks advanced functions
 */
- (void)recordLaunchOptionsEvent:(NSDictionary *)launchOptions;

/*!
 *  \~chinese
 统计本地通知的事件

 @param notification   本体通知的内容

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在AppDelegate 的-application:didReceiveLocalNotification:中，
 调用此方法并将 launchOptions 传入即可。

 @remarks 高级功能
 
 *  \~english
 Count locally notified events

 @param notification   Content of ontology notification

 @ discussion This method is used to count the click rate of RongCloud push service.
  If you need to count the click rate of the push service, you only need to call this method in -application:didReceiveLocalNotification: of AppDelegate and pass in the launchOptions.

  @ remarks advanced functions
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)recordLocalNotificationEvent:(UILocalNotification *)notification;
#pragma clang diagnostic pop

/*!
 *  \~chinese
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
 *  \~chinese
 统计远程推送的点击事件

 @param userInfo    远程推送的内容

 @discussion 此方法用于统计融云推送服务的点击率。
 如果您需要统计推送服务的点击率，只需要在 AppDelegate 的-application:didReceiveRemoteNotification:中，
 调用此方法并将 launchOptions 传入即可。

 @remarks 高级功能
 
 *  \~english
 Count the events of remote push

 @param userInfo    Content of remote push

 @ discussion This method is used to count the click rate of RongCloud push service.
  If you need to count the click rate of the push service, you only need to call this method in -application:didReceiveRemoteNotification: of AppDelegate and pass in the launchOptions.

  @ remarks advanced functions
 */
- (void)recordRemoteNotificationEvent:(NSDictionary *)userInfo;

/*!
 *  \~chinese
 获取点击的启动事件中，融云推送服务的扩展字段

 @param launchOptions   App 的启动附加信息
 @return 收到的融云推送服务的扩展字段，nil 表示该启动事件不包含来自融云的推送服务

 @discussion 此方法仅用于获取融云推送服务的扩展字段。

 @remarks 高级功能
 
 *  \~english
 Get the extension field of the RongCloud push service in the clicked start event

 @param launchOptions   Additional information about app startup
 @ return Received extension field of the RongCloud push service. Nil indicates that the start event does not include the push service from the RongCoud service.

 @ discussion This method is only used to obtain the extended fields of RongCloud push service.

  @ remarks advanced functions
 */
- (NSDictionary *)getPushExtraFromLaunchOptions:(NSDictionary *)launchOptions;

/*!
 *  \~chinese
 获取点击的远程推送中，融云推送服务的扩展字段

 @param userInfo    远程推送的内容
 @return 收到的融云推送服务的扩展字段，nil 表示该远程推送不包含来自融云的推送服务

 @discussion 此方法仅用于获取融云推送服务的扩展字段。

 @remarks 高级功能
 
 *  \~english
 Get the extension field of the RongCloud push service in the clicked remote push.

 @param userInfo    Content of remote push.
 @ return Received extension field of RongCloud push service. Nil indicates that the remote push does not include the push service from RongCloud.

 @ discussion This method is only used to obtain the extended fields of RongCloud push service.

  @ remarks advanced functions
 */
- (NSDictionary *)getPushExtraFromRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - Util

/*!
 *  \~chinese
 获取当前 IMLibCore SDK的版本号

 @return 当前 IMLibCore SDK 的版本号，如: @"2.0.0"

 @remarks 数据获取
 
 *  \~english
 Get the version number of the current IMLibCore SDK.

 @ return Version number of the current IMLibCore SDK, e.g.: @ "2.0.0"

 @ remarks Data acquisition
 */
+ (NSString *)getVersion;

/*!
 *  \~chinese
 获取当前手机与服务器的时间差

 @return 时间差
 @discussion 消息发送成功后，SDK 会与服务器同步时间，消息所在数据库中存储的时间就是服务器时间。

 @remarks 数据获取
 
 *  \~english
 Get the time difference between the current mobile phone and the server

 @ return time difference
 @ discussion After the message is sent successfully, the SDK synchronizes the time with the server, and the time stored in the database where the message is located is the server time.
 @ remarks Data acquisition

  @ remarks data acquisition
 */
- (long long)getDeltaTime;

/*!
 *  \~chinese
 将AMR格式的音频数据转化为 WAV 格式的音频数据，数据开头携带 WAVE 文件头

 @param data    AMR 格式的音频数据，必须是 AMR-NB 的格式
 @return        WAV 格式的音频数据

 @remarks 数据获取
 
 *  \~english
 Convert audio data in AMR format into audio data in WAV format with WAVE file header at the beginning of the data.

 @param data    Audio data in AMR format, which must be in AMR-NB format
 @ return         Audio data in WAV format

 @ remarks Data acquisition
 */
- (NSData *)decodeAMRToWAVE:(NSData *)data;

/*!
 *  \~chinese
 将 AMR 格式的音频数据转化为 WAV 格式的音频数据，数据开头不携带 WAV 文件头

 @param data    AMR 格式的音频数据，必须是 AMR-NB 的格式
 @return        WAV 格式的音频数据

 @remarks 数据获取
 
 *  \~english
 Convert audio data in AMR format into audio data in WAV format with WAV file header at the beginning of the data.

 @param data     Audio data in AMR format, which must be in AMR-NB format.
 @ return      Audio data in WAV format

 @ remarks Data acquisition
 */
- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data;

#pragma mark - Voice Message Setting
/**
 *  \~chinese
 语音消息采样率，默认 8KHz

 @discussion
 2.9.12 之前的版本只支持 8KHz。如果设置为 16KHz，老版本将无法播放 16KHz 的语音消息。
 客服会话只支持 8KHz。

 @remarks 功能设置
 
 *  \~english
 Voice message sampling rate, with default value of 8KHz

 @ discussion
 The versions prior to 2.9.12 only supports 8KHz. If it is set to 16kHz, the old version will not be able to play 16KHz voice messages.
  The customer service conversations only support 8KHz.

  @ remarks function setting
 */
@property (nonatomic, assign) RCSampleRate sampleRate __deprecated_msg("deprecated");

/**
 *  \~chinese
  语音消息类型，默认 RCVoiceMessageTypeOrdinary

  @discussion 老版本 SDK 不兼容新版本语音消息
  2.9.19 之前的版本无法播放高音质语音消息；
  2.9.19 及之后的版本可以同时兼容普通音质语音消息和高音质语音消息；
  客服会话类型 (ConversationType_CUSTOMERSERVICE) 不支持高音质语音消息。

  @remarks 功能设置
 
 *  \~english
 Voice message type, with default value of RCVoiceMessageTypeOrdinary

 @ discussion The old version of SDK is not compatible with the new version of voice messages.
 The versions prior to 2.9.19 cannot play high-quality voice messages;
 2.9.19 and later versions can be compatible with both normal and high quality voice messages.
 The customer service conversation type (ConversationType_CUSTOMERSERVICE) does not support high-quality voice messages.

   @ remarks function setting
  */
@property (nonatomic, assign) RCVoiceMessageType voiceMsgType;

#pragma mark - Search

/*!
 *  \~chinese
 根据关键字搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param keyword          关键字
 @param count            最大的查询数量
 @param startTime        查询 startTime 之前的消息（传 0 表示不限时间）

 @return 匹配的消息列表

 @remarks 消息操作
 
 *  \~english
 Search messages in a specified conversation based on keywords.

 @param conversationType Conversation type
 @param targetId         Conversation ID
 @param keyword         Keyword
 @param count         Maximum number of queries
 @param startTime         Query messages before startTime (0 indicates unlimited time).

 @ return Matching message list

 @ remarks Message operation
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                 keyword:(NSString *)keyword
                                   count:(int)count
                               startTime:(long long)startTime;

/*!
 *  \~chinese
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
 
 *  \~english
 Search messages in a specified conversation based on time, offset, and number.

 @param conversationType Conversation type
 @param targetId         Conversation ID
 @param keyword         Keyword, in which empty value indicates to check all messages that meet the criteria by default
 @param startTime         Query the message after startTime, startTime > = 0
 @param endTime         Query the messages before endTime, endTime > startTime.
 @param offset         Offset of the queried message, offset > = 0
 @param limit         For the maximum number of queries, the limit should be greater than 0, and the maximum value should be 100. If it is greater than 100, it will default to 100.

  @ return List of messages matched

 @ remarks Message operation
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                 keyword:(NSString *)keyword
                               startTime:(long long)startTime
                                 endTime:(long long)endTime
                                  offset:(int)offset
                                   limit:(int)limit;

/*!
 *  \~chinese
 按用户 ID 搜索指定会话中的消息

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param userId           搜索用户 ID
 @param count            最大的查询数量
 @param startTime        查询 startTime 之前的消息（传 0 表示不限时间）

 @return 匹配的消息列表

 @remarks 消息操作
 
 *  \~english
 Search messages in a specified conversation by user ID

 @param conversationType Conversation type
 @param targetId         Conversation ID
 @param userId         Search user ID
 @param count         Maximum number of queries.
 @param startTime         Query messages before startTime (0 indicates unlimited time)

 @ return List of message matched

 @ remarks Message operation
 */
- (NSArray<RCMessage *> *)searchMessages:(RCConversationType)conversationType
                                targetId:(NSString *)targetId
                                  userId:(NSString *)userId
                                   count:(int)count
                               startTime:(long long)startTime;

/*!
 *  \~chinese
 根据关键字搜索会话

 @param conversationTypeList 需要搜索的会话类型列表
 @param objectNameList       需要搜索的消息类型名列表(即每个消息类方法 getObjectName 的返回值)
 @param keyword              关键字

 @return 匹配的会话搜索结果列表

 @discussion 目前，SDK 内置的文本消息、文件消息、图文消息支持搜索。
 自定义的消息必须要实现 RCMessageContent 的 getSearchableWords 接口才能进行搜索。

 @remarks 消息操作
 
 *  \~english
 Search a conversation based on keywords

 @param conversationTypeList List of conversation types to be searched
 @param objectNameList        List of type names of message to be searched (that is, the return value of each message class method getObjectName)
 @param keyword              Keyword

 @ return Search results list for conversation matched.

 @ discussion Currently, SDK's built-in text messages, file messages, and image and text messages support search
  Custom messages must implement getSearchableWords interface of RCMessageContent before they can be searched

  @ remarks message operation
 */
- (NSArray<RCSearchConversationResult *> *)searchConversations:(NSArray<NSNumber *> *)conversationTypeList
                                                   messageType:(NSArray<NSString *> *)objectNameList
                                                       keyword:(NSString *)keyword;

#pragma mark - Log

/*!
 *  \~chinese
 设置日志级别

 @remarks 高级功能
 
 *  \~english
 Set log level

 @ remarks Advanced functions
 */
@property (nonatomic, assign) RCLogLevel logLevel;

/*!
 *  \~chinese
 设置 IMLibCore 日志的监听器

 @param delegate IMLibCore 日志的监听器

 @discussion 您可以通过 logLevel 来控制日志的级别。

 @remarks 功能设置
 
 *  \~english
 Set listeners for IMLibCore logs

 @param delegate  Listeners for IMLibCore logs

 @ discussion You can control the level of logs through logLevel.

  @ remarks function setting
 */
- (void)setRCLogInfoDelegate:(id<RCLogInfoDelegate>)delegate;

#pragma mark - File Storage

/*!
 *  \~chinese
 文件消息下载路径

 @discussion 默认值为沙盒下的 Documents/MyFile 目录。您可以通过修改 RCConfig.plist 中的 RelativePath 来修改该路径。

 @remarks 数据获取
 
 *  \~english
 File message downloading path

 @ discussion The default value is the Documents/MyFile directory under sandboxes. You can modify the path by modifying the RelativePath in RCConfig.plist.

  @ remarks data acquisition
 */
@property (nonatomic, strong, readonly) NSString *fileStoragePath;

#pragma mark - VendorToken
/*!
 *  \~chinese
 获取Vendor token. 仅供融云第三方服务厂家使用。

 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @remarks 数据获取
 
 *  \~english
 Get Vendor token, which is for RongCloud's third-party service manufacturers only.

  @ param  successBlock Callback for success
 @ param  errorBlock   Callback for failure

 @ remarks Data acquisition
 */
- (void)getVendorToken:(void (^)(NSString *vendorToken))successBlock error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 *  \~chinese
 远程推送相关设置

 @remarks 功能设置
 
 *  \~english
 Remote push of related settings

 @ remarks Function setting
 */
@property (nonatomic, strong, readonly) RCPushProfile *pushProfile;

#pragma mark - History Message
/**
 *  \~chinese
 设置离线消息在服务端的存储时间（以天为单位）

 @param duration      存储时间，范围【1~7天】
 @param  successBlock 成功回调
 @param  errorBlock   失败回调

 @remarks 功能设置
 
 *  \~english
 Set the storage time of offline messages on the server (in days)

 @param duration      Storage time, range [1~7 days]
 @ param  Callback for successBlock
 @ param  Callback for errorBlock

 @ remarks Function setting
 */
- (void)setOfflineMessageDuration:(int)duration
                          success:(void (^)(void))successBlock
                          failure:(void (^)(RCErrorCode nErrorCode))errorBlock;

/**
 *  \~chinese
 获取离线消息时间 （以天为单位）

 @return 离线消息存储时间

 @remarks 数据获取
 
 *  \~english
 Get offline message time (in days)

 @ return Storage time of offline message

 @ remarks Data acquisition
 */
- (int)getOfflineMessageDuration;

/**
 *  \~chinese
 设置集成 SDK 的用户 App 版本信息。便于融云排查问题时，作为分析依据，属于自愿行为。

 @param  appVer   用户 APP 的版本信息。

 @remarks 功能设置
 
 *  \~english
 Set the user App version information for the integrated SDK. When it is convenient for RongCloud to investigate the problem, as the basis for analysis, it shall be voluntary.

  @ param  appVer    Version information of user APP

  @ remarks function setting
 */
- (void)setAppVer:(NSString *)appVer;

/**
 *  \~chinese
 GIF 消息大小限制，以 KB 为单位，超过这个大小的 GIF 消息不能被发送

 @return GIF 消息大小，以 KB 为单位

 @remarks 数据获取
 
 *  \~english
 GIF message size limit, in KB. GIF messages exceeding this size cannot be sent

 @ return GIF message size, in KB

 @ remarks Data acquisition
 */
- (NSInteger)getGIFLimitSize;

/**
 *  \~chinese
 小视频消息时长限制，以 秒 为单位，超过这个时长的小视频消息不能在相册中被选择发送

 @return 小视频消息时长，以 秒 为单位
 
 *  \~english
 Duration limit of small video messages, in seconds. Small video messages exceeding this limit cannot be selected to be sent in the album

 @ return Duration of small video message, in seconds
 */
- (NSTimeInterval)getVideoDurationLimit;

#pragma mark - Conversation Status: Sync,Notification,Top

/*!
 *  \~chinese
设置会话状态（包含置顶，消息免打扰）同步的监听器

@param delegate 会话状态同步的监听器

@discussion 可以设置并实现此 delegate 来进行会话状态同步。SDK 会在回调的 conversationStatusChange:方法中通知您会话状态的改变。

@remarks 功能设置
 
 *  \~english
 Listeners that set conversation status (including top setting and Do Not Disturb setting) synchronization

 @param delegate Listeners for conversation status synchronization

 @ discussion It can set and implement this delegate for conversation status synchronization. SDK will notify you of the change in conversation status in the callback conversationStatusChange: method.

 @ remarks function setting
*/
- (void)setRCConversationStatusChangeDelegate:(id<RCConversationStatusChangeDelegate>)delegate;

#pragma mark - Message Expansion
/**
 *  \~chinese
 更新消息扩展信息

 @param expansionDic 要更新的消息扩展信息键值对
 @param messageUId 消息 messageUId
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 消息扩展信息是以字典形式存在。设置的时候从 expansionDic 中读取 key，如果原有的扩展信息中 key 不存在则添加新的 KV 对，如果 key 存在则替换成新的 value。
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 @discussion 扩展信息字典中的 Key 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 32；Value 最长长度，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
 
 @remarks 高级功能
 
 *  \~english
 Update message extension information

 @param expansionDic Message extension information key-value pair to be updated
 @param messageUId Message messageUId.
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ discussion The message extension information exists in the form of a dictionary. Read key from expansionDic when setting. If key does not exist in the original extension information, add a new KV pair, or replace it with a new value if key exists.
  @ discussion The extension information only supports single chat and groups. Other conversation types cannot set extension information
 @ discussion The Key in the extended information dictionary supports the combination of uppercase and lowercase letters, numbers, and some special symbols + =-_. The maximum length is 32; For the maximum length of Value, the maximum number of extensions set at a time is 20, and the total number of messages extensions cannot exceed 300
 @ remarks Advanced functions
*/
- (void)updateMessageExpansion:(NSDictionary<NSString *, NSString *> *)expansionDic
                    messageUId:(NSString *)messageUId
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode status))errorBlock;

/**
 *  \~chinese
 删除消息扩展信息中特定的键值对

 @param keyArray 消息扩展信息中待删除的 key 的列表
 @param messageUId 消息 messageUId
 @param successBlock 成功的回调
 @param errorBlock 失败的回调

 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 
 @remarks 高级功能
 
 *  \~english
 Delete a specific key-value pair in the message extension information.

 @param keyArray List of key to be deleted in message extension information
 @param messageUId Message messageUId
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ discussion The extension information only supports single chat and groups and other conversation types cannot set extension information.

 @ remarks Advanced functions
*/
- (void)removeMessageExpansionForKey:(NSArray<NSString *> *)keyArray
                          messageUId:(NSString *)messageUId
                             success:(void (^)(void))successBlock
                               error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 设置 IMLibCore 的消息扩展监听器
 
 @discussion 代理回调在非主线程
 
 @remarks 高级功能
 
 *  \~english
 Set the message extension listener for IMLibCore

 @ discussion Proxy callback in non-main thread

 @ remarks Advanced functions
 */
@property (nonatomic, weak) id<RCMessageExpansionDelegate> messageExpansionDelegate;

#pragma mark - Tag
/*!
 *  \~chinese
 添加标签
 
 @param tagInfo 标签信息。只需要设置标签信息的 tagId 和 tagName。
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 最多支持添加 20 个标签
 @remarks 高级功能
 
 *  \~english
 Add tags

 @param tagInfo Tag information. You only shall set the tagId and tagName of the tag information.
  @param successBlock Callback for success.
 @param errorBlock Callback for failure

 @ discussion Support to add 20 tags at most
 @ remarks Advanced functions
 */
- (void)addTag:(RCTagInfo *)tagInfo
       success:(void (^)(void))successBlock
         error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
 移除标签
 
 @param tagId 标签 ID
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 
 *  \~english
 Remove tag

 @param tagId Tag ID
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ remarks Advanced functions
 */
- (void)removeTag:(NSString *)tagId
          success:(void (^)(void))successBlock
            error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
 更新标签信息
 
 @param tagInfo 标签信息。只支持修改标签信息的 tagName
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 
 *  \~english
 Update tag information

 @param tagInfo  Tag information. Only tagName that modifies tag information is supported
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ remarks Advanced functions
 */
- (void)updateTag:(RCTagInfo *)tagInfo
          success:(void (^)(void))successBlock
            error:(void (^)(RCErrorCode errorCode))errorBlock;


/*!
 *  \~chinese
 获取标签列表
 
 @return 标签列表
 @remarks 高级功能
 
 *  \~english
 Get a list of tags

 @ return Tag list
 @ remarks Advanced functions
 */
- (NSArray<RCTagInfo *> *)getTags;

/*!
 *  \~chinese
 标签变化监听器
 
 @discussion 标签添加移除更新会触发此监听器，用于多端同步
 @discussion 本端添加删除更新标签，不会触发此监听器，在相关调用方法的 block 块直接回调
 
 @remarks 高级功能
 
 *  \~english
 Listener for tag changing

 @ discussion Addition, removal and update of a tag triggers this listener for multi-terminal synchronization
 @ discussion Local addition, removal and update of a tag will not trigger this listener, and it will be called back directly in the block of the relevant call method.

 @ remarks Advanced functions
 */
@property (nonatomic, weak) id<RCTagDelegate> tagDelegate;

/*!
 *  \~chinese
 添加会话到指定标签
 
 @param tagId 标签 ID
 @param conversationIdentifiers 会话信息列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 每次添加会话个数最大为 1000。最多支持添加 1000 个会话，如果标签添加的会话总数已超过 1000，会自动覆盖早期添加的会话
 @remarks 高级功能
 
 *  \~english
 Add a conversation to the specified tag

 @param tagId Tag ID
 @param conversationIdentifiers Conversation information list
 @param successBlock Callback for success
 @param errorBlock  Callback for failure

 @ discussion Maximum 1000 conversations are added at a time. A maximum of 1000 conversations can be added. If the total number of conversations added by the tag exceeds 1000, the previously added conversations will be automatically overwritten.
 @ remarks Advanced functions
 */
- (void)addConversationsToTag:(NSString *)tagId
      conversationIdentifiers:(NSArray<RCConversationIdentifier *> *)conversationIdentifiers
                      success:(void (^)(void))successBlock
                        error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
 从指定标签移除会话
 
 @param tagId 标签 ID
 @param conversationIdentifiers 会话信息列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 每次移除会话个数最大为 1000
 @remarks 高级功能
 
 *  \~english
 Remove a conversation from the specified tag

 @param tagId Tag ID
 @param conversationIdentifiers Conversation information list
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ discussion Maximum 1000 conversations are removed at a time
 @ remarks Advanced functions
 */
- (void)removeConversationsFromTag:(NSString *)tagId
           conversationIdentifiers:(NSArray<RCConversationIdentifier *> *)conversationIdentifiers
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
 从指定会话中移除标签

 @param conversationIdentifier 会话信息
 @param tagIds 标签 ID 列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 
 *  \~english
 Remove the tag from the specified conversation

 @param conversationIdentifier Conversation information.
 @param tagIds Tag ID list
 @param successBlock Callback for success
 @param errorBlock Callback for failure

 @ remarks Advanced functions
 */
- (void)removeTagsFromConversation:(RCConversationIdentifier *)conversationIdentifier
                            tagIds:(NSArray<NSString *> *)tagIds
                           success:(void (^)(void))successBlock
                             error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
 获取会话的所有标签
 
 @param conversationIdentifier 会话信息
 @return  会话所属的标签列表
 
 @remarks 高级功能
 
 *  \~english
 Get all the tags for the conversation

 @param conversationIdentifier Conversation information.
 @ return  List of tags to which the conversation belongs

 @ remarks Advanced functions
 */
- (NSArray<RCConversationTagInfo *> *)getTagsFromConversation:(RCConversationIdentifier *)conversationIdentifier;

/*!
 *  \~chinese
 分页获取标签中会话列表
 
 @param tagId 标签 ID
 @param timestamp            会话的时间戳（获取这个时间戳之前的会话列表，0表示从最新开始获取）
 @param count                获取的数量（当实际取回的会话数量小于 count 值时，表明已取完数据）
 @return                     会话 RCConversation 的列表
 
 @remarks 高级功能
 
 *  \~english
 Get the list of conversations in the tag page by page

 @param tagId tag ID
 @param timestamp            Timestamp of the conversation (get the list of conversations before this timestamp, 0 indicates obtaining from the latest).
 @param count            Number of conversations obtained (When the actual number of retrieved conversations is less than the count value, it indicates that the data has been fetched.)
 @ return                     List of conversation RCConversation

 @ remarks Advanced functions
 */
- (NSArray<RCConversation *> *)getConversationsFromTagByPage:(NSString *)tagId
                                                   timestamp:(long long)timestamp
                                                       count:(int)count;

/*!
 *  \~chinese
 获取标签中会话消息未读数
 
 @param tagId 标签 ID
 @param isContain    是否包含免打扰会话
 @return 会话消息未读数
 
 @remarks 高级功能
 
 *  \~english
 Get the number of unread conversation messages in the tag

 @param tagId Tag ID
 @param isContain   Does it include a Do Not Disturb conversation
 @ return  Number of unread conversation messages

 @ remarks Advanced functions
 */
- (int)getUnreadCountByTag:(NSString *)tagId
            containBlocked:(BOOL)isContain;

/*!
 *  \~chinese
 设置标签中的会话置顶
 
 @param tagId 标签 ID
 @param conversationIdentifier 会话信息
 @param top 是否置顶
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能

 *  \~english
 Set the conversation in the tag to be top

 @param tagId Tag ID
 @param conversationIdentifier Conversation information
 @param top Whether or not to set top
 @param successBlock  Callback for success
 @param errorBlock Callback for failure

 @ remarks Advanced functions
 */
- (void)setConversationToTopInTag:(NSString *)tagId
           conversationIdentifier:(RCConversationIdentifier *)conversationIdentifier
                            isTop:(BOOL)top
                          success:(void (^)(void))successBlock
                            error:(void (^)(RCErrorCode errorCode))errorBlock;

/*!
 *  \~chinese
 获取标签中的会话置顶状态
 
 @param conversationIdentifier 会话信息
 @param tagId 标签 ID
 @return 置顶状态
 
 @remarks 高级功能
 
 *  \~english
 Get the conversation top setting status in the tag.

 @param conversationIdentifier Conversation information
 @param tagId Tag ID
 @ return top setting status

 @ remarks Advanced functions
 */
- (BOOL)getConversationTopStatusInTag:(RCConversationIdentifier *)conversationIdentifier tagId:(NSString *)tagId;


/*!
 *  \~chinese
 会话标签变化监听器
 
 @discussion 会话标签添加移除更新会触发此监听器，用于多端同步
 @discussion 本端操作会话标签，不会触发此监听器，在相关调用方法的 block 块直接回调
 
 @remarks 高级功能
 
 *  \~english
 Listener for conversation tag changing.

 @ discussion Addition, removal and update of the conversation tag triggers this listener for multi-terminal synchronization.
 @ discussion Local operation on the conversation tag does not trigger this listener, and the block of the relevant calling method is called back directly

 @ remarks Advanced functions
 */
@property (nonatomic, weak) id<RCConversationTagDelegate> conversationTagDelegate;

/*!
 *  \~chinese
 缩略图压缩配置
 
 @remarks 缩略图压缩配置，如果此处设置了配置就按照这个配置进行压缩。如果此处没有设置，会按照 RCConfig.plist 中的配置进行压缩。
 
 *  \~english
 Thumbnail compression configuration

 @ remarks Thumbnail compression configuration. If the configuration is set here, it is compressed according to this configuration. If it is not set here, it will be compressed according to the configuration in RCConfig.plist.
 */
@property (nonatomic, strong) RCImageCompressConfig *imageCompressConfig;

/*!
 *  \~chinese
 子模块是否正在使用声音通道，特指 RTCLib
 
 *  \~english
 Whether the submodule is using a sound channel, especially the RTCLib
 */
- (BOOL)isAudioHolding;

/*!
 *  \~chinese
 子模块是否正在使用摄像头，特指 RTCLib
 
 *  \~english
 Whether the submodule is using a camera, especially the RTCLib
 */
- (BOOL)isCameraHolding;

@end

#endif
