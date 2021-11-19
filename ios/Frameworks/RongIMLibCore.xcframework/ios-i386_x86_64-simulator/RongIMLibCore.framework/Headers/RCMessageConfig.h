//
//  RCMessageConfig.h
//  RongIMLib
//
//  Created by RongCloud on 2020/6/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCMessageConfig : NSObject

/*!
 *  \~chinese
 是否关闭通知
 YES: 关闭通知（不发送通知）
 NO: 不关闭通知（发送通知）
 默认 NO
 
 *  \~english
 Whether to turn off notification.
 YES: Turn off notifications (do not send notifications).
 NO: Do not turn off notification (send notification).
 Default NO
 */
@property (nonatomic, assign) BOOL disableNotification;

@end

