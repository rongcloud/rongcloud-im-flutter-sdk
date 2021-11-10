//
//  RCClearConversationOption.h
//  RongIMLibCore
//
//  Created by 孙浩 on 2021/8/23.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCClearConversationOption : NSObject

/*
 是否清除本地历史消息
 */
@property (nonatomic, assign) BOOL isDeleteMessage;

@end

NS_ASSUME_NONNULL_END
