//
//  RCTagProtocol.h
//  RongIMLib
//
//  Created by RongCloud on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#ifndef RCTagProtocol_h
#define RCTagProtocol_h

@protocol RCTagDelegate <NSObject>

/*!
 *  \~chinese
 标签变化
 
 @discussion 本端添加删除更新标签，不会触发不会触发此回调方法，在相关调用方法的 block 块直接回调
 
 *  \~english
 Tag change.

 @ discussion Local label addition, deletion and update will not trigger or trigger this callback method, which will be called back directly in the block of the relevant calling method.
 */
- (void)onTagChanged;

@end


@protocol RCConversationTagDelegate <NSObject>

/*!
 *  \~chinese
 会话标签变化
 
 @discussion 本端添加删除更新会话标签，不会触发此回调方法，在相关调用方法的 block 块直接回调
 
 *  \~english
 Conversation tag change.

 @ discussion Local addition, deletion and update of conversation tag will not trigger this callback method, and will be called back directly in the block of the relevant calling method.
 */

- (void)onConversationTagChanged;

@end
#endif /* RCTagProtocol_h */
