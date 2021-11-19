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

/*!
 *  \~chinese
 公众服务的菜单项
 
 *  \~english
 Menu items for public service. 
 */
@interface RCPublicServiceMenuItem : NSObject

/*!
 *  \~chinese
 菜单的 ID
 
 *  \~english
 ID of the menu
 */
@property (nonatomic, copy) NSString *id;

/*!
 *  \~chinese
 菜单的标题
 
 *  \~english
 The title of the menu
 */
@property (nonatomic, copy) NSString *name;

/*!
 *  \~chinese
 菜单的 URL 链接
 
 *  \~english
 URL link to menus
 */
@property (nonatomic, copy) NSString *url;

/*!
 *  \~chinese
 菜单的类型
 
 *  \~english
 Type of menu
 */
@property (nonatomic, assign) RCPublicServiceMenuItemType type;

/*!
 *  \~chinese
 菜单中的子菜单

 @discussion 子菜单为RCPublicServiceMenuItem的数组
 
 *  \~english
 Submenus in the menu.

 @ discussion  The submenu is an array of RCPublicServiceMenuItem.
 */
@property (nonatomic, strong) NSArray <RCPublicServiceMenuItem *> *subMenuItems;

/*!
 *  \~chinese
 将菜单项的json数组解码（已废弃，请勿使用）

 @param jsonArray   由菜单项原始Json数据组成的数组
 @return            公众服务菜单项RCPublicServiceMenuItem的数组

 @warning **已废弃，请勿使用。**
 
 *  \~english
 Decode the json array of menu items (obsolete, do not use).

 @param jsonArray An array of raw Json data for menu items.
 @ return an array of public service menu items RCPublicServiceMenuItem.

 @ warning * * is obsolete, please do not use it. **
 */
+ (NSArray *)menuItemsFromJsonArray:(NSArray *)jsonArray __deprecated_msg("deprecated");

@end
