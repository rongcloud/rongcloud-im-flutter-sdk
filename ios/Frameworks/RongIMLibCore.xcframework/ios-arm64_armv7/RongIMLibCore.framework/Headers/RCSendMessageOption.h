//
//  RCSendMessageOption.h
//  RongIMLib
//
//  Created by liyan on 2019/4/29.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCSendMessageOption : NSObject

/*
 *  \~chinese
 发送的消息，是否走 VOIP 推送
 
 *  \~english
 The message sent, whether to use VOIP push or not
 */
@property (nonatomic, assign) BOOL isVoIPPush;

@end

NS_ASSUME_NONNULL_END
