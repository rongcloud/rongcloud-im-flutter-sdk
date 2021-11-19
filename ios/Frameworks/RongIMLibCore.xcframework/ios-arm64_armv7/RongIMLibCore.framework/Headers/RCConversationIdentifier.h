//
//  RCConversationIdentifier.h
//  RongIMLib
//
//  Created by RongCloud on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 *  \~chinese
 会话标识
 *  \~english
 Conversation identification
 */
@interface RCConversationIdentifier : NSObject
/*!
 *  \~chinese
 会话类型
 *  \~english
 Conversation type
 */
@property (nonatomic, assign) RCConversationType type;
/*!
 *  \~chinese
 会话 ID
 *  \~english
 Conversation ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 *  \~chinese
 RCConversationIdentifier 初始化方法

 @param  type    会话类型
 @param  targetId       会话 id
 
 *  \~english
 RCConversationIdentifier initialization method.

 @ param type conversation type.
 @ param targetId conversation id.
 */

- (instancetype)initWithConversationIdentifier:(RCConversationType)type
                                      targetId:(NSString *)targetId;

@end

NS_ASSUME_NONNULL_END
