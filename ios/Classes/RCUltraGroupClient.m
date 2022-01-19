//
//  RCUltraGroupClient.m
//  rongcloud_im_plugin
//
//  Created by zhangyifan on 2022/1/11.
//

#import "RCUltraGroupClient.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCIMFlutterDefine.h"
#import "RCFlutterMessageFactory.h"
#import "RCFlutterUtil.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@interface RCUltraGroupClient ()
<RCUltraGroupTypingStatusDelegate,
RCUltraGroupMessageChangeDelegate,
RCUltraGroupReadTimeDelegate>

@property (nonatomic, strong) FlutterMethodChannel *channel;

@end
@implementation RCUltraGroupClient

+ (instancetype)sharedClient {
    static RCUltraGroupClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[RCUltraGroupClient alloc] init];
    });
    
    return client;
}


- (void)addFlutterChannel:(FlutterMethodChannel *)channel {
    self.channel = channel;
}

- (void)removeFlutterChannel {
    self.channel = nil;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    NSString *method = call.method;
    NSLog(@"RCFlutterIM:%@",method);
    
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        NSLog(@"非法参数 :%@",method);
        result(nil);
        return;
    }
    
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    
    if ([method isEqual:RCUltraGroupSyncReadStatus]) {
        [self syncUlTraGroupReadStatus:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetConversationListForAllChannel]) {
        [self getConversationListForAllChannel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetUnreadMentionedCount]) {
        [self getUltraGroupUnreadMentionedCount:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupModifyMessage]) {
        [self modifyUltraGroupMessage:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupRecallMessage]) {
        [self recallUltraGroupMessage:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupDeleteMessages]) {
        [self deleteUltraGroupMessages:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupSendTypingStatus]) {
        [self sendUltraGroupTypingStatus:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupDeleteMessagesForAllChannel]) {
        [self deleteUltraGroupMessagesForAllChannel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupDeleteRemoteMessages]) {
        [self deleteRemoteUltraGroupMessages:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetBatchRemoteMessages]) {
        [self getBatchRemoteUltraGroupMessages:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupUpdateMessageExpansion]) {
        [self updateUltraGroupMessageExpansion:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupRemoveMessageExpansion]) {
        [self removeUltraGroupMessageExpansion:arguments result:result];
    }
}

- (void)setUltraGroupDelegate {
    [[RCChannelClient sharedChannelManager] setRCUltraGroupTypingStatusDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupMessageChangeDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupReadTimeDelegate:self];
}

#pragma mark - Delegate

- (void)onUltraGroupMessageModified:(NSArray<RCMessage *> *)messages {
    NSLog(@"RCFlutterIM:onUltraGroupMessageModified");
    NSMutableArray *messageArr = [NSMutableArray array];
    for (RCMessage *msg in messages) {
        NSDictionary *dict = [RCFlutterMessageFactory message2Dic:msg];
        [messageArr addObject:dict];
    }
    NSDictionary *arguments = @{@"messages":messageArr.copy};
    [self.channel invokeMethod:RCUltraGroupOnMessageModified arguments:arguments];
}

- (void)onUltraGroupMessageRecalled:(NSArray<RCMessage *> *)messages {
    NSLog(@"RCFlutterIM:onUltraGroupMessageRecalled");
    NSMutableArray *messageArr = [NSMutableArray array];
    for (RCMessage *msg in messages) {
        NSDictionary *dict = [RCFlutterMessageFactory message2Dic:msg];
        [messageArr addObject:dict];
    }
    NSDictionary *arguments = @{@"messages":messageArr.copy};
    [self.channel invokeMethod:RCUltraGroupOnMessageRecalled arguments:arguments];
}

- (void)onUltraGroupMessageExpansionUpdated:(NSArray<RCMessage *> *)messages {
    NSLog(@"RCFlutterIM:onUltraGroupMessageExpansionUpdated");
    NSMutableArray *messageArr = [NSMutableArray array];
    for (RCMessage *msg in messages) {
        NSDictionary *dict = [RCFlutterMessageFactory message2Dic:msg];
        [messageArr addObject:dict];
    }
    NSDictionary *arguments = @{@"messages":messageArr.copy};
    [self.channel invokeMethod:RCUltraGroupOnMessageExpansionUpdated arguments:arguments];
}

- (void)onUltraGroupReadTimeReceived:(NSString *)targetId channelId:(NSString *)channelId readTime:(long long)readTime {
    NSLog(@"RCFlutterIM:onUltraGroupMessageExpansionUpdated");
    NSDictionary *arguments = @{@"targetId":targetId,@"readTime":@(readTime)};
    [self.channel invokeMethod:RCUltraGroupOnReadTimeReceived arguments:arguments];
}

-(void)onUltraGroupTypingStatusChanged:(NSArray<RCUltraGroupTypingStatusInfo *> *)infoArr {
    NSLog(@"RCFlutterIM:onUltraGroupTypingStatusChanged");
    NSMutableArray *arr = [NSMutableArray array];
    for (RCUltraGroupTypingStatusInfo *info in infoArr) {
        NSDictionary *infoDic = [NSDictionary dictionary];
        [infoDic setValue:info.targetId forKey:@"targetId"];
        [infoDic setValue:info.channelId forKey:@"channelId"];
        [infoDic setValue:info.userId forKey:@"userId"];
        [infoDic setValue:@(info.userNumbers) forKey:@"userNumbers"];
        [infoDic setValue:@(info.timestamp) forKey:@"timestamp"];
        [infoDic setValue:@(info.status) forKey:@"status"];
        [arr addObject:infoDic];
    }
    NSDictionary *arguments = @{@"infoArr":arr.copy};
    [self.channel invokeMethod:RCUltraGroupOnTypingStatusChanged arguments:arguments];
}

#pragma mark - Method

- (void)syncUlTraGroupReadStatus:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSLog(@"RCFlutterIM:syncUlTraGroupReadStatus %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    
    [[RCChannelClient sharedChannelManager] syncUltraGroupReadStatus:targetId channelId:channelId time:timestamp success:^{
        NSLog(@"RCFlutterIM:syncUlTraGroupReadStatus success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode errorCode) {
        NSLog(@"RCFlutterIM:syncUlTraGroupReadStatus error : %ld",(long)errorCode);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(errorCode) forKey:@"code"];
        result(dic);
    }];
}

- (void)getConversationListForAllChannel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getConversationListForAllChannel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    RCConversationType type = [arguments[@"conversationType"] integerValue];
    NSArray *conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:type targetId:targetId];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(RCConversation *con in conversationList) {
        NSString *conStr = [RCFlutterMessageFactory conversation2String:con];
        [arr addObject:conStr];
    }
    result(arr);
}

- (void)getUltraGroupUnreadMentionedCount:(NSDictionary *)arguments result:(FlutterResult)result{
    
    NSLog(@"RCFlutterIM:getUltraGroupUnreadMentionedCount");
    NSString *targetId = arguments[@"targetId"];
    int count = [[RCChannelClient sharedChannelManager] getUltraGroupUnreadMentionedCount:targetId];
    result([NSNumber numberWithInteger:count]);
}

- (void)sendUltraGroupTypingStatus:(NSDictionary *)arguments result:(FlutterResult)result{
    NSLog(@"RCFlutterIM:sendUltraGroupTypingStatus");
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    RCUltraGroupTypingStatus typingStatus = [arguments[@"typingStatus"] integerValue];
    [[RCChannelClient sharedChannelManager] sendUltraGroupTypingStatus:targetId channleId:channelId typingStatus:typingStatus success:^{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)deleteUltraGroupMessagesForAllChannel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:deleteUltraGroupMessagesForAllChannel");
    
    NSString *targetId = arguments[@"targetId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    BOOL isSuccess = [[RCChannelClient sharedChannelManager] deleteUltraGroupMessagesForAllChannel:targetId timestamp:timestamp];
    result([NSNumber numberWithBool:isSuccess]);
}

- (void)deleteUltraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    BOOL isSuccess = [[RCChannelClient sharedChannelManager] deleteUltraGroupMessages:targetId channelId:channelId timestamp:timestamp];
    result([NSNumber numberWithBool:isSuccess]);
}

- (void)deleteRemoteUltraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    [[RCChannelClient sharedChannelManager] deleteRemoteUltraGroupMessages:targetId channelId:channelId timestamp:timestamp success:^{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

/**
 消息修改
 */
- (void)modifyUltraGroupMessage:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    NSString *contentStr = arguments[@"content"];
    NSString *objName = arguments[@"objectName"];
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:objName];
    
    RCMessageContent *content = nil;
    if([objName isEqualToString:RCVoiceMessageTypeIdentifier]) {
        content = [RCFlutterUtil getVoiceMessage:data];
    } else {
        content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
    }
    if(content == nil) {
        NSLog(@"RCFlutterIM:modifyUltraGroupMessage content invalid");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(33003) forKey:@"code"];
        result(dic);
        return;
    }
    [[RCChannelClient sharedChannelManager] modifyUltraGroupMessage:messageUId messageContent:content success:^{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
    
}

/**
 更新消息扩展信息
 */
- (void)updateUltraGroupMessageExpansion:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    NSDictionary *expansionDic = arguments[@"expansionDic"];
    [[RCChannelClient sharedChannelManager] updateUltraGroupMessageExpansion:messageUId expansionDic:expansionDic success:^{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

/**
 删除消息扩展信息中特定的键值对
 */
- (void)removeUltraGroupMessageExpansion:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    NSArray *keyArray = arguments[@"keyArray"];
    [[RCChannelClient sharedChannelManager] removeUltraGroupMessageExpansion:messageUId keyArray:keyArray success:^{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

/*!
 撤回消息
 */
- (void)recallUltraGroupMessage:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *messageUId = arguments[@"messageUId"];
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:messageUId];
    [[RCChannelClient sharedChannelManager] recallUltraGroupMessage:message success:^(long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

/*!
 获取同一个超级群下的批量服务消息（含所有频道）
 */
- (void)getBatchRemoteUltraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSArray *messagesStr = arguments[@"messages"];
    NSMutableArray *messages = [NSMutableArray array];
    for (NSDictionary *dict in messagesStr) {
        [messages addObject:[RCFlutterMessageFactory dic2Message:dict]];
    }
    [[RCChannelClient sharedChannelManager] getBatchRemoteUrtraGroupMessages:messages.copy success:^(NSArray *matchedMsgList, NSArray *notMatchMsgList) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

@end
