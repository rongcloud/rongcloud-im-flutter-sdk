/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceProfile.h
//  Created by litao on 15/4/9.

#import "RCPublicServiceMenu.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 公众服务账号信息
 
 *  \~english
 Public service account information 
 */
@interface RCPublicServiceProfile : NSObject

/*!
 *  \~chinese
 公众服务账号的名称
 
 *  \~english
 The name of the public service account.
 */
@property (nonatomic, copy) NSString *name;

/*!
 *  \~chinese
 公众服务账号的描述
 
 *  \~english
 Description of public service account.
 */
@property (nonatomic, copy) NSString *introduction;

/*!
 *  \~chinese
 公众服务账号的 ID
 
 *  \~english
 ID of the public service account.
 */
@property (nonatomic, copy) NSString *publicServiceId;

/*!
 *  \~chinese
 公众服务账号头像 URL
 
 *  \~english
 Profile image URL of public service account
 */
@property (nonatomic, copy) NSString *portraitUrl;

/*!
 *  \~chinese
 公众服务账号的所有者

 @discussion 当前版本暂不支持。
 
 *  \~english
 The owner of the public service account.

 @ discussion it is not supported in the current version
 */
@property (nonatomic, copy) NSString *owner;

/*!
 *  \~chinese
 公众服务账号所有者的 URL

 @discussion 当前版本暂不支持。
 
 *  \~english
 URL of the owner of the public service account.

 @ discussion It is not supported in the current version.
 */
@property (nonatomic, copy) NSString *ownerUrl;

/*!
 *  \~chinese
 公众服务账号的联系电话

 @discussion 当前版本暂不支持。
 
 *  \~english
 The contact number of the public service account.

 @ discussion It is not supported in the current version.
 */
@property (nonatomic, copy) NSString *publicServiceTel;

/*!
 *  \~chinese
 公众服务账号历史消息

 @discussion 当前版本暂不支持。
 
 *  \~english
 Historical news of public service account.

 @ discussion It is not supported in the current version.
 */
@property (nonatomic, copy) NSString *histroyMsgUrl;

/*!
 *  \~chinese
 公众服务账号地理位置

 @discussion 当前版本暂不支持。
 
 *  \~english
 Geographical location of public service account.

 @ discussion It is not supported in the current version.
 */
@property (nonatomic, strong) CLLocation *location;

/*!
 *  \~chinese
 公众服务账号经营范围

 @discussion 当前版本暂不支持。
 
 *  \~english
 Business scope of public service account.

 @ discussion It is not supported in the current version.
 */
@property (nonatomic, copy) NSString *scope;

/*!
 *  \~chinese
 公众服务账号类型
 
 *  \~english
 Type of public service account
 */
@property (nonatomic) RCPublicServiceType publicServiceType;

/*!
 *  \~chinese
 是否关注该公众服务账号
 
 *  \~english
 Whether to pay attention to the public service account
 */
@property (nonatomic, getter=isFollowed) BOOL followed;

/*!
 *  \~chinese
 公众服务账号菜单
 
 *  \~english
 Public service account menu
 */
@property (nonatomic, strong) RCPublicServiceMenu *menu;

/*!
 *  \~chinese
 公众服务账号的全局属性

 @discussion 此公众服务账号是否设置为所有用户均关注。
 
 *  \~english
 Global attributes of public service accounts.

 @ discussion Whether the public service account is set to be followed by all users.
 */
@property (nonatomic, getter=isGlobal) BOOL global;

/*!
 *  \~chinese
 公众服务账号信息的 json 数据
 
 *  \~english
 Json data of public service account information.
 */
@property (nonatomic, strong) NSDictionary *jsonDict;

/**
 *  \~chinese
 是否禁用公众号菜单
 
 *  \~english
 Whether to disable the official account menu
 */
@property (nonatomic, assign) BOOL disableMenu;

/**
 *  \~chinese
 是否禁用输入框
 
 *  \~english
 Whether to disable the input box
 */
@property (nonatomic, assign) BOOL disableInput;

/*!
 *  \~chinese
 初始化公众服务账号信息

 @param jsonContent    公众账号信息的 json 数据
 
 *  \~english
 Initialize public service account information.

 @param jsonContent  Json data of public account information
 */
- (void)initContent:(NSString *)jsonContent;

@end
