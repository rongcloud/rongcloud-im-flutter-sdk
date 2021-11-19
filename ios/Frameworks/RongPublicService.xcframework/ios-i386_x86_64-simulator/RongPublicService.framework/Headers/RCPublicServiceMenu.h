/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceMenu.h
//  Created by litao on 15/4/14.

#import "RCPublicServiceMenuItem.h"
#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 公众服务账号菜单类

 @discussion
 公众服务菜单类，其中包含若干数量的菜单项，每个菜单项可能还包含子菜单项。
 公众服务菜单的树状结构如下所示：
 Menu -> MenuItem1
         MenuItem2  -> MenuItem2.1
                       MenuItem2.2
         MenuItem3  -> MenuItem3.1
                       MenuItem3.2
                       MenuItem3.3
 
 *  \~english
 Public service account menu class.

 @ discussion
 A public service menu class that contains a number of menu items, each of which may also contain submenu items.
  The tree structure of the public service menu is as follows:
  Menu-> MenuItem1.
 MenuItem2-> MenuItem2.1.
 MenuItem2.2.
 MenuItem3-> MenuItem3.1.
 MenuItem3.2.
 MenuItem3.3.
 */
@interface RCPublicServiceMenu : NSObject

/*!
 *  \~chinese
 菜单中包含的所有菜单项 RCPublicServiceMenuItem 数组
 
 *  \~english
 RCPublicServiceMenuItem array of all menu items contained in the menu.
 */
@property (nonatomic, strong) NSArray <RCPublicServiceMenuItem *> *menuItems;

/*!
 *  \~chinese
 将公众服务菜单下的所有菜单项解码（已废弃，请勿使用）

 @param jsonDictionary  公众服务菜单项Json组成的数组

 @warning **已废弃，请勿使用。**
 
 *  \~english
 Decode all menu items under the public service menu (obsolete, please do not use).

 @param jsonDictionary An array of public service menu items Json.

 @ warning * * is obsolete, please do not use it. **
 */
- (void)decodeWithJsonDictionaryArray:(NSArray *)jsonDictionary __deprecated_msg("deprecated");

@end
