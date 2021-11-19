//
//  RCMessageReadUser.h
//  RongIMLibCore
//
//  Created by RongCloud on 2021/2/22.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 已读用户对象
 
 *  \~english
 Read user object
 */
@interface RCGroupMessageReaderV2 : NSObject

/**
 *  \~chinese
 已读用户 id
 
 *  \~english
 Read user id
 */
@property (nonatomic, copy) NSString *userId;

/**
 *  \~chinese
 已读时间
 
 *  \~english
 Read time
 */
@property (nonatomic, assign) long long readTime;

@end
