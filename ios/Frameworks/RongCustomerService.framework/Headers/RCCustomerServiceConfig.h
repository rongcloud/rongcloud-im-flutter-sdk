//
//  RCCustomerServiceConfig.h
//  RongIMLib
//
//  Created by litao on 16/2/25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCCSLeaveMessageItem.h"
#import "RCEvaluateItem.h"
#import "RCCustomerServiceDefine.h"

/*!
 客服配置对象
 */
@interface RCCustomerServiceConfig : NSObject
/*!
 是否被客服加为黑名单
 */
@property (nonatomic) BOOL isBlack;

/*!
 公司名称
 */
@property (nonatomic, copy) NSString *companyName;

/*!
 公司的 Url
 */
@property (nonatomic, copy) NSString *companyUrl;

/*!
 机器人会话是否不需要评价
 */
@property (nonatomic, assign) BOOL robotSessionNoEva;

/*!
 人工服务会话是否不需要评价
 */
@property (nonatomic, assign) BOOL humanSessionNoEva;

/*!
 人工服务的评价选项
 */
@property (nonatomic, strong) NSArray <RCEvaluateItem *> *humanEvaluateItems;

/*!
 客服无应答提示时间间隔
 */
@property (nonatomic) int adminTipTime;

/*!
 客服无应答提示内容
 */
@property (nonatomic, copy) NSString *adminTipWord;

/*!
 用户无应答提示时间间隔
 */
@property (nonatomic) int userTipTime;

/*!
 客服无应答提示内容
 */
@property (nonatomic, copy) NSString *userTipWord;

/*!
 弹出客服评价时机
 */
@property (nonatomic, assign) RCCSEvaEntryPoint evaEntryPoint;

/*!
 评价类型
 @discussion
 如果 evaType 为 RCCSEvaSeparately，发送机器人评价消息调用 RCIMClient 中 evaluateCustomerService: knownledgeId: robotValue: suggest: 方法；
 发送人工评价消息调用 RCIMClient 中
 evaluateCustomerService: dialogId: starValue: suggest: resolveStatus: tagText: extra: 方法。
 如果 evaType 为 EVA_UNIFIED，发送评价消息调用 RCIMClient 中
 evaluateCustomerService: dialogId: starValue: suggest: resolveStatus:
 */
@property (nonatomic, assign) RCCSEvaType evaType;

/*!
 是否显示解决状态:0.不显示；1.显示
 */
@property (nonatomic, assign) int reportResolveStatus;

/*!
 留言样式:0.跳转留言界面；1.跳转url留言。默认 0
 */
@property (nonatomic, assign) RCCSLMType leaveMessageType;

/*!
 是否支持地图发送：0.支持；1.不支持
 */
@property (nonatomic, assign) int disableLocation;

/*!
 自定义留言的 url
 */
@property (nonatomic, copy) NSString *leaveMessageWebUrl;

/*!
 默认留言样式
 */
@property (nonatomic, copy) NSArray<RCCSLeaveMessageItem *> *leaveMessageNativeInfo;

/*!
 通告内容
 */
@property (nonatomic, copy) NSString *announceMsg;

/*!
 点击通告对应的链接 url
 */
@property (nonatomic, copy) NSString *announceClickUrl;
@end
