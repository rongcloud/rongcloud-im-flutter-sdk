//
//  RCBlockedMessageInfo.h
//  RongIMLibCore
//
//  Created by 孙浩 on 2021/7/9.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCBlockedMessageInfo : NSObject

/**
 *  会话类型
 */
@property (nonatomic, assign) RCConversationType type;

/**
 *  会话 ID
 */
@property (nonatomic, copy) NSString *targetId;

/**
 *  被拦截的消息 ID
 */
@property (nonatomic, copy) NSString *blockedMsgUId;

/**
 *  拦截原因
 *  1,全局敏感词：命中了融云内置的全局敏感词
 *  2,自定义敏感词拦截：命中了客户在融云自定义的敏感词
 *  3,第三方审核拦截：命中了第三方（数美）或模板路由决定不下发的状态
 */
@property (nonatomic, assign) RCMessageBlockType blockType;

/**
 *  附加信息
 */
@property (nonatomic, copy) NSString *extra;

/*!
 RCBlockedMessageInfo 初始化方法

 @param  type    会话类型
 @param  targetId       会话 ID
 @param  blockedMsgUId       被拦截的消息 ID
 @param  blockType       会话 id
 */
- (instancetype)initWithConversationType:(RCConversationType)type
                                targetId:(NSString *)targetId
                           blockedMsgUId:(NSString *)blockedMsgUId
                               blockType:(RCMessageBlockType)blockType;

@end

NS_ASSUME_NONNULL_END
