//
//  RCCSLeaveMessage.h
//  RongIMLib
//
//  Created by 张改红 on 2016/12/7.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLibCore/RongIMLibCore.h>
/*!
 客服留言消息的类型名
 */
#define RCCSLeaveMessageTypeIdentifier @"RC:CsLM"

/*!
 客服留言消息类
 @discussion 客服留言消息类，此消息不存储不计入未读消息数。
 
 @remarks 信令类消息
 */
@interface RCCSLeaveMessage : RCMessageContent
/*!
 发送的留言 json
 */
@property (nonatomic, strong) NSDictionary *leaveMessageDic;
@end
