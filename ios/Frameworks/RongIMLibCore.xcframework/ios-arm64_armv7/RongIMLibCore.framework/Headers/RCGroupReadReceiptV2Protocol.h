//
//  RCGroupReadReceiptV2Protocol.h
//  RongIMLibCore
//
//  Created by 张改红 on 2021/3/9.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#ifndef RCGroupReadReceiptV2Protocol_h
#define RCGroupReadReceiptV2Protocol_h

@protocol RCGroupReadReceiptV2Delegate <NSObject>

/*!
 消息已读回执响应（收到阅读回执响应，可以按照 messageUId 更新消息的阅读数）
 @param conversationType conversationType
 @param targetId         targetId
 @param channelId          所属会话的业务标识
 @param messageUId       请求已读回执的消息ID
 @param readCount 已读用户数
 @param totalCount 群内总用户数
  */
- (void)onMessageReceiptResponse:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                       channelId:(NSString *)channelId
                      messageUId:(NSString *)messageUId
                       readCount:(int)readCount
                      totalCount:(int)totalCount;

@end

#endif /* RCGroupReadReceiptV2Protocol_h */
