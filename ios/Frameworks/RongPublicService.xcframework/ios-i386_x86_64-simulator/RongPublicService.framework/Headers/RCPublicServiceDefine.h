//
//  RCPublicServiceDefine.h
//  RongPublicService
//
//  Created by Qi on 2021/8/24.
//  Copyright © 2021 张改红. All rights reserved.
//

#ifndef RCPublicServiceDefine_h
#define RCPublicServiceDefine_h

#pragma mark RCPublicServiceMenuItemType - 公众服务菜单类型
/*!
 公众服务菜单类型
 */
typedef NS_ENUM(NSUInteger, RCPublicServiceMenuItemType) {
    /*!
     包含子菜单的一组菜单
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_GROUP = 0,

    /*!
     包含查看事件的菜单
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_VIEW = 1,

    /*!
     包含点击事件的菜单
     */
    RC_PUBLIC_SERVICE_MENU_ITEM_CLICK = 2,
};

#endif /* RCPublicServiceDefine_h */
