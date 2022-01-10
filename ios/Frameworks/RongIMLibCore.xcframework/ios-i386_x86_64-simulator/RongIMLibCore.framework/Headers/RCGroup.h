/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCGroup.h
//  Created by Heq.Shinoda on 14-9-6.

#import <Foundation/Foundation.h>

/*!
 群组信息类
 */
@interface RCGroup : NSObject <NSCoding>

/*!
 群组 ID
 */
@property (nonatomic, copy) NSString *groupId;

/*!
 群组名称
 */
@property (nonatomic, copy) NSString *groupName;

/*!
 群组头像的 URL
 */
@property (nonatomic, copy) NSString *portraitUri;

/*!
 群组信息的初始化方法

 @param groupId         群组 ID
 @param groupName       群组名称
 @param portraitUri     群组头像的 URL
 @return                群组信息对象
 */
- (instancetype)initWithGroupId:(NSString *)groupId groupName:(NSString *)groupName portraitUri:(NSString *)portraitUri;

@end
