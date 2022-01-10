//
//  RCUserOnlineStatusInfo.h
//  RongIMLib
//
//  Created by 杜立召 on 16/9/26.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

/*!
 用户在线状态
 */
@interface RCUserOnlineStatusInfo : NSObject

/*!
 在线的平台
*/
@property (nonatomic, assign) RCPlatform platform;

/*!
 融云服务在线状态

 @discussion 0 表示离线，1 表示在线
 */
@property (nonatomic, assign) int rcServiceStatus;

/*!
 用户自定义的在线状态(1 < customerStatus <= 255)

 @discussion
 如果没有通过 RCIMClient 的 setUserOnlineStatus:success:error: 设置自定义的在线状态，默认的在线状态值为 1，若离线则为 0。
 */
@property (nonatomic, assign) int customerStatus;

@end
