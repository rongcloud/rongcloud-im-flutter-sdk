//
//  RCIMFlutterWrapper.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/5.
//

#import "RCIMFlutterWrapper.h"
#import "RCIMFlutterDefine.h"
#import "RCFlutterConfig.h"
#import "RCFlutterMessageFactory.h"
#import "RCIMFlutterLog.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@interface RCIMFlutterWrapper ()<RCIMClientReceiveMessageDelegate,RCConnectionStatusChangeDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) RCFlutterConfig *config;
@end

@implementation RCIMFlutterWrapper
+ (instancetype)sharedWrapper {
    static RCIMFlutterWrapper *wrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[self alloc] init];
    });
    return wrapper;
}
- (void)addFlutterChannel:(FlutterMethodChannel *)channel {
    self.channel = channel;
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([RCMethodKeyInit isEqualToString:call.method]){
        [self initWithRCIMAppKey:call.arguments];
    }else if([RCMethodKeyConfig isEqualToString:call.method]){
        [self config:call.arguments];
    }else if([RCMethodKeySetServerInfo isEqualToString:call.method]) {
        [self setServerInfo:call.arguments];
    }else if([RCMethodKeyConnect isEqualToString:call.method]) {
        [self connectWithToken:call.arguments result:result];
    }else if([RCMethodKeyDisconnect isEqualToString:call.method]) {
        [self disconnect:call.arguments];
    }else if([RCMethodKeyRefreshUserInfo isEqualToString:call.method]) {
        [self refreshUserInfo:call.arguments];
    }else if([RCMethodKeySendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments result:result];
    }else if([RCMethodKeyJoinChatRoom isEqualToString:call.method]) {
        [self joinChatRoom:call.arguments];
    }else if([RCMethodKeyQuitChatRoom isEqualToString:call.method]) {
        [self quitChatRoom:call.arguments];
    }else if([RCMethodKeyGetHistoryMessage isEqualToString:call.method]) {
        [self getHistoryMessage:call.arguments result:result];
    }else if([RCMethodKeyGetHistoryMessages.lowercaseString isEqualToString:call.method.lowercaseString]) {
        [self getHistoryMessages:call.arguments result:result];
    }else if ([RCMethodKeyGetMessage isEqualToString:call.method]) {
        [self getMessage:call.arguments result:result];
    }else if([RCMethodKeyGetConversationList isEqualToString:call.method]) {
        [self getConversationList:call.arguments result:result];
    }else if([RCMethodKeyGetConversation isEqualToString:call.method]) {
        [self getConversation:call.arguments result:result];
    }else if([RCMethodKeyGetChatRoomInfo isEqualToString:call.method]) {
        [self getChatRoomInfo:call.arguments result:result];
    }else if([RCMethodKeyClearMessagesUnreadStatus isEqualToString:call.method]) {
        [self clearMessagesUnreadStatus:call.arguments result:result];
    }else if ([RCMethodCallBackKeyGetRemoteHistoryMessages isEqualToString:call.method]){
        [self getRemoteHistoryMessages:call.arguments result:result];
    }else if ([RCMethodKeySetCurrentUserInfo isEqualToString:call.method]) {
        [self setCurrentUserInfo:call.arguments];
    }else if ([RCMethodKeyInsertIncomingMessage isEqualToString:call.method]) {
        [self insertIncomingMessage:call.arguments result:result];
    }else if ([RCMethodKeyInsertOutgoingMessage isEqualToString:call.method]) {
        [self insertOutgoingMessage:call.arguments result:result];
    }else if ([RCMethodKeyGetTotalUnreadCount isEqualToString:call.method]) {
        [self getTotalUnreadCount:result];
    }else if ([RCMethodKeyGetUnreadCountTargetId isEqualToString:call.method]) {
        [self getUnreadCountTargetId:call.arguments result:result];
    }else if ([RCMethodKeySetConversationNotificationStatus isEqualToString:call.method]) {
        [self setConversationNotificationStatus:call.arguments result:result];
    }else if ([RCMethodKeyGetConversationNotificationStatus isEqualToString:call.method]) {
        [self getConversationNotificationStatus:call.arguments result:result];
    }else if ([RCMethodKeyRemoveConversation isEqualToString:call.method]) {
        [self removeConversation:call.arguments result:result];
    }else if ([RCMethodKeyGetBlockedConversationList isEqualToString:call.method]) {
        [self getBlockedConversationList:call.arguments result:result];
    }else if ([RCMethodKeySetConversationToTop isEqualToString:call.method]) {
        [self setConversationToTop:call.arguments result:result];
    }else if ([RCMethodKeyGetUnreadCountConversationTypeList isEqualToString:call.method]) {
        [self getUnreadCountConversationTypeList:call.arguments result:result];
    }else if([RCMethodKeyDeleteMessages isEqualToString:call.method]) {
        [self deleteMessages:call.arguments result:result];
    }else if([RCMethodKeyDeleteMessageByIds isEqualToString:call.method]) {
        [self deleteMessageByIds:call.arguments result:result];
    }else if([RCMethodKeyAddToBlackList isEqualToString:call.method]) {
        [self addToBlackList:call.arguments result:result];
    }else if([RCMethodKeyRemoveFromBlackList isEqualToString:call.method]) {
        [self removeFromBlackList:call.arguments result:result];
    }else if([RCMethodKeyGetBlackListStatus isEqualToString:call.method]) {
        [self getBlackListStatus:call.arguments result:result];
    }else if([RCMethodKeyGetBlackList isEqualToString:call.method]) {
        [self getBlackList:result];
    }
    else {
        result(FlutterMethodNotImplemented);
    }

}




#pragma mark - selector
- (void)initWithRCIMAppKey:(id)arg {
    NSString *LOG_TAG =  @"init";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *appkey = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] initWithAppKey:appkey];
        
        [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
        [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    }else {
        NSLog(@"init 非法参数类型");
    }
}

- (void)config:(id)arg {
    NSString *LOG_TAG =  @"config";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *conf = (NSDictionary *)arg;
        RCFlutterConfig *config = [[RCFlutterConfig alloc] init];
        [config updateConf:conf];
        self.config = config;
        NSLog(@"RCFlutterConfig %@",conf);
        [self updateIMConfig];
        
    }else {
        NSLog(@"RCFlutterConfig 非法参数类型");
    }
}

- (void)setServerInfo:(id)arg {
    NSString *LOG_TAG =  @"setServerInfo";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *naviServer = dic[@"naviServer"];
        NSString *fileServer = dic[@"fileServer"];
        [[RCIMClient sharedRCIMClient] setServerInfo:naviServer fileServer:fileServer];
    }
}

- (void)connectWithToken:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"connect";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *token = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCConnectErrorCode status) {
            [RCLog i:[NSString stringWithFormat:@"%@ fail %@",LOG_TAG,@(status)]];
            result(@(status));
        } tokenIncorrect:^{
            [RCLog i:[NSString stringWithFormat:@"%@ fail %@",LOG_TAG,@(RC_CONN_TOKEN_INCORRECT)]];
            result(@(RC_CONN_TOKEN_INCORRECT));
        }];
    }
}

- (void)disconnect:(id)arg  {
    NSString *LOG_TAG =  @"disconnect";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSNumber class]]) {
        BOOL needPush = [((NSNumber *) arg) boolValue];
        [[RCIMClient sharedRCIMClient] disconnect:needPush];
    }
}

- (void)setCurrentUserInfo:(id)arg{
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        NSString *name = dic[@"name"];
        NSString *portraitUrl = dic[@"portraitUrl"];
        if(userId.length >=0) {
            RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portraitUrl];
            [[RCIMClient sharedRCIMClient] setCurrentUserInfo:user];
        }
    }
}

- (void)refreshUserInfo:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *userId = param[@"userId"];
        NSString *name = param[@"name"];
        NSString *portraitUrl = param[@"portraitUrl"];
        if(userId.length >=0) {
            RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portraitUrl];
//            [[RCIMClient sharedRCIMClient] refreshUserInfoCache:user withUserId:userId];
        }
    }
}

- (void)sendMessage:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG =  @"sendMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *objName = param[@"objectName"];
        if([self isMediaMessage:objName]) {
            [self sendMediaMessage:arg result:result];
            return;
        }
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *contentStr = param[@"content"];
        NSString *pushContent = param[@"pushContent"];
        if(pushContent.length <= 0) {
            pushContent = nil;
        }
        NSString *pushData = param[@"pushData"];
        if(pushData.length <= 0) {
            pushData = nil;
        }
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:objName];
        
        RCMessageContent *content = nil;
        if([objName isEqualToString:RCVoiceMessageTypeIdentifier]) {
            content = [self getVoiceMessage:data];
        }else {
             content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        }
        if(content == nil) {
            [RCLog e:[NSString stringWithFormat:@"%@  message content is nil",LOG_TAG]];
            result(nil);
            return;
        }
        
        __weak typeof(self) ws = self;
        RCMessage *message = [[RCIMClient sharedRCIMClient] sendMessage:type targetId:targetId content:content pushContent:pushContent pushData:pushData success:^(long messageId) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(nErrorCode) forKey:@"code"];
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        }];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
        result(dic);
    }
}

- (void)sendMediaMessage:(id)arg result:(FlutterResult)result {
    NSDictionary *param = (NSDictionary *)arg;
    NSString *objName = param[@"objectName"];
    RCConversationType type = [param[@"conversationType"] integerValue];
    NSString *targetId = param[@"targetId"];
    NSString *contentStr = param[@"content"];
    NSString *pushContent = param[@"pushContent"];
    if(pushContent.length <= 0) {
        pushContent = nil;
    }
    NSString *pushData = param[@"pushData"];
    if(pushData.length <= 0) {
        pushData = nil;
    }
    RCMessageContent *content = nil;
    if([objName isEqualToString:@"RC:ImgMsg"]) {
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        NSString *extra = [msgDic valueForKey:@"extra"];
        content = [RCImageMessage messageWithImageURI:localPath];
        ((RCImageMessage *)content).extra = extra;
    } else if ([objName isEqualToString:@"RC:HQVCMsg"]) {
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        long duration = [[msgDic valueForKey:@"duration"] longValue];
        NSString *extra = [msgDic valueForKey:@"extra"];
        content = [RCHQVoiceMessage messageWithPath:localPath duration:duration];
        ((RCHQVoiceMessage *)content).extra = extra;
    } else {
        NSLog(@"%s 非法的媒体消息类型",__func__);
        return;
    }
    
    __weak typeof(self) ws = self;
    RCMessage *message =  [[RCIMClient sharedRCIMClient] sendMediaMessage:type targetId:targetId content:content pushContent:pushContent pushData:pushData progress:^(int progress, long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(messageId) forKey:@"messageId"];
        [dic setObject:@(progress) forKey:@"progress"];
        [ws.channel invokeMethod:RCMethodCallBackKeyUploadMediaProgress arguments:dic];
    } success:^(long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(messageId) forKey:@"messageId"];
        [dic setObject:@(SentStatus_SENT) forKey:@"status"];
        [dic setObject:@(0) forKey:@"code"];
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } error:^(RCErrorCode errorCode, long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(messageId) forKey:@"messageId"];
        [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
        [dic setObject:@(errorCode) forKey:@"code"];
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } cancel:^(long messageId) {
        
    }];
    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:jsonString forKey:@"message"];
    [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
    result(dic);
}

- (void)joinChatRoom:(id)arg {
    NSString *LOG_TAG =  @"joinChatRoom";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        int msgCount = [dic[@"messageCount"] intValue];
        
        __weak typeof(self) ws = self;
        [[RCIMClient sharedRCIMClient] joinChatRoom:targetId messageCount:msgCount success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(status) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        }];
    }
}

- (void)quitChatRoom:(id)arg {
    NSString *LOG_TAG =  @"quitChatRoom";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        
        __weak typeof(self) ws = self;
        [[RCIMClient sharedRCIMClient] quitChatRoom:targetId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyQuitChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            [RCLog i:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(status) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyQuitChatRoom arguments:callbackDic];
        }];
    }
}

- (void)getHistoryMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getHistoryMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        int messageId = [dic[@"messageId"] intValue];
        int count = [dic[@"count"] intValue];
        NSArray <RCMessage *> *msgs = [[RCIMClient sharedRCIMClient] getHistoryMessages:type targetId:targetId oldestMessageId:messageId count:count];
        NSMutableArray *msgsArray = [NSMutableArray new];
        for(RCMessage *message in msgs) {
            NSString *jsonString = [RCFlutterMessageFactory message2String:message];
            [msgsArray addObject:jsonString];
        }
        result(msgsArray);
    }
}

- (void)getHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getHistoryMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        long long sentTime = [dic[@"sentTime"] longLongValue];
        int beforeCount = [dic[@"beforeCount"] intValue];
        int afterCount = [dic[@"afterCount"] intValue];
        
        NSArray <RCMessage *> *msgs = [[RCIMClient sharedRCIMClient] getHistoryMessages:type targetId:targetId sentTime:sentTime beforeCount:beforeCount afterCount:afterCount];
        NSMutableArray *msgsArray = [NSMutableArray new];
        for(RCMessage *message in msgs) {
            NSString *jsonString = [RCFlutterMessageFactory message2String:message];
            [msgsArray addObject:jsonString];
        }
        result(msgsArray);
    }
}

- (void)getMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int messageId = [dic[@"messageId"] intValue];
        RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(jsonString);
    }
}

- (void)getRemoteHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getRemoteHistoryMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        long recordTime = [dic[@"recordTime"] longValue];
        int count = [dic[@"count"] intValue];
        
        [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:type targetId:targetId recordTime:recordTime count:count success:^(NSArray *messages, BOOL isRemaining) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableArray *msgsArray = [NSMutableArray new];
            for(RCMessage *message in messages) {
                NSString *jsonString = [RCFlutterMessageFactory message2String:message];
                [msgsArray addObject:jsonString];
            }
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(0) forKey:@"code"];
            [callbackDic setObject:msgsArray forKey:@"messages"];
            result(callbackDic);
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(status) forKey:@"code"];
            result(callbackDic);
        }];
    }
}

- (void)getConversationList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationList";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        
        NSArray *conversations = [[RCIMClient sharedRCIMClient] getConversationList:typeArray];
        NSMutableArray *arr = [NSMutableArray new];
        for(RCConversation *con in conversations) {
            NSString *conStr = [RCFlutterMessageFactory conversation2String:con];
            [arr addObject:conStr];
        }
        result(arr);
    }
}

- (void)getConversation:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversation";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType conversationType = [param[@"conversationType"] intValue];
        NSString *targetId = param[@"targetId"];
        RCConversation *con = [[RCIMClient sharedRCIMClient] getConversation:conversationType targetId:targetId];
        NSString *conStr = @"";
        if(con) {
            conStr = [RCFlutterMessageFactory conversation2String:con];
        }
        result(conStr);
    }
}

- (void)getChatRoomInfo:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getChatRoomInfo";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        int memberCount = [dic[@"memeberCount"] intValue];
        int memberOrder = [dic[@"memberOrder"] intValue];
        [[RCIMClient sharedRCIMClient] getChatRoomInfo:targetId count:memberCount order:memberOrder success:^(RCChatRoomInfo *chatRoomInfo) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSDictionary *resultDic = [RCFlutterMessageFactory chatRoomInfo2Dictionary:chatRoomInfo];
            result(resultDic);
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(nil);
        }];
        
    }
}

- (void)clearMessagesUnreadStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"clearMessagesUnreadStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = (RCConversationType)[dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        BOOL rc = [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:type targetId:targetId];
        result([NSNumber numberWithBool:rc]);
    }
}


#pragma mark - 插入消息

- (void)insertOutgoingMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"insertOutgoingMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        int sendStatus = [param[@"sendStatus"] intValue];
        NSString *objName = param[@"objectName"];
        NSString *contentStr = param[@"content"];
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:objName];
        
        RCMessageContent *content = nil;
        if([objName isEqualToString:RCVoiceMessageTypeIdentifier]) {
            content = [self getVoiceMessage:data];
        }else {
            content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        }
        if(content == nil) {
            [RCLog e:[NSString stringWithFormat:@"%@ message content is nil",LOG_TAG]];
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        long sendTime = [param[@"sendTime"] longValue];
        
        RCMessage *message = [[RCIMClient sharedRCIMClient] insertOutgoingMessage:type targetId:targetId sentStatus:sendStatus content:content sentTime:sendTime];
        if (!message) {
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(@{@"message":jsonString,@"code":@(0)});
    }
    
}

- (void)insertIncomingMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"insertIncomingMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *senderUserId = param[@"senderUserId"];
        int receivedStatus = [param[@"receivedStatus"] intValue];
        NSString *objName = param[@"objectName"];
        NSString *contentStr = param[@"content"];
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:objName];
        
        RCMessageContent *content = nil;
        if([objName isEqualToString:RCVoiceMessageTypeIdentifier]) {
            content = [self getVoiceMessage:data];
        }else {
            content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        }
        if(content == nil) {
            [RCLog e:[NSString stringWithFormat:@"%@ message content is nil",LOG_TAG]];
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        long sendTime = [param[@"sendTime"] longValue];
        
        RCMessage *message = [[RCIMClient sharedRCIMClient] insertIncomingMessage:type targetId:targetId senderUserId:senderUserId receivedStatus:receivedStatus content:content sentTime:sendTime];
        if (!message) {
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(@{@"message":jsonString,@"code":@(0)});
    }
}

#pragma mark -- 未读数

- (void)getTotalUnreadCount:(FlutterResult)result{
    NSString *LOG_TAG =  @"getTotalUnreadCount";
    [RCLog i:[NSString stringWithFormat:@"%@ start",LOG_TAG]];
    int count = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    result(@{@"count":@(count),@"code":@(0)});
}

- (void)getUnreadCountTargetId:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getUnreadCountTargetId";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type =  [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        
        int count = [[RCIMClient sharedRCIMClient] getUnreadCount:type targetId:targetId];
        result(@{@"count":@(count),@"code":@(0)});
    }
}

- (void)getUnreadCountConversationTypeList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getUnreadCountConversationTypeList";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        BOOL isContain = [param[@"isContain"] boolValue];
        int count = [[RCIMClient sharedRCIMClient] getUnreadCount:typeArray containBlocked:isContain];
        result(@{@"count":@(count),@"code":@(0)});
    }
}

- (void)deleteMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"deleteMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type =  [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        [[RCIMClient sharedRCIMClient] deleteMessages:type targetId:targetId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ error:%@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)deleteMessageByIds:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG =  @"deleteMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSArray *messageIds = dic[@"messageIds"];
        BOOL success = [[RCIMClient sharedRCIMClient] deleteMessages:messageIds];
        if(success) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        }else {
            [RCLog e:[NSString stringWithFormat:@"%@ error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)removeConversation:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeConversation";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type =  [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        BOOL success = [[RCIMClient sharedRCIMClient] removeConversation:type targetId:targetId];
        result(@(success));
    }
}


#pragma mark - 会话提醒

- (void)setConversationNotificationStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"setConversationNotificationStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        BOOL isBlocked = [param[@"isBlocked"] boolValue]; 
        
        [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:type targetId:targetId isBlocked:isBlocked success:^(RCConversationNotificationStatus nStatus) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@{@"status":@(nStatus),@"code":@(0)});
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@{@"code":@(status)});
        }];
    }
}

- (void)getConversationNotificationStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationNotificationStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        
        [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:type targetId:targetId success:^(RCConversationNotificationStatus nStatus) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@{@"status":@(nStatus),@"code":@(0)});
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@{@"code":@(status)});
        }];
    }
}

- (void)getBlockedConversationList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getBlockedConversationList";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
  
       NSArray *conversationArray = [[RCIMClient sharedRCIMClient] getBlockedConversationList:typeArray];
        
       result(@{@"conversationList":conversationArray,@"code":@(0)});
    }
}

#pragma mark - 会话置顶

- (void)setConversationToTop:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"setConversationToTop";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        BOOL isTop = [param[@"isTop"] boolValue];
        
        BOOL status = [[RCIMClient sharedRCIMClient] setConversationToTop:type targetId:targetId isTop:isTop];
        result(@{@"status":@(status),@"code":@(0)});
    }
}

- (void)getTopConversationList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getTopConversationList";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        
        NSArray *conversationArray = [[RCIMClient sharedRCIMClient] getTopConversationList:typeArray];
        result(@{@"conversationList":conversationArray,@"code":@(0)});
    }
}

#pragma mark - 黑名单
- (void)addToBlackList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"addToBlackList";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        [[RCIMClient sharedRCIMClient] addToBlacklist:userId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)removeFromBlackList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeFromBlackList";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        [[RCIMClient sharedRCIMClient] removeFromBlacklist:userId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)getBlackListStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getBlackListStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        [[RCIMClient sharedRCIMClient] getBlacklistStatus:userId success:^(int bizStatus) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            if(bizStatus == 101) {//和 Android 保持一致
                bizStatus = 1;
            }
            result(@{@"status":@(bizStatus),@"code":@(0)});
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@{@"status":@(1),@"code":@(status)});
        }];
    }
}

- (void)getBlackList:(FlutterResult)result {
    NSString *LOG_TAG =  @"getBlackList";
    [RCLog i:[NSString stringWithFormat:@"%@ start ",LOG_TAG]];
    [[RCIMClient sharedRCIMClient] getBlacklist:^(NSArray *blockUserIds) {
        [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
        if(!blockUserIds) {
            blockUserIds = [NSArray new];
        }
        result(@{@"userIdList":blockUserIds,@"code":@(0)});
    } error:^(RCErrorCode status) {
        [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
        result(@{@"userIdList":[NSArray new],@"code":@(0)});
    }];
}

#pragma mark - 传递数据
- (void)sendDataToFlutter:(NSDictionary *)userInfo {
    NSString *LOG_TAG =  @"sendDataToFlutter";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,userInfo]];
    
    [self.channel invokeMethod:RCMethodCallBackKeySendDataToFlutter arguments:userInfo];
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    @autoreleasepool {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(nLeft) forKey:@"left"];
        
        [self.channel invokeMethod:RCMethodCallBackKeyReceiveMessage arguments:dic];
    }
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    NSString *LOG_TAG =  @"onConnectionStatusChanged";
    [RCLog i:[NSString stringWithFormat:@"%@",LOG_TAG]];
    NSDictionary *dic = @{@"status":@(status)};
    [self.channel invokeMethod:RCMethodCallBackKeyConnectionStatusChange arguments:dic];
}

#pragma mark - util
- (void)updateIMConfig {
//    [RCIM sharedRCIM].enablePersistentUserInfoCache = self.config.enablePersistentUserInfoCache;
}

- (RCMessageContent *)getVoiceMessage:(NSData *)data {
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

#pragma mark - private method

- (BOOL)isMediaMessage:(NSString *)objName {
    if([objName isEqualToString:@"RC:ImgMsg"] || [objName isEqualToString:@"RC:HQVCMsg"]) {
        return YES;
    }
    return NO;
}

- (void)pushToVC:(UIViewController *)vc {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)rootVC;
        [nav pushViewController:vc animated:YES];
    }else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [rootVC presentViewController:nav animated:YES completion:nil ];
    }
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 33)];
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backEvent:) forControlEvents:UIControlEventTouchUpInside];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)backEvent:(UIButton *)btn {
    id vc = [self findViewController:btn];
    if(vc && [vc isKindOfClass:[UIViewController class]]) {
        [self popFromVC:(UIViewController *)vc];
    }
}

- (void)popFromVC:(UIViewController *)vc {
    UINavigationController *nav = vc.navigationController;
    if(nav && nav.childViewControllers.count > 1) {
        [nav popViewControllerAnimated:YES];
    }else {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIViewController *)findViewController:(UIView *)sourceView {
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}
@end
