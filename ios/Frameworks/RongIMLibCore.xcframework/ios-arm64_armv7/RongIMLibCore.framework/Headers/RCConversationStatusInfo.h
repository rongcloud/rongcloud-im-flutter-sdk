//
//  RCConversationStatusInfo.h
//  RongIMLib
//
//  Created by liyan on 2020/5/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"

/*!
 *  \~chinese
会话状态类型
 *  \~english
 Conversation state type
*/

typedef NS_ENUM(NSUInteger, RCConversationStatusType) {
    /*!
     *  \~chinese
     免打扰
     *  \~english
     Do not disturb
     */
    RCConversationStatusType_Mute = 1,

    /*!
     *  \~chinese
     置顶
     *  \~english
     Top
     */
    RCConversationStatusType_Top = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface RCConversationStatusInfo : NSObject

/*!
 *  \~chinese
 会话类型
 *  \~english
 Conversation type
 */
@property (nonatomic, assign) RCConversationType conversationType;

/*!
 *  \~chinese
 会话 ID
 *  \~english
 Conversation ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 *  \~chinese
 所属会话的业务标识
 *  \~english
 Business identifier of the conversation to which it belongs.
 */
@property (nonatomic, copy) NSString *channelId;

/*!
 *  \~chinese
 会话状态改变的类型
 *  \~english
 Types of conversation state changes
*/
@property (nonatomic, assign) RCConversationStatusType conversationStatusType;

/*!
 *  \~chinese
 如果 conversationStatusType  = RCConversationStatusType_Mute， conversationStatusvalue = 0
 是提醒，conversationStatusvalue = 1 是免打扰。  如果 conversationStatusType  = RCConversationStatusType_Top，
 conversationStatusvalue = 0 是不置顶，conversationStatusvalue = 1 是置顶。
 
 *  \~english
 If conversationStatusType = RCConversationStatusType_Mute, conversationStatusvalue = 0.
 Is a reminder, conversationStatusvalue = 1 is do not disturb.  If conversationStatusType = RCConversationStatusType_Top.
 ConversationStatusvalue = 0 indicates non top setting, conversationStatusvalue = 1 is the top setting.
*/
@property (nonatomic, assign) int conversationStatusvalue;

@end

NS_ASSUME_NONNULL_END
