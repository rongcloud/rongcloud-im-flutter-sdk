/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCStatusDefine.h
//  Created by Heq.Shinoda on 14-4-21.

#import <Foundation/Foundation.h>

#ifndef __RCStatusDefine
#define __RCStatusDefine

#pragma mark - 错误码相关

#pragma mark RCConnectErrorCode - 建立连接返回的错误码
/*!
 建立连接返回的错误码

 */
typedef NS_ENUM(NSInteger, RCConnectErrorCode) {

    /*!
     AppKey 错误

     @discussion 请检查您使用的 AppKey 是否正确。
     */
    RC_CONN_ID_REJECT = 31002,

    /*!
     Token 无效

     @discussion 请检查客户端初始化使用的 AppKey 和您服务器获取 token 使用的 AppKey 是否一致。
     @discussion 您可能需要请求您的服务器重新获取 token，并使用新的 token 建立连接。
     */
    RC_CONN_TOKEN_INCORRECT = 31004,

    /*!
     App 校验未通过
     
     @discussion 您开通了 App 校验功能，但是校验未通过
     */
    RC_CONN_NOT_AUTHRORIZED = 31005,

    /*!
     BundleID 不正确

     @discussion 请检查您 App 的 BundleID 是否正确。
     */
    RC_CONN_PACKAGE_NAME_INVALID = 31007,

    /*!
     AppKey 被封禁或已删除

     @discussion 请检查您使用的 AppKey 是否被封禁或已删除。
     */
    RC_CONN_APP_BLOCKED_OR_DELETED = 31008,

    /*!
     用户被封禁

     @discussion 请检查您使用的 Token 是否正确，以及对应的 UserId 是否被封禁。
     */
    RC_CONN_USER_BLOCKED = 31009,

    /*!
     用户被踢下线

      @discussion 当前用户在其他设备上登录，此设备被踢下线
     */
    RC_DISCONN_KICK = 31010,
    
    /*!
     token 已过期
     
     @discussion 您可能需要请求您的服务器重新获取 token，并使用新的 token 建立连接。
     */
    RC_CONN_TOKEN_EXPIRE = 31020,

    /*!
     用户在其它设备上登录

      @discussion 重连过程中当前用户在其它设备上登录
     */
    RC_CONN_OTHER_DEVICE_LOGIN = 31023,
    
    /*!
     连接总数量超过服务设定的并发限定值
     
     @discussion 私有云专属
     */
    CONCURRENT_LIMIT_ERROR = 31024,
    
    /*!
     环境校验失败
     
     @discussion 请检查 AppKey 和连接环境（开发环境/生产环境）是否匹配
     */
    RC_CONN_CLUSTER_ERROR  = 31025,
    
    /*!
     APP 服务校验失败
     
     @discussion 连接接口 RCConnectOption.connectExt 参数在 APP 服务验证不通过
     */
    RC_CONN_APP_AUTH_FAILED  = 31026,
    
    /*!
     token 已经被使用过，无法再连接
     
     @discussion 一次性 token 只能连接一次，之后再使用会上报此错误
     */
    RC_CONN_DISPOSABLE_TOKEN_USED = 31027,

    /*!
     SDK 没有初始化

     @discussion 在使用 SDK 任何功能之前，必须先 Init。
     */
    RC_CLIENT_NOT_INIT = 33001,

    /*!
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     */
    RC_INVALID_PARAMETER = 33003,

    /*!
     Connection 已经存在

     @discussion
     调用过connect之后，只有在 token 错误或者被踢下线或者用户 logout 的情况下才需要再次调用 connect。其它情况下 SDK
     会自动重连，不需要应用多次调用 connect 来保持连接。
     */
    RC_CONNECTION_EXIST = 34001,

    /*!
     连接环境不正确（融云公有云 SDK 无法连接到私有云环境）

     @discussion 融云公有云 SDK 无法连接到私有云环境。请确认需要连接的环境，使用正确 SDK 版本。
     */
    RC_ENVIRONMENT_ERROR = 34005,

    /*!
     连接超时。

    @discussion 当调用 connectWithToken:timeLimit:dbOpened:success:error:  接口，timeLimit 为有效值时，SDK 在 timeLimit 时间内还没连接成功返回此错误。
    */
    RC_CONNECT_TIMEOUT = 34006,

    /*!
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     */
    RC_INVALID_ARGUMENT = -1000
};

#pragma mark RCErrorCode - 具体业务错误码
/*!
 具体业务错误码
 */
typedef NS_ENUM(NSInteger, RCErrorCode) {
    /*!
     成功
     */
    RC_SUCCESS = 0,
    
    /*!
     未知错误（预留）
     */
    ERRORCODE_UNKNOWN = -1,

    /*!
     已被对方加入黑名单，消息发送失败。
     */
    REJECTED_BY_BLACKLIST = 405,
    
    
    /*!
     上传媒体文件格式不支持
     */
    RC_MEDIA_FILETYPE_INVALID = 34019,

    /*!
     超时
     */
    ERRORCODE_TIMEOUT = 5004,

    /*!
     发送消息频率过高，1 秒钟最多只允许发送 5 条消息
     */
    SEND_MSG_FREQUENCY_OVERRUN = 20604,
    
    /*!
    请求超出了调用频率限制，请稍后再试

    @discussion 接口调用过于频繁，请稍后再试。
    */
    RC_REQUEST_OVERFREQUENCY = 20607,

    /*!
     当前用户不在该讨论组中
     */
    NOT_IN_DISCUSSION = 21406,

    /*!
     当前用户不在该群组中
     */
    NOT_IN_GROUP = 22406,

    /*!
     当前用户在群组中已被禁言
     */
    FORBIDDEN_IN_GROUP = 22408,

    /*!
     当前用户不在该聊天室中
     */
    NOT_IN_CHATROOM = 23406,

    /*!
     当前用户在该聊天室中已被禁言
     */
    FORBIDDEN_IN_CHATROOM = 23408,

    /*!
     当前用户已被踢出并禁止加入聊天室。被禁止的时间取决于服务端调用踢出接口时传入的时间。
     */
    KICKED_FROM_CHATROOM = 23409,

    /*!
     聊天室不存在
     */
    RC_CHATROOM_NOT_EXIST = 23410,

    /*!
     聊天室成员超限，默认聊天室成员没有人数限制，但是开发者可以提交工单申请针对 App Key
     进行聊天室人数限制，在限制人数的情况下，调用加入聊天室的接口时人数超限，就会返回此错误码
     */
    RC_CHATROOM_IS_FULL = 23411,

    /*!
     聊天室接口参数无效。请确认参数是否为空或者有效。
     */
    RC_PARAMETER_INVALID_CHATROOM = 23412,

    /*!
     聊天室云存储业务未开通
     */
    RC_ROAMING_SERVICE_UNAVAILABLE_CHATROOM = 23414,

    /*!
     超过聊天室的最大状态设置数，1 个聊天室默认最多设置 100 个
     */
    RC_EXCCED_MAX_KV_SIZE = 23423,

    /*!
     聊天室中非法覆盖状态值，状态已存在，没有权限覆盖
     */
    RC_TRY_OVERWRITE_INVALID_KEY = 23424,

    /*!
     超过聊天室中状态设置频率，1 个聊天室 1 秒钟最多设置和删除状态 100 次
     */
    RC_EXCCED_MAX_CALL_API_SIZE = 23425,

    /*!
     聊天室状态存储功能没有开通，请联系商务开通
     */
    RC_KV_STORE_NOT_AVAILABLE = 23426,

    /*!
     聊天室状态值不存在
    */
    RC_KEY_NOT_EXIST = 23427,
    
    /*!
     聊天室批量设置 KV 部分不成功
    */
    RC_KV_STORE_NOT_ALL_SUCCESS = 23428,
    
    /*!
     聊天室设置 KV，数量超限（最多一次 10 条）
    */
    RC_KV_STORE_OUT_OF_LIMIT = 23429,
    
    /*!
     超级群功能没有开通，请联系商务开通
    */
    RC_ULTRA_GROUP_NOT_AVAILABLE = 24401,
    
    /*!
     当前用户不在该超级群中
     */
    RC_NOT_IN_ULTRA_GROUP = 24406,
    
    /*!
     当前用户在超级群中已被禁言
     */
    RC_FORBIDDEN_IN_ULTRA_GROUP = 24408,
    
    /*!
     操作跟服务端同步时出现问题，有可能是操作过于频繁所致。如果出现该错误，请延时 0.5s 再试
    */
    RC_SETTING_SYNC_FAILED = 26002,

    /*!
     小视频服务未开通。可以在融云开发者后台中开启该服务。
    */
    RC_SIGHT_SERVICE_UNAVAILABLE = 26101,
    
    /*!
     聊天室状态未同步完成
     刚加入聊天室时调用获取 KV 接口，极限情况下会存在本地数据和服务器未同步完成的情况，建议延时一段时间再获取
     */
    RC_KV_STORE_NOT_SYNC = 34004,
    
    /*!
     聊天室被重置
    */
    RC_CHATROOM_RESET = 33009,

    /*!
     当前连接不可用（连接已经被释放）
     */
    RC_CHANNEL_INVALID = 30001,

    /*!
     当前连接不可用
     */
    RC_NETWORK_UNAVAILABLE = 30002,

    /*!
     客户端发送消息请求，融云服务端响应超时。
     */
    RC_MSG_RESPONSE_TIMEOUT = 30003,
    
    /*!
    将消息存储到本地数据时失败。
    发送或插入消息时，消息需要存储到本地数据库，当存库失败时，会回调此错误码。
    
    可能由以下几种原因引起：
    * 1. 消息内包含非法参数。请检查消息的 targetId 或 senderId 是否为空或超过最大长度 64 字节。
    * 2. SDK 没有初始化。在使用 SDK 任何功能之前，请确保先初始化。
    * 3. SDK 没有连接。请确保调用 SDK 连接方法并回调数据库打开后再调用消息相关 API。
    */
    
    BIZ_SAVE_MESSAGE_ERROR = 33000,

    /*!
     SDK 没有初始化

     @discussion 在使用 SDK 任何功能之前，必须先 Init。
     */
    CLIENT_NOT_INIT = 33001,

    /*!
     数据库错误
     
     @discussion 连接融云的时候 SDK 会打开数据库，如果没有连接融云就调用了业务接口，因为数据库尚未打开，有可能出现该错误。
     @discussion 数据库路径中包含 userId，如果您获取 token 时传入的 userId 包含特殊字符，有可能导致该错误。userId
     支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 64 字节。
     */
    DATABASE_ERROR = 33002,

    /*!
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     */
    INVALID_PARAMETER = 33003,

    /*!
     历史消息云存储业务未开通。可以在融云开发者后台中开启该服务。
     */
    MSG_ROAMING_SERVICE_UNAVAILABLE = 33007,
    
    /*!
     标签不存在
     */
    RC_TAG_NOT_EXIST = 33100,
    
    /*!
     标签已存在
     */
    RC_TAG_ALREADY_EXISTS = 33101,
    
    /*!
     会话中不存在对应标签
     */
    RC_TAG_INVALID_FOR_CONVERSATION = 33102,
    
    /*!
     公众号非法类型，针对会话类型：ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_ERROR_TYPE = 29201,

    /*!
     公众号默认已关注，针对会话类型：ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_DEFFOLLOWED = 29102,
    
    /*!
     公众号已关注，针对会话类型：ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_FOLLOWED = 29103,
    
    /*!
     公众号默认已取消关注，针对会话类型：ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_DEFUNFOLLOWED = 29104,
    
    /*!
     公众号已经取消关注，针对会话类型：ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_UNFOLLOWED = 29105,
    
    /*!
     公众号未关注，针对会话类型：ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_UNFOLLOW = 29106,

    /*!
     公众号非法类型，针对会话类型：ConversationType_PUBLICSERVICE
     */
    INVALID_PUBLIC_NUMBER = 29201,

    /*!
     公众号默认已关注，针对会话类型：ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_DEFFOLLOWED = 29202,
    
    /*!
     公众号已关注，针对会话类型：ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_FOLLOWED = 29203,
    
    /*!
     公众号默认已取消关注，针对会话类型：ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_DEFUNFOLLOWED = 29204,
    
    /*!
     公众号已经取消关注，针对会话类型：ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_UNFOLLOWED = 29205,
    
    /*!
     公众号未关注，针对会话类型：ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_UNFOLLOW = 29206,
    
    /*!
      消息大小超限，消息体（序列化成 json 格式之后的内容）最大 128k bytes。
     */
    RC_MSG_SIZE_OUT_OF_LIMIT = 30016,

    /*!
    撤回消息参数无效。请确认撤回消息参数是否正确的填写。
     */
    RC_RECALLMESSAGE_PARAMETER_INVALID = 25101,

    /*!
    push 设置参数无效。请确认是否正确的填写了 push 参数。
     */
    RC_PUSHSETTING_PARAMETER_INVALID = 26001,
    
    /*!
     用户标签个数超限，最多支持添加 20 个标签
     */
    RC_TAG_LIMIT_EXCEED = 26004,

    /*!
    操作被禁止。 此错误码已被弃用。
     */
    RC_OPERATION_BLOCKED = 20605,

    /*!
    操作不支持。仅私有云有效，服务端禁用了该操作。
     */
    RC_OPERATION_NOT_SUPPORT = 20606,

    /*!
     发送的消息中包含敏感词 （发送方发送失败，接收方不会收到消息）
     */
    RC_MSG_BLOCKED_SENSITIVE_WORD = 21501,

    /*!
     消息中敏感词已经被替换 （接收方可以收到被替换之后的消息）
     */
    RC_MSG_REPLACED_SENSITIVE_WORD = 21502,

    /*!
     小视频时间长度超出限制，默认小视频时长上限为 2 分钟
     */
    RC_SIGHT_MSG_DURATION_LIMIT_EXCEED = 34002,

    /*!
     GIF 消息文件大小超出限制， 默认 GIF 文件大小上限是 2 MB
     */
    RC_GIF_MSG_SIZE_LIMIT_EXCEED = 34003,
    
    /**
     * 查询的公共服务信息不存在。
     * <p>请确认查询的公共服务的类型和公共服务 id 是否匹配。</p>
     */
    RC_PUBLIC_SERVICE_PROFILE_NOT_EXIST = 34007,
    
    /**
    * 消息不能被扩展。
    * <p>消息在发送时，RCMessage 对象的属性 canIncludeExpansion 置为 YES 才能进行扩展。</p>
    */
    RC_MESSAGE_CANT_EXPAND = 34008,

    /**
    * 消息扩展失败。
    * <p>一般是网络原因导致的，请确保网络状态良好，并且融云 SDK 连接正常</p>
    */
    RC_MESSAGE_EXPAND_FAIL = 34009,
    
    /*!
     消息扩展大小超出限制， 默认消息扩展字典 key 长度不超过 32 ，value 长度不超过 64 ，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
     */
    RC_MSG_EXPANSION_SIZE_LIMIT_EXCEED = 34010,
    
    /*!
     媒体消息媒体文件 http  上传失败
     */
    RC_FILE_UPLOAD_FAILED = 34011,
    
    /*!
     指定的会话类型不支持标签功能，会话标签仅支持单群聊会话、系统会话
     */
    RC_CONVERSATION_TAG_INVALID_CONVERSATION_TYPE = 34012,
    
    /*!
     批量处理指定标签的会话个数超限，批量处理会话个数最大为 1000
     */
    RC_CONVERSATION_TAG_LIMIT_EXCEED = 34013,
    
    /*!
     群已读回执版本不支持
     */
    RC_Group_Read_Receipt_Version_Not_Support = 34014,
    
    /*!
     视频消息压缩失败
     */
    RC_SIGHT_COMPRESS_FAILED = 34015,
    
    /*!
     用户级别设置未开通
     */
    RC_USER_SETTING_DISABLED = 34016,
    
    /*!
     消息处理失败
     * <p>一般是消息处理为 nil </p>
     */
    RC_MESSAGE_NULL_EXCEPTION = 34017,
    
    /*!
     媒体文件上传异常，媒体文件不存在或文件大小为 0
     */
    RC_MEDIA_EXCEPTION = 34018,
    
    /**
     * 文件已过期或被清理
     * 小视频文件默认存储 7 天，其它文件默认存储 6个月。到期后自动清理。
     * 如果小视频文件需要存储更长时间，可在[融云开发者后台](https://developer.rongcloud.cn/advance/index)的 **服务管理-> 小视频-> 服务设置** 中开通小视频高级版功能，开通后小视频文件，默认存储 6 个月。
     */
    RC_FILE_EXPIRED = 34020,
    
    /*!
     * 消息未被注册
     * 发送或者插入自定义消息之前，请确保注册了该类型的消息{RCCoreClient 或者 RCIM 的 registerMessageType}
     * added from 5.1.7
     */
    RC_MESSAGE_NOT_REGISTERED = 34021,
    
    /*!
     * 该接口不支持超级群会话
     * 
     */
    RC_ULTRA_GROUP_NOT_SUPPORT = 34022,
    
    /*!
     超级群功能未开通
     */
    RC_ULTRA_GROUP_DISABLED = 34023,
    
    /*!
     超级群频道不存在
     */
    RC_ULTRA_GROUP_CHANNEL_NOT_EXIST = 34024,
    
    /*!
     超级群扩展消息，但是原始消息不存在
     */
    RC_ORIGINAL_MESSAGE_NOT_EXIST = 22201,
     
    /*!
     超级群扩展消息，但是原始消息不支持扩展
     */
    RC_ORIGINAL_MESSAGE_CANT_EXPAND = 22202,

    /*!
     超级群扩展消息，扩展内容格式错误
     */
    RC_MESSAGE_EXPAND_FORMAT_ERROR = 22203,
};

typedef NS_ENUM(NSInteger, RCDBErrorCode) {
    RCDBOpenSuccess = 0,
    RCDBOpenFailed = 33002,
};

#pragma mark - 连接状态

#pragma mark RCConnectionStatus - 网络连接状态码
/*!
 网络连接状态码
 */
typedef NS_ENUM(NSInteger, RCConnectionStatus) {
    /*!
     未知状态

     @discussion 建立连接中出现异常的临时状态，SDK 会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_UNKNOWN = -1,

    /*!
     连接成功
     */
    ConnectionStatus_Connected = 0,

    /*!
     连接过程中，当前设备网络不可用

     @discussion 当网络恢复可用时，SDK 会做好自动重连，开发者无须处理。
     */
    ConnectionStatus_NETWORK_UNAVAILABLE = 1,

    /*!
     当前用户在其他设备上登录，此设备被踢下线
     */
    ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT = 6,

    /*!
     连接中
     */
    ConnectionStatus_Connecting = 10,

    /*!
     连接失败或未连接
     */
    ConnectionStatus_Unconnected = 11,

    /*!
     已登出
     */
    ConnectionStatus_SignOut = 12,

    /*!
     连接暂时挂起（多是由于网络问题导致），SDK 会在合适时机进行自动重连
    */
    ConnectionStatus_Suspend = 13,

    /*!
     自动连接超时，SDK 将不会继续连接，用户需要做超时处理，再自行调用 connectWithToken 接口进行连接
    */
    ConnectionStatus_Timeout = 14,

    /*!
     Token无效

     @discussion
     Token 无效一般有两种原因。一是 token 错误，请您检查客户端初始化使用的 AppKey 和您服务器获取 token 使用的 AppKey
     是否一致；二是 token 过期，是因为您在开发者后台设置了 token 过期时间，您需要请求您的服务器重新获取 token
     并再次用新的 token 建立连接。
     */
    ConnectionStatus_TOKEN_INCORRECT = 15,

    /*!
     与服务器的连接已断开,用户被封禁
     */
    ConnectionStatus_DISCONN_EXCEPTION = 16
};

#pragma mark RCNetworkStatus - 当前所处的网络
/*!
 当前所处的网络
 */
typedef NS_ENUM(NSUInteger, RCNetworkStatus) {
    /*!
     当前网络不可用
     */
    RC_NotReachable = 0,

    /*!
     当前处于 WiFi 网络
     */
    RC_ReachableViaWiFi = 1,

    /*!
     移动网络
     */
    RC_ReachableViaWWAN = 2,
};

#pragma mark RCSDKRunningMode - SDK当前所处的状态
/*!
 SDK 当前所处的状态
 */
typedef NS_ENUM(NSUInteger, RCSDKRunningMode) {
    /*!
     后台运行状态
     */
    RCSDKRunningMode_Background = 0,

    /*!
     前台运行状态
     */
    RCSDKRunningMode_Foreground = 1
};

#pragma mark - 会话相关

#pragma mark RCConversationType - 会话类型
/*!
 会话类型
 */
typedef NS_ENUM(NSUInteger, RCConversationType) {
    /*!
     单聊
     */
    ConversationType_PRIVATE = 1,

    /*!
     讨论组
     */
    ConversationType_DISCUSSION = 2,

    /*!
     群组
     */
    ConversationType_GROUP = 3,

    /*!
     聊天室
     */
    ConversationType_CHATROOM = 4,

    /*!
     客服
     */
    ConversationType_CUSTOMERSERVICE = 5,

    /*!
     系统会话
     */
    ConversationType_SYSTEM = 6,

    /*!
     应用内公众服务会话

     @discussion
     客服 2.0 使用应用内公众服务会话（ConversationType_APPSERVICE）的方式实现。
     即客服 2.0  会话是其中一个应用内公众服务会话， 这种方式我们目前不推荐，
     请尽快升级到新客服，升级方法请参考官网的客服文档。文档链接
     https://docs.rongcloud.cn/services/public/app/prepare/
     */
    ConversationType_APPSERVICE = 7,

    /*!
     跨应用公众服务会话
     */
    ConversationType_PUBLICSERVICE = 8,

    /*!
     推送服务会话
     */
    ConversationType_PUSHSERVICE = 9,
    
    /*!
     超级群
     */
    ConversationType_ULTRAROUP = 10,

    /*!
     加密会话（仅对部分私有云用户开放，公有云用户不适用）
     */
    ConversationType_Encrypted = 11,
    /**
     * RTC 会话
     */
    ConversationType_RTC = 12,

    /*!
     无效类型
     */
    ConversationType_INVALID

};

#pragma mark RCConversationNotificationStatus - 会话提醒状态
/*!
 会话提醒状态
 */
typedef NS_ENUM(NSUInteger, RCConversationNotificationStatus) {
    /*!
     免打扰

     */
    DO_NOT_DISTURB = 0,

    /*!
     新消息提醒
     */
    NOTIFY = 1,
};

#pragma mark RCReadReceiptMessageType - 消息回执
/*!
 已读状态消息类型
 */
typedef NS_ENUM(NSUInteger, RCReadReceiptMessageType) {
    /*!
     根据会话来更新未读消息状态
     */
    RC_ReadReceipt_Conversation = 1,
};

#pragma mark - 消息相关

#pragma mark RCMessagePersistent - 消息的存储策略
/*!
 消息的存储策略
 */
typedef NS_ENUM(NSUInteger, RCMessagePersistent) {
    /*!
     在本地不存储，不计入未读数
     */
    MessagePersistent_NONE = 0,

    /*!
     在本地只存储，但不计入未读数
     */
    MessagePersistent_ISPERSISTED = 1,

    /*!
     在本地进行存储并计入未读数
     */
    MessagePersistent_ISCOUNTED = 3,

    /*!
     在本地不存储，不计入未读数，并且如果对方不在线，服务器会直接丢弃该消息，对方如果之后再上线也不会再收到此消息。

     @discussion 一般用于发送输入状态之类的消息。
     */
    MessagePersistent_STATUS = 16
};

#pragma mark RCMessageDirection - 消息的方向
/*!
 消息的方向
 */
typedef NS_ENUM(NSUInteger, RCMessageDirection) {
    /*!
     发送
     */
    MessageDirection_SEND = 1,

    /*!
     接收
     */
    MessageDirection_RECEIVE = 2
};

#pragma mark RCSentStatus - 消息的发送状态
/*!
 消息的发送状态
 */
typedef NS_ENUM(NSUInteger, RCSentStatus) {
    /*!
     发送中
     */
    SentStatus_SENDING = 10,

    /*!
     发送失败
     */
    SentStatus_FAILED = 20,

    /*!
     已发送成功
     */
    SentStatus_SENT = 30,

    /*!
     对方已接收
     */
    SentStatus_RECEIVED = 40,

    /*!
     对方已阅读
     */
    SentStatus_READ = 50,

    /*!
     对方已销毁
     */
    SentStatus_DESTROYED = 60,

    /*!
     发送已取消
     */
    SentStatus_CANCELED = 70,

    /*!
     无效类型
     */
    SentStatus_INVALID
};

#pragma mark RCReceivedStatus - 消息的接收状态
/*!
 消息的接收状态
 */
typedef NS_ENUM(NSUInteger, RCReceivedStatus) {
    /*!
     未读
     */
    ReceivedStatus_UNREAD = 0,

    /*!
     已读
     */
    ReceivedStatus_READ = 1,

    /*!
     已听

     @discussion 仅用于语音消息
     */
    ReceivedStatus_LISTENED = 2,

    /*!
     已下载
     */
    ReceivedStatus_DOWNLOADED = 4,

    /*!
     该消息已经被其他登录的多端收取过。（即该消息已经被其他端收取过后。当前端才登录，并重新拉取了这条消息。客户可以通过这个状态更新
     UI，比如不再提示）。
     */
    ReceivedStatus_RETRIEVED = 8,

    /*!
     该消息是被多端同时收取的。（即其他端正同时登录，一条消息被同时发往多端。客户可以通过这个状态值更新自己的某些 UI
     状态）。
     */
    ReceivedStatus_MULTIPLERECEIVE = 16,

};

#pragma mark RCMediaType - 消息内容中多媒体文件的类型
/*!
 消息内容中多媒体文件的类型
 */
typedef NS_ENUM(NSUInteger, RCMediaType) {
    /*!
     图片
     */
    MediaType_IMAGE = 1,

    /*!
     语音
     */
    MediaType_AUDIO = 2,

    /*!
     视频
     */
    MediaType_VIDEO = 3,

    /*!
     其他文件
     */
    MediaType_FILE = 4,

    /*!
     小视频
     */
    MediaType_SIGHT = 5,

    /*!
     合并转发
     */
    MediaType_HTML = 6
};

#pragma mark RCTypingStatus - 输入状态
typedef NS_ENUM(NSUInteger, RCUltraGroupTypingStatus) {
    /*!
     正在输入文本
     */
    RCUltraGroupTypingStatusText = 0,
};

#pragma mark RCMediaType - 消息中@提醒的类型
/*!
 @提醒的类型
 */
typedef NS_ENUM(NSUInteger, RCMentionedType) {
    /*!
     @ 所有人
     */
    RC_Mentioned_All = 1,

    /*!
     @ 部分指定用户
     */
    RC_Mentioned_Users = 2,
};

/**
 语音消息采样率

 - RCSample_Rate_8000: 8KHz
 - RCSample_Rate_16000: 16KHz
 */
typedef NS_ENUM(NSInteger, RCSampleRate) {
    RCSample_Rate_8000 = 1,  // 8KHz
    RCSample_Rate_16000 = 2, // 16KHz
};

/**
 语音消息类型

 - RCVoiceMessageTypeOrdinary: 普通音质语音消息
 - RCVoiceMessageTypeHighQuality: 高音质语音消息
 */
typedef NS_ENUM(NSInteger, RCVoiceMessageType) {
    RCVoiceMessageTypeOrdinary = 1,
    RCVoiceMessageTypeHighQuality = 2,
};

#pragma mark - 公众服务相关

#pragma mark RCPublicServiceType - 公众服务账号类型
/*!
 公众服务账号类型
 */
typedef NS_ENUM(NSUInteger, RCPublicServiceType) {
    /*!
     应用内公众服务账号
     */
    RC_APP_PUBLIC_SERVICE = 7,

    /*!
     跨应用公众服务账号
     */
    RC_PUBLIC_SERVICE = 8,
};

#pragma mark RCSearchType - 公众服务查找匹配方式
/*!
 公众服务查找匹配方式
 */
typedef NS_ENUM(NSUInteger, RCSearchType) {
    /*!
     精确匹配
     */
    RC_SEARCH_TYPE_EXACT = 0,

    /*!
     模糊匹配
     */
    RC_SEARCH_TYPE_FUZZY = 1,
    /*!
     无效类型
     */
    RCSearchType_INVALID
};

#pragma mark RCLogLevel - 日志级别
/*!
 日志级别
 */
typedef NS_ENUM(NSUInteger, RCLogLevel) {

    /*!
     *  不输出任何日志
     */
    RC_Log_Level_None = 0,

    /*!
     *  只输出错误的日志
     */
    RC_Log_Level_Error = 1,

    /*!
     *  输出错误和警告的日志
     */
    RC_Log_Level_Warn = 2,

    /*!
     *  输出错误、警告和一般的日志
     */
    RC_Log_Level_Info = 3,

    /*!
     *  输出输出错误、警告和一般的日志以及 debug 日志
     */
    RC_Log_Level_Debug = 4,

    /*!
     *  输出所有日志
     */
    RC_Log_Level_Verbose = 5,
};

#pragma mark RCTimestampOrder - 历史消息查询顺序
/*!
 日志级别
 */
typedef NS_ENUM(NSUInteger, RCTimestampOrder) {
    /*!
     *  降序, 按照时间戳从大到小
     */
    RC_Timestamp_Desc = 0,

    /*!
     *  升序, 按照时间戳从小到大
     */
    RC_Timestamp_Asc = 1,
};

#pragma mark RCPlatform - 在线平台
/*!
 在线平台
 */
typedef NS_ENUM(NSUInteger, RCPlatform) {
    /*!
     其它平台
     */
    RCPlatform_Other = 0,

    /*!
     iOS
     */
    RCPlatform_iOS = 1,

    /*!
     Android
     */
    RCPlatform_Android = 2,

    /*!
     Web
     */
    RCPlatform_Web = 3,

    /*!
     PC
     */
    RCPlatform_PC = 4
};

#pragma mark RCPushLauguageType - push 语言设置
/*!
 push 语言设置
 */
typedef NS_ENUM(NSUInteger, RCPushLauguage) {
    /*!
     英文
     */
    RCPushLauguage_EN_US = 1,
    /*!
     中文
     */
    RCPushLauguage_ZH_CN = 2,
    /*!
     阿拉伯文
     */
    RCPushLauguage_AR_SA
};

#pragma mark RCMessageBlockType - 消息被拦截类型

/*!
 消息被拦截类型
 */
typedef NS_ENUM(NSUInteger, RCMessageBlockType) {
    /*!
     全局敏感词：命中了融云内置的全局敏感词
     */
    RCMessageBlockTypeGlobal = 1,

    /*!
     自定义敏感词拦截：命中了客户在融云自定义的敏感词
     */
    RCMessageBlockTypeCustom = 2,
    
    /*!
     第三方审核拦截：命中了第三方（数美）或模板路由决定不下发的状态
     */
    RCMessageBlockTypeThirdParty = 3,
};

#endif
