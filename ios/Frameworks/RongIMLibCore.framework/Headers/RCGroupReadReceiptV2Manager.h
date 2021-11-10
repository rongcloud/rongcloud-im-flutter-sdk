//
//  RCGroupReadReceiptV2Manager.h
//  RongIMLibCore
//
//  Created by 张改红 on 2021/3/9.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCGroupMessageReaderV2.h"
#import "RCMessage.h"
#import "RCGroupReadReceiptV2Protocol.h"
@interface RCGroupReadReceiptV2Manager : NSObject
/*!
 获取单例类
 */
+ (instancetype)sharedManager;

/*!
 群已读回执代理
 */
@property (nonatomic, weak) id<RCGroupReadReceiptV2Delegate> groupReadReceiptV2Delegate;

/*!
 发送阅读回执

 @param conversationType 会话类型
 @param targetId         会话 ID
 @param channelId          所属会话的业务标识
 @param messageList      已经阅读了的消息列表
 @param successBlock     发送成功的回调
 @param errorBlock       发送失败的回调[nErrorCode: 失败的错误码]

 @discussion 当用户阅读了需要阅读回执的消息，可以通过此接口发送阅读回执，消息的发送方即可直接知道那些人已经阅读。

 @remarks 高级功能
 */
- (void)sendReadReceiptResponse:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                      channelId:(NSString *)channelId
                    messageList:(NSArray<RCMessage *> *)messageList
                        success:(void (^)(void))successBlock
                          error:(void (^)(RCErrorCode nErrorCode))errorBlock;

/*!
 获取群消息已读用户列表
 
 @param message        消息体
 @param successBlock     同步成功的回调
 @param errorBlock       同步失败的回调[nErrorCode: 失败的错误码]

 @remarks 高级功能
 */
- (void)getGroupMessageReaderList:(RCMessage *)message
                          success:(void (^)(NSArray <RCGroupMessageReaderV2 *> *readerList, int totalCount))successBlock
                            error:(void (^)(RCErrorCode nErrorCode))errorBlock;
@end
