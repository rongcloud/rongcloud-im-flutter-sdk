//
//  RCPublicServiceClient.h
//  RongPublicService
//
//  Created by RongCloud on 2020/9/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPublicServiceProfile.h"


@interface RCPublicServiceClient : NSObject

+ (instancetype)sharedPublicServiceClient;

/*!
 *  \~chinese
 查找公众服务账号

 @param searchType                  查找匹配方式
 @param searchKey                   查找关键字
 @param successBlock                查找成功的回调
 [accounts:查找到的公众服务账号信息 RCPublicServiceProfile 的数组]
 @param errorBlock                  查找失败的回调 [status:失败的错误码]

 @remarks 公众号
 
 *  \~english
 Find the public service account.

 @param searchType Find matching mode.
 @param searchKey Find keyword.
 @param successBlock  Callback for successful finding
 [accounts: array of found public service account information RCPublicServiceProfile].
 @param errorBlock  Callback for failed finding [status: error code of failure].

 @ remarks official account.
 */
- (void)searchPublicService:(RCSearchType)searchType
                  searchKey:(NSString *)searchKey
                    success:(void (^)(NSArray *accounts))successBlock
                      error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 按类型查找公众服务账号

 @param publicServiceType           公众服务账号的类型
 @param searchType                  查找匹配方式
 @param searchKey                   查找关键字
 @param successBlock                查找成功的回调
 [accounts:查找到的公众服务账号信息 RCPublicServiceProfile 的数组]
 @param errorBlock                  查找失败的回调 [status:失败的错误码]

 @remarks 公众号
 
 *  \~english
 Find public service accounts by type.

 @param publicServiceType Type of public service account.
 @param searchType Find matching mode.
 @param searchKey Find keyword.
 @param successBlock Callback for successful finding
 [accounts: array of found public service account information RCPublicServiceProfile]
 @param errorBlock Callback for failed finding  [status: error code of  failure].

 @ remarks official account.
 */
- (void)searchPublicServiceByType:(RCPublicServiceType)publicServiceType
                       searchType:(RCSearchType)searchType
                        searchKey:(NSString *)searchKey
                          success:(void (^)(NSArray *accounts))successBlock
                            error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 关注公众服务账号

 @param publicServiceType       公众服务账号的类型
 @param publicServiceId         公众服务的账号 ID
 @param successBlock            关注成功的回调
 @param errorBlock              关注失败的回调 [status:失败的错误码]

 @remarks 公众号
 
 *  \~english
 Follow the public service account.

 @param publicServiceType Type of public service account.
 @param publicServiceId Public service account ID.
 @param successBlock  Callback for successful following
 @param errorBlock Callback for failed following[ status: error codes of failures].

 @ remarks official account.
 */
- (void)subscribePublicService:(RCPublicServiceType)publicServiceType
               publicServiceId:(NSString *)publicServiceId
                       success:(void (^)(void))successBlock
                         error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 取消关注公众服务账号

 @param publicServiceType       公众服务账号的类型
 @param publicServiceId         公众服务的账号 ID
 @param successBlock            取消关注成功的回调
 @param errorBlock              取消关注失败的回调 [status:失败的错误码]

 @remarks 公众号
 
 *  \~english
 Cancel the public service to follow

 @param publicServiceType Type of public service account.
 @param publicServiceId Public service account ID.
 @param successBlock Callback for canceling following successfully
 @param errorBlock Callback for failing to cancel following [status: error code of failure].

 @ remarks official account.
 */
- (void)unsubscribePublicService:(RCPublicServiceType)publicServiceType
                 publicServiceId:(NSString *)publicServiceId
                         success:(void (^)(void))successBlock
                           error:(void (^)(RCErrorCode status))errorBlock;

/*!
 *  \~chinese
 查询已关注的公众服务账号

 @return 公众服务信息 RCPublicServiceProfile 列表

 @remarks 公众号
 
 *  \~english
 Inquire about the public service accounts that you have followed.

 @ return Public Service Information RCPublicServiceProfile list.

 @ remarks official account.
 */
- (NSArray *)getPublicServiceList;

/*!
 *  \~chinese
 获取公众服务账号信息

 @param publicServiceType       公众服务账号的类型
 @param publicServiceId         公众服务的账号 ID
 @return                        公众服务账号的信息

 @discussion 此方法会从本地缓存中获取公众服务账号信息

 @remarks 公众号
 
 *  \~english
 Obtain public service account information.

 @param publicServiceType Type of public service account.
 @param publicServiceId Public service account ID.
 @ return information of public service account.

 @ discussion This method will get the public service account information from the local cache.

 @ remarks official account.
 */
- (RCPublicServiceProfile *)getPublicServiceProfile:(RCPublicServiceType)publicServiceType
                                    publicServiceId:(NSString *)publicServiceId;

/*!
 *  \~chinese
 获取公众服务账号信息

 @param targetId                        公众服务的账号 ID
 @param type                            公众服务账号的类型
 @param onSuccess                       获取成功的回调
 [serviceProfile:获取到的公众账号信息]
 @param onError                         获取失败的回调 [error:失败的错误码]

 @discussion 此方法会从服务器获取公众服务账号信息

 @remarks 公众号
 
 *  \~english
 Obtain public service account information.

 @param targetId Public service account ID.
 @param type Type of public service account.
 @param onSuccess Callback for successful getting
 [serviceProfile: obtained public account information].
 @param onError Callback for getting failure  [error: error code of failure].

 @ discussion This method will get the public service account information from the server.

 @ remarks official account.
 */
- (void)getPublicServiceProfile:(NSString *)targetId
               conversationType:(RCConversationType)type
                      onSuccess:(void (^)(RCPublicServiceProfile *serviceProfile))onSuccess
                        onError:(void (^)(RCErrorCode errorCode))onError;

/*!
 *  \~chinese
 获取公众服务使用的 WebView Controller

 @param URLString   准备打开的 URL
 @return            公众服务使用的 WebView Controller

 @discussion
 如果您选在用 WebView 打开 URL 连接，则您需要在 App 的 Info.plist 的 NSAppTransportSecurity 中增加
 NSAllowsArbitraryLoadsInWebContent 和 NSAllowsArbitraryLoads 字段，并在苹果审核的时候提供额外的说明。
 更多内容可以参考：https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW55

 @remarks 公众号
 
 *  \~english
 Get the WebView Controller used by the public service.

 @param URLString Ready to open URL.
 @ return WebView Controller used by the public service.

 @ discussion
 If you choose to open a URL connection with WebView, you shall add it to the NSAppTransportSecurity of App's Info.plist.
 NSAllowsArbitraryLoadsInWebContent and NSAllowsArbitraryLoads fields, and provide additional instructions during Apple's audit.
  For more information, please refer to https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW55.

 @ remarks official account.
 */
- (UIViewController *)getPublicServiceWebViewController:(NSString *)URLString;

@end

