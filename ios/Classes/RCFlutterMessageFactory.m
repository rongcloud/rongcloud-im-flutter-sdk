//
//  RCFlutterMessageFactory.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/13.
//

#import "RCFlutterMessageFactory.h"

@implementation RCFlutterMessageFactory
+ (NSString *)message2String:(RCMessage *)message {
    NSDictionary *dic = [self message2Dic:message];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)conversation2String:(RCConversation *)conversation {
    NSDictionary *dic = [self conversation2Dic:conversation];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)chatRoomInfo2Dictionary:(RCChatRoomInfo *)chatRoomInfo {
    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    if(!chatRoomInfo) {
        return resultDic;
    }
    [resultDic setObject:chatRoomInfo.targetId forKey:@"targetId"];
    [resultDic setObject:@(chatRoomInfo.memberOrder) forKey:@"memberOrder"];
    [resultDic setObject:@(chatRoomInfo.totalMemberCount) forKey:@"totalMemeberCount"];
    
    NSMutableArray *memArr = [NSMutableArray new];
    for(RCChatRoomMemberInfo *mem in chatRoomInfo.memberInfoArray) {
        NSMutableDictionary *mDic = [NSMutableDictionary new];
        [mDic setObject:mem.userId forKey:@"userId"];
        [mDic setObject:@(mem.joinTime) forKey:@"joinTime"];
        [memArr addObject:mDic];
    }
    
    [resultDic setObject:memArr forKey:@"memberInfoList"];
    
    return resultDic;
}

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
    [dic setObject:message.messageUId?:@"" forKey:@"messageUId"];
    RCMessageContent *content = message.content;
    NSData *data = content.encode;
    NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [dic setObject:contentStr forKey:@"content"];
    return [dic copy];
}

+ (NSDictionary *)conversation2Dic:(RCConversation *)conversation {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(conversation.conversationType) forKey:@"conversationType"];
    [dic setObject:conversation.targetId forKey:@"targetId"];
    [dic setObject:@(conversation.unreadMessageCount) forKey:@"unreadMessageCount"];
    [dic setObject:@(conversation.receivedStatus) forKey:@"receivedStatus"];
    [dic setObject:@(conversation.sentStatus) forKey:@"sentStatus"];
    [dic setObject:@(conversation.sentTime) forKey:@"sentTime"];
    [dic setObject:@(conversation.isTop) forKey:@"isTop"];
    [dic setObject:conversation.objectName forKey:@"objectName"];
    [dic setObject:conversation.senderUserId forKey:@"senderUserId"];
    [dic setObject:@(conversation.lastestMessageId) forKey:@"latestMessageId"];
    RCMessageContent *content = conversation.lastestMessage;
    NSData *data = content.encode;
    NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [dic setObject:contentStr forKey:@"content"];
    return [dic copy];
}
@end
