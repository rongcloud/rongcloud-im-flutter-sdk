//
//  RCFlutterMessageFactory.h
//  Pods-Runner
//
//  Created by Sin on 2019/6/13.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCFlutterMessageFactory : NSObject
+ (NSString *)message2String:(RCMessage *)message;
+ (NSString *)conversation2String:(RCConversation *)conversation;
+ (NSDictionary *)chatRoomInfo2Dictionary:(RCChatRoomInfo *)chatRoomInfo;
+ (RCMessage *)dic2Message:(NSDictionary *)msgDic;
+ (NSString *)messageContent2String:(RCMessageContent *)content;
+ (NSString *)typingStatus2String:(RCUserTypingStatus *)status;
+ (NSString *)searchConversationResult2String:(RCSearchConversationResult *)result;
@end

NS_ASSUME_NONNULL_END
