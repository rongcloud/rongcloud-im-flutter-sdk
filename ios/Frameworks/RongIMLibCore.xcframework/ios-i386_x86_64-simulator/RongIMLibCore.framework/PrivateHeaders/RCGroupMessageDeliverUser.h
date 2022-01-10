//
//  RCGroupMessageDeliverUser.h
//  RongIMLibCore
//
//  Created by 孙浩 on 2021/11/10.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCGroupMessageDeliverUser : NSObject

/**
 已送达用户 Id
 */
@property (nonatomic, copy) NSString *userId;

/**
 送达时间（Unix 时间戳、毫秒）
 */
@property (nonatomic, assign) long long deliverTime;

@end

NS_ASSUME_NONNULL_END
