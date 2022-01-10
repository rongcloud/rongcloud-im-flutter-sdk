//
//  RCUltraGroupTypingStatusInfo.h
//  RongIMLibCore
//
//  Created by zafer on 2021/12/20.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCStatusDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCUltraGroupTypingStatusInfo : NSObject
/*!
 会话 ID
 */
@property (nonatomic, copy) NSString *targetId;

/*!
 所属会话的业务标识
 */
@property (nonatomic, copy) NSString *channelId;

/*!
 用户id
 */
@property (nonatomic, copy) NSString *userId;

/*!
 用户数
 */
@property (nonatomic, assign) NSInteger userNumbers;

/*!
 输入状态
 */
@property (nonatomic, assign) RCUltraGroupTypingStatus status;

/*!
 服务端收到用户操作的上行时间.
 */
@property (nonatomic, assign) long long timestamp;

@end

NS_ASSUME_NONNULL_END
