//
//  ConversationTagInfo.h
//  RongIMLib
//
//  Created by 张改红 on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCTagInfo.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 会话所属的标签信息
 */
@interface RCConversationTagInfo : NSObject

/*!
 标签 ID
 */
@property (nonatomic, strong) RCTagInfo *tagInfo;

/*!
 会话是否置顶
 */
@property (nonatomic, assign) BOOL isTop;

@end

NS_ASSUME_NONNULL_END
