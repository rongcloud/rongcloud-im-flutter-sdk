//
//  RCChatRoomProtocol.h
//  RongChatRoom
//
//  Created by RongCloud on 2020/8/12.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#ifndef RCChatRoomProtocol_h
#define RCChatRoomProtocol_h

typedef NS_ENUM(NSUInteger, RCChatRoomDestroyType) {
    /*!
     * \~chinese
     开发者主动销毁
     * \~english
     Developers take the initiative to destroy
     */
    RCChatRoomDestroyTypeManual = 0,

    /*!
     * \~chinese
     聊天室长时间不活跃，被系统自动回收
     * \~english
     The chatroom is inactive for a long time and is automatically recycled by the system.
     */
    RCChatRoomDestroyTypeAuto = 3
};

#pragma mark - RCChatRoomStatusDelegate

/*!
 * \~chinese
 聊天室状态的的监听器

 @discussion
 设置IMLib的聊天室状态监听器，请参考 RCChatRoomClient 的 setChatRoomStatusDelegate: 方法。
 
 * \~english
 Listeners for the status of chatrooms.

 @ discussion
 To set the chatroom status listener of chatroom, please refer to the setChatRoomStatusDelegate: method of RCChatRoomClient.
 */
@protocol RCChatRoomStatusDelegate <NSObject>

/*!
 * \~chinese
 开始加入聊天室的回调

 @param chatroomId 聊天室ID
 
 * \~english
 Callback for joining the chatroom.

@param chatroomId Chatroom ID.
 */
- (void)onChatRoomJoining:(NSString *)chatroomId;

/*!
 * \~chinese
 加入聊天室成功的回调

 @param chatroomId 聊天室ID
 
 * \~english
 Callback for successful joining of the chatroom

 @param chatroomId Chatroom ID.
 */
- (void)onChatRoomJoined:(NSString *)chatroomId;

/*!
 * \~chinese
 加入聊天室失败的回调

 @param chatroomId 聊天室ID
 @param errorCode  加入失败的错误码

 @discussion
 如果错误码是 KICKED_FROM_CHATROOM 或 RC_CHATROOM_NOT_EXIST ，则不会自动重新加入聊天室，App需要按照自己的逻辑处理。
 
 * \~english
 Callback for failed to join chatroom.

 @param chatroomId Chatroom ID.
 @param errorCode Add a failed error code.

 @ discussion
 If the error code is KICKED_FROM_CHATROOM or RC_CHATROOM_NOT_EXIST, it will not automatically rejoin the chatroom, App shall follow its own logic.
 */
- (void)onChatRoomJoinFailed:(NSString *)chatroomId errorCode:(RCErrorCode)errorCode;

/*!
 * \~chinese
 加入聊天室成功，但是聊天室被重置。接收到此回调后，还会收到 onChatRoomJoined：回调。

 @param chatroomId 聊天室ID
 
 * \~english
 The chatroom is jointed successfully, but the chatroom is reset. After receiving this callback, you will also receive an onChatRoomJoined: callback.
  

  @param chatroomId Chatroom ID.
 */
- (void)onChatRoomReset:(NSString *)chatroomId;

/*!
 * \~chinese
 退出聊天室成功的回调

 @param chatroomId 聊天室ID
 
 * \~english
 Callback for successful exit from the chatroom
 @param chatroomId Chatroom ID.
 */
- (void)onChatRoomQuited:(NSString *)chatroomId;

/*!
 * \~chinese
 聊天室被销毁的回调，用户在线的时候房间被销毁才会收到此回调。

 @param chatroomId 聊天室ID
 @param type 聊天室销毁原因

 * \~english
 The callback in which the chatroom is destructed. The callback will only be received when the room is destructed when the user is online.

  @param chatroomId Chatroom ID.
 @param type Reasons for the destruction of chatrooms.
 */
- (void)onChatRoomDestroyed:(NSString *)chatroomId type:(RCChatRoomDestroyType)type;

@end


#pragma mark - RCChatRoomKVStatusChangeDelegate

/**
 * \~chinese
 ChatRoom 聊天室 KV 状态变化监听器
 @discussion 设置代理请参考 RCIMClient 的 setRCChatRoomKVStatusChangeDelegate: 方法。

 * \~english
 ChatRoom ChatRoom KV Status ChangeDelegate
 @discussion  Please refer to the  setRCChatRoomKVStatusChangeDelegate: method of RCChatRoomClient。
 */
@protocol RCChatRoomKVStatusChangeDelegate <NSObject>


/**
 * \~chinese
 ChatRoom 刚加入聊天室时 KV 同步完成的回调
 
 @param roomId 聊天室 Id
 
 * \~english
 Callback of ChatRoom kv did sync
 @param roomId ChatRoom Id
 */
- (void)chatRoomKVDidSync:(NSString *)roomId;

/**
 * \~chinese
 ChatRoom 聊天室 KV 变化的回调
 
 @param roomId 聊天室 Id
 @param entry KV 字典，如果刚进入聊天室时存在  KV，会通过此回调将所有 KV 返回，再次回调时为其他人设置或者修改 KV
 
 * \~english
 Callback of Chatroom kv update
 @param roomId ChatRoom Id
 @param entry KV map，If there are KVs when you first enter the chat room, all KVs will be returned through this callback. When you call back again, you can set or modify the KVs for others
 */
- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *, NSString *> *)entry;

/**
 * \~chinese
 ChatRoom 聊天室 KV 被删除的回调
 
 @param roomId 聊天室 Id
 @param entry KV 字典
 
 * \~english
 Callback when chat room KV is deleted
 @param roomId Chatroom Id
 @param entry KV dictionary
 */
- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *, NSString *> *)entry;

@end

#endif /* RCChatRoomProtocol_h */
