//
//  RCUserOnlineStatusInfo.h
//  RongIMLib
//
//  Created by RongCloud on 16/9/26.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 用户在线状态
 
 *  \~english
 User online status 
 */
@interface RCUserOnlineStatusInfo : NSObject

/*!
 *  \~chinese
 在线的平台
 
 *  \~english
 Online platform
*/
@property (nonatomic, assign) RCPlatform platform;

/*!
 *  \~chinese
 融云服务在线状态

 @discussion 0 表示离线，1 表示在线
 
 *  \~english
 Online status of financial cloud service.

 @ discussion 0 means offline, 1 means online.
 */
@property (nonatomic, assign) int rcServiceStatus;

/*!
 *  \~chinese
 用户自定义的在线状态(1 < customerStatus <= 255)

 @discussion
 如果没有通过 RCIMClient 的 setUserOnlineStatus:success:error: 设置自定义的在线状态，默认的在线状态值为 1，若离线则为 0。
 
 *  \~english
 User-defined presence status (1 < customerStatus < = 255).

 @ discussion
 If failed, perform setUserOnlineStatus:success:error: of RCIMClient. Set the custom online status. The default online status value is 1. if offline, it is 0.
 */
@property (nonatomic, assign) int customerStatus;

@end
