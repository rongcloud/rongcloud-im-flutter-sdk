//
//  RCUltraGroupClient.h
//  rongcloud_im_plugin
//
//  Created by zhangyifan on 2022/1/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCUltraGroupClient : NSObject

+ (instancetype)sharedClient;

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

- (void)setUltraGroupDelegate;

- (void)addFlutterChannel:(FlutterMethodChannel *_Nonnull)channel;

- (void)removeFlutterChannel;
@end

NS_ASSUME_NONNULL_END
