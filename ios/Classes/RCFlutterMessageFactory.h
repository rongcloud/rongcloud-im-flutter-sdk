//
//  RCFlutterMessageFactory.h
//  Pods-Runner
//
//  Created by Sin on 2019/6/13.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterMessageFactory : NSObject

+ (NSDictionary *)message2Dic:(RCMessage *)message;
+ (NSString *)message2String:(RCMessage *)message;
@end

NS_ASSUME_NONNULL_END
