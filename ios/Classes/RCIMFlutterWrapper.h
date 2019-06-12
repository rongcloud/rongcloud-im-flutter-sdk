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
- (void)addFlutterChannel:(FlutterMethodChannel *)channel;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@end

NS_ASSUME_NONNULL_END
