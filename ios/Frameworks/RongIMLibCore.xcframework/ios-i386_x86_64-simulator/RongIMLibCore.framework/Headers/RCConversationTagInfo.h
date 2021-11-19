//
//  ConversationTagInfo.h
//  RongIMLib
//
//  Created by RongCloud on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTagInfo.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 *  \~chinese
 会话所属的标签信息
 *  \~english
 Tag information to which the conversation belongs
 */
@interface RCConversationTagInfo : NSObject

/*!
 *  \~chinese
 标签信息
 
 *  \~english
 tag info
 */
@property (nonatomic, strong) RCTagInfo *tagInfo;

/*!
 *  \~chinese
 会话是否置顶
 
 *  \~english
 Whether the conversation is at the top
 */
@property (nonatomic, assign) BOOL isTop;

@end

NS_ASSUME_NONNULL_END
