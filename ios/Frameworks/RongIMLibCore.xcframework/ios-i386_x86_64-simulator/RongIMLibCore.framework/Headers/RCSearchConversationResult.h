//
//  RCSearchConversationResult.h
//  RongIMLib
//
//  Created by RongCloud on 16/9/29.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import "RCConversation.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 搜索的会话结果
 
 *  \~english
 conversation results of the search
 */
@interface RCSearchConversationResult : NSObject

/*!
 *  \~chinese
 匹配的会话对象
 
 *  \~english
 Matching conversation object.
 */
@property (nonatomic, strong) RCConversation *conversation;

/*
 *  \~chinese
 会话匹配的消息条数
 
 *  \~english
 Number of messages matched by the conversation
 */
@property (nonatomic, assign) int matchCount;
@end
