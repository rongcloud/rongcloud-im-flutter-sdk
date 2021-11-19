/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCUserInfo.h
//  Created by Heq.Shinoda on 14-6-16.

#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 用户信息类
 
 *  \~english
 User information class 
 */
@interface RCUserInfo : NSObject <NSCoding>

/*!
 *  \~chinese
 用户 ID
 
 *  \~english
 User ID
 */
@property (nonatomic, copy) NSString *userId;

/*!
 *  \~chinese
 用户名称
 
 *  \~english
 User name
 */
@property (nonatomic, copy) NSString *name;

/*!
 *  \~chinese
 用户头像的 URL
 
 *  \~english
 The URL of the user's portrait
 */
@property (nonatomic, copy) NSString *portraitUri;

/**
 *  \~chinese
 用户信息附加字段
 
 *  \~english
 Additional fields of user information
 */
@property (nonatomic, copy) NSString *extra;

/*!
 *  \~chinese
 用户信息的初始化方法

 @param userId      用户 ID
 @param username    用户名称
 @param portrait    用户头像的 URL
 @return            用户信息对象
 
 *  \~english
 Initialization method of user information.

 @param userId User ID.
 @param username User name.
 @param portrait The URL of the user's portrait.
 @ return user Information object.
 */
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)username portrait:(NSString *)portrait;

@end
