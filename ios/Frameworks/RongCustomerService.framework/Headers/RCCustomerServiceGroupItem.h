//
//  RCCustomerGroupItem.h
//  RongIMLib
//
//  Created by 张改红 on 16/7/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 客服分组对象
 */
@interface RCCustomerServiceGroupItem : NSObject

/*!
 客服分组 id
 */
@property (nonatomic, copy) NSString *groupId;

/*!
 客服分组名称
 */
@property (nonatomic, copy) NSString *name;

/*!
 该客服分组是否在线，YES 表示在线， NO 表示不在线
 */
@property (nonatomic, assign) BOOL online;
@end
