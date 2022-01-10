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
 公众服务账号信息
 */
@interface RCPublicServiceProfile : NSObject

/*!
 公众服务账号的名称
 */
@property (nonatomic, copy) NSString *name;

/*!
 公众服务账号的描述
 */
@property (nonatomic, copy) NSString *introduction;

/*!
 公众服务账号的 ID
 */
@property (nonatomic, copy) NSString *publicServiceId;

/*!
 公众服务账号头像 URL
 */
@property (nonatomic, copy) NSString *portraitUrl;

/*!
 公众服务账号的所有者

 @discussion 当前版本暂不支持。
 */
@property (nonatomic, copy) NSString *owner;

/*!
 公众服务账号所有者的 URL

 @discussion 当前版本暂不支持。
 */
@property (nonatomic, copy) NSString *ownerUrl;

/*!
 公众服务账号的联系电话

 @discussion 当前版本暂不支持。
 */
@property (nonatomic, copy) NSString *publicServiceTel;

/*!
 公众服务账号历史消息

 @discussion 当前版本暂不支持。
 */
@property (nonatomic, copy) NSString *histroyMsgUrl;

/*!
 公众服务账号地理位置

 @discussion 当前版本暂不支持。
 */
@property (nonatomic, strong) CLLocation *location;

/*!
 公众服务账号经营范围

 @discussion 当前版本暂不支持。
 */
@property (nonatomic, copy) NSString *scope;

/*!
 公众服务账号类型
 */
@property (nonatomic) RCPublicServiceType publicServiceType;

/*!
 是否关注该公众服务账号
 */
@property (nonatomic, getter=isFollowed) BOOL followed;

/*!
 公众服务账号菜单
 */
@property (nonatomic, strong) RCPublicServiceMenu *menu;

/*!
 公众服务账号的全局属性

 @discussion 此公众服务账号是否设置为所有用户均关注。
 */
@property (nonatomic, getter=isGlobal) BOOL global;

/*!
 公众服务账号信息的 json 数据
 */
@property (nonatomic, strong) NSDictionary *jsonDict;

/**
 是否禁用公众号菜单
 */
@property (nonatomic, assign) BOOL disableMenu;

/**
 是否禁用输入框
 */
@property (nonatomic, assign) BOOL disableInput;

/*!
 初始化公众服务账号信息

 @param jsonContent    公众账号信息的 json 数据
 */
- (void)initContent:(NSString *)jsonContent;

@end
