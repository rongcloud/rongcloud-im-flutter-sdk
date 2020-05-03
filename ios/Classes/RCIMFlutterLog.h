//
//  RCIMFlutterLog.h
//  Pods-Runner
//
//  Created by Sin on 2019/7/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define RCLog RCIMFlutterLog

@interface RCIMFlutterLog : NSObject
+ (void)i:(NSString *)content;
+ (void)e:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
