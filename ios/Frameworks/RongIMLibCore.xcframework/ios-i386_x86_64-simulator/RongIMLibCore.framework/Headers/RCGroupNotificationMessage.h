/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCGroupNotificationMessage.h
//  Created by xugang on 14/11/24.

#import "RCMessageContent.h"

/*!
 *  \~chinese
 群组通知消息的类型名
 
 *  \~english
 Type name of the group notification message
 */
#define RCGroupNotificationMessageIdentifier @"RC:GrpNtf"

/*!
 *  \~chinese
 有成员加入群组的通知
 
 *  \~english
 Notice of members joining the group
 */
#define GroupNotificationMessage_GroupOperationAdd @"Add"
/*!
 *  \~chinese
 有成员退出群组的通知
 
 *  \~english
 Notice of exit of a member from the group
 */
#define GroupNotificationMessage_GroupOperationQuit @"Quit"
/*!
 *  \~chinese
 有成员被踢出群组的通知
 
 *  \~english
 Notice that a member has been kicked out of the group
 */
#define GroupNotificationMessage_GroupOperationKicked @"Kicked"
/*!
 *  \~chinese
 群组名称发生变更的通知
 
 *  \~english
 Notification of a change in the group name
 */
#define GroupNotificationMessage_GroupOperationRename @"Rename"
/*!
 *  \~chinese
 群组公告发生变更的通知
 
 *  \~english
 Notice of a change in the group announcement
 */
#define GroupNotificationMessage_GroupOperationBulletin @"Bulletin"

/*!
 *  \~chinese
 群组通知消息类

 @discussion 群组通知消息类，此消息会进行存储，但不计入未读消息数。
 
 @remarks 通知类消息
 
 *  \~english
 Group notification message class.

 @ discussion group notification message class, which is stored but will not be counted as unread messages.
  
  @ remarks notification message
 */
@interface RCGroupNotificationMessage : RCMessageContent <NSCoding>

/*!
 *  \~chinese
 群组通知的当前操作名

 @discussion
 群组通知的当前操作名称，您可以使用预定义好的操作名，也可以是您自己定义的任何操作名。
 预定义的操作名：GroupNotificationMessage_GroupOperationAdd、GroupNotificationMessage_GroupOperationQuit、GroupNotificationMessage_GroupOperationKicked、GroupNotificationMessage_GroupOperationRename、GroupNotificationMessage_GroupOperationBulletin。
 
 *  \~english
 The current operation name of the group notification.

 @ discussion
 The current operation name of the group notification, you can use a predefined operation name, or any operation name that you define yourself.
  Predefined operation names: GroupNotificationMessage_GroupOperationAdd, GroupNotificationMessage_GroupOperationQuit, GroupNotificationMessage_GroupOperationKicked, GroupNotificationMessage_GroupOperationRename, GroupNotificationMessage_GroupOperationBulletin.
 */
@property (nonatomic, copy) NSString *operation;

/*!
 *  \~chinese
 当前操作发起用户的用户 ID
 
 *  \~english
 User ID of the user who initiated the current operation
 */
@property (nonatomic, copy) NSString *operatorUserId;

/*!
 *  \~chinese
 当前操作的目标对象

 @discussion
 当前操作的目标对象，如被当前操作目标用户的用户 ID 或变更后的群主名称等。
 
 *  \~english
 The target object of the current operation.

 @ discussion
 The target object of the current operation, such as the user ID or the changed group owner name of the target user of the current operation.
 */
@property (nonatomic, copy) NSString *data;

/*!
 *  \~chinese
 当前操作的消息内容
 
 *  \~english
 Message content of the current operation
 */
@property (nonatomic, copy) NSString *message;

/*!
 *  \~chinese
 初始化群组通知消息

 @param operation       群组通知的当前操作名
 @param operatorUserId  当前操作发起用户的用户 ID
 @param data            当前操作的目标对象
 @param message         当前操作的消息内容
 @param extra           当前操作的附加信息
 @return                群组通知消息对象

 @discussion 群组关系由开发者维护，所有的群组操作都由您的服务器自己管理和维护。
 所以群组通知的操作名和目标对象、消息内容、扩展信息您均可以自己定制，只要您发送方和接收方针对具体字段内容做好UI显示即可。
 
 *  \~english
 Initialize group notification messages.

 @param operation The current operation name of the group notification.
 @param operatorUserId User ID of the user who initiated the current operation.
 @param data The target object of the current operation.
 @param message Message content of the current operation.
 @param extra Additional information for the current operation.
 @ return Group Notification message object.

 @ discussion Group relationships are maintained by developers, and all group operations are managed and maintained by your server.
  Therefore, you can customize the operation name and target object, message content and extended information of the group notification, as long as your sender and receiver make a good UI display of the specific field content.
 */
+ (instancetype)notificationWithOperation:(NSString *)operation
                           operatorUserId:(NSString *)operatorUserId
                                     data:(NSString *)data
                                  message:(NSString *)message
                                    extra:(NSString *)extra;

@end
