//
//  RCCustomerServiceDefine.h
//  RongCustomerService
//
//  Created by Qi on 2021/8/24.
//  Copyright © 2021 张改红. All rights reserved.
//

#ifndef RCCustomerServiceDefine_h
#define RCCustomerServiceDefine_h

/*!
 客服服务方式
 */
typedef NS_ENUM(NSUInteger, RCCSModeType) {
    /*!
     无客服服务
     */
    RC_CS_NoService = 0,

    /*!
     机器人服务
     */
    RC_CS_RobotOnly = 1,

    /*!
     人工服务
     */
    RC_CS_HumanOnly = 2,

    /*!
     机器人优先服务
     */
    RC_CS_RobotFirst = 3,
};

/*!
 客服评价时机
 */
typedef NS_ENUM(NSUInteger, RCCSEvaEntryPoint) {
    /*!
     离开客服评价
     */
    RCCSEvaLeave = 0,

    /*!
     在扩展中展示客户主动评价按钮，离开客服不评价
     */
    RCCSEvaExtention = 1,

    /*!
     无评价入口
     */
    RCCSEvaNone = 2,

    /*!
     坐席结束会话评价
     */
    RCCSEvaCSEnd = 3,
};

/*!
 客服留言类型
 */
typedef NS_ENUM(NSUInteger, RCCSLMType) {
    /*!
     本地 Native 页面留言
     */
    RCCSLMNative = 0,

    /*!
     web 页面留言
     */
    RCCSLMWeb = 1,
};

/*!
 客服问题解决状态
 */
typedef NS_ENUM(NSUInteger, RCCSResolveStatus) {
    /*!
     未解决
     */
    RCCSUnresolved = 0,

    /*!
     已解决
     */
    RCCSResolved = 1,

    /*!
     解决中
     */
    RCCSResolving = 2,
};

/*!
 客服评价类型
 */
typedef NS_ENUM(NSUInteger, RCCSEvaType) {
    /*!
     人工机器人分开评价
     */
    RCCSEvaSeparately = 0,

    /*!
     人工机器人统一评价
     */
    EVA_UNIFIED = 1,
};

#endif /* RCCustomerServiceDefine_h */
