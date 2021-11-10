//
//  RCGroupReadReceiptInfoV2.h
//  RongIMLibCore
//
//  Created by 张改红 on 2021/3/9.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCGroupMessageReaderV2.h"
@interface RCGroupReadReceiptInfoV2 : NSObject
/**
 是否已经发送回执
 */
@property (nonatomic, assign) BOOL hasRespond;

/*!
 发送回执的用户 ID 列表
 */
@property (nonatomic, strong) NSArray <RCGroupMessageReaderV2 *> *readerList;

/**
 *  已读人数
 */
@property (nonatomic, assign) int readCount;

/**
 *  群内总人数
 */
@property (nonatomic, assign) int totalCount;

@end
