//
//  RCRemoteHistoryMsgOption.h
//  RongIMLib
//
//  Created by Zhaoqianyu on 2019/7/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 拉取顺序
 RCRemoteHistoryOrderDesc - 降序
 RCRemoteHistoryOrderAsc - 升序
 
 *  \~english
 Pull sequence.
 RCRemoteHistoryOrderDesc-descending.
 RCRemoteHistoryOrderAsc-ascending order.
 */
typedef enum : NSUInteger {
    RCRemoteHistoryOrderDesc = 0,
    RCRemoteHistoryOrderAsc,
} RCRemoteHistoryOrder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  \~chinese
 RCIMClient - getRemoteHistoryMessage 接口对应的参数选项
 
 *  \~english
 Parameter options for RCIMClient-getRemoteHistoryMessage interface.
 */
@interface RCRemoteHistoryMsgOption : NSObject

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
 RCRemoteHistoryOrderDesc： 降序，结合传入的时间戳参数，获取发送时间递增的消息
 RCRemoteHistoryOrderAsc： 升序，结合传入的时间戳参数，获取发送时间递减的消息
 默认降序
 
 *  \~english
 Pull sequence.
 RCRemoteHistoryOrderDesc: Descending order, the passed timestamp parameters are combined to get messages with an increasing sending time.
 RCRemoteHistoryOrderAsc:
  Ascending order,  the passed timestamp parameters are combiend to get the message with decreasing sending time.
 Default descending order.
 */
@property (nonatomic, assign) RCRemoteHistoryOrder order;

/**
 *  \~chinese
 是否需要排重
 YES: 拉取回来的消息全部返回
 NO: 拉取回来的消息只返回本地数据库中不存在的
 默认 NO
 
 *  \~english
 Does it shall be weighed?
 YES: All the messages pulled back are returned.
 NO: The pulled messages only return messages that do not exist in the local database.
 Default NO
 */
@property (nonatomic, assign) BOOL includeLocalExistMessage;

@end

NS_ASSUME_NONNULL_END
