//
//  RCDiscussionClient.h
//  RongDiscussion
//
//  Created by 张改红 on 2020/8/18.
//  Copyright © 2020 张改红. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RCStatusDefine.h>
#import "RCDiscussion.h"


@interface RCDiscussionClient : NSObject

+ (instancetype)sharedDiscussionClient;

#pragma mark - 讨论组操作（已废弃，请勿使用）

/*!
 创建讨论组

 @param name            讨论组名称
 @param userIdList      用户 ID 的列表
 @param successBlock    创建讨论组成功的回调
 [discussion:创建成功返回的讨论组对象]
 @param errorBlock      创建讨论组失败的回调 [status:创建失败的错误码]

 @remarks 会话
 */
- (void)createDiscussion:(NSString *)name
              userIdList:(NSArray *)userIdList
                 success:(void (^)(RCDiscussion *discussion))successBlock
                   error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

/*!
 讨论组加人，将用户加入讨论组

 @param discussionId    讨论组 ID
 @param userIdList      需要加入的用户 ID 列表
 @param successBlock    讨论组加人成功的回调
 [discussion:讨论组加人成功返回的讨论组对象]
 @param errorBlock      讨论组加人失败的回调 [status:讨论组加人失败的错误码]

 @discussion 设置的讨论组名称长度不能超过 40 个字符，否则将会截断为前 40 个字符。

 @remarks 会话
 */
- (void)addMemberToDiscussion:(NSString *)discussionId
                   userIdList:(NSArray *)userIdList
                      success:(void (^)(RCDiscussion *discussion))successBlock
                        error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

/*!
 讨论组踢人，将用户移出讨论组

 @param discussionId    讨论组 ID
 @param userId          需要移出的用户 ID
 @param successBlock    讨论组踢人成功的回调
 [discussion:讨论组踢人成功返回的讨论组对象]
 @param errorBlock      讨论组踢人失败的回调 [status:讨论组踢人失败的错误码]

 @discussion
 如果当前登录用户不是此讨论组的创建者并且此讨论组没有开放加人权限，则会返回错误。

 @warning 不能使用此接口将自己移除，否则会返回错误。
 如果您需要退出该讨论组，可以使用-quitDiscussion:success:error:方法。

 @remarks 会话
 */
- (void)removeMemberFromDiscussion:(NSString *)discussionId
                            userId:(NSString *)userId
                           success:(void (^)(RCDiscussion *discussion))successBlock
                             error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

/*!
 退出当前讨论组

 @param discussionId    讨论组 ID
 @param successBlock    退出成功的回调 [discussion:退出成功返回的讨论组对象]
 @param errorBlock      退出失败的回调 [status:退出失败的错误码]

 @remarks 会话
 */
- (void)quitDiscussion:(NSString *)discussionId
               success:(void (^)(RCDiscussion *discussion))successBlock
                 error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

/*!
 获取讨论组的信息

 @param discussionId    需要获取信息的讨论组 ID
 @param successBlock    获取讨论组信息成功的回调 [discussion:获取的讨论组信息]
 @param errorBlock      获取讨论组信息失败的回调
 [status:获取讨论组信息失败的错误码]

 @remarks 会话
 */
- (void)getDiscussion:(NSString *)discussionId
              success:(void (^)(RCDiscussion *discussion))successBlock
                error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

/*!
 设置讨论组名称

 @param discussionId            需要设置的讨论组 ID
 @param discussionName          需要设置的讨论组名称，discussionName 长度<=40
 @param successBlock            设置成功的回调
 @param errorBlock              设置失败的回调 [status:设置失败的错误码]

 @discussion 设置的讨论组名称长度不能超过 40 个字符，否则将会截断为前 40 个字符。

 @remarks 会话
 */
- (void)setDiscussionName:(NSString *)discussionId
                     name:(NSString *)discussionName
                  success:(void (^)(void))successBlock
                    error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

/*!
 设置讨论组是否开放加人权限

 @param discussionId    讨论组 ID
 @param isOpen          是否开放加人权限
 @param successBlock    设置成功的回调
 @param errorBlock      设置失败的回调[status:设置失败的错误码]

 @discussion 讨论组默认开放加人权限，即所有成员都可以加人。
 如果关闭加人权限之后，只有讨论组的创建者有加人权限。

 @remarks 会话
 */
- (void)setDiscussionInviteStatus:(NSString *)discussionId
                           isOpen:(BOOL)isOpen
                          success:(void (^)(void))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("已废弃，请勿使用。");

@end

