//
//  RCPushProfile.h
//  RongIMLib
//
//  Created by RongCloud on 16/12/26.
//  Copyright © 2016 RongCloud. All rights reserved.
//

#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

@interface RCPushProfile : NSObject

/**
 *  \~chinese
 是否显示远程推送的内容

 *  \~english
 Whether to display the content of remote push
 */
@property (nonatomic, assign, readonly) BOOL isShowPushContent;

/**
 *  \~chinese
 远程推送的语言

 *  \~english
 The language of remote push
 */
@property (nonatomic, assign, readonly) RCPushLauguage pushLauguage;

/**
 *  \~chinese
 其他端在线时，手机是否接收远程推送(多个手机端登录，最后一个会接收)

 *  \~english
 Whether the mobile phone receives remote push when the other end is online (multiple mobile phones log in, the last one will receive it)
 */
@property (nonatomic, assign, readonly) BOOL receiveStatus;

/**
 *  \~chinese
 设置是否显示远程推送的内容

 @param isShowPushContent 是否显示推送的具体内容（ YES 显示 NO 不显示）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 
 *  \~english
 Set whether to display the contents of remote push.

 @param isShowPushContent Whether to display the specific content of the push (YES display NO does not display).
 @param successBlock Callback for success
 @param errorBlock Callback for failure
 */
- (void)updateShowPushContentStatus:(BOOL)isShowPushContent
                            success:(void (^)(void))successBlock
                              error:(void (^)(RCErrorCode status))errorBlock;

/**
 *  \~chinese
 设置推送内容的自然语言

 @param pushLauguage      设置推送内容的自然语言
 @param successBlock      成功回调
 @param errorBlock        失败回调
 
 *  \~english
 Set the natural language of push content.

 @param pushLauguage Set the natural language of push content.
 @param successBlock Callback for success
 @param errorBlock Callback for failure
 */
- (void)setPushLauguage:(RCPushLauguage)pushLauguage
                success:(void (^)(void))successBlock
                  error:(void (^)(RCErrorCode status))errorBlock __deprecated_msg("Use setPushLauguageCode:success:error");


/**
 *  \~chinese
 设置推送内容的自然语言
 
 @param lauguage             通过 SDK 设置的语言环境，语言缩写内容格式为 (ISO-639 Language Code)_(ISO-3166 Country Codes)，如：zh_CN。目前融云支持的内置推送语言为 zh_CN、en_US、ar_SA
 @param successBlock    成功回调
 @param errorBlock        失败回调
 
 *  \~english
 Set the natural language of push content.

 @param lauguage Through the locale set by SDK, the format of the language abbreviation content is (ISO-639 Language Code) _ (ISO-3166 Country Codes),) such as: zh_CN. Currently, the built-in push languages supported by RongCloud are zh_CN, en_US and ar_SA.
 @param successBlock Callback for success
 @param errorBlock Callback for failure
 */
- (void)setPushLauguageCode:(NSString *)lauguage
                    success:(void (^)(void))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/**
 *  \~chinese
 设置 Web 端在线时，手机端是否接收推送

 @param receiveStatus     是否接收推送（ YES 接收 NO 不接收）
 @param successBlock      成功回调
 @param errorBlock        失败回调
 
 *  \~english
 Set whether the mobile phone will receive push when the Web terminal is online.

 @param receiveStatus  Whether to receive push or not (YES receive NO does not receive).
 @param successBlock Callback for success
 @param errorBlock Callback for failure
 */
- (void)setPushReceiveStatus:(BOOL)receiveStatus
                     success:(void (^)(void))successBlock
                       error:(void (^)(RCErrorCode status))errorBlock;

@end
