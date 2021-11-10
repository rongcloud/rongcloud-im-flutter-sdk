//
//  RCCustomerServiceClient.h
//  RongCustomerService
//
//  Created by 张改红 on 2020/10/14.
//  Copyright © 2020 张改红. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCCustomerServiceConfig.h"
#import "RCCustomerServiceGroupItem.h"
#import "RCCustomerServiceInfo.h"
#import "RCCustomerServiceDefine.h"

@interface RCCustomerServiceClient : NSObject

+ (instancetype)sharedCustomerServiceClient;

#pragma mark - 客服方法
/*!
 发起客服聊天

 @param kefuId       客服 ID
 @param csInfo       客服信息
 @param successBlock            发起客服会话成功的回调
 @param errorBlock              发起客服会话失败的回调 [errorCode:失败的错误码 errMsg:错误信息]
 @param modeTypeBlock           客服模式变化
 @param pullEvaluationBlock     客服请求评价
 @param selectGroupBlock        客服分组选择
 @param quitBlock 客服被动结束。如果主动调用 stopCustomerService，则不会调用到该 block

 @discussion
 有些客服提供商可能会主动邀请评价，有些不会，所以用lib开发客服需要注意对 pullEvaluationBlock 的处理。在
 pullEvaluationBlock 里应该弹出评价。如果 pullEvaluationBlock
 没有被调用到，需要在结束客服时（之前之后都可以）弹出评价框并评价。如果客服有分组，selectGroupBlock
 会被回调，此时必须让用户选择分组然后调用 selectCustomerServiceGroup:withGroupId:。

 @warning 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)startCustomerService:(NSString *)kefuId
                        info:(RCCustomerServiceInfo *)csInfo
                   onSuccess:(void (^)(RCCustomerServiceConfig *config))successBlock
                     onError:(void (^)(int errorCode, NSString *errMsg))errorBlock
                  onModeType:(void (^)(RCCSModeType mode))modeTypeBlock
            onPullEvaluation:(void (^)(NSString *dialogId))pullEvaluationBlock
               onSelectGroup:(void (^)(NSArray<RCCustomerServiceGroupItem *> *groupList))selectGroupBlock
                      onQuit:(void (^)(NSString *quitMsg))quitBlock;

/*!
 客服后台关于评价相关的客服参数配置

 @param evaConfigBlock       客服配置回调

 @discussion 此方法依赖 startCustomerService 方法，只有调用成功以后才有效。
 @warning 如果你使用的 IMLib，或者使用kit但想要自定义评价弹窗，可以参考相关配置绘制评价 UI

 @remarks 客服
 */
- (void)getHumanEvaluateCustomerServiceConfig:(void (^)(NSDictionary *evaConfig))evaConfigBlock;

/*!
 结束客服聊天

 @param kefuId       客服 ID

 @discussion 此方法依赖 startCustomerService 方法，只有调用成功以后才有效。
 @warning
 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)stopCustomerService:(NSString *)kefuId;

/*!
 选择客服分组模式

 @param kefuId       客服 ID
 @param groupId       选择的客服分组 id
 @discussion 此方法依赖 startCustomerService 方法，只有调用成功以后才有效。
 @warning
 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)selectCustomerServiceGroup:(NSString *)kefuId withGroupId:(NSString *)groupId;

/*!
 切换客服模式

 @param kefuId       客服 ID

 @discussion
 此方法依赖 startCustomerService 方法，而且只有当前客服模式为机器人优先才可调用。
 @warning
 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)switchToHumanMode:(NSString *)kefuId;

/*!
 评价机器人客服，用于对单条机器人应答的评价。

 @param kefuId                客服 ID
 @param knownledgeId          知识点 ID
 @param isRobotResolved       是否解决问题
 @param suggest                客户建议

 @discussion 此方法依赖 startCustomerService 方法。可在客服结束之前或之后调用。
 @discussion
 有些客服服务商需要对机器人回答的词条进行评价，机器人回答的文本消息的 extra 带有{“robotEva”:”1”,
 “sid”:”xxx”}字段，当用户对这一条消息评价后调用本函数同步到服务器，knownledgedID为extra 中的
 sid。若是离开会话触发的评价或者在加号扩展中主动触发的评价，knownledgedID 填 nil

 @warning
 如果你使用IMKit，请不要使用此方法。RCConversationViewController默认已经做了处理。

 @remarks 客服
 */
- (void)evaluateCustomerService:(NSString *)kefuId
                   knownledgeId:(NSString *)knownledgeId
                     robotValue:(BOOL)isRobotResolved
                        suggest:(NSString *)suggest;

/*!
 评价人工客服。

 @param kefuId                客服 ID
 @param dialogId              对话 ID，客服请求评价的对话 ID
 @param value                 分数，取值范围 1-5
 @param suggest               客户建议
 @param resolveStatus         解决状态，如果没有解决状态，这里可以随意赋值，SDK 不会处理
 @param tagText               客户评价的标签
 @param extra                 扩展内容

 @discussion 此方法依赖 startCustomerService 方法。可在客服结束之前或之后调用。
 @discussion
 有些客服服务商会主动邀请评价，pullEvaluationBlock 会被调用到，当评价完成后调用本函数同步到服务器，dialogId 填
 pullEvaluationBlock 返回的 dialogId。若是离开会话触发的评价或者在加号扩展中主动触发的评价，dialogID 为 nil

 @warning
 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)evaluateCustomerService:(NSString *)kefuId
                       dialogId:(NSString *)dialogId
                      starValue:(int)value
                        suggest:(NSString *)suggest
                  resolveStatus:(RCCSResolveStatus)resolveStatus
                        tagText:(NSString *)tagText
                          extra:(NSDictionary *)extra;

/*!
 通用客服评价，不区分机器人人工

 @param kefuId                客服 ID
 @param dialogId              对话 ID，客服请求评价的对话 ID
 @param value                 分数，取值范围 1-5
 @param suggest               客户建议
 @param resolveStatus         解决状态，如果没有解决状态，这里可以随意赋值，SDK不 会处理
 @discussion 此方法依赖 startCustomerService 方法。可在客服结束之前或之后调用。
 @discussion
 有些客服服务商会主动邀请评价，pullEvaluationBlock 会被调用到，当评价完成后调用本函数同步到服务器，dialogId 填
 pullEvaluationBlock 返回的 dialogId。若是离开会话触发的评价或者在加号扩展中主动触发的评价，dialogID 为 nil
 @warning
 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)evaluateCustomerService:(NSString *)kefuId
                       dialogId:(NSString *)dialogId
                      starValue:(int)value
                        suggest:(NSString *)suggest
                  resolveStatus:(RCCSResolveStatus)resolveStatus;

/*!
 客服留言

 @param kefuId                客服 ID
 @param leaveMessageDic       客服留言信息字典，根据 RCCSLeaveMessageItem 中关于留言的配置存储对应的 key-value
 @param successBlock          成功回调
 @param failureBlock          失败回调
 @discussion 此方法依赖 startCustomerService 方法。可在客服结束之前或之后调用。
 @discussion 如果一些值没有，可以传 nil
 @warning
 如果你使用 IMKit，请不要使用此方法。RCConversationViewController 默认已经做了处理。

 @remarks 客服
 */
- (void)leaveMessageCustomerService:(NSString *)kefuId
                    leaveMessageDic:(NSDictionary *)leaveMessageDic
                            success:(void (^)(void))successBlock
                            failure:(void (^)(void))failureBlock;
@end
