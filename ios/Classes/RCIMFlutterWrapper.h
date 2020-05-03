//
//  RCIMFlutterWrapper.h
//  Pods-Runner
//
//  Created by Sin on 2019/6/5.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCIMFlutterWrapper : NSObject

+ (instancetype)sharedWrapper;
/*
 iOS可通过该接口向 Flutter 传递数据
 @discussion 如果是远程推送的数据，延时之后再调用该接口，防止 Flutter 尚未初始化就调用，导致 Flutter 无法接受数据
 */
- (void)sendDataToFlutter:(NSDictionary *)userInfo;
@end

NS_ASSUME_NONNULL_END

/*
 内部接口,开发者请勿调用
 */
@interface RCIMFlutterWrapper (Internal)

- (void)addFlutterChannel:(FlutterMethodChannel *_Nonnull)channel;
- (void)handleMethodCall:(FlutterMethodCall*_Nonnull)call result:(FlutterResult _Nonnull )result;

@end
