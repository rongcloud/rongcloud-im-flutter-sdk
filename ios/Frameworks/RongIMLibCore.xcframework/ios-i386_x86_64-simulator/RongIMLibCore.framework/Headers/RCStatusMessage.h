/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCStatusMessage.h
//  Created by Heq.Shinoda on 14-6-13.

#import "RCMessageContent.h"
/**
 状态消息的抽象基类，表示某种状态，不会存入消息历史记录。
 此类消息不保证一定到达接收方（但只是理论上存在丢失的可能），但是速度最快，所以通常用来传递状态信息。
*/
@interface RCStatusMessage : RCMessageContent

@end
