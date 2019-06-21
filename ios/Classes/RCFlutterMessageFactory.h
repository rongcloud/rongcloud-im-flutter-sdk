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
+ (NSString *)message2String:(RCMessage *)message;
+ (NSString *)conversation2String:(RCConversation *)conversation;
@end

NS_ASSUME_NONNULL_END
