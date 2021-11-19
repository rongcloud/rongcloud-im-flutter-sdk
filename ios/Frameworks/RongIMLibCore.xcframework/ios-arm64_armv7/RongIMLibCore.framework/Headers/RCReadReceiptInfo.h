//
//  RCReadReceiptInfo.h
//  RongIMLib
//
//  Created by RongCloud on 16/8/29.
//  Copyright © 2016 RongCloud. All rights reserved.
//
#import "RCStatusDefine.h"
#import <Foundation/Foundation.h>

@interface RCReadReceiptInfo : NSObject

/*!
 *  \~chinese
 是否需要回执消息
 
 *  \~english
 Do you need a receipt message?
 */
@property (nonatomic, assign) BOOL isReceiptRequestMessage;

/**
 *  \~chinese
 是否已经发送回执
 
 *  \~english
 Whether a receipt has been sent
 */
@property (nonatomic, assign) BOOL hasRespond;

/*!
 *  \~chinese
 发送回执的用户 ID 列表
 
 *  \~english
 ID list of users who send receipts
 */
@property (nonatomic, strong) NSMutableDictionary *userIdList;

@end
