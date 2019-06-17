//
//  RCFlutterMessageFactory.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/13.
//

#import "RCFlutterMessageFactory.h"

@implementation RCFlutterMessageFactory
+ (NSDictionary *)message2Dic:(RCMessage *)message {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(message.conversationType) forKey:@"conversationType"];
    [dic setObject:message.targetId forKey:@"targetId"];
    [dic setObject:@(message.messageId) forKey:@"messageId"];
    [dic setObject:@(message.messageDirection) forKey:@"messageDirection"];
    [dic setObject:message.senderUserId forKey:@"senderUserId"];
    [dic setObject:@(message.receivedStatus) forKey:@"receivedStatus"];
    [dic setObject:@(message.sentStatus) forKey:@"sentStatus"];
    [dic setObject:@(message.sentTime) forKey:@"sentTime"];
    [dic setObject:message.objectName forKey:@"objectName"];
    [dic setObject:message.messageUId forKey:@"messageUId"];
    RCMessageContent *content = message.content;
    NSData *data = content.encode;
    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [dic setObject:contentDic forKey:@"content"];
    return [dic copy];
}

+ (NSString *)message2String:(RCMessage *)message {
    NSDictionary *dic = [self message2Dic:message];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
