//
//  RCChatRoomProtocol.h
//  RongChatRoom
//
//  Created by 张改红 on 2020/8/12.
//  Copyright © 2020 张改红. All rights reserved.
//

#ifndef RCChatRoomProtocol_h
#define RCChatRoomProtocol_h

@class RCChatRoomMemberAction;

typedef NS_ENUM(NSUInteger, RCChatRoomDestroyType) {
    /*!
     开发者主动销毁
     */
    RCChatRoomDestroyTypeManual = 0,

    /*!
     聊天室长时间不活跃，被系统自动回收
     */
    RCChatRoomDestroyTypeAuto = 3
};

#pragma mark - 聊天室监听器

/*!
 IMLib聊天室状态的的监听器

 @discussion
 设置IMLib的聊天室状态监听器，请参考RCIMClient的setChatRoomStatusDelegate:方法。
 */
@protocol RCChatRoomStatusDelegate <NSObject>

/*!
 开始加入聊天室的回调

 @param chatroomId 聊天室ID
 */
- (void)onChatRoomJoining:(NSString *)chatroomId;

/*!
 加入聊天室成功的回调

 @param chatroomId 聊天室ID
 */
- (void)onChatRoomJoined:(NSString *)chatroomId;

/*!
 加入聊天室失败的回调

 @param chatroomId 聊天室ID
 @param errorCode  加入失败的错误码

 @discussion
 如果错误码是KICKED_FROM_CHATROOM或RC_CHATROOM_NOT_EXIST，则不会自动重新加入聊天室，App需要按照自己的逻辑处理。
 */
- (void)onChatRoomJoinFailed:(NSString *)chatroomId errorCode:(RCErrorCode)errorCode;

/*!
 加入聊天室成功，但是聊天室被重置。接收到此回调后，还会收到 onChatRoomJoined：回调。

 @param chatroomId 聊天室ID
 */
- (void)onChatRoomReset:(NSString *)chatroomId;

/*!
 退出聊天室成功的回调

 @param chatroomId 聊天室ID
 */
- (void)onChatRoomQuited:(NSString *)chatroomId;

/*!
 聊天室被销毁的回调，用户在线的时候房间被销毁才会收到此回调。

 @param chatroomId 聊天室ID
 @param type 聊天室销毁原因

 */
- (void)onChatRoomDestroyed:(NSString *)chatroomId type:(RCChatRoomDestroyType)type;

@end


#pragma mark - 聊天室 KV 状态变化

/**
 IMLib 聊天室 KV 状态变化监听器
 @discussion 设置代理请参考 RCIMClient 的 setRCChatRoomKVStatusChangeDelegate: 方法。
 */
@protocol RCChatRoomKVStatusChangeDelegate <NSObject>


/**
 IMLib 刚加入聊天室时 KV 同步完成的回调
 
 @param roomId 聊天室 Id
 */
- (void)chatRoomKVDidSync:(NSString *)roomId;

/**
 IMLib 聊天室 KV 变化的回调
 
 @param roomId 聊天室 Id
 @param entry KV 字典，如果刚进入聊天室时存在  KV，会通过此回调将所有 KV 返回，再次回调时为其他人设置或者修改 KV
 */
- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *, NSString *> *)entry;

/**
 IMLib 聊天室 KV 被删除的回调
 
 @param roomId 聊天室 Id
 @param entry KV 字典
 */
- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *, NSString *> *)entry;

@end


#pragma mark - 聊天室成员变化监听器
@protocol RCChatRoomMemberDelegate <NSObject>
/**
 有聊天室成员加入或退出的回调
 
 @param members 相关信息
 @param roomId 聊天室 Id
 */
- (void)memberDidChange:(NSArray <RCChatRoomMemberAction *> *)members inRoom:(NSString *)roomId;

@end

#endif /* RCChatRoomProtocol_h */
