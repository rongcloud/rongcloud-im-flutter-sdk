//
//  RCConversationIdentifier.h
//  RongIMLib
//
//  Created by 张改红 on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 会话标识
 */
@interface RCConversationIdentifier : NSObject
/*!
 会话类型
 */
@property (nonatomic, assign) RCConversationType type;
/*!
 会话 ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 RCConversationIdentifier 初始化方法

 @param  type    会话类型
 @param  targetId       会话 id
 */

- (instancetype)initWithConversationIdentifier:(RCConversationType)type
                                      targetId:(NSString *)targetId;

@end

NS_ASSUME_NONNULL_END
