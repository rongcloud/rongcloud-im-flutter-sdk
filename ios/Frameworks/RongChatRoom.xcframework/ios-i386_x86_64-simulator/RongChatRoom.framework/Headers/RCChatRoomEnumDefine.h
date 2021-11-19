//
//  RCChatRoomEnumDefine.h
//  RongChatRoom
//
//  Created by RongCloud on 2020/8/12.
//  Copyright © 2020 RongCloud. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef RCChatRoomEnumDefine_h
#define RCChatRoomEnumDefine_h

#pragma mark RCChatRoomStatus
/*!
 * \~chinese
 聊天室状态码
 *
 * \~english
 * Chatroom status code
 */
typedef NS_ENUM(NSInteger, RCChatRoomStatus) {
    /*!
     * \~chinese
     正在加入聊天室中
     * \~english
     Joining the chatroom
     */
    RCChatRoomStatus_Joining = 1,

    /*!
     * \~chinese
     加入聊天室成功
     * \~english
     Join the chatroom successfully
     */
    RCChatRoomStatus_Joined = 2,
    /*!
     * \~chinese
     加入聊天室失败
     * \~english
     Failed to join chatroom
     */
    RCChatRoomStatus_JoinFailed = 3,

    /*!
     * \~chinese
     退出了聊天室
     * \~english
     Quit the chatroom
     */
    RCChatRoomStatus_Quited = 4,
    
    /*!
     * \~chinese
     聊天室被销毁
     * \~english
     The chatroom is destroyed
     */
    RCChatRoomStatus_Destroyed = 5,
    /*!
     * \~chinese
     聊天室被重置
     由于聊天室长时间不活跃，已经被系统回收。聊天室 KV 已经被清空，请开发者刷新界面。
     * \~english
     The chatroom is reset.
     As the chatroom has been inactive for a long time, it has been recycled by the system. The chatroom KV has been emptied, please refresh the interface.
     */
    RCChatRoomStatus_Reset = 6,
    
};

#pragma mark RCChatRoomMemberOrder
/*!
 * \~chinese
 聊天室成员的排列顺序
 * \~english
 The order of chatroom members
 */
typedef NS_ENUM(NSUInteger, RCChatRoomMemberOrder) {
    /*!
     * \~chinese
     升序，返回最早加入的成员列表
     * \~english
     Ascending order, return the list of the earliest members
     */
    RC_ChatRoom_Member_Asc = 1,

    /*!
     * \~chinese
     降序，返回最晚加入的成员列表
     * \~english
     Descending order, return the list of the latest members
     */
    RC_ChatRoom_Member_Desc = 2,
};
#endif /* RCChatRoomEnumDefine_h */
