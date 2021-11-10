//
//  RCChatRoomMemberInfo.h
//  RongIMLib
//
//  Created by 岑裕 on 16/1/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 聊天室成员信息类
 */
@interface RCChatRoomMemberInfo : NSObject

/*!
 用户 ID
 */
@property (nonatomic, copy) NSString *userId;

/*!
 用户加入聊天室时间（Unix 时间戳，毫秒）
 */
@property (nonatomic, assign) long long joinTime;

@end
