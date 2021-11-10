//
//  RCEvaluateItem.h
//  RongIMLib
//
//  Created by litao on 16/4/29.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 客服评价对象
 */
@interface RCEvaluateItem : NSObject

/*!
 客服评价描述
 */
@property (nonatomic, copy) NSString *describe; // description

/*!
 客服评价星级，1 ~ 5 级
 */
@property (nonatomic) int value;
@end
