//
//  RCRecallNotificationMessage.h
//  RongIMLib
//
//  Created by litao on 16/7/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>

/*!
 撤回通知消息的类型名
 */
#define RCRecallNotificationMessageIdentifier @"RC:RcNtf"

/*!
 撤回通知消息类
 @discussion 撤回通知消息，此消息会进行本地存储，但不计入未读消息数。
 
 @remarks 通知类消息
 */
@interface RCRecallNotificationMessage : RCMessageContent <NSCoding>

/*!
 发起撤回操作的用户 ID
 */
@property (nonatomic, copy) NSString *operatorId;

/*!
 撤回的时间（毫秒）
 */
@property (nonatomic, assign) long long recallTime;

/*!
 原消息的消息类型名
 */
@property (nonatomic, copy) NSString *originalObjectName;

/*!
 是否是管理员操作
 */
@property (nonatomic, assign) BOOL isAdmin;

/*!
 是否删除
 */
@property (nonatomic, assign) BOOL isDelete;

/*!
 撤回的文本消息的内容
*/
@property (nonatomic, copy) NSString *recallContent;

/*!
 撤回动作的时间（毫秒）
*/
@property (nonatomic, assign) long long recallActionTime;

/*!
 被撤回的原消息
*/
@property (nonatomic, strong) RCMessageContent *originalMessageContent;

@end
