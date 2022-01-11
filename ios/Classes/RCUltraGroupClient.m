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

@interface RCUltraGroupClient ()
<RCUltraGroupTypingStatusDelegate,
RCUltraGroupMessageChangeDelegate,
RCUlTraGroupReadTimeDelegate>

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
        [self modifyUltraGroupMessage:arguments result:result]
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
        [self getBatchRemoteUrtraGroupMessages:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupUpdateMessageExpansion]) {
        [self updateUltraGroupMessageExpansion:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupRemoveMessageExpansion]) {
        [self removeUltraGroupMessageExpansion:arguments result:result];
    }
}

- (void)setUltraGroupDelegate {
    [[RCChannelClient sharedChannelManager] setRCUltraGroupTypingStatusDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupMessageChangeDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUlTraGroupReadTimeDelegate:self];
}

#pragma mark - Delegate

- (void)onUltraGroupMessageModified:(NSArray<RCMessage *> *)messages {
    NSLog(@"RCFlutterIM:onUltraGroupMessageModified");
    NSDictionary *arguments = @{};
    [self.channel invokeMethod:RCUltraGroupOnMessageModified arguments:arguments];
}

- (void)onUltraGroupMessageRecalled:(NSArray<RCMessage *> *)messages {
    NSLog(@"RCFlutterIM:onUltraGroupMessageRecalled");
    NSDictionary *arguments = @{};
    [self.channel invokeMethod:RCUltraGroupOnMessageRecalled arguments:arguments];
}

- (void)onUltraGroupMessageExpansionUpdated:(NSArray<RCMessage *> *)messages {
    NSLog(@"RCFlutterIM:onUltraGroupMessageExpansionUpdated");
    NSDictionary *arguments = @{};
    [self.channel invokeMethod:RCUltraGroupOnMessageExpansionUpdated arguments:arguments];
}

-(void)onUlTraGroupReadTimeReceived:(NSString *)targetId readTime:(long long)readTime {
    NSLog(@"RCFlutterIM:onUltraGroupMessageExpansionUpdated");
    NSDictionary *arguments = @{};
    [self.channel invokeMethod:RCUltraGroupOnReadTimeReceived arguments:arguments];
}

-(void)onUltraGroupTypingStatusChanged:(NSArray<RCUltraGroupTypingStatusInfo *> *)infoArr {
    NSLog(@"RCFlutterIM:onUltraGroupTypingStatusChanged");
    NSDictionary *arguments = @{};
    [self.channel invokeMethod:RCUltraGroupOnTypingStatusChanged arguments:arguments];
}

#pragma mark - Method

- (void)syncUlTraGroupReadStatus:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSLog(@"RCFlutterIM:syncUlTraGroupReadStatus %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    
    [[RCChannelClient sharedChannelManager] syncUlTraGroupReadStatus:targetId channelId:channelId time:timestamp success:^{
        NSLog(@"RCFlutterIM:syncUlTraGroupReadStatus success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode errorCode) {
        NSLog(@"RCFlutterIM:syncUlTraGroupReadStatus error : %@",errorCode);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(errorCode) forKey:@"code"];
        result(dic);
    }];
}

- (void)getConversationListForAllChannel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getConversationListForAllChannel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    RCConversationType type = [param[@"conversationType"] integerValue];
    NSArray *conversationList = [[RCChannelClient sharedChannelManager] getConversationListForAllChannel:type targetId:targetId];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(RCConversation *con in conversationList) {
        NSString *conStr = [RCFlutterMessageFactory conversation2String:con];
        [arr addObject:conStr];
    }
    result(arr);
}

- (int)getUltraGroupUnreadMentionedCount:(NSDictionary *)arguments result:(FlutterResult)result{
    
    NSLog(@"RCFlutterIM:getUltraGroupUnreadMentionedCount");
    NSString *targetId = arguments[@"targetId"];
    int count = [[RCChannelClient sharedChannelManager] getUltraGroupUnreadMentionedCount:targetId];
    result(count);
}

/*!
 向会话中发送正在输入的状态
 
 @param targetId            会话目标  ID
 @param channelId          所属会话的频道id
 @param status                输入状态类型
 
 @remarks 高级功能
 */
- (void)sendUltraGroupTypingStatus:(NSDictionary *)arguments result:(FlutterResult)result{
    NSLog(@"RCFlutterIM:sendUltraGroupTypingStatus");
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    RCUltraGroupTypingStatus typingStatus = [arguments[@"typingStatus"] integerValue];
    [RCChannelClient sharedChannelManager] sendUltraGroupTypingStatus:targetId channleId:channelId typingStatus:RCUltraGroupTypingStatusText success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    result(nil);
}

- (BOOL)deleteUltraGroupMessagesForAllChannel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:deleteUltraGroupMessagesForAllChannel");
    
    NSString *targetId = arguments[@"targetId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    [[RCChannelClient sharedChannelManager] deleteUltraGroupMessagesForAllChannel:targetId timestamp:timestamp];
    
    result(nil);
}

/*!
 删除本地特定 channel 特点时间之前的消息
 
 @param targetId            会话 ID
 @param channelId           频道 ID
 @param timestamp          会话的时间戳
 @return             是否删除成功
 
 @remarks 消息操作
 */
- (BOOL)deleteUltraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    [[RCChannelClient sharedChannelManager] deleteUltraGroupMessages:targetId channelId:channelId timestamp:timestamp];
    
    result(nil);
}

/*!
 删除服务端特定 channel 特定时间之前的消息
 
 @param targetId            会话 ID
 @param channelId           频道 ID
 @param timestamp          会话的时间戳
 @param successBlock    成功的回调
 @param errorBlock         失败的回调
 
 @remarks 消息操作
 */
- (void)deleteRemoteUltraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    [[RCChannelClient sharedChannelManager] deleteRemoteUltraGroupMessages:targetId channelId:channelId timestamp:timestamp success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
}

/**
 消息修改
 
 @param messageUId 将被修改的消息id
 @param newContent 将被修改的消息内容
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 消息操作
 */
- (void)modifyUltraGroupMessage:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    NSString *contentStr = arguments[@"content"];
    [[RCChannelClient sharedChannelManager] modifyUltraGroupMessage:targetId messageContent:contentStr success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
}

/**
 更新消息扩展信息
 
 @param messageUId 消息 messageUId
 @param expansionDic 要更新的消息扩展信息键值对
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @remarks 高级功能
 */
- (void)updateUltraGroupMessageExpansion:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    
    //    NSString *expansionDicStr = arguments[@"expansionDic"];
    //    NSData *data = [expansionDicStr dataUsingEncoding:NSUTF8StringEncoding];
    //    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSDictionary *expansionDic = arguments[@"expansionDic"];
    [[RCChannelClient sharedChannelManager] updateUltraGroupMessageExpansion:messageUId expansionDic:dic success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
}

/**
 删除消息扩展信息中特定的键值对
 
 @param messageUId 消息 messageUId
 @param keyArray 消息扩展信息中待删除的 key 的列表
 @param successBlock 成功的回调
 @param errorBlock 失败的回调
 
 @discussion 扩展信息只支持单聊和群组，其它会话类型不能设置扩展信息
 
 @remarks 高级功能
 */
- (void)removeUltraGroupMessageExpansion:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    NSArray *keyArray = arguments[@"keyArray"];
    [[RCChannelClient sharedChannelManager] removeUltraGroupMessageExpansion:messageUId keyArray:keyArray success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
}

/*!
 撤回消息
 
 @param message      需要撤回的消息
 @param successBlock 撤回成功的回调 [messageId:撤回的消息 ID，该消息已经变更为新的消息]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 @remarks 高级功能
 */
- (void)recallUltraGroupMessage:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *messageUId = arguments[@"messageUId"];
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessage:messageUId];
    [[RCChannelClient sharedChannelManager] recallUltraGroupMessage:message success:^(long messageId) {
        
    } error:^(RCErrorCode status) {
        
    }];
}

/*!
 获取同一个超级群下的批量服务消息（含所有频道）
 
 @param messages      消息列表
 @param successBlock 撤回成功的回调 [matchedMsgList:成功的消息列表，notMatchMsgList:失败的消息列表]
 @param errorBlock   撤回失败的回调 [errorCode:撤回失败错误码]
 @remarks 高级功能
 */
- (void)getBatchRemoteUrtraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSArray *messagesStr = arguments[@"messages"];
    NSMutableArray *messages = [NSMutableArray array];
    for (NSDictionary *dict in messagesStr) {
        [messages addObject:[RCFlutterMessageFactory dic2Message:dict]];
    }
    [[RCChannelClient sharedChannelManager] getBatchRemoteUrtraGroupMessages:messages.copy success:^(NSArray *matchedMsgList, NSArray *notMatchMsgList) {
        
    } error:^(RCErrorCode status) {
        
    }];
}

@end
