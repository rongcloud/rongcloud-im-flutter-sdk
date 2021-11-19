//
//  RCChatRoomInfo.h
//  RongIMLib
//
//  Created by RongCloud on 16/1/11.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCChatRoomMemberInfo.h"
#import "RCChatRoomEnumDefine.h"
/*!
 * \~chinese
 聊天室信息类
 * \~english
 Chatroom information class
 */
@interface RCChatRoomInfo : NSObject

/*!
 * \~chinese
 聊天室 ID
 * \~english
 Chatroom ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 * \~chinese
 包含的成员信息类型
 * \~english
 Type of member information included
 */
@property (nonatomic, assign) RCChatRoomMemberOrder memberOrder;

/*!
 * \~chinese
 聊天室中的部分成员信息 RCChatRoomMemberInfo 列表

 @discussion
 如果成员类型为 RC_ChatRoom_Member_Asc，则为最早加入的成员列表，按成员加入时间升序排列；
 如果成员类型为 RC_ChatRoom_Member_Desc，则为最晚加入的成员列表，按成员加入时间降序排列。
 
 * \~english
 RCChatRoomMemberInfo list of some member information in the chatroom.

 @ discussion
 If the member type is RC_ChatRoom_Member_Asc, it is the list of the earliest members, sorted in ascending order by the time they are added.
 If the member type is RC_ChatRoom_Member_Desc, it is the list of the latest members, sorted in descending order by the time they are added.
 */
@property (nonatomic, strong) NSArray <RCChatRoomMemberInfo *> *memberInfoArray;

/*!
 * \~chinese
 当前聊天室的成员总数
 * \~english
 Total number of members of the current chatroom.
 */
@property (nonatomic, assign) int totalMemberCount;

@end
