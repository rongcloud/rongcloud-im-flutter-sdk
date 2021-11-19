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
 *  \~chinese
 群组信息类
 
 *  \~english
 Group information class
 */
@interface RCGroup : NSObject <NSCoding>

/*!
 *  \~chinese
 群组 ID
 
 *  \~english
 Group ID
 */
@property (nonatomic, copy) NSString *groupId;

/*!
 *  \~chinese
 群组名称
 
 *  \~english
 Group name
 */
@property (nonatomic, copy) NSString *groupName;

/*!
 *  \~chinese
 群组头像的 URL
 
 *  \~english
 URL of group portrait
 */
@property (nonatomic, copy) NSString *portraitUri;

/*!
 *  \~chinese
 群组信息的初始化方法

 @param groupId         群组 ID
 @param groupName       群组名称
 @param portraitUri     群组头像的 URL
 @return                群组信息对象
 
 *  \~english
 Initialization method of group information.

 @param groupId Group ID.
 @param groupName Group name.
 @param portraitUri URL of group portrait.
 @ return Group Information object.
 */
- (instancetype)initWithGroupId:(NSString *)groupId groupName:(NSString *)groupName portraitUri:(NSString *)portraitUri;

@end
