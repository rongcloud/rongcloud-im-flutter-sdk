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
RCUltraGroupReadTimeDelegate,
RCUltraGroupConversationDelegate>

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


- (void)setFlutterChannel:(FlutterMethodChannel *)channel {
    self.channel = channel;
}


- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    NSString *method = call.method;
    NSLog(@"RCFlutterIM:%@",method);
    
    if (call.arguments != nil && ![call.arguments isKindOfClass:[NSDictionary class]]) {
        NSLog(@"非法参数 :%@",method);
        result(nil);
        return;
    }
    
    NSDictionary *arguments = (NSDictionary *)call.arguments;
    
    if ([method isEqual:RCUltraGroupSyncReadStatus]) {
        [self syncUltraGroupReadStatus:arguments result:result];
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
    } else if ([method isEqualToString:RCUltraGroupSetNotificationQuietHoursLevel]) {
        [self setNotificationQuietHoursLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetNotificationQuietHoursLevel]) {
        [self getNotificationQuietHoursLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupSetConversationChannelNotificationLevel]) {
        [self setConversationChannelNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetConversationChannelNotificationLevel]) {
        [self getConversationChannelNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupSetConversationTypeNotificationLevel]) {
        [self setConversationTypeNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetConversationTypeNotificationLevel]) {
        [self getConversationTypeNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupSetConversationDefaultNotificationLevel]) {
        [self setUltraGroupConversationDefaultNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetConversationDefaultNotificationLevel]) {
        [self getUltraGroupConversationDefaultNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupSetConversationChannelDefaultNotificationLevel]) {
        [self setUltraGroupConversationChannelDefaultNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetConversationChannelDefaultNotificationLevel]) {
        [self getUltraGroupConversationChannelDefaultNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetUltraGroupUnreadCount]) {
        [self getUltraGroupUnreadCount:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetUltraGroupAllUnreadCount]) {
        [self getUltraGroupAllUnreadCount:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetUltraGroupAllUnreadMentionedCount]) {
        [self getUltraGroupAllUnreadMentionedCount:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupSetConversationNotificationLevel]) {
        [self setConversationNotificationLevel:arguments result:result];
    } else if ([method isEqualToString:RCUltraGroupGetConversationNotificationLevel]) {
        [self getConversationNotificationLevel:arguments result:result];
    }
    
}

- (void)setUltraGroupDelegate {
    [[RCChannelClient sharedChannelManager] setRCUltraGroupTypingStatusDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupMessageChangeDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupReadTimeDelegate:self];
    [[RCChannelClient sharedChannelManager] setUltraGroupConversationDelegate:self];
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
        NSMutableDictionary *infoDic = [NSMutableDictionary new];
        [infoDic setObject:info.targetId forKey:@"targetId"];
        [infoDic setObject:info.channelId forKey:@"channelId"];
        [infoDic setObject:info.userId forKey:@"userId"];
        [infoDic setObject:@(info.userNumbers) forKey:@"userNumbers"];
        [infoDic setObject:@(info.timestamp) forKey:@"timestamp"];
        [infoDic setObject:@(info.status) forKey:@"status"];
        [arr addObject:infoDic];
    }
    NSDictionary *arguments = @{@"infoArr":arr.copy};
    [self.channel invokeMethod:RCUltraGroupOnTypingStatusChanged arguments:arguments];
}

- (void)ultraGroupConversationListDidSync{
    NSLog(@"RCFlutterIM:ultraGroupConversationListDidSync");
    [self.channel invokeMethod:RCUltraGroupConversationListDidSync arguments:nil];
}

#pragma mark - Method

- (void)setNotificationQuietHoursLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSLog(@"RCFlutterIM:setNotificationQuietHoursLevel %@",arguments);
    NSString *startTime = arguments[@"startTime"];
    int spanMins = [arguments[@"spanMins"] intValue];
    int pushNotificationQuietHoursLevel = [arguments[@"pushNotificationQuietHoursLevel"] intValue];
    
    [[RCChannelClient sharedChannelManager] setNotificationQuietHoursLevel:startTime spanMins:spanMins level:pushNotificationQuietHoursLevel success:^{
        NSLog(@"RCFlutterIM:setNotificationQuietHoursLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setNotificationQuietHoursLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}


- (void)getNotificationQuietHoursLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSLog(@"RCFlutterIM:getNotificationQuietHoursLevel %@",arguments);
    
    [[RCChannelClient sharedChannelManager] getNotificationQuietHoursLevel:^(NSString *startTime, int spanMins, RCPushNotificationQuietHoursLevel level) {
        NSLog(@"RCFlutterIM:setNotificationQuietHoursLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        if (startTime != nil) {
            [dic setObject:startTime forKey:@"startTime"];
        }
        [dic setObject:@(spanMins) forKey:@"spanMins"];
        [dic setObject:@(level) forKey:@"pushNotificationQuietHoursLevel"];
        result(dic);
        
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setNotificationQuietHoursLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}


- (void)setConversationChannelNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSLog(@"RCFlutterIM:setConversationChannelNotificationLevel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    RCConversationType conversationType = [arguments[@"conversationType"] integerValue];
    int pushNotificationLevel = [arguments[@"pushNotificationLevel"] intValue];
    
    [[RCChannelClient sharedChannelManager] setConversationChannelNotificationLevel:conversationType targetId:targetId channelId:channelId level:pushNotificationLevel success:^{
        NSLog(@"RCFlutterIM:setConversationChannelNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setConversationChannelNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}


- (void)getConversationChannelNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getConversationChannelNotificationLevel %@",arguments);
    
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    RCConversationType conversationType = [arguments[@"conversationType"] integerValue];
    
    [[RCChannelClient sharedChannelManager] getConversationChannelNotificationLevel:conversationType targetId:targetId channelId:channelId success:^(RCPushNotificationLevel level) {
        NSLog(@"RCFlutterIM:setConversationChannelNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(level) forKey:@"pushNotificationLevel"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setConversationChannelNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)setConversationTypeNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:setConversationTypeNotificationLevel %@",arguments);
    RCConversationType conversationType = [arguments[@"conversationType"] integerValue];
    int pushNotificationLevel = [arguments[@"pushNotificationLevel"] intValue];
    
    [[RCChannelClient sharedChannelManager] setConversationTypeNotificationLevel:conversationType level:pushNotificationLevel success:^{
        NSLog(@"RCFlutterIM:setConversationTypeNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setConversationTypeNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)getConversationTypeNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getConversationTypeNotificationLevel %@",arguments);
    RCConversationType conversationType = [arguments[@"conversationType"] integerValue];
    
    [[RCChannelClient sharedChannelManager] getConversationTypeNotificationLevel:conversationType success:^(RCPushNotificationLevel level) {
        NSLog(@"RCFlutterIM:setConversationTypeNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(level) forKey:@"pushNotificationLevel"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setConversationTypeNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
    
}

- (void)setUltraGroupConversationDefaultNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:setUltraGroupConversationDefaultNotificationLevel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    int pushNotificationLevel = [arguments[@"pushNotificationLevel"] intValue];
    
    [[RCChannelClient sharedChannelManager] setUltraGroupConversationDefaultNotificationLevel:targetId level:pushNotificationLevel success:^{
        NSLog(@"RCFlutterIM:setUltraGroupConversationDefaultNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setUltraGroupConversationDefaultNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
    
}

- (void)getUltraGroupConversationDefaultNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getUltraGroupConversationDefaultNotificationLevel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    
    [[RCChannelClient sharedChannelManager] getUltraGroupConversationDefaultNotificationLevel:targetId success:^(RCPushNotificationLevel level) {
        NSLog(@"RCFlutterIM:getUltraGroupConversationDefaultNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(level) forKey:@"pushNotificationLevel"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:getUltraGroupConversationDefaultNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}


- (void)setConversationNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:setConversationNotificationLevel %@",arguments);
    RCConversationType type = [arguments[@"conversationType"] integerValue];
    NSString *targetId = arguments[@"targetId"];
    int pushNotificationLevel = [arguments[@"pushNotificationLevel"] intValue];
    [[RCChannelClient sharedChannelManager] setConversationNotificationLevel:type targetId:targetId level:pushNotificationLevel success:^{
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
    
}

- (void)getConversationNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getConversationNotificationLevel %@",arguments);
    RCConversationType type = [arguments[@"conversationType"] integerValue];
    NSString *targetId = arguments[@"targetId"];
    [[RCChannelClient sharedChannelManager] getConversationNotificationLevel:type targetId:targetId success:^(RCPushNotificationLevel level) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(level) forKey:@"pushNotificationLevel"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)setUltraGroupConversationChannelDefaultNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:setUltraGroupConversationChannelDefaultNotificationLevel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    int pushNotificationLevel = [arguments[@"pushNotificationLevel"] intValue];
    
    [[RCChannelClient sharedChannelManager] setUltraGroupConversationChannelDefaultNotificationLevel:targetId channelId:channelId level:pushNotificationLevel success:^{
        NSLog(@"RCFlutterIM:setUltraGroupConversationChannelDefaultNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:setUltraGroupConversationChannelDefaultNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)getUltraGroupConversationChannelDefaultNotificationLevel:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getUltraGroupConversationChannelDefaultNotificationLevel %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    
    [[RCChannelClient sharedChannelManager] getUltraGroupConversationChannelDefaultNotificationLevel:targetId channelId:channelId success:^(RCPushNotificationLevel level) {
        NSLog(@"RCFlutterIM:getUltraGroupConversationChannelDefaultNotificationLevel success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(level) forKey:@"pushNotificationLevel"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:getUltraGroupConversationChannelDefaultNotificationLevel error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)getUltraGroupUnreadCount:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getUltraGroupUnreadCount %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    
    [[RCChannelClient sharedChannelManager] getUltraGroupUnreadCount:targetId success:^(NSInteger count) {
        NSLog(@"RCFlutterIM:getUltraGroupUnreadCount success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(count) forKey:@"count"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:getUltraGroupUnreadCount error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}


- (void)getUltraGroupAllUnreadCount:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getUltraGroupAllUnreadCount %@",arguments);
    
    
    [[RCChannelClient sharedChannelManager] getUltraGroupAllUnreadCount:^(NSInteger count) {
        NSLog(@"RCFlutterIM:getUltraGroupAllUnreadCount success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(count) forKey:@"count"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:getUltraGroupAllUnreadCount error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

- (void)getUltraGroupAllUnreadMentionedCount:(NSDictionary *)arguments result:(FlutterResult)result {
    NSLog(@"RCFlutterIM:getUltraGroupAllUnreadMentionedCount %@",arguments);
    
    [[RCChannelClient sharedChannelManager] getUltraGroupAllUnreadMentionedCount:^(NSInteger count) {
        NSLog(@"RCFlutterIM:getUltraGroupAllUnreadMentionedCount success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:@(count) forKey:@"count"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSLog(@"RCFlutterIM:getUltraGroupAllUnreadMentionedCount error : %ld",(long)status);
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}



- (void)syncUltraGroupReadStatus:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSLog(@"RCFlutterIM:syncUltraGroupReadStatus %@",arguments);
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    
    [[RCChannelClient sharedChannelManager] syncUltraGroupReadStatus:targetId channelId:channelId time:timestamp success:^{
        NSLog(@"RCFlutterIM:syncUltraGroupReadStatus success");
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(0) forKey:@"code"];
        result(dic);
    } error:^(RCErrorCode errorCode) {
        NSLog(@"RCFlutterIM:syncUltraGroupReadStatus error : %ld",(long)errorCode);
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
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:@(count) forKey:@"count"];
    result(dic);
    
}

- (void)sendUltraGroupTypingStatus:(NSDictionary *)arguments result:(FlutterResult)result{
    NSLog(@"RCFlutterIM:sendUltraGroupTypingStatus");
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    RCUltraGroupTypingStatus typingStatus = [arguments[@"typingStatus"] integerValue];
    [[RCChannelClient sharedChannelManager] sendUltraGroupTypingStatus:targetId channelId:channelId typingStatus:typingStatus success:^{
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
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if (isSuccess) {
        [dic setObject:@(0) forKey:@"code"];
    }else {
        [dic setObject:@(-1) forKey:@"code"];
    }
    result(dic);
}

- (void)deleteUltraGroupMessages:(NSDictionary *)arguments result:(FlutterResult)result {
    
    NSString *targetId = arguments[@"targetId"];
    NSString *channelId = arguments[@"channelId"];
    long long timestamp = [arguments[@"timestamp"] longLongValue];
    BOOL isSuccess = [[RCChannelClient sharedChannelManager] deleteUltraGroupMessages:targetId channelId:channelId timestamp:timestamp];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if (isSuccess) {
        [dic setObject:@(0) forKey:@"code"];
    }else {
        [dic setObject:@(-1) forKey:@"code"];
    }
    result(dic);
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
        
        RCMessage *resultMessage = [[RCCoreClient sharedCoreClient] getMessage:messageId];
        NSDictionary *dict = [RCFlutterMessageFactory message2Dic:resultMessage];
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:dict forKey:@"message"];
        
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
    [[RCChannelClient sharedChannelManager] getBatchRemoteUltraGroupMessages:messages.copy
                                                                     success:^(NSArray *matchedMsgList, NSArray *notMatchMsgList) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        
        NSMutableArray *messageArr = [NSMutableArray array];
        for (RCMessage *msg in matchedMsgList) {
            NSDictionary *dict = [RCFlutterMessageFactory message2Dic:msg];
            [messageArr addObject:dict];
        }
        
        NSMutableArray *notMatchMessageArr = [NSMutableArray array];
        for (RCMessage *msg in notMatchMsgList) {
            NSDictionary *dict = [RCFlutterMessageFactory message2Dic:msg];
            [notMatchMessageArr addObject:dict];
        }
        
        [dic setObject:@(0) forKey:@"code"];
        [dic setObject:messageArr.copy forKey:@"matchedMsgList"];
        [dic setObject:notMatchMessageArr.copy forKey:@"notMatchMsgList"];
        result(dic);
    } error:^(RCErrorCode status) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(status) forKey:@"code"];
        result(dic);
    }];
}

@end
