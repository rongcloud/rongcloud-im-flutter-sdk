//
//  RCTagInfo.h
//  RongIMLib
//
//  Created by 张改红 on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 标签信息
 */
@interface RCTagInfo : NSObject
/*!
 标签 ID
 */
@property (nonatomic, copy) NSString *tagId;

/*!
 标签名称
 */
@property (nonatomic, copy)  NSString *tagName;

/*!
 该标签下的会话个数
 */
@property (nonatomic, assign) NSInteger count;

/*!
 标签创建时间
 */
@property (nonatomic, assign) long long timestamp;

/*!
 RCTagInfo 初始化方法

 @param  tagId    标签 id
 @param  tagName            标签名称
 */
- (instancetype)initWithTagInfo:(NSString *)tagId
                        tagName:(NSString *)tagName;
@end
