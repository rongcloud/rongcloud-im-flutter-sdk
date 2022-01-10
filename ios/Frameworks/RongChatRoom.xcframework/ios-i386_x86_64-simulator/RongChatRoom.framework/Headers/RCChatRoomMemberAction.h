//
//  RCChatRoomMemberAction.h
//  RongChatRoom
//
//  Created by 孙浩 on 2021/7/12.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCChatRoomEnumDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCChatRoomMemberAction : NSObject

/*!
 成员 ID
 */
@property (nonatomic, copy) NSString *memberId;

/*!
 成员加入或者退出
 */
@property (nonatomic, assign) RCChatRoomMemberActionType action;

/*!
 RCChatRoomMemberAction 初始化方法

 @param  memberId        成员 ID
 @param  action            成员加入或退出
 */
- (instancetype)initWithMemberId:(NSString *)memberId
                          action:(RCChatRoomMemberActionType)action;

@end

NS_ASSUME_NONNULL_END
