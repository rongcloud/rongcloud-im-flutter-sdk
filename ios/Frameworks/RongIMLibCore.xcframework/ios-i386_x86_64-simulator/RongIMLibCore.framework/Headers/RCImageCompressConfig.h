//
//  RCImageCompressConfig.h
//  RongIMLibCore
//
//  Created by liyan on 2021/3/9.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCImageCompressConfig : NSObject

/*!
 *  \~chinese
 缩略图最大尺寸
 
 *  \~english
 Maximum size of thumbnail
 */
@property (nonatomic, assign) CGFloat maxSize;

/*!
 *  \~chinese
 缩略图最小尺寸
 
 *  \~english
 Minimum size of thumbnail
 */
@property (nonatomic, assign) CGFloat minSize;

/*!
 *  \~chinese
 缩略图质量压缩比
 * 
 *  \~english
 Thumbnail mass compression ratio
 */
@property (nonatomic, assign) CGFloat quality;

@end

NS_ASSUME_NONNULL_END
