//
//  RCFlutterViewFactory.h
//  Pods-Runner
//
//  Created by Sin on 2019/6/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterViewFactory : NSObject<FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messager;
@end

NS_ASSUME_NONNULL_END
