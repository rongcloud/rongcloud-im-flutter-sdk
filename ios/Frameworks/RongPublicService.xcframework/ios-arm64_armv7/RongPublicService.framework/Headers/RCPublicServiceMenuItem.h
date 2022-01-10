/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceMenuItem.h
//  Created by litao on 15/4/14.

#import <RongIMLibCore/RongIMLibCore.h>
#import <Foundation/Foundation.h>
#import "RCPublicServiceDefine.h"

/*!
 公众服务的菜单项
 */
@interface RCPublicServiceMenuItem : NSObject

/*!
 菜单的 ID
 */
@property (nonatomic, copy) NSString *id;

/*!
 菜单的标题
 */
@property (nonatomic, copy) NSString *name;

/*!
 菜单的 URL 链接
 */
@property (nonatomic, copy) NSString *url;

/*!
 菜单的类型
 */
@property (nonatomic) RCPublicServiceMenuItemType type;

/*!
 菜单中的子菜单

 @discussion 子菜单为RCPublicServiceMenuItem的数组
 */
@property (nonatomic, strong) NSArray <RCPublicServiceMenuItem *> *subMenuItems;

/*!
 将菜单项的json数组解码（已废弃，请勿使用）

 @param jsonArray   由菜单项原始Json数据组成的数组
 @return            公众服务菜单项RCPublicServiceMenuItem的数组

 @warning **已废弃，请勿使用。**
 */
+ (NSArray *)menuItemsFromJsonArray:(NSArray *)jsonArray __deprecated_msg("已废弃，请勿使用。");

@end
