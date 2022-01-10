//
//  RCPrivateMessageDeliverInfo.h
//  RongIMLibCore
//
//  Created by 孙浩 on 2021/11/10.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCPrivateMessageDeliverInfo : NSObject

/**
 消息 messageUId
 */
@property (nonatomic, copy) NSString *messageUId;

/**
 会话 ID
 */
@property (nonatomic, copy) NSString *targetId;

/**
 消息类型名
 */
@property (nonatomic, copy) NSString *objectName;

/**
 送达时间（Unix 时间戳、毫秒）
 */
@property (nonatomic, assign) long long deliverTime;

@end

NS_ASSUME_NONNULL_END
