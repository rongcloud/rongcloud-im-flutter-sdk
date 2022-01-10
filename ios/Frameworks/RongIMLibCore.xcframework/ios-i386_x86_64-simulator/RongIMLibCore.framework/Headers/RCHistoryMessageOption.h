//
//  RCHistoryMessageOption.h
//  RongIMLibCore
//
//  Created by 张改红 on 2021/4/20.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 拉取顺序
 RCHistoryMessageOrderDesc - 降序
 RCHistoryMessageOrderAsc - 升序
 */
typedef enum : NSUInteger {
    RCHistoryMessageOrderDesc = 0,
    RCHistoryMessageOrderAsc,
} RCHistoryMessageOrder;

@interface RCHistoryMessageOption : NSObject
/**
 起始的消息发送时间戳，毫秒
 默认 0
 */
@property (nonatomic, assign) long long recordTime;

/**
 需要获取的消息数量， 0 < count <= 20
 默认 0
 */
@property (nonatomic, assign) NSInteger count;

/**
 拉取顺序
 RCRemoteHistoryOrderDesc： 降序，结合传入的时间戳参数，获取 recordtime 之前的消息
 RCRemoteHistoryOrderAsc： 升序，结合传入的时间戳参数，获取 recordtime 之后的消息
 默认降序
 */
@property (nonatomic, assign) RCHistoryMessageOrder order;
@end
