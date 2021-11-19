//
//  RCChatRoomMemberInfo.h
//  RongIMLib
//
//  Created by RongCloud on 16/1/10.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * \~chinese
 聊天室成员信息类
 * \~english
 Chatroom member information class
 */
@interface RCChatRoomMemberInfo : NSObject

/*!
 * \~chinese
 用户 ID
 * \~english
 User ID
 */
@property (nonatomic, copy) NSString *userId;

/*!
 * \~chinese
 用户加入聊天室时间（Unix 时间戳，毫秒）
 * \~english
 Time when the user joins the chatroom (Unix timestamp, milliseconds)
 */
@property (nonatomic, assign) long long joinTime;

@end
