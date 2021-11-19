//
//  RCGroupReadReceiptInfoV2.h
//  RongIMLibCore
//
//  Created by RongCloud on 2021/3/9.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCGroupMessageReaderV2.h"
@interface RCGroupReadReceiptInfoV2 : NSObject
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
@property (nonatomic, strong) NSArray <RCGroupMessageReaderV2 *> *readerList;

/**
 *  \~chinese
 *  已读人数
 *
 *  \~english
 * Number of people read
 */
@property (nonatomic, assign) int readCount;

/**
 *  \~chinese
 *  群内总人数
 *
 *  \~english
 *  Total number of people in the group
 */
@property (nonatomic, assign) int totalCount;

@end
