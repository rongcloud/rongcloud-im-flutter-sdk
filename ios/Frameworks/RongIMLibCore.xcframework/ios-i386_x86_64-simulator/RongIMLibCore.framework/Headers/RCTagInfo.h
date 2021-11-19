//
//  RCTagInfo.h
//  RongIMLib
//
//  Created by RongCloud on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 *  \~chinese
 标签信息
 
 *  \~english
 Tag information
 */
@interface RCTagInfo : NSObject
/*!
 *  \~chinese
 标签 ID
 
 *  \~english
 tag ID 
 */
@property (nonatomic, copy) NSString *tagId;

/*!
 *  \~chinese
 标签名称
 
 *  \~english
 Tag name
 */
@property (nonatomic, copy)  NSString *tagName;

/*!
 *  \~chinese
 该标签下的会话个数
 
 *  \~english
 The number of conversations under this tag
 */
@property (nonatomic, assign) NSInteger count;

/*!
 *  \~chinese
 标签创建时间
 
 *  \~english
 Tag creation time
 */
@property (nonatomic, assign) long long timestamp;

/*!
 *  \~chinese
 RCTagInfo 初始化方法

 @param  tagId    标签 id
 @param  tagName            标签名称
 
 *  \~english
 RCTagInfo initialization method.

 @ param tagId tag id.
 @ param tagName tag name.
 */
- (instancetype)initWithTagInfo:(NSString *)tagId
                        tagName:(NSString *)tagName;
@end
