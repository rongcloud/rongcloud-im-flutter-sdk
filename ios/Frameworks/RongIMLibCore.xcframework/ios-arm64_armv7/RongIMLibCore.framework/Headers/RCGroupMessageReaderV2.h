//
//  RCMessageReadUser.h
//  RongIMLibCore
//
//  Created by 张改红 on 2021/2/22.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 已读用户对象
 */
@interface RCGroupMessageReaderV2 : NSObject

/**
 已读用户 id
 */
@property (nonatomic, copy) NSString *userId;

/**
 已读时间
 */
@property (nonatomic, assign) long long readTime;

@end
