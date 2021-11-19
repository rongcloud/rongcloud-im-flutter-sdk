//
//  RCUserTypingStatus.h
//  RongIMLib
//
//  Created by RongCloud on 16/1/8.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 用户输入状态类
 
 *  \~english
 User input status class.
 */
@interface RCUserTypingStatus : NSObject

/*!
 *  \~chinese
 当前正在输入的用户 ID
 
 *  \~english
 The user ID that is currently being entered. 
 */
@property (nonatomic, copy) NSString *userId;

/*!
 *  \~chinese
 当前正在输入的消息类型名

 @discussion
 contentType 为用户当前正在编辑的消息类型名，即 RCMessageContent 中 getObjectName 的返回值。
 如文本消息，应该传类型名"RC:TxtMsg"。
 
 *  \~english
 The name of the message type currently being entered.

 @ discussion
 ContentType is the name of the message type that the user is currently editing, that is, the return value of getObjectName in RCMessageContent.
  E.g. for a text message, pass the type name "RC:TxtMsg".
 */
@property (nonatomic, copy) NSString *contentType;

/*!
 *  \~chinese
 初始化用户输入状态对象

 @param userId     当前正在输入的用户ID
 @param objectName 当前正在输入的消息类型名

 @return 用户输入状态对象
 
 *  \~english
 Initialize user input status object.

 @param userId The user ID that is currently being entered.
 @param objectName The name of the message type currently being entered.

 @ return user input status object.
 */
- (instancetype)initWithUserId:(NSString *)userId contentType:(NSString *)objectName;

@end
