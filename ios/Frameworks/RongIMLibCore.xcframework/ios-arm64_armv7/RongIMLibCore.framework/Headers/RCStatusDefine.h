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

#pragma mark - Error Code

#pragma mark RCConnectErrorCode
/*!
 *  \~chinese
 建立连接返回的错误码
 
 *  \~english
 Error code returned by establishing a connection
 */
typedef NS_ENUM(NSInteger, RCConnectErrorCode) {

    /*!
     *  \~chinese
     AppKey 错误

     @discussion 请检查您使用的 AppKey 是否正确。
     
     *  \~english
     AppKey error.

     @ discussion Please check that you are using the correct AppKey.
     */
    RC_CONN_ID_REJECT = 31002,

    /*!
     *  \~chinese
     Token 无效

     @discussion 请检查客户端初始化使用的 AppKey 和您服务器获取 token 使用的 AppKey 是否一致。
     @discussion 您可能需要请求您的服务器重新获取 token，并使用新的 token 建立连接。
     
     *  \~english
     Invalid Token.

     @ discussion Token is generally invalid for two reasons.
          The first is the token error. Please check whether the AppKey used by the client initialization is consistent with the AppKey used by your server to obtain the token.
     Second, the token expires because you set the token expiration time in the developer background. You shall request your server to retrieve the token and use the new token again to establish a connection.
     */
    RC_CONN_TOKEN_INCORRECT = 31004,

    /*!
     *  \~chinese
     App 校验未通过
     
     @discussion 您开通了 App 校验功能，但是校验未通过
     
     *  \~english
     AppKey does not match Token.

     @ discussion
     Please check that the AppKey and Token you are using are correct and match. Generally there are three reasons.
     */
    RC_CONN_NOT_AUTHRORIZED = 31005,

    /*!
     *  \~chinese
     BundleID 不正确

     @discussion 请检查您 App 的 BundleID 是否正确。
     
     *  \~english
     Incorrect BundleID.

     @ discussion Please check that the BundleID of your App is correct.
     */
    RC_CONN_PACKAGE_NAME_INVALID = 31007,

    /*!
     *  \~chinese
     AppKey 被封禁或已删除

     @discussion 请检查您使用的 AppKey 是否被封禁或已删除。
     
     *  \~english
     AppKey is blocked or deleted.

     @ discussion Please check whether the AppKey you are using is blocked or deleted.
     */
    RC_CONN_APP_BLOCKED_OR_DELETED = 31008,

    /*!
     *  \~chinese
     用户被封禁

     @discussion 请检查您使用的 Token 是否正确，以及对应的 UserId 是否被封禁。
     
     *  \~english
     Users are blocked.

     @ discussion Please check whether the Token you are using is correct and whether the corresponding UserId is blocked.
     */
    RC_CONN_USER_BLOCKED = 31009,

    /*!
     *  \~chinese
     用户被踢下线

      @discussion 当前用户在其他设备上登录，此设备被踢下线
     
     *  \~english
     The user is kicked offline.

     @ discussion The current user logs in on another device, and this device is kicked offline.
     */
    RC_DISCONN_KICK = 31010,
    
    /*!
     *  \~chinese
     token 已过期
     
     @discussion 您可能需要请求您的服务器重新获取 token，并使用新的 token 建立连接。
    
    *  \~english
     The token has expired

     @Discussion you may need to request your server to retrieve the token and establish a connection with the new token.
     */
    RC_CONN_TOKEN_EXPIRE = 31020,

    /*!
     *  \~chinese
     用户在其它设备上登录

      @discussion 重连过程中当前用户在其它设备上登录
     
     *  \~english
     The user logs in on another device.

     @ discussion The current user logs in on another device during the reconnection process.
     */
    RC_CONN_OTHER_DEVICE_LOGIN = 31023,
    
    /*!
     *  \~chinese
     连接总数量超过服务设定的并发限定值
     
     @discussion 私有云专属
    
     *  \~english
     The connection exceeds the concurrency limit.
     @discussion private cloud only
     */
    CONCURRENT_LIMIT_ERROR = 31024,
    
    /*!
     *  \~chinese
     环境校验失败
     
     @discussion 请检查 AppKey 和连接环境（开发环境/生产环境）是否匹配
    
     *  \~english
     Environment verification failed

     @Discussion please check whether the appkey matches the connection environment (development environment / production environment)
     */
    RC_CONN_CLUSTER_ERROR  = 31026,

    /*!
     *  \~chinese
     SDK 没有初始化

     @discussion 在使用 SDK 任何功能之前，必须先 Init。
     
     *  \~english
     SDK is not initialized.

     @ discussion It must Init before using any SDK functionality.
     */
    RC_CLIENT_NOT_INIT = 33001,

    /*!
     *  \~chinese
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     
     *  \~english
     The parameter passed in when the developer interface is called is incorrect.

     @ discussion Please check the parameter types and values passed in when the interface is called.
     */
    RC_INVALID_PARAMETER = 33003,

    /*!
     *  \~chinese
     Connection 已经存在

     @discussion
     调用过connect之后，只有在 token 错误或者被踢下线或者用户 logout 的情况下才需要再次调用 connect。其它情况下 SDK
     会自动重连，不需要应用多次调用 connect 来保持连接。
     
     *  \~english
     Connection already exists.

     @ discussion
     After calling connect, connect is called again only if there is a token error, or the user is kicked off, or the user logs out. In other cases, SDK will automatically reconnect, and an application need not call connect multiple times to maintain the connection.
     */
    RC_CONNECTION_EXIST = 34001,

    /*!
     *  \~chinese
     连接环境不正确（融云公有云 SDK 无法连接到私有云环境）

     @discussion 融云公有云 SDK 无法连接到私有云环境。请确认需要连接的环境，使用正确 SDK 版本。
     
     *  \~english
     Incorrect connection environment (RongCloud public cloud SDK cannot connect to private cloud environment).

     @ discussion RongCloud Public Cloud SDK cannot connect to the private cloud environment. Please confirm the environment to which you shall connect and use the correct SDK version.
     */
    RC_ENVIRONMENT_ERROR = 34005,

    /*!
     *  \~chinese
     连接超时。

    @discussion 当调用 connectWithToken:timeLimit:dbOpened:success:error:  接口，timeLimit 为有效值时，SDK 在 timeLimit 时间内还没连接成功返回此错误。
     
     *  \~english
     The connection timed out.

         @ discussion When  connectWithToken:timeLimit:dbOpened:success:error:  Interface is called, if timeLimit is a valid value and SDK has not been connected successfully within timeLimit time. This error is returned.
    */
    RC_CONNECT_TIMEOUT = 34006,

    /*!
     *  \~chinese
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     
     *  \~english
     The parameter passed in when the developer interface is called is incorrect.

     @ discussion Please check the parameter types and values passed in when the interface is called.
     */
    RC_INVALID_ARGUMENT = -1000
};

#pragma mark RCErrorCode
/*!
 *  \~chinese
 具体业务错误码
 
 *  \~english
 Specific business error code
 */
typedef NS_ENUM(NSInteger, RCErrorCode) {
    /*!
     *  \~chinese
     成功
     
     *  \~english
     Success
     */
    RC_SUCCESS = 0,
    
    /*!
     *  \~chinese
     未知错误（预留）
     
     *  \~english
     Unknown error (reserved)
     */
    ERRORCODE_UNKNOWN = -1,

    /*!
     *  \~chinese
     已被对方加入黑名单，消息发送失败。
     
     *  \~english
     It has been blacklisted by the other party, and the message failed to be sent.
     */
    REJECTED_BY_BLACKLIST = 405,
    
    
    /*!
     *  \~chinese
     上传媒体文件格式不支持
     
     *  \~english
     Upload media file format is not supported
     */
    RC_MEDIA_FILETYPE_INVALID = 34019,

    /*!
     *  \~chinese
     超时
     
     *  \~english
     Timeout
     */
    ERRORCODE_TIMEOUT = 5004,

    /*!
     *  \~chinese
     发送消息频率过高，1 秒钟最多只允许发送 5 条消息
     
     *  \~english
     The frequency of sending messages is too high and a maximum of 5 messages are allowed to be sent per second
     */
    SEND_MSG_FREQUENCY_OVERRUN = 20604,
    
    /*!
     *  \~chinese
    请求超出了调用频率限制，请稍后再试

    @discussion 接口调用过于频繁，请稍后再试。
     
     *  \~english
     The request exceeds the limit of call frequency. Please try again later.

     @ discussion The interface is called too frequently. Please try again later.
    */
    RC_REQUEST_OVERFREQUENCY = 20607,

    /*!
     *  \~chinese
     当前用户不在该讨论组中
     
     *  \~english
     The current user is not in this discussion group.
     */
    NOT_IN_DISCUSSION = 21406,

    /*!
     *  \~chinese
     当前用户不在该群组中
     
     *  \~english
     The current user is not in this group
     */
    NOT_IN_GROUP = 22406,

    /*!
     *  \~chinese
     当前用户在群组中已被禁言
     
     *  \~english
     The current user has been banned in the group
     */
    FORBIDDEN_IN_GROUP = 22408,

    /*!
     *  \~chinese
     当前用户不在该聊天室中
     
     *  \~english
     The current user is not in this chatroom
     */
    NOT_IN_CHATROOM = 23406,

    /*!
     *  \~chinese
     当前用户在该聊天室中已被禁言
     
     *  \~english
     The current user has been banned in this chatroom
     */
    FORBIDDEN_IN_CHATROOM = 23408,

    /*!
     *  \~chinese
     当前用户已被踢出并禁止加入聊天室。被禁止的时间取决于服务端调用踢出接口时传入的时间。
     
     *  \~english
     The current user has been kicked out and banned from the chatroom. The prohibited time depends on the time passed in when the server invokes kicking out of the interface
     */
    KICKED_FROM_CHATROOM = 23409,

    /*!
     *  \~chinese
     聊天室不存在
     
     *  \~english
     chatroom does not exist
     */
    RC_CHATROOM_NOT_EXIST = 23410,

    /*!
     *  \~chinese
     聊天室成员超限，默认聊天室成员没有人数限制，但是开发者可以提交工单申请针对 App Key
     进行聊天室人数限制，在限制人数的情况下，调用加入聊天室的接口时人数超限，就会返回此错误码
     
     *  \~english
     chatroom membership exceeds the limit. By default, there is no limit on the number of chatroom members, but developers can submit a ticket to apply for App Key.
     Limit the number of people in a chatroom. In the case of a limit, if the number of people exceeds the limit when calling the interface to join the chatroom, this error code will be returned.
     */
    RC_CHATROOM_IS_FULL = 23411,

    /*!
     *  \~chinese
     聊天室接口参数无效。请确认参数是否为空或者有效。
     
     *  \~english
     The chatroom interface parameter is invalid. Please confirm that the parameter is empty or valid.
     */
    RC_PARAMETER_INVALID_CHATROOM = 23412,

    /*!
     *  \~chinese
     聊天室云存储业务未开通
     
     *  \~english
     The chatroom cloud storage service has not been activated.
     */
    RC_ROAMING_SERVICE_UNAVAILABLE_CHATROOM = 23414,

    /*!
     *  \~chinese
     超过聊天室的最大状态设置数，1 个聊天室默认最多设置 100 个
     
     *  \~english
     The maximum number of status settings for a chatroom is exceeded and a maximum of 100 status settings can be set for 1 chatroom by default.
     */
    RC_EXCCED_MAX_KV_SIZE = 23423,

    /*!
     *  \~chinese
     聊天室中非法覆盖状态值，状态已存在，没有权限覆盖
     
     *  \~english
     The status value is illegally overwritten in the chatroom. The status already exists and there is no permission to overwrite it.
     */
    RC_TRY_OVERWRITE_INVALID_KEY = 23424,

    /*!
     *  \~chinese
     超过聊天室中状态设置频率，1 个聊天室 1 秒钟最多设置和删除状态 100 次
     
     *  \~english
     The maximum frequency of status setting in a chatroom is exceeded. The status for a chatroom can be set and deleted for up to 100 times per second.
     */
    RC_EXCCED_MAX_CALL_API_SIZE = 23425,

    /*!
     *  \~chinese
     聊天室状态存储功能没有开通，请联系商务开通
     
     *  \~english
     The chatroom status storage function is not enabled, please contact commerce person to open.
     */
    RC_KV_STORE_NOT_AVAILABLE = 23426,

    /*!
     *  \~chinese
     聊天室状态值不存在
     
     *  \~english
     The chatroom status value does not exist.
    */
    RC_KEY_NOT_EXIST = 23427,
    
    /*!
     *  \~chinese
     操作跟服务端同步时出现问题，有可能是操作过于频繁所致。如果出现该错误，请延时 0.5s 再试
     
     *  \~english
     There is a problem when the operation is synchronized with the server, which may be caused by the frequent operation. If this error occurs, please delay 0.5s and try again
    */
    RC_SETTING_SYNC_FAILED = 26002,

    /*!
     *  \~chinese
     小视频服务未开通。可以在融云开发者后台中开启该服务。
     
     *  \~english
     Small video service is not enabled. The service can be started in the background of rongyun developers.
    */
    RC_SIGHT_SERVICE_UNAVAILABLE = 26101,
    
    /*!
     *  \~chinese
     聊天室状态未同步完成
     刚加入聊天室时调用获取 KV 接口，极限情况下会存在本地数据和服务器未同步完成的情况，建议延时一段时间再获取
     
     *  \~english
     chatroom status is not completed synchronously.
     Call the interface to get KV when you just join the chatroom. In extreme cases, the local data and the server are not completed synchronously. It is recommended to delay the acquisition for a period of time.
     */
    RC_KV_STORE_NOT_SYNC = 34004,
    
    /*!
     *  \~chinese
     聊天室被重置
     
     *  \~english
     The chatroom is reset
    */
    RC_CHATROOM_RESET = 33009,

    /*!
     *  \~chinese
     当前连接不可用（连接已经被释放）
     
     *  \~english
     The current connection is not available (the connection has been released).
     */
    RC_CHANNEL_INVALID = 30001,

    /*!
     *  \~chinese
     当前连接不可用
     
     *  \~english
     The current connection is not available.
     */
    RC_NETWORK_UNAVAILABLE = 30002,

    /*!
     *  \~chinese
     客户端发送消息请求，融云服务端响应超时。
     
     *  \~english
     The client sends a message request, and the RongCloud server responds to a timeout.
     */
    RC_MSG_RESPONSE_TIMEOUT = 30003,

    /*!
     *  \~chinese
     SDK 没有初始化

     @discussion 在使用 SDK 任何功能之前，必须先 Init。
     
     *  \~english
     SDK is not initialized.

     @ discussion It must Init before using any SDK functionality.
     */
    CLIENT_NOT_INIT = 33001,

    /*!
     *  \~chinese
     数据库错误
     
     @discussion 连接融云的时候 SDK 会打开数据库，如果没有连接融云就调用了业务接口，因为数据库尚未打开，有可能出现该错误。
     @discussion 数据库路径中包含 userId，如果您获取 token 时传入的 userId 包含特殊字符，有可能导致该错误。userId
     支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式，最大长度 64 字节。
     
     *  \~english
     Database error.

     @ discussion The database will be opened when connecting to the cloud melting. If you do not connect to the cloud melting, the business interface will be called because the database has not been opened yet, and this error may occur.
          @ discussion The database path contains userId, if the userId passed in when you get the token contains special characters, which may cause this error. UserId.
     The combination of uppercase and lowercase letters, numbers and some special symbols + =-_ is supported, with a maximum length of 64 bytes.
     */
    DATABASE_ERROR = 33002,

    /*!
     *  \~chinese
     开发者接口调用时传入的参数错误

     @discussion 请检查接口调用时传入的参数类型和值。
     
     *  \~english
     The parameter passed in when the developer interface is called is incorrect.

     @ discussion Please check the parameter types and values passed in when the interface is called.
     */
    INVALID_PARAMETER = 33003,

    /*!
     *  \~chinese
     历史消息云存储业务未开通。可以在融云开发者后台中开启该服务。
     
     *  \~english
     The cloud storage service of historical messages has not been activated. You can enable this service in the backend of RongCloud developer.
     */
    MSG_ROAMING_SERVICE_UNAVAILABLE = 33007,
    
    /*!
     *  \~chinese
     标签不存在
     
     *  \~english
     Tag does not exist
     */
    RC_TAG_NOT_EXIST = 33100,
    
    /*!
     *  \~chinese
     标签已存在
     
     *  \~english
     Tag already exists
     */
    RC_TAG_ALREADY_EXISTS = 33101,
    
    /*!
     *  \~chinese
     会话中不存在对应标签
     
     *  \~english
     There is no corresponding tag in the conversation
     */
    RC_TAG_INVALID_FOR_CONVERSATION = 33102,
    
    /*!
     *  \~chinese
     公众号非法类型，针对会话类型：ConversationType_APPSERVICE
     
     *  \~english
     Illegal official account type, for conversation type: ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_ERROR_TYPE = 29201,

    /*!
     *  \~chinese
     公众号默认已关注，针对会话类型：ConversationType_APPSERVICE
     
     *  \~english
     Official account has been followed by default, for conversation type: ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_DEFFOLLOWED = 29102,
    
    /*!
     *  \~chinese
     公众号已关注，针对会话类型：ConversationType_APPSERVICE
     
     *  \~english
     Official account has been followed, for conversation type: ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_FOLLOWED = 29103,
    
    /*!
     *  \~chinese
     公众号默认已取消关注，针对会话类型：ConversationType_APPSERVICE
     
     *  \~english
     Official account has been unfollowed by default, for conversation type: ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_DEFUNFOLLOWED = 29104,
    
    /*!
     *  \~chinese
     公众号已经取消关注，针对会话类型：ConversationType_APPSERVICE
     
     *  \~english
     The official account has been unfollowed, for conversation type: ConversationType_APPSERVICE
     */
    RC_APP_PUBLICSERVICE_UNFOLLOWED = 29105,
    
    /*!
     *  \~chinese
     公众号未关注，针对会话类型：ConversationType_APPSERVICE
     
     *  \~english
     Official account is not followed, for conversation type: ConversationType_APPSERVICE.
     */
    RC_APP_PUBLICSERVICE_UNFOLLOW = 29106,

    /*!
     *  \~chinese
     公众号非法类型，针对会话类型：ConversationType_PUBLICSERVICE
     
     *  \~english
     Illegal official account type, for conversation type: ConversationType_PUBLICSERVICE
     */
    INVALID_PUBLIC_NUMBER = 29201,

    /*!
     *  \~chinese
     公众号默认已关注，针对会话类型：ConversationType_PUBLICSERVICE
     
     *  \~english
     Official account has been followed by default, for conversation type: ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_DEFFOLLOWED = 29202,
    
    /*!
     *  \~chinese
     公众号已关注，针对会话类型：ConversationType_PUBLICSERVICE
     
     *  \~english
     Official account has been following, for conversation type: ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_FOLLOWED = 29203,
    
    /*!
     *  \~chinese
     公众号默认已取消关注，针对会话类型：ConversationType_PUBLICSERVICE
     
     *  \~english
     Official account has been unfollowed by default, for conversation type: ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_DEFUNFOLLOWED = 29204,
    
    /*!
     *  \~chinese
     公众号已经取消关注，针对会话类型：ConversationType_PUBLICSERVICE
     
     *  \~english
     The official account has been unfollowed, for conversation type: ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_UNFOLLOWED = 29205,
    
    /*!
     *  \~chinese
     公众号未关注，针对会话类型：ConversationType_PUBLICSERVICE
     
     *  \~english
     Official account is not followed, for conversation type: ConversationType_PUBLICSERVICE
     */
    RC_PUBLICSERVICE_UNFOLLOW = 29206,
    
    /*!
     *  \~chinese
      消息大小超限，消息体（序列化成 json 格式之后的内容）最大 128k bytes。
     
     *  \~english
     The message size exceeds the limit, and the message body (the content after serialization into json format) is up to 128k bytes
     */
    RC_MSG_SIZE_OUT_OF_LIMIT = 30016,

    /*!
     *  \~chinese
    撤回消息参数无效。请确认撤回消息参数是否正确的填写。
     
     *  \~english
     The recall message parameter is invalid. Please make sure that the recall message parameters are filled in correctly.
     */
    RC_RECALLMESSAGE_PARAMETER_INVALID = 25101,

    /*!
     *  \~chinese
    push 设置参数无效。请确认是否正确的填写了 push 参数。
     
     *  \~english
     Invalid push setting parameter. Please make sure that the push parameter is entered correctly.
     */
    RC_PUSHSETTING_PARAMETER_INVALID = 26001,
    
    /*!
     *  \~chinese
     用户标签个数超限，最多支持添加 20 个标签
     
     *  \~english
     The number of user tags exceeds the limit and a maximum of 20 tags can be added.
     */
    RC_TAG_LIMIT_EXCEED = 26004,

    /*!
     *  \~chinese
    操作被禁止。 此错误码已被弃用。
     
     *  \~english
     The operation is prohibited. This error code has been deprecated.
     */
    RC_OPERATION_BLOCKED = 20605,

    /*!
     *  \~chinese 
    操作不支持。仅私有云有效，服务端禁用了该操作。
     
     *  \~english
     The operation is not supported. Only the private cloud is valid, and the server disables this operation.
     */
    RC_OPERATION_NOT_SUPPORT = 20606,

    /*!
     *  \~chinese
     发送的消息中包含敏感词 （发送方发送失败，接收方不会收到消息）
     
     *  \~english
     The message sent contains sensitive words (the sender fails to send, and the receiver does not receive the message).
     */
    RC_MSG_BLOCKED_SENSITIVE_WORD = 21501,

    /*!
     *  \~chinese
     消息中敏感词已经被替换 （接收方可以收到被替换之后的消息）
     
     *  \~english
     The sensitive words in the message have been replaced (the receiver can receive the message after the replacement).
     */
    RC_MSG_REPLACED_SENSITIVE_WORD = 21502,

    /*!
     *  \~chinese
     小视频时间长度超出限制，默认小视频时长上限为 2 分钟
     
     *  \~english
     The length of small video exceeds the limit. By default, the maximum length of small video is 2 minutes.
     */
    RC_SIGHT_MSG_DURATION_LIMIT_EXCEED = 34002,

    /*!
     *  \~chinese
     GIF 消息文件大小超出限制， 默认 GIF 文件大小上限是 2 MB
     
     *  \~english
     The size of the GIF message file exceeds the limit and the maximum size of the default GIF file is 2 MB
     */
    RC_GIF_MSG_SIZE_LIMIT_EXCEED = 34003,
    
    /**
     *  \~chinese
     * 查询的公共服务信息不存在。
     * <p>请确认查询的公共服务的类型和公共服务 id 是否匹配。</p>
     
     *  \~english
     * The public service information queried does not exist.
     * <p> Please make sure that the type of public service queried matches the public service id. </p>
     */
    RC_PUBLIC_SERVICE_PROFILE_NOT_EXIST = 34007,
    
    /**
     *  \~chinese
     * 消息不能被扩展。
     * <p>消息在发送时，RCMessage 对象的属性 canIncludeExpansion 置为 YES 才能进行扩展。</p>
     
     *  \~english
     * Messages cannot be extended.
     * <p> When a message is sent, the property canIncludeExpansion of the RCMessage object is set to YES before it can be extended.
    */
    RC_MESSAGE_CANT_EXPAND = 34008,

    /**
     *  \~chinese
     * 消息扩展失败。
     * <p>一般是网络原因导致的，请确保网络状态良好，并且融云 SDK 连接正常</p>
     
     *  \~english
     * Message expansion failed.
     * <p> Usually it is caused by the network. Make sure the network is in good condition and the cloud SDK connection is normal </p>.
    */
    RC_MESSAGE_EXPAND_FAIL = 34009,
    
    /*!
     *  \~chinese
     消息扩展大小超出限制， 默认消息扩展字典 key 长度不超过 32 ，value 长度不超过 64 ，单次设置扩展数量最大为 20，消息的扩展总数不能超过 300
     
     *  \~english
     The message extension size exceeds the limit. The default message extension dictionary key length does not exceed 32, the value length does not exceed 64, the maximum number of extensions set at a time is 20, and the total number of message extensions cannot exceed 300.
     */
    RC_MSG_EXPANSION_SIZE_LIMIT_EXCEED = 34010,
    
    /*!
     *  \~chinese
     媒体消息媒体文件 http  上传失败
     
     *  \~english
     Media message media file http upload failed
     */
    RC_FILE_UPLOAD_FAILED = 34011,
    
    /*!
     *  \~chinese
     指定的会话类型不支持标签功能，会话标签仅支持单群聊会话、系统会话
     
     *  \~english
     The specified conversation type does not support tag function, and conversation tag only supports single group chat conversation and system conversation
     */
    RC_CONVERSATION_TAG_INVALID_CONVERSATION_TYPE = 34012,
    
    /*!
     *  \~chinese
     批量处理指定标签的会话个数超限，批量处理会话个数最大为 1000
     
     *  \~english
     The number of conversations for batch processing of specified tags exceeds the limit, and the maximum number of conversations for batch processing is 1000
     */
    RC_CONVERSATION_TAG_LIMIT_EXCEED = 34013,
    
    /*!
     *  \~chinese
     群已读回执版本不支持
     
     *  \~english
     Group read receipt version is not supported
     */
    RC_Group_Read_Receipt_Version_Not_Support = 34014,
    
    /*!
     *  \~chinese
     视频消息压缩失败
     
     *  \~english
     Video message compression failed
     */
    RC_SIGHT_COMPRESS_FAILED = 34015,
    
    /*!
     *  \~chinese
     用户级别设置未开通
     
     *  \~english
     User level settings are not enabled
     */
    RC_USER_SETTING_DISABLED = 34016,
    
    /*!
     *  \~chinese
     消息处理失败
     * <p>一般是消息处理为 nil </p>
     
     *  \~english
     Message processing failed.
     *<p> Generally, messages are handled as nil </p>
     */
    RC_MESSAGE_NULL_EXCEPTION = 34017,
    
    /*!
     *  \~chinese
     媒体文件上传异常，媒体文件不存在或文件大小为 0
     
     *  \~english
     Media file upload exception, media file does not exist or file size is 0
     */
    RC_MEDIA_EXCEPTION = 34018,
};

typedef NS_ENUM(NSInteger, RCDBErrorCode) {
    RCDBOpenSuccess = 0,
    RCDBOpenFailed = 33002,
};

#pragma mark - RCConnectionStatus

#pragma mark RCConnectionStatus
/*!
 *  \~chinese
 网络连接状态码
 
 *  \~english
 Network connection status code.
 */
typedef NS_ENUM(NSInteger, RCConnectionStatus) {
    /*!
     *  \~chinese
     未知状态

     @discussion 建立连接中出现异常的临时状态，SDK 会做好自动重连，开发者无须处理。
     
     *  \~english
     Unknown state.

     @ discussion If an abnormal temporary state occurs during the connection establishment, SDK will reconnect automatically and developers need not deal with it.
     */
    ConnectionStatus_UNKNOWN = -1,

    /*!
     *  \~chinese
     连接成功
     
     *  \~english
     Connected successfully
     */
    ConnectionStatus_Connected = 0,

    /*!
     *  \~chinese
     连接过程中，当前设备网络不可用

     @discussion 当网络恢复可用时，SDK 会做好自动重连，开发者无须处理。
     
     *  \~english
     The current device network is not available during connection.

     @ discussion When the network is available, SDK will reconnect automatically, so developers don't have to deal with it.
     */
    ConnectionStatus_NETWORK_UNAVAILABLE = 1,

    /*!
     *  \~chinese
     当前用户在其他设备上登录，此设备被踢下线
     
     *  \~english
     The current user is logged in on another device, and this device is kicked off the line.
     */
    ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT = 6,

    /*!
     *  \~chinese
     连接中
     
     *  \~english
     Connecting
     */
    ConnectionStatus_Connecting = 10,

    /*!
     *  \~chinese
     连接失败或未连接
     
     *  \~english
     Connection failed or not connected.
     */
    ConnectionStatus_Unconnected = 11,

    /*!
     *  \~chinese
     已登出
     
     *  \~english
     Logged out.
     */
    ConnectionStatus_SignOut = 12,

    /*!
     *  \~chinese
     连接暂时挂起（多是由于网络问题导致），SDK 会在合适时机进行自动重连
     
     *  \~english
     Connection is temporarily suspended (mostly due to network problems that cause) and SDK will reconnect automatically at the appropriate time.
    */
    ConnectionStatus_Suspend = 13,

    /*!
     *  \~chinese
     自动连接超时，SDK 将不会继续连接，用户需要做超时处理，再自行调用 connectWithToken 接口进行连接
     
     *  \~english
     Automatic connection timeout, SDK will not continue to connect, users shall do timeout handling, and the connectWithToken interface is called to connect.
    */
    ConnectionStatus_Timeout = 14,

    /*!
     *  \~chinese
     Token无效

     @discussion
     Token 无效一般有两种原因。一是 token 错误，请您检查客户端初始化使用的 AppKey 和您服务器获取 token 使用的 AppKey
     是否一致；二是 token 过期，是因为您在开发者后台设置了 token 过期时间，您需要请求您的服务器重新获取 token
     并再次用新的 token 建立连接。
     
     *  \~english
     Invalid Token.

     @ discussion
     Generally there are two reasons why Token is invalid. One is the token error. Please check the AppKey used by the client initialization and the AppKey used by your server to obtain the token.
     Whether it is consistent; Second, the token expires because you set the token expiration time in the developer background, and you shall request your server to retrieve the token and establish a connection with the new token again.
     */
    ConnectionStatus_TOKEN_INCORRECT = 15,

    /*!
     *  \~chinese
     与服务器的连接已断开,用户被封禁
     
     *  \~english
     The connection to the server has been disconnected and the user is blocked.
     */
    ConnectionStatus_DISCONN_EXCEPTION = 16
};

#pragma mark RCNetworkStatus
/*!
 *  \~chinese
 当前所处的网络
 
 *  \~english
 Current network
 */
typedef NS_ENUM(NSUInteger, RCNetworkStatus) {
    /*!
     *  \~chinese
     当前网络不可用
     
     *  \~english
     The current network is not available
     */
    RC_NotReachable = 0,

    /*!
     *  \~chinese
     当前处于 WiFi 网络
     
     *  \~english
     Currently on WiFi network
     */
    RC_ReachableViaWiFi = 1,

    /*!
     *  \~chinese
     移动网络
     
     *  \~english
     Mobile network
     */
    RC_ReachableViaWWAN = 2,
};

#pragma mark RCSDKRunningMode
/*!
 *  \~chinese
 SDK 当前所处的状态
 
 *  \~english
 The current state of SDK
 */
typedef NS_ENUM(NSUInteger, RCSDKRunningMode) {
    /*!
     *  \~chinese
     后台运行状态
     
     *  \~english
     Background running status
     */
    RCSDKRunningMode_Background = 0,

    /*!
     *  \~chinese
     前台运行状态
     
     *  \~english
     Foreground operation status
     */
    RCSDKRunningMode_Foreground = 1
};

#pragma mark - Conversation

#pragma mark RCConversationType
/*!
 *  \~chinese
 会话类型
 
 *  \~english
 Conversation type
 */
typedef NS_ENUM(NSUInteger, RCConversationType) {
    /*!
     *  \~chinese
     单聊
     
     *  \~english
     Chat alone
     */
    ConversationType_PRIVATE = 1,

    /*!
     *  \~chinese
     讨论组
     
     *  \~english
     Discussion group
     */
    ConversationType_DISCUSSION = 2,

    /*!
     *  \~chinese
     群组
     
     *  \~english
     Group
     */
    ConversationType_GROUP = 3,

    /*!
     *  \~chinese
     聊天室
     
     *  \~english
     chatroom
     */
    ConversationType_CHATROOM = 4,

    /*!
     *  \~chinese
     客服
     
     *  \~english
     Customer Service
     */
    ConversationType_CUSTOMERSERVICE = 5,

    /*!
     *  \~chinese
     系统会话
     
     *  \~english
     System conversation
     */
    ConversationType_SYSTEM = 6,

    /*!
     *  \~chinese
     应用内公众服务会话

     @discussion
     客服 2.0 使用应用内公众服务会话（ConversationType_APPSERVICE）的方式实现。
     即客服 2.0  会话是其中一个应用内公众服务会话， 这种方式我们目前不推荐，
     请尽快升级到新客服，升级方法请参考官网的客服文档。文档链接
     https://docs.rongcloud.cn/services/public/app/prepare/
     
     *  \~english
     In-application public service conversation.

     @ discussion
     Customer service 2. 0 is implemented using an in-application public service conversation (ConversationType_APPSERVICE).
          That is, customer service 2.0 conversation is one of the public service conversations in the application, which we do not recommend at this time.
     Please upgrade to the new customer service as soon as possible. For upgrade methods, please refer to the customer service documentation on the official website. Document link.
          https://docs.rongcloud.cn/services/public/app/prepare/
     */
    ConversationType_APPSERVICE = 7,

    /*!
     *  \~chinese
     跨应用公众服务会话
     
     *  \~english
     Cross-application public service conversation
     */
    ConversationType_PUBLICSERVICE = 8,

    /*!
     *  \~chinese
     推送服务会话
     
     *  \~english
     Push service conversation
     */
    ConversationType_PUSHSERVICE = 9,

    /*!
     *  \~chinese
     加密会话（仅对部分私有云用户开放，公有云用户不适用）
     
     *  \~english
     Encrypted conversation (only available to some private cloud users, not public cloud users)
     */
    ConversationType_Encrypted = 11,
    /**
     *  \~chinese
     * RTC 会话
     
     *  \~english
     * RTC conversation
     */
    ConversationType_RTC = 12,

    /*!
     *  \~chinese
     无效类型
     
     *  \~english
     Invalid type
     */
    ConversationType_INVALID

};

#pragma mark RCConversationNotificationStatus
/*!
 *  \~chinese
 会话提醒状态
 
 *  \~english
 Conversation reminder status
 */
typedef NS_ENUM(NSUInteger, RCConversationNotificationStatus) {
    /*!
     *  \~chinese
     免打扰
     
     *  \~english
     Do not disturb
     */
    DO_NOT_DISTURB = 0,

    /*!
     *  \~chinese
     新消息提醒
     
     *  \~english
     New message reminder
     */
    NOTIFY = 1,
};

#pragma mark RCReadReceiptMessageType
/*!
 *  \~chinese
 已读状态消息类型
 
 *  \~english
 Read status message type
 */
typedef NS_ENUM(NSUInteger, RCReadReceiptMessageType) {
    /*!
     *  \~chinese
     根据会话来更新未读消息状态
     
     *  \~english
     Update the status of unread messages based on the conversation
     */
    RC_ReadReceipt_Conversation = 1,
};

#pragma mark - Message

#pragma mark RCMessagePersistent
/*!
 *  \~chinese
 消息的存储策略
 
 *  \~english
 Storage strategy of messages
 */
typedef NS_ENUM(NSUInteger, RCMessagePersistent) {
    /*!
     *  \~chinese
     在本地不存储，不计入未读数
     
     *  \~english
     It is not stored locally and is not counted as unread number
     */
    MessagePersistent_NONE = 0,

    /*!
     *  \~chinese
     在本地只存储，但不计入未读数
     
     *  \~english
     Only stored locally, but not counted as unread number
     */
    MessagePersistent_ISPERSISTED = 1,

    /*!
     *  \~chinese
     在本地进行存储并计入未读数
     
     *  \~english
     Store locally and count as unread number
     */
    MessagePersistent_ISCOUNTED = 3,

    /*!
     *  \~chinese
     在本地不存储，不计入未读数，并且如果对方不在线，服务器会直接丢弃该消息，对方如果之后再上线也不会再收到此消息。

     @discussion 一般用于发送输入状态之类的消息，该类型消息的messageUId为nil。
     
     *  \~english
     It is not stored locally and is not counted into unread number. If the other party is not online, the server will directly discard the message, and the other party will not receive the message if it goes online later.

          @ discussion It is typically used to send messages such as input status, and the messageUId for this type of message is nil.
     */
    MessagePersistent_STATUS = 16
};

#pragma mark RCMessageDirection
/*!
 *  \~chinese
 消息的方向
 
 *  \~english
 The direction of the message.
 */
typedef NS_ENUM(NSUInteger, RCMessageDirection) {
    /*!
     *  \~chinese
     发送
     
     *  \~english
     Send
     */
    MessageDirection_SEND = 1,

    /*!
     *  \~chinese
     接收
     
     *  \~english
     Receive
     */
    MessageDirection_RECEIVE = 2
};

#pragma mark RCSentStatus
/*!
 *  \~chinese
 消息的发送状态
 
 *  \~english
 The sending status of the message
 */
typedef NS_ENUM(NSUInteger, RCSentStatus) {
    /*!
     *  \~chinese
     发送中
     
     *  \~english
     Sending
     */
    SentStatus_SENDING = 10,

    /*!
     *  \~chinese
     发送失败
     
     *  \~english
     Failed to send
     */
    SentStatus_FAILED = 20,

    /*!
     *  \~chinese
     已发送成功
     
     *  \~english
     Sent successfully
     */
    SentStatus_SENT = 30,

    /*!
     *  \~chinese
     对方已接收
     
     *  \~english
     The other party has received
     */
    SentStatus_RECEIVED = 40,

    /*!
     *  \~chinese
     对方已阅读
     
     *  \~english
     The other party has read
     */
    SentStatus_READ = 50,

    /*!
     *  \~chinese
     对方已销毁
     
     *  \~english
     The other party has been destroyed
     */
    SentStatus_DESTROYED = 60,

    /*!
     *  \~chinese
     发送已取消
     
     *  \~english
     Sending is canceled
     */
    SentStatus_CANCELED = 70,

    /*!
     *  \~chinese
     无效类型
     
     *  \~english
     Invalid type
     */
    SentStatus_INVALID
};

#pragma mark RCReceivedStatus
/*!
 *  \~chinese
 消息的接收状态
 
 *  \~english
 The receiving status of the message
 */
typedef NS_ENUM(NSUInteger, RCReceivedStatus) {
    /*!
     *  \~chinese
     未读
     
     *  \~english
     Unread
     */
    ReceivedStatus_UNREAD = 0,

    /*!
     *  \~chinese
     已读
     
     *  \~english
     Read
     */
    ReceivedStatus_READ = 1,

    /*!
     *  \~chinese
     已听

     @discussion 仅用于语音消息
     
     *  \~english
     Heard.

     @ discussion It is for voice messages only
     */
    ReceivedStatus_LISTENED = 2,

    /*!
     *  \~chinese
     已下载
     
     *  \~english
     Downloaded
     */
    ReceivedStatus_DOWNLOADED = 4,

    /*!
     *  \~chinese
     该消息已经被其他登录的多端收取过。（即该消息已经被其他端收取过后。当前端才登录，并重新拉取了这条消息。客户可以通过这个状态更新
     UI，比如不再提示）。
     
     *  \~english
     This message has been received by other logins. (That is, after the message has been received by other parties. The current side just logs in and pulls the message again. Customers can update UI through this status, for example, no more prompts).
     */
    ReceivedStatus_RETRIEVED = 8,

    /*!
     *  \~chinese
     该消息是被多端同时收取的。（即其他端正同时登录，一条消息被同时发往多端。客户可以通过这个状态值更新自己的某些 UI
     状态）。
     
     *  \~english
     The message is received by multiple parties at the same time. (That is, other terminals log in at the same time, and a message is sent to multiple terminals at the same time. Customers can update some of their UI status with this status value).
     */
    ReceivedStatus_MULTIPLERECEIVE = 16,

};

#pragma mark RCMediaType
/*!
 *  \~chinese
 消息内容中多媒体文件的类型
 
 *  \~english
 The type of multimedia file in the message content
 */
typedef NS_ENUM(NSUInteger, RCMediaType) {
    /*!
     *  \~chinese
     图片
     
     *  \~english
     Image
     */
    MediaType_IMAGE = 1,

    /*!
     *  \~chinese
     语音
     
     *  \~english
     Voice
     */
    MediaType_AUDIO = 2,

    /*!
     *  \~chinese
     视频
     
     *  \~english
     Video
     */
    MediaType_VIDEO = 3,

    /*!
     *  \~chinese
     其他文件
     
     *  \~english
     Other documents
     */
    MediaType_FILE = 4,

    /*!
     *  \~chinese
     小视频
     
     *  \~english
     Small video
     */
    MediaType_SIGHT = 5,

    /*!
     *  \~chinese
     合并转发
     
     *  \~english
     Merge and forward
     */
    MediaType_HTML = 6
};

#pragma mark RCMentionedType
/*!
 *  \~chinese
 @提醒的类型
 
 *  \~english
 @ Type of reminder
 */
typedef NS_ENUM(NSUInteger, RCMentionedType) {
    /*!
     *  \~chinese
     @ 所有人
     
     *  \~english
     @ Everyone
     */
    RC_Mentioned_All = 1,

    /*!
     *  \~chinese
     @ 部分指定用户
     
     *  \~english
     @ Part of the specified user
     */
    RC_Mentioned_Users = 2,
};

/**
 *  \~chinese
 语音消息采样率

 - RCSample_Rate_8000: 8KHz
 - RCSample_Rate_16000: 16KHz
 
 *  \~english
 Voice message sampling rate.

 -RCSample_Rate_8000: 8KHz.
 -RCSample_Rate_16000: 16KHz
 */
typedef NS_ENUM(NSInteger, RCSampleRate) {
    RCSample_Rate_8000 = 1,  // 8KHz
    RCSample_Rate_16000 = 2, // 16KHz
};

/**
 *  \~chinese
 语音消息类型

 - RCVoiceMessageTypeOrdinary: 普通音质语音消息
 - RCVoiceMessageTypeHighQuality: 高音质语音消息
 
 *  \~english
 Voice message type.

 -RCVoiceMessageTypeOrdinary: Normal sound quality voice message.
 -RCVoiceMessageTypeHighQuality: High quality voice message.
 */
typedef NS_ENUM(NSInteger, RCVoiceMessageType) {
    RCVoiceMessageTypeOrdinary = 1,
    RCVoiceMessageTypeHighQuality = 2,
};

#pragma mark - PublicService

#pragma mark RCPublicServiceType
/*!
 *  \~chinese
 公众服务账号类型
 
 *  \~english
 Type of public service account
 */
typedef NS_ENUM(NSUInteger, RCPublicServiceType) {
    /*!
     *  \~chinese
     应用内公众服务账号
     
     *  \~english
     Public service account in the application
     */
    RC_APP_PUBLIC_SERVICE = 7,

    /*!
     *  \~chinese
     跨应用公众服务账号
     
     *  \~english
     Cross-application public service account
     */
    RC_PUBLIC_SERVICE = 8,
};

#pragma mark RCPublicServiceMenuItemType
/*!
 *  \~chinese
 公众服务菜单类型
 
 *  \~english
 Public service menu type
 */
typedef NS_ENUM(NSUInteger, RCPublicServiceMenuItemType) {
    /*!
     *  \~chinese
     包含子菜单的一组菜单
     
     *  \~english
     A set of menus containing submenus
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_GROUP = 0,

    /*!
     *  \~chinese
     包含查看事件的菜单
     
     *  \~english
     Menu containing view events
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_VIEW = 1,

    /*!
     *  \~chinese
     包含点击事件的菜单
     
     *  \~english
     Menu containing click events
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_CLICK = 2,
};

#pragma mark RCSearchType
/*!
 *  \~chinese
 公众服务查找匹配方式
 
 *  \~english
 Public service search matching mode
 */
typedef NS_ENUM(NSUInteger, RCSearchType) {
    /*!
     *  \~chinese
     精确匹配
     
     *  \~english
     Exact matching
     */
    RC_SEARCH_TYPE_EXACT = 0,

    /*!
     *  \~chinese
     模糊匹配
     
     *  \~english
     Fuzzy matching
     */
    RC_SEARCH_TYPE_FUZZY = 1,
    /*!
     *  \~chinese
     无效类型
     
     *  \~english
     Invalid type
     */
    RCSearchType_INVALID
};

/*!
 *  \~chinese
 客服服务方式
 
 *  \~english
 Customer service mode
 */
typedef NS_ENUM(NSUInteger, RCCSModeType) {
    /*!
     *  \~chinese
     无客服服务
     
     *  \~english
     No customer service
     */
    RC_CS_NoService = 0,

    /*!
     *  \~chinese
     机器人服务
     
     *  \~english
     Robot service
     */
    RC_CS_RobotOnly = 1,

    /*!
     *  \~chinese
     人工服务
     
     *  \~english
     Manual service
     */
    RC_CS_HumanOnly = 2,

    /*!
     *  \~chinese
     机器人优先服务
     
     *  \~english
     Robot priority service
     */
    RC_CS_RobotFirst = 3,
};

/*!
 *  \~chinese
 客服评价时机
 
 *  \~english
 Timing of customer service evaluation
 */
typedef NS_ENUM(NSUInteger, RCCSEvaEntryPoint) {
    /*!
     *  \~chinese
     离开客服评价
     
     *  \~english
     Leave customer service evaluation
     */
    RCCSEvaLeave = 0,

    /*!
     *  \~chinese
     在扩展中展示客户主动评价按钮，离开客服不评价
     
     *  \~english
     Show the customer active evaluation button in the expansion and leave the customer service without evaluation
     */
    RCCSEvaExtention = 1,

    /*!
     *  \~chinese
     无评价入口
     
     *  \~english
     No evaluation entrance
     */
    RCCSEvaNone = 2,

    /*!
     *  \~chinese
     坐席结束会话评价
     
     *  \~english
     Evaluation of the end of the conversation at the end of the seat
     */
    RCCSEvaCSEnd = 3,
};

/*!
 *  \~chinese
 客服留言类型
 
 *  \~english
 Customer service message type
 */
typedef NS_ENUM(NSUInteger, RCCSLMType) {
    /*!
     *  \~chinese
     本地 Native 页面留言
     
     *  \~english
     Local Native page message
     */
    RCCSLMNative = 0,

    /*!
     *  \~chinese
     web 页面留言
     
     *  \~english
     Web page message
     */
    RCCSLMWeb = 1,
};

/*!
 *  \~chinese
 客服问题解决状态
 
 *  \~english
 Resolution status of customer service problem
 */
typedef NS_ENUM(NSUInteger, RCCSResolveStatus) {
    /*!
     *  \~chinese
     未解决
     
     *  \~english
     Unresolved
     */
    RCCSUnresolved = 0,

    /*!
     *  \~chinese
     已解决
     
     *  \~english
     Resolved
     */
    RCCSResolved = 1,

    /*!
     *  \~chinese
     解决中
     
     *  \~english
     Solving
     */
    RCCSResolving = 2,
};

/*!
 *  \~chinese
 客服评价类型
 
 *  \~english
 Type of customer service evaluation
 */
typedef NS_ENUM(NSUInteger, RCCSEvaType) {
    /*!
     *  \~chinese
     人工机器人分开评价
     
     *  \~english
     Separate evaluation of manual and robot
     */
    RCCSEvaSeparately = 0,

    /*!
     *  \~chinese
     人工机器人统一评价
     
     *  \~english
     Unified evaluation of manual and robot
     */
    EVA_UNIFIED = 1,
};

#pragma mark RCLogLevel
/*!
 *  \~chinese
 日志级别
 
 *  \~english
 Log level
 */
typedef NS_ENUM(NSUInteger, RCLogLevel) {

    /*!
     *  \~chinese
     *  不输出任何日志
     
     *  \~english
     * Do not output any logs
     */
    RC_Log_Level_None = 0,

    /*!
     *  \~chinese
     *  只输出错误的日志
     
     *  \~english
     * Output only error logs
     */
    RC_Log_Level_Error = 1,

    /*!
     *  \~chinese
     *  输出错误和警告的日志
     
     *  \~english
     * Output logs of errors and warnings
     */
    RC_Log_Level_Warn = 2,

    /*!
     *  \~chinese
     *  输出错误、警告和一般的日志
     
     *  \~english
     * Output errors, warnings, and general logs
     */
    RC_Log_Level_Info = 3,

    /*!
     *  \~chinese
     *  输出输出错误、警告和一般的日志以及 debug 日志
     
     *  \~english
     * Output errors, warnings and general logs as well as debug logs
     */
    RC_Log_Level_Debug = 4,

    /*!
     *  \~chinese
     *  输出所有日志
     
     *  \~english
     * Output all logs
     */
    RC_Log_Level_Verbose = 5,
};

#pragma mark RCTimestampOrder
/*!
 *  \~chinese
 时间戳顺序
 
 *  \~english
 Timestamp Order
 */
typedef NS_ENUM(NSUInteger, RCTimestampOrder) {
    /*!
     *  \~chinese
     *  降序, 按照时间戳从大到小
     
     *  \~english
     * Descending order, from large to small according to timestamp
     */
    RC_Timestamp_Desc = 0,

    /*!
     *  \~chinese
     *  升序, 按照时间戳从小到大
     
     *  \~english
     * In ascending order, from small to large according to the timestamp
     */
    RC_Timestamp_Asc = 1,
};

#pragma mark RCPlatform
/*!
 *  \~chinese
 在线平台
 
 *  \~english
 Online platform
 */
typedef NS_ENUM(NSUInteger, RCPlatform) {
    /*!
     *  \~chinese
     其它平台
     
     *  \~english
     Other platforms
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

#pragma mark RCPushLauguageType
/*!
 *  \~chinese
 push 语言设置
 
 *  \~english
 Push language Settings
 */
typedef NS_ENUM(NSUInteger, RCPushLauguage) {
    /*!
     *  \~chinese
     英文
     
     *  \~english
     English
     */
    RCPushLauguage_EN_US = 1,
    /*!
     *  \~chinese
     中文
     
     *  \~english
     Chinese
     */
    RCPushLauguage_ZH_CN = 2,
    /*!
     *  \~chinese
     阿拉伯文
     
     *  \~english
     Arabic
     */
    RCPushLauguage_AR_SA
};

#endif
