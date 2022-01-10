//
//  RCTagProtocol.h
//  RongIMLib
//
//  Created by 张改红 on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#ifndef RCTagProtocol_h
#define RCTagProtocol_h

@protocol RCTagDelegate <NSObject>

/*!
 标签变化
 
 @discussion 本端添加删除更新标签，不会触发不会触发此回调方法，在相关调用方法的 block 块直接回调
 */
- (void)onTagChanged;

@end


@protocol RCConversationTagDelegate <NSObject>

/*!
 会话标签变化
 
 @discussion 本端添加删除更新会话标签，不会触发此回调方法，在相关调用方法的 block 块直接回调
 */

- (void)onConversationTagChanged;

@end
#endif /* RCTagProtocol_h */
