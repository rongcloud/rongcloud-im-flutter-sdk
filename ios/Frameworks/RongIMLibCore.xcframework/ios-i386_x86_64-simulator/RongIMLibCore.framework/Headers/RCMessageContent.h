/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCMessageContent.h
//  Created by Heq.Shinoda on 14-6-13.

#ifndef __RCMessageContent
#define __RCMessageContent

#import "RCMentionedInfo.h"
#import "RCStatusDefine.h"
#import "RCUserInfo.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 消息内容的编解码协议

 @discussion 用于标示消息内容的类型，进行消息的编码和解码。
 所有自定义消息必须实现此协议，否则将无法正常传输和使用。
 
 *  \~english
 Codec protocol for message content.

 @ discussion It is used to identify the type of message content and to encode and decode the message.
  All custom messages must implement this protocol, otherwise they will not be transmitted and used properly.
 */
@protocol RCMessageCoding <NSObject>
@required

/*!
 *  \~chinese
 将消息内容序列化，编码成为可传输的json数据

 @discussion
 消息内容通过此方法，将消息中的所有数据，编码成为json数据，返回的json数据将用于网络传输。
 
 *  \~english
 Serialize the message content and encode it into transportable json data.

 @ discussion
 Through this method, the message content encodes all the data in the message into json data, and the returned json data will be used for network transmission.
 */
- (NSData *)encode;

/*!
 *  \~chinese
 将json数据的内容反序列化，解码生成可用的消息内容

 @param data    消息中的原始json数据

 @discussion
 网络传输的json数据，会通过此方法解码，获取消息内容中的所有数据，生成有效的消息内容。
 
 *  \~english
 Deserialize the contents of json data and decode them to generate available message content.

 @param data Raw json data in the message.

 @ discussion
 The json data transmitted over the network will be decoded by this method, all the data in the message content will be obtained, and the valid message content will be generated.
 */
- (void)decodeWithData:(NSData *)data;

/*!
 *  \~chinese
 返回消息的类型名

 @return 消息的类型名

 @discussion 您定义的消息类型名，需要在各个平台上保持一致，以保证消息互通。

 @warning 请勿使用@"RC:"开头的类型名，以免和SDK默认的消息名称冲突
 
 *  \~english
 Return the type name of the message.

 @ return Type name of message.

 @ discussion The name of the message type you defined shall be consistent across platforms to ensure message interoperability.

  @ warning Do not use a type name that begins with @ "RC:", so as not to conflict with the default message name of SDK.
 */
+ (NSString *)getObjectName;

/*!
 *  \~chinese
 返回可搜索的关键内容列表

 @return 返回可搜索的关键内容列表

 @discussion 这里返回的关键内容列表将用于消息搜索，自定义消息必须要实现此接口才能进行搜索。
 
 *  \~english
 Return a list of searchable key content.

 @ return Return a list of key content that can be searched.

 @ discussion The list of key content returned here will be used for message search, and custom messages must implement this interface before searching.
 */
- (NSArray<NSString *> *)getSearchableWords;
@end

/*!
 *  \~chinese
 消息内容的存储协议

 @discussion 用于确定消息内容的存储策略。
 所有自定义消息必须实现此协议，否则将无法正常存储和使用。
 
 *  \~english
 Storage protocol for message content.

 @ discussion It  is used to determine the storage policy for the content of the message.
  All custom messages must implement this protocol, otherwise they will not be stored and used properly.
 */
@protocol RCMessagePersistentCompatible <NSObject>
@required

/*!
 *  \~chinese
 返回消息的存储策略

 @return 消息的存储策略

 @discussion 指明此消息类型在本地是否存储、是否计入未读消息数。
 
 *  \~english
 Return the storage policy of the message.

 @ return Storage policy for messages.

 @ discussion It indicates whether this message type is stored locally and counted as unread messages.
 */
+ (RCMessagePersistent)persistentFlag;
@end

/*!
 *  \~chinese
 消息内容摘要的协议

 @discussion 用于在会话列表和本地通知中显示消息的摘要。
 
 *  \~english
 Protocol for message content digest.

 @ discussion It is used to display a digest of messages in the conversation list and in local notifications.
 */
@protocol RCMessageContentView
@optional

/*!
 *  \~chinese
 返回在会话列表和本地通知中显示的消息内容摘要

 @return 会话列表和本地通知中显示的消息内容摘要

 @discussion
 如果您使用IMKit，当会话的最后一条消息为自定义消息时，需要通过此方法获取在会话列表展现的内容摘要；
 当App在后台收到消息时，需要通过此方法获取在本地通知中展现的内容摘要。
 
 *  \~english
 Return a digest of the message contents displayed in the conversation list and local notifications.

 @ return conversation list and digest of messages displayed in local notifications.

 @ discussion
 If you use IMKit, when the last message of the conversation is a custom message, you shall use this method to get the digest of the content displayed in the conversation list.
 When App receives a message in the background, it uses this method to obtain a digest of the content presented in the local notification.
 */
- (NSString *)conversationDigest;

@end

/*!
 *  \~chinese
 消息内容的基类

 @discussion 此类为消息实体类 RCMessage 中的消息内容 content 的基类。
 所有的消息内容均为此类的子类，包括 SDK 自带的消息（如 RCTextMessage、RCImageMessage 等）和用户自定义的消息。
 所有的自定义消息必须继承此类，并实现 RCMessageCoding 和 RCMessagePersistentCompatible、RCMessageContentView 协议。
 
 *  \~english
 The base class of the message content.

 @ discussion This class is the base class for the message content in the message entity class RCMessage.
  All message contents are subclasses of this class, including messages that come with SDK (such as RCTextMessage, RCImageMessage, etc.) and user-defined messages.
  All custom messages must inherit this class and implement the RCMessageCoding and RCMessagePersistentCompatible, RCMessageContentView protocols.
 */
@interface RCMessageContent : NSObject <RCMessageCoding, RCMessagePersistentCompatible, RCMessageContentView>

/*!
 *  \~chinese
 消息内容中携带的发送者的用户信息

 @discussion
 如果您使用IMKit，可以通过RCIM的enableMessageAttachUserInfo属性设置在每次发送消息中携带发送者的用户信息。
 
 *  \~english
 User information of the sender carried in the message content.

 @ discussion
 If you use IMKit, you can set the enableMessageAttachUserInfo property of RCIM to carry the sender's user information in each message sent.
 */
@property (nonatomic, strong) RCUserInfo *senderUserInfo;

/*!
 *  \~chinese
 消息中的 @ 提醒信息
 
 *  \~english
 @ reminder message in message.
 */
@property (nonatomic, strong) RCMentionedInfo *mentionedInfo;

/**
 *  \~chinese
 设置焚烧时间

 @discussion 默认是 0，0 代表该消息非阅后即焚消息。
 
 *  \~english
 Set burning time.

 @ discussion The default value is 0, which means that the message will be burned immediately after it is read.
 */
@property (nonatomic, assign) NSUInteger destructDuration;

/*!
 *  \~chinese
 消息的附加信息
 
 *  \~english
 Additional information for messages.
 */
@property (nonatomic, copy) NSString *extra;

/**
 *  \~chinese
 将用户信息编码到字典中

 @param userInfo 要编码的用户信息
 @return 存有用户信息的 Dictionary
 
 *  \~english
 Encode user information into a dictionary.

 @param userInfo User information to be encoded.
 @ return Dictionary with user information.
 */
- (NSDictionary *)encodeUserInfo:(RCUserInfo *)userInfo;

/*!
 *  \~chinese
 将消息内容中携带的用户信息解码

 @param dictionary 用户信息的Dictionary
 
 *  \~english
 Decode the user information carried in the message content.

 @param dictionary Dictionary of user information.
 */
- (void)decodeUserInfo:(NSDictionary *)dictionary;

/**
 *  \~chinese
 将@提醒信息编码到字典中

 @param mentionedInfo 要编码的@信息
 @return 存有@信息的 Dictionary
 
 *  \~english
 Encode @ reminder information into the dictionary.

 @param mentionedInfo @ information to be encoded.
 @ return Dictionary with @ information.
 */
- (NSDictionary *)encodeMentionedInfo:(RCMentionedInfo *)mentionedInfo;

/*!
 *  \~chinese
 将消息内容中携带的@提醒信息解码

 @param dictionary @提醒信息的Dictionary
 
 *  \~english
 Decode the @ reminder information carried in the message content.

 @param dictionary @ Dictionary of reminder messages.
 */
- (void)decodeMentionedInfo:(NSDictionary *)dictionary;

/*!
 *  \~chinese
 消息内容的原始json数据

 @discussion 此字段存放消息内容中未编码的json数据。
 SDK内置的消息，如果消息解码失败，默认会将消息的内容存放到此字段；如果编码和解码正常，此字段会置为nil。
 
 *  \~english
 The original json data of the message content.

 @ discussion This field stores unencoded json data in the message content.
  The message built into SDK. If the message decoding fails, the default will store the contents of the message in this field; if the encoding and decoding are normal, this field will be set to nil.
 */
@property (nonatomic, strong, setter=setRawJSONData:) NSData *rawJSONData;

@end
#endif
