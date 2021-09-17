//
//  RCDLocationMessage.h
//  Runner
//
//  Created by 孙浩 on 2021/9/6.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 地理位置消息的类型名
 */
#define RCDLocationMessageTypeIdentifier @"RCD:LBSMsg"

/*!
 地理位置消息类

 @discussion 地理位置消息类，此消息会进行存储并计入未读消息数。
 
 @remarks 内容类消息
 */
@interface RCDLocationMessage : RCMessageContent <NSCoding>

/*!
 地理位置的二维坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D location;

/*!
 地理位置的名称
 */
@property (nonatomic, copy) NSString *locationName;

/*!
 地理位置的缩略图
 */
@property (nonatomic, strong) UIImage *thumbnailImage;

/*!
 初始化地理位置消息

 @param image 地理位置的缩略图
 @param location 地理位置的二维坐标
 @param locationName 地理位置的名称
 @return 地理位置消息的对象
 */
+ (instancetype)messageWithLocationImage:(UIImage *)image
                                location:(CLLocationCoordinate2D)location
                            locationName:(NSString *)locationName;

@end

NS_ASSUME_NONNULL_END
