//
//  RCCSLeaveMessage.h
//  RongIMLib
//
//  Created by 张改红 on 2016/12/6.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>
/*!
  客服邀请留言消息类的类型名
 */
#define RCCSPullLeaveMessageTypeIdentifier @"RC:CsPLM"
/*!
 客服邀请留言消息类
 
 @remarks 信令类消息
 */
@interface RCCSPullLeaveMessage : RCMessageContent
/*!
  消息显示内容
 */
@property (nonatomic, copy) NSString *content;
@end
