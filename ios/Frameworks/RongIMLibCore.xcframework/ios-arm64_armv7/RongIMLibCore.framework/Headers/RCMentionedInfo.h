//
//  RCMentionedInfo.h
//  RongIMLib
//
//  Created by RongCloud on 16/7/6.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 消息中的 @ 提醒信息对象
 
 *  \~english
 @ reminder information object in message
 */
@interface RCMentionedInfo : NSObject

/*!
 *  \~chinese
 @ 提醒的类型
 
 *  \~english
 @ Type of reminder
 */
@property (nonatomic, assign) RCMentionedType type;

/*!
 *  \~chinese
 @ 的用户 ID 列表

 @discussion 如果 type 是 @ 所有人，则可以传 nil
 
 *  \~english
 @ user ID list.

 @ discussion If type is @ all, you can pass nil.
 */
@property (nonatomic, strong) NSArray<NSString *> *userIdList;

/*!
 *  \~chinese
 包含 @ 提醒的消息，本地通知和远程推送显示的内容
 
 *  \~english
 Message containing @ reminder, local notifications, and content displayed by remote push.
 */
@property (nonatomic, copy) NSString *mentionedContent;

/*!
 *  \~chinese
 是否 @ 了我
 
 *  \~english
 Do you @ me?
 */
@property (nonatomic, readonly) BOOL isMentionedMe;

/*!
 *  \~chinese
 初始化 @ 提醒信息

 @param type       @ 提醒的类型
 @param userIdList @ 的用户 ID 列表
 @param mentionedContent @ Push 内容

 @return @ 提醒信息的对象
 
 *  \~english
 Initialize @ reminder message.

 @param type @ Type of reminder
 @param userIdList @ user ID list
 @param mentionedContent @ Push content

 @ return @ the object of the reminder message
 */
- (instancetype)initWithMentionedType:(RCMentionedType)type
                           userIdList:(NSArray *)userIdList
                     mentionedContent:(NSString *)mentionedContent;

@end
