//
//  RCFlutterMessageFactory.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/13.
//

#import "RCFlutterMessageFactory.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@implementation RCFlutterMessageFactory
+ (NSString *)message2String:(RCMessage *)message {
    if (message == nil) {
        return nil;
    }
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
    if(!message) {
        return [NSDictionary new];
    }
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(message.conversationType) forKey:@"conversationType"];
    [dic setObject:message.targetId forKey:@"targetId"];
    [dic setObject:@(message.messageId) forKey:@"messageId"];
    [dic setObject:message.channelId?:@"" forKey:@"channelId"];
    [dic setObject:@(message.messageDirection) forKey:@"messageDirection"];
    [dic setObject:message.senderUserId forKey:@"senderUserId"];
    [dic setObject:@(message.receivedStatus) forKey:@"receivedStatus"];
    [dic setObject:@(message.sentStatus) forKey:@"sentStatus"];
    [dic setObject:@(message.sentTime) forKey:@"sentTime"];
    [dic setObject:message.objectName forKey:@"objectName"];
    [dic setObject:message.messageUId?:@"" forKey:@"messageUId"];
    [dic setObject:message.extra?:@"" forKey:@"extra"];
    RCReadReceiptInfo *readReceiptInfo = message.readReceiptInfo;
    NSMutableDictionary *readReceiptDict = [NSMutableDictionary new];
    [readReceiptDict setObject:@(readReceiptInfo.hasRespond) forKey:@"hasRespond"];
    [readReceiptDict setObject:@(readReceiptInfo.isReceiptRequestMessage) forKey:@"isReceiptRequestMessage"];
    if (readReceiptInfo.userIdList) {
        [readReceiptDict setObject:readReceiptInfo.userIdList forKey:@"userIdList"];
    }
    [dic setObject:readReceiptDict forKey:@"readReceiptInfo"];
    RCMessageConfig *messageConfig = message.messageConfig;
    NSMutableDictionary *messageConfigDict = [NSMutableDictionary new];
    [messageConfigDict setObject:@(messageConfig.disableNotification) forKey:@"disableNotification"];
    [dic setObject:messageConfigDict forKey:@"messageConfig"];
    
    RCMessagePushConfig *messagePushConfig = message.messagePushConfig;
    if (messagePushConfig) {
        NSMutableDictionary *messagePushConfigDict = [NSMutableDictionary new];
        [messagePushConfigDict setObject:messagePushConfig.pushTitle?:@"" forKey:@"pushTitle"];
        [messagePushConfigDict setObject:messagePushConfig.pushContent?:@"" forKey:@"pushContent"];
        [messagePushConfigDict setObject:messagePushConfig.pushData?:@"" forKey:@"pushData"];
        [messagePushConfigDict setObject:@(messagePushConfig.forceShowDetailContent) forKey:@"forceShowDetailContent"];
        [messagePushConfigDict setObject:messagePushConfig.templateId?:@"" forKey:@"templateId"];
        [messagePushConfigDict setObject:@(messagePushConfig.disablePushTitle) forKey:@"disablePushTitle"];

        
        if (messagePushConfig.iOSConfig) {
            NSMutableDictionary *iOSConfigDict = [NSMutableDictionary new];
            [iOSConfigDict setObject:messagePushConfig.iOSConfig.threadId?:@"" forKey:@"thread_id"];
            [iOSConfigDict setObject:messagePushConfig.iOSConfig.apnsCollapseId?:@"" forKey:@"apns_collapse_id"];
            [messagePushConfigDict setObject:iOSConfigDict forKey:@"iOSConfig"];
        }
        
        if (messagePushConfig.androidConfig) {
            NSMutableDictionary *androidConfigDict = [NSMutableDictionary new];
            [androidConfigDict setObject:messagePushConfig.androidConfig.notificationId?:@"" forKey:@"notificationId"];
            [androidConfigDict setObject:messagePushConfig.androidConfig.channelIdMi?:@"" forKey:@"channelIdMi"];
            [androidConfigDict setObject:messagePushConfig.androidConfig.channelIdHW?:@"" forKey:@"channelIdHW"];
            [androidConfigDict setObject:messagePushConfig.androidConfig.channelIdOPPO?:@"" forKey:@"channelIdOPPO"];
            [androidConfigDict setObject:messagePushConfig.androidConfig.typeVivo?:@"" forKey:@"typeVivo"];
            [messagePushConfigDict setObject:androidConfigDict forKey:@"androidConfig"];
        }
        [dic setObject:messagePushConfigDict forKey:@"messagePushConfig"];
    }
    
    RCMessageContent *content = message.content;
    content = [self convertLocalPathIfNeed:content];
    if ([content isKindOfClass:[RCFileMessage class]]) {
        content = [self converFileMessage:content];
    } else if ([content isKindOfClass:[RCReferenceMessage class]]) {
        content = [self converReferenceMessage:content];
    }
    if ([content isKindOfClass:[RCPublicServiceCommandMessage class]]) {
        if (((RCPublicServiceCommandMessage *)content).command) {
            NSData *data = content.encode;
            NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [dic setObject:contentStr forKey:@"content"];
        } else {
            [dic setObject:@"" forKey:@"content"];
        }
    } else {
        if ([content isKindOfClass:[RCFileMessage class]]) {
            content = [self converFileMessage:content];
        } else if ([content isKindOfClass:[RCReferenceMessage class]]) {
            content = [self converReferenceMessage:content];
        }
        NSData *data = content.encode;
        NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [dic setObject:contentStr forKey:@"content"];
    }
    [dic setObject:@(message.canIncludeExpansion) forKey:@"canIncludeExpansion"];
    if (message.expansionDic) {
        [dic setObject:message.expansionDic forKey:@"expansionDic"];
    }
    return [dic copy];
}

+ (RCMessageContent *)converFileMessage:(RCMessageContent *)content {
    if([content isKindOfClass:[RCMediaMessageContent class]]) {
        RCFileMessage *msg = (RCFileMessage *)content;
        msg.name = msg.name?:@"";
        msg.localPath = msg.localPath?:@"";
    }
    return content;
}

+ (RCMessageContent *)converReferenceMessage:(RCMessageContent *)content {
    RCReferenceMessage *msg = (RCReferenceMessage *)content;
    RCMessageContent *msgContent = msg.referMsg;
    if ([msgContent isKindOfClass:[RCFileMessage class]]) {
        msgContent = [self converFileMessage:msgContent];
        msg.referMsg = msgContent;
    }
    return msg;
}

+ (RCMessageContent *)convertLocalPathIfNeed:(RCMessageContent *)content {
    if([content isKindOfClass:[RCMediaMessageContent class]]) {
        RCMediaMessageContent *msg = (RCMediaMessageContent *)content;
        if ([RCUtilities isLocalPath:msg.localPath]) {
            msg.localPath = [RCUtilities getCorrectedFilePath:msg.localPath];
        }
        content = msg;
    }
    return content;
}

+ (NSDictionary *)conversation2Dic:(RCConversation *)conversation {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(conversation.conversationType) forKey:@"conversationType"];
    [dic setObject:conversation.targetId forKey:@"targetId"];
    [dic setObject:conversation.channelId forKey:@"channelId"];
    [dic setObject:@(conversation.unreadMessageCount) forKey:@"unreadMessageCount"];
    [dic setObject:@(conversation.receivedStatus) forKey:@"receivedStatus"];
    [dic setObject:@(conversation.sentStatus) forKey:@"sentStatus"];
    [dic setObject:@(conversation.sentTime) forKey:@"sentTime"];
    [dic setObject:@(conversation.isTop) forKey:@"isTop"];
    [dic setObject:conversation.objectName forKey:@"objectName"];
    [dic setObject:conversation.senderUserId forKey:@"senderUserId"];
    [dic setObject:@(conversation.lastestMessageId) forKey:@"latestMessageId"];
    [dic setObject:@(conversation.mentionedCount) forKey:@"mentionedCount"];
    [dic setObject:conversation.draft forKey:@"draft"];
    [dic setObject:@(conversation.blockStatus) forKey:@"blockStatus"];
    [dic setObject:@(conversation.receivedTime) forKey:@"receivedTime"];
    [dic setObject:@(conversation.lastestMessageDirection) forKey:@"lastestMessageDirection"];
    [dic setObject:conversation.lastestMessageUId forKey:@"lastestMessageUId"];
    [dic setObject:@(conversation.hasUnreadMentioned) forKey:@"hasUnreadMentioned"];

    RCMessageContent *content = conversation.lastestMessage;
    content = [self convertLocalPathIfNeed:content];
    if ([content isKindOfClass:[RCFileMessage class]]) {
        content = [self converFileMessage:content];
    } else if ([content isKindOfClass:[RCReferenceMessage class]]) {
        content = [self converReferenceMessage:content];
    }
    NSData *data = content.encode;
    NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [dic setObject:contentStr forKey:@"content"];
    return [dic copy];
}

+ (RCMessage *)dic2Message:(NSDictionary *)msgDic {
    RCMessage *message = [[RCMessage alloc] init];
    message.conversationType = [msgDic[@"conversationType"] integerValue];
    message.targetId = msgDic[@"targetId"];
    message.channelId = msgDic[@"channelId"];
    if (msgDic[@"messageId"] && ![msgDic[@"messageId"] isKindOfClass:[NSNull class]]) {
        message.messageId = [msgDic[@"messageId"] integerValue];
    }
    if (msgDic[@"messageDirection"] && ![msgDic[@"messageDirection"] isKindOfClass:[NSNull class]]) {
        message.messageDirection = [msgDic[@"messageDirection"] integerValue];
    }
    message.senderUserId = msgDic[@"senderUserId"];
    if (msgDic[@"receivedStatus"] && ![msgDic[@"receivedStatus"] isKindOfClass:[NSNull class]]) {
        message.receivedStatus = [msgDic[@"receivedStatus"] integerValue];
    }
    if (msgDic[@"sentStatus"] && ![msgDic[@"sentStatus"] isKindOfClass:[NSNull class]]) {
        message.sentStatus = [msgDic[@"sentStatus"] integerValue];
    }
    if (msgDic[@"sentTime"] && ![msgDic[@"sentTime"] isKindOfClass:[NSNull class]]) {
        message.sentTime = [msgDic[@"sentTime"] integerValue];
    }
    message.objectName = msgDic[@"objectName"];
    message.messageUId = msgDic[@"messageUId"];
    
    NSString *contentStr = msgDic[@"content"];
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:message.objectName];
    
    RCMessageContent *content = nil;
    if([message.objectName isEqualToString:RCVoiceMessageTypeIdentifier]) {
        content = [self getVoiceMessage:data];
    } else {
        content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
    }
    message.content = content;
    if (msgDic[@"canIncludeExpansion"] && ![msgDic[@"canIncludeExpansion"] isKindOfClass:[NSNull class]]) {
        message.canIncludeExpansion = [msgDic[@"canIncludeExpansion"] boolValue];
    }
    if (msgDic[@"expansionDic"] && ![msgDic[@"expansionDic"] isKindOfClass:[NSNull class]]) {
        message.expansionDic = msgDic[@"expansionDic"];
    }
    NSDictionary *messageConfig = msgDic[@"messageConfig"];
    if (messageConfig[@"disableNotification"] && ![messageConfig[@"disableNotification"] isKindOfClass:[NSNull class]]) {
        message.messageConfig.disableNotification = [messageConfig[@"disableNotification"] boolValue];
    }
    NSDictionary *messagePushConfig = msgDic[@"messagePushConfig"];
    if (messagePushConfig) {
        message.messagePushConfig.pushTitle = messagePushConfig[@"pushTitle"];
        message.messagePushConfig.pushContent = messagePushConfig[@"pushContent"];
        message.messagePushConfig.pushData = messagePushConfig[@"pushData"];
        message.messagePushConfig.templateId = messagePushConfig[@"templateId"];
        message.messagePushConfig.disablePushTitle = [messagePushConfig[@"disablePushTitle"] boolValue];
        if (messagePushConfig[@"forceShowDetailContent"] && ![messagePushConfig[@"forceShowDetailContent"] isKindOfClass:[NSNull class]]) {
            message.messagePushConfig.forceShowDetailContent = [messagePushConfig[@"forceShowDetailContent"] boolValue];
        }
        if (messagePushConfig[@"iOSConfig"]) {
            NSDictionary *iOSConfigDict = messagePushConfig[@"iOSConfig"];
            message.messagePushConfig.iOSConfig.threadId = iOSConfigDict[@"thread_id"];
            message.messagePushConfig.iOSConfig.apnsCollapseId = iOSConfigDict[@"apns_collapse_id"];
        }
        if (messagePushConfig[@"androidConfig"]) {
            NSDictionary *androidConfigDict = messagePushConfig[@"androidConfig"];
            message.messagePushConfig.androidConfig.notificationId = androidConfigDict[@"notificationId"];
            message.messagePushConfig.androidConfig.channelIdMi = androidConfigDict[@"channelIdMi"];
            message.messagePushConfig.androidConfig.channelIdHW = androidConfigDict[@"channelIdHW"];
            message.messagePushConfig.androidConfig.channelIdOPPO = androidConfigDict[@"channelIdOPPO"];
            message.messagePushConfig.androidConfig.typeVivo = androidConfigDict[@"typeVivo"];
        }
    }
    
    NSDictionary *readReceiptInfo = msgDic[@"readReceiptInfo"];
    if (readReceiptInfo[@"isReceiptRequestMessage"] && ![readReceiptInfo[@"isReceiptRequestMessage"] isKindOfClass:[NSNull class]]) {
        message.readReceiptInfo.isReceiptRequestMessage = [readReceiptInfo[@"isReceiptRequestMessage"] boolValue];
    }
    if (readReceiptInfo[@"hasRespond"] && ![readReceiptInfo[@"hasRespond"] isKindOfClass:[NSNull class]]) {
        message.readReceiptInfo.isReceiptRequestMessage = [readReceiptInfo[@"hasRespond"] boolValue];
    }
    if (readReceiptInfo[@"userIdList"] && ![readReceiptInfo[@"userIdList"] isKindOfClass:[NSNull class]]) {
        message.readReceiptInfo.userIdList = readReceiptInfo[@"userIdList"];
    }
    
    return message;
}

+ (NSString *)messageContent2String:(RCMessageContent *)content {
    if (!content) {
        return @"";
    }
    if ([content isKindOfClass:[RCFileMessage class]]) {
        content = [self converFileMessage:content];
    } else if ([content isKindOfClass:[RCReferenceMessage class]]) {
        content = [self converReferenceMessage:content];
    }
    NSData *data = content.encode;
    NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return contentStr;
}

+ (NSString *)typingStatus2String:(RCUserTypingStatus *)status {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:status.userId?:@"" forKey:@"userId"];
    [dic setObject:status.contentType?:@"" forKey:@"typingContentType"];
    return [self dict2String:dic];
}
+ (NSString *)searchConversationResult2String:(RCSearchConversationResult *)result {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:[self conversation2String:result.conversation] forKey:@"mConversation"];
    [dic setObject:@(result.matchCount)?:@(0) forKey:@"mMatchCount"];
    return [self dict2String:dic];
}

+ (NSString *)dict2String:(NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (RCMessageContent *)getVoiceMessage:(NSData *)data {
    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *localPath = contentDic[@"localPath"];
    int duration = [contentDic[@"duration"] intValue];
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        NSLog(@"创建语音消息失败：语音文件路径不存在:%@",localPath);
        return nil;
    }
    NSData *voiceData= [NSData dataWithContentsOfFile:localPath];
    RCVoiceMessage *msg = [RCVoiceMessage messageWithAudio:voiceData duration:duration];
    return msg;
}

+ (NSString *)tagInfo2String:(RCTagInfo *)tagInfo {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:tagInfo.tagId forKey:@"tagId"];
    [dic setObject:tagInfo.tagName forKey:@"tagName"];
    [dic setObject:@(tagInfo.count) forKey:@"count"];
    [dic setObject:@(tagInfo.timestamp) forKey:@"timestamp"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)conversationTagInfo2String:(RCConversationTagInfo *)tagInfo {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(tagInfo.isTop) forKey:@"isTop"];
    NSMutableDictionary *taginfoDic = [NSMutableDictionary new];
    [taginfoDic setObject:tagInfo.tagInfo.tagId forKey:@"tagId"];
    [taginfoDic setObject:tagInfo.tagInfo.tagName forKey:@"tagName"];
    [taginfoDic setObject:@(tagInfo.tagInfo.count) forKey:@"count"];
    [taginfoDic setObject:@(tagInfo.tagInfo.timestamp) forKey:@"timestamp"];
    NSData *taginfoDicJsonData = [NSJSONSerialization dataWithJSONObject:taginfoDic options:0 error:nil];
    NSString *taginfoJsonString = [[NSString alloc] initWithData:taginfoDicJsonData encoding:NSUTF8StringEncoding];
    [dic setObject:taginfoJsonString forKey:@"tagInfo"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (RCConversationIdentifier *)dict2ConversationIdentifier:(NSDictionary *)dict {
    RCConversationIdentifier *identifer = [[RCConversationIdentifier alloc] init];
    identifer.targetId = [dict objectForKey:@"targetId"];
    identifer.type = [[dict objectForKey:@"conversationType"] integerValue];
    return  identifer;
}


@end
