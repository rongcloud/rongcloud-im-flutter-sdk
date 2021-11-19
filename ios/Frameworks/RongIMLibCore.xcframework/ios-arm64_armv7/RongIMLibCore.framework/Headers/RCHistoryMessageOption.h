//
//  RCHistoryMessageOption.h
//  RongIMLibCore
//
//  Created by RongCloud on 2021/4/20.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 拉取顺序
 RCHistoryMessageOrderDesc - 降序
 RCHistoryMessageOrderAsc - 升序
 
 *  \~english
 Pull sequence.
 RCHistoryMessageOrderDesc-descending.
 RCHistoryMessageOrderAsc-ascending order.
 */
typedef enum : NSUInteger {
    RCHistoryMessageOrderDesc = 0,
    RCHistoryMessageOrderAsc,
} RCHistoryMessageOrder;

@interface RCHistoryMessageOption : NSObject
/**
 *  \~chinese
 起始的消息发送时间戳，毫秒
 默认 0
 
 *  \~english
 Initial message sending timestamp, millisecond.
 Default 0.
 */
@property (nonatomic, assign) long long recordTime;

/**
 *  \~chinese
 需要获取的消息数量， 0 < count <= 20
 默认 0
 
 *  \~english
 The number of messages to be obtained, 0 < count < = 20.
 Default 0.
 */
@property (nonatomic, assign) NSInteger count;

/**
 *  \~chinese
 拉取顺序
 RCRemoteHistoryOrderDesc： 降序，结合传入的时间戳参数，获取 recordtime 之前的消息
 RCRemoteHistoryOrderAsc： 升序，结合传入的时间戳参数，获取 recordtime 之后的消息
 默认降序
 
 *  \~english
 Pull sequence.
 RCRemoteHistoryOrderDesc: Descending order, the passed timestamp parameters are combined to get the messages before recordtime.
 RCRemoteHistoryOrderAsc: Ascending order,  the passed timestamp parameters are combined to get the message after recordtime
 Default descending order.
 */
@property (nonatomic, assign) RCHistoryMessageOrder order;
@end
