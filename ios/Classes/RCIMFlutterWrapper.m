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
#import "RCFlutterUtil.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@interface RCIMFlutterWrapper ()<RCIMClientReceiveMessageDelegate,RCConnectionStatusChangeDelegate,RCTypingStatusDelegate>
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

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageHasReadNotification:) name:RCLibDispatchReadReceiptNotification object:nil];
    }
    return self;
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
    }else if([RCMethodKeyGetConversationListByPage isEqualToString:call.method]) {
        [self getConversationListByPage:call.arguments result:result];
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
    }else if ([RCMethodKeySendReadReceiptMessage isEqualToString:call.method]){
        [self sendReadReceiptMessage:call.arguments result:result];
    }else if ([RCMethodKeySendReadReceiptRequest isEqualToString:call.method]){
        [self sendReadReceiptRequest:call.arguments result:result];
    }else if ([RCMethodKeySendReadReceiptResponse isEqualToString:call.method]){
        [self sendReadReceiptResponse:call.arguments result:result];
    }else if ([RCMethodKeyClearHistoryMessages isEqualToString:call.method]){
        [self clearHistoryMessages:call.arguments result:result];
    }else if ([RCMethodKeyRecallMessage isEqualToString:call.method]) {
        [self recallMessage:call.arguments result:result];
    }else if ([RCMethodKeySetChatRoomEntry isEqualToString:call.method]) {
        [self setChatRoomEntry:call.arguments result:result];
    }else if ([RCMethodKeyForceSetChatRoomEntry isEqualToString:call.method]) {
        [self forceSetChatRoomEntry:call.arguments result:result];
    }else if ([RCMethodKeyGetChatRoomEntry isEqualToString:call.method]) {
        [self getChatRoomEntry:call.arguments result:result];
    }else if ([RCMethodKeyGetAllChatRoomEntries isEqualToString:call.method]) {
        [self getAllChatRoomEntries:call.arguments result:result];
    }else if ([RCMethodKeyRemoveChatRoomEntry isEqualToString:call.method]) {
        [self removeChatRoomEntry:call.arguments result:result];
    }else if ([RCMethodKeyForceRemoveChatRoomEntry isEqualToString:call.method]) {
        [self forceRemoveChatRoomEntry:call.arguments result:result];
    }else if ([RCMethodKeySyncConversationReadStatus isEqualToString:call.method]) {
        [self syncConversationReadStatus:call.arguments result:result];
    }else if ([RCMethodKeyGetTextMessageDraft isEqualToString:call.method]) {
        [self getTextMessageDraft:call.arguments result:result];
    }else if ([RCMethodKeySaveTextMessageDraft isEqualToString:call.method]) {
        [self saveTextMessageDraft:call.arguments result:result];
    }else if([RCMethodKeySearchConversations isEqualToString:call.method]) {
        [self searchConversations:call.arguments result:result];
    }else if([RCMethodKeySearchMessages isEqualToString:call.method]) {
        [self searchMessages:call.arguments result:result];
    }else if([RCMethodKeySendTypingStatus isEqualToString:call.method]) {
        [self sendTypingStatus:call.arguments result:result];
    }else if([RCMethodKeyDownloadMediaMessage isEqualToString:call.method]) {
        [self downloadMediaMessage:call.arguments result:result];
    }else if([RCMethodKeySetNotificationQuietHours isEqualToString:call.method]) {
        [self setNotificationQuietHours:call.arguments result:result];
    }else if([RCMethodKeyRemoveNotificationQuietHours isEqualToString:call.method]) {
        [self removeNotificationQuietHours:call.arguments result:result];
    }else if([RCMethodKeyGetNotificationQuietHours isEqualToString:call.method]) {
        [self getNotificationQuietHours:call.arguments result:result];
    }else if([RCMethodKeyGetUnreadMentionedMessages isEqualToString:call.method]) {
        [self getUnreadMentionedMessages:call.arguments result:result];
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
        
        /// imlib 默认检测到小视频 SDK，才会注册小视频消息，但是这里没有小视频 SDK
        [[RCIMClient sharedRCIMClient] registerMessageType:RCSightMessage.class];
        
        [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
        [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
        [[RCIMClient sharedRCIMClient] setRCTypingStatusDelegate:self];
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
        localPath = [self getCorrectLocalPath:localPath];
        NSString *extra = [msgDic valueForKey:@"extra"];
        content = [RCImageMessage messageWithImageURI:localPath];
        ((RCImageMessage *)content).extra = extra;
    } else if ([objName isEqualToString:@"RC:HQVCMsg"]) {
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        localPath = [self getCorrectLocalPath:localPath];
        long duration = [[msgDic valueForKey:@"duration"] longValue];
        NSString *extra = [msgDic valueForKey:@"extra"];
        content = [RCHQVoiceMessage messageWithPath:localPath duration:duration];
        ((RCHQVoiceMessage *)content).extra = extra;
    } else if ([objName isEqualToString:@"RC:SightMsg"]) {
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        localPath = [self getCorrectLocalPath:localPath];
        long duration = [[msgDic valueForKey:@"duration"] longValue];
        NSString *extra = [msgDic valueForKey:@"extra"];
        
        UIImage *thumbImg = [RCFlutterUtil getVideoPreViewImage:localPath];
        content = [RCSightMessage messageWithLocalPath:localPath thumbnail:thumbImg duration:duration];
        ((RCSightMessage *)content).extra = extra;
    } else if ([objName isEqualToString:@"RC:FileMsg"]) {
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        localPath = [self getCorrectLocalPath:localPath];
        //           NSString *mType = [msgDic valueForKey:@"mType"];
        NSString *extra = [msgDic valueForKey:@"extra"];
        
        content = [RCFileMessage messageWithFile:localPath];
        ((RCFileMessage *)content).extra = extra;
    } else {
        NSLog(@"%s 非法的媒体消息类型",__func__);
        return;
    }
    
    if([content isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)content;
        if(sightMsg.duration > 10) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(-1) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(RC_SIGHT_MSG_DURATION_LIMIT_EXCEED) forKey:@"code"];
            [self.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            return;
        }
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

- (void)getConversationListByPage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationListByPage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        int count = [param[@"count"] intValue];
        long long startTime = [param[@"startTime"] longLongValue];
        
        NSArray *conversations = [[RCIMClient sharedRCIMClient] getConversationList:typeArray count:count startTime:startTime];
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

- (void)clearHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"clearHistoryMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type =  [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        long long recordTime = [param[@"recordTime"] longLongValue];
        BOOL clearRemote = [param[@"clearRemote"] boolValue];
        [[RCIMClient sharedRCIMClient] clearHistoryMessages:type targetId:targetId recordTime:recordTime clearRemote:clearRemote success:^{
            result(@(0));
        } error:^(RCErrorCode status) {
            result(@(status));
        }];
    }
}

- (void)recallMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"recallMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSDictionary *messageDic = param[@"message"];
        NSString *pushContent = param[@"pushContent"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [[RCIMClient sharedRCIMClient] recallMessage:message pushContent:pushContent success:^(long messageId) {
            RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
            RCRecallNotificationMessage *recallNotificationMessage = (RCRecallNotificationMessage *)message.content;
            
            [dic setObject:[RCFlutterMessageFactory messageContent2String:recallNotificationMessage] forKey:@"recallNotificationMessage"];
            [dic setObject:@(0) forKey:@"errorCode"];
            result(dic);
        } error:^(RCErrorCode errorcode) {
            result(@{@"recallNotificationMessage":@"", @"errorCode":@(errorcode)});
        }];
    }
}

- (void)syncConversationReadStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"syncConversationReadStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        long long timestamp = [param[@"timestamp"] longLongValue];
        [[RCIMClient sharedRCIMClient] syncConversationReadStatus:type targetId:targetId time:timestamp success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            result(@(nErrorCode));
        }];
    }
}

#pragma mark - 草稿
- (void)getTextMessageDraft:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getTextMessageDraft";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *draft = [[RCIMClient sharedRCIMClient] getTextMessageDraft:type targetId:targetId];
        result(draft?:@"");
    }
}

- (void)saveTextMessageDraft:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"saveTextMessageDraft";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *content = param[@"content"];
        BOOL isSuccess = [[RCIMClient sharedRCIMClient] saveTextMessageDraft:type targetId:targetId content:content];
        result(@(isSuccess));
    }
}

#pragma mark - 搜索
- (void)searchConversations:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"searchConversations";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *keyword = param[@"keyword"];
        NSArray *conversationTypes = param[@"conversationTypes"];
        NSArray *objectNames = param[@"objectNames"];
        
        if (conversationTypes && objectNames) {
            NSArray *results = [[RCIMClient sharedRCIMClient] searchConversations:conversationTypes messageType:objectNames keyword:keyword];
            NSMutableArray *resultStrings = [NSMutableArray arrayWithCapacity:results.count];
            for (RCSearchConversationResult *result in results) {
                NSString *resultString = [RCFlutterMessageFactory searchConversationResult2String:result];
                [resultStrings addObject:resultString];
            }
            result(@{@"code": @(0), @"SearchConversationResult": [resultStrings copy]});
        } else {
            result(@{@"code": @(0), @"SearchConversationResult": @[]});
        }
    }
}

- (void)searchMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"searchMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        int count = [param[@"count"] intValue];
        long long beginTime = [param[@"beginTime"] longLongValue];
        NSString *keyword = param[@"keyword"];
        
        NSArray *results = [[RCIMClient sharedRCIMClient] searchMessages:type targetId:targetId keyword:keyword count:count startTime:beginTime];
        if (results.count > 0) {
            NSMutableArray *messageStrings = [NSMutableArray arrayWithCapacity:results.count];
            for (RCMessage *message in results) {
                NSString *messageString = [RCFlutterMessageFactory message2String:message];
                [messageStrings addObject:messageString];
            }
            result(@{@"code": @(0), @"messages": messageStrings});
        } else {
            result(@{@"code": @(0), @"messages": @[]});
        }
    }
}

#pragma mark - 发送输入状态
- (void)sendTypingStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"sendTypingStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *typingContentType = param[@"typingContentType"];
        
        [[RCIMClient sharedRCIMClient] sendTypingStatus:type targetId:targetId contentType:typingContentType];
    }
}

- (void)downloadMediaMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"downloadMediaMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        [[RCIMClient sharedRCIMClient] downloadMediaMessage:message.messageId progress:^(int progress) {
            NSDictionary *callbackDic = @{@"messageId": @(message.messageId), @"progress": @(progress), @"code": @(10)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessageCallBack arguments:callbackDic];
        } success:^(NSString *mediaPath) {
            RCMessage *tempMessage = [[RCIMClient sharedRCIMClient] getMessage:message.messageId];
            NSString *messageString = [RCFlutterMessageFactory message2String:tempMessage];
            NSDictionary *callbackDic = @{@"messageId": @(tempMessage.messageId), @"message": messageString, @"code": @(0)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessageCallBack arguments:callbackDic];
        } error:^(RCErrorCode errorCode) {
            NSDictionary *callbackDic = @{@"messageId": @(message.messageId), @"code": @(errorCode)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessageCallBack arguments:callbackDic];
        } cancel:^{
            NSDictionary *callbackDic = @{@"messageId": @(message.messageId), @"code": @(20)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessageCallBack arguments:callbackDic];
        }];
    }
}


#pragma mark - 全局消息提醒
- (void)setNotificationQuietHours:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setNotificationQuietHours";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSString *startTime = param[@"startTime"];
        int spanMins = [param[@"spanMins"] intValue];
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTime spanMins:spanMins success:^{
            result(@(0));
        } error:^(RCErrorCode status) {
            result(@(status));
        }];
    }
}

- (void)removeNotificationQuietHours:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeNotificationQuietHours";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
        result(@(0));
    } error:^(RCErrorCode status) {
        result(@(status));
    }];
}

- (void)getNotificationQuietHours:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"sendTypingStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:@(0) forKey:@"code"];
        [dict setObject:startTime forKey:@"startTime"];
        [dict setObject:@(spansMin) forKey:@"spansMin"];
        result(dict);
    } error:^(RCErrorCode status) {
        result(@{@"code": @(0)});
    }];
}

- (void)getUnreadMentionedMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getUnreadMentionedMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSArray *messages = [[RCIMClient sharedRCIMClient] getUnreadMentionedMessages:type targetId:targetId];
        NSMutableArray *arr = [NSMutableArray new];
        for(RCMessage *msg in messages) {
            NSString *msgStr = [RCFlutterMessageFactory message2String:msg];
            [arr addObject:msgStr];
        }
        result(arr);
    }
}

#pragma mark - 聊天室状态存储 (使用前必须先联系商务开通)
- (void)setChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatroomId = param[@"chatroomId"];
        NSString *key = param[@"key"];
        NSString *value = param[@"value"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        BOOL autoDelete = [param[@"autoDelete"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] setChatRoomEntry:chatroomId key:key value:value sendNotification:sendNotification autoDelete:autoDelete notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            result(@(nErrorCode));
        }];
    }
}

- (void)forceSetChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"forceSetChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatroomId = param[@"chatroomId"];
        NSString *key = param[@"key"];
        NSString *value = param[@"value"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        BOOL autoDelete = [param[@"autoDelete"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] forceSetChatRoomEntry:chatroomId key:key value:value sendNotification:sendNotification autoDelete:autoDelete notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            result(@(nErrorCode));
        }];
    }
}

- (void)getChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatroomId = param[@"chatroomId"];
        NSString *key = param[@"key"];
        
        [[RCIMClient sharedRCIMClient] getChatRoomEntry:chatroomId key:key success:^(NSDictionary *entry) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (entry) {
                [dict setObject:entry forKey:@"entry"];
            }
            [dict setObject:@(0) forKey:@"code"];
            result(dict);
        } error:^(RCErrorCode nErrorCode) {
            result(@{@"entry":@{}, @"code": @(nErrorCode)});
        }];
    }
}

- (void)getAllChatRoomEntries:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getAllChatRoomEntries";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatroomId = param[@"chatroomId"];
        
        [[RCIMClient sharedRCIMClient] getAllChatRoomEntries:chatroomId success:^(NSDictionary *entry) {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (entry) {
                [dict setObject:entry forKey:@"entry"];
            }
            [dict setObject:@(0) forKey:@"code"];
            result(dict);
        } error:^(RCErrorCode nErrorCode) {
            result(@{@"entry":@{}, @"code": @(nErrorCode)});
        }];
    }
}

- (void)removeChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatroomId = param[@"chatroomId"];
        NSString *key = param[@"key"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] removeChatRoomEntry:chatroomId key:key sendNotification:sendNotification notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            result(@(nErrorCode));
        }];
    }
}

- (void)forceRemoveChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"forceRemoveChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatroomId = param[@"chatroomId"];
        NSString *key = param[@"key"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] forceRemoveChatRoomEntry:chatroomId key:key sendNotification:sendNotification notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            result(@(nErrorCode));
        }];
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


- (void)sendReadReceiptMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"sendReadReceiptMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        long long timestamp = [param[@"timestamp"] longLongValue];
        [[RCIMClient sharedRCIMClient] sendReadReceiptMessage:type targetId:targetId time:timestamp success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@{@"code":@(0)});
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
    }
}

- (void)sendReadReceiptRequest:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"sendReadReceiptRequest";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSDictionary *messageDic = param[@"messageMap"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        [[RCIMClient sharedRCIMClient] sendReadReceiptRequest:message success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@{@"code":@(0)});
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
    }
}

- (void)sendReadReceiptResponse:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"sendReadReceiptResponse";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSArray *messageMapList = param[@"messageMapList"];
        NSMutableArray *messageList = [NSMutableArray arrayWithCapacity:messageMapList.count];
        for (NSDictionary *messageDic in messageMapList) {
            RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
            [messageList addObject:message];
        }
        
        [[RCIMClient sharedRCIMClient] sendReadReceiptResponse:type targetId:targetId messageList:messageList success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@{@"code":@(0)});
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
    }
}

- (void)receiveMessageHasReadNotification:(NSNotification *)notification {

    NSDictionary *dict = @{@"cType":[notification.userInfo objectForKey:@"cType"],
                           @"messageTime":[notification.userInfo objectForKey:@"messageTime"],
                           @"tId":[notification.userInfo objectForKey:@"tId"]
    };
    NSString *LOG_TAG =  @"receiveMessageHasReadNotification";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,dict]];
    [self.channel invokeMethod:RCMethodCallBackKeyReceiveReadReceipt arguments:dict];
}

#pragma mark - 传递数据
- (void)sendDataToFlutter:(NSDictionary *)userInfo {
    NSString *LOG_TAG =  @"sendDataToFlutter";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,userInfo]];
    
    [self.channel invokeMethod:RCMethodCallBackKeySendDataToFlutter arguments:userInfo];
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
    
}

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object offline:(BOOL)offline hasPackage:(BOOL)hasPackage {
    @autoreleasepool {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(nLeft) forKey:@"left"];
        [dic setObject:@(offline) forKey:@"offline"];
        [dic setObject:@(hasPackage) forKey:@"hasPackage"];
        
        [self.channel invokeMethod:RCMethodCallBackKeyReceiveMessage arguments:dic];
    }
}

- (void)onMessageReceiptRequest:(RCConversationType)conversationType
                       targetId:(NSString *)targetId
                     messageUId:(NSString *)messageUId {
    if (messageUId) {
        NSDictionary *statusDic =
        @{ @"targetId" : targetId,
           @"conversationType" : @(conversationType),
           @"messageUId" : messageUId };
        [self.channel invokeMethod:RCMethodCallBackKeyReceiptRequest arguments:statusDic];
    }
}

- (void)onMessageReceiptResponse:(RCConversationType)conversationType
                        targetId:(NSString *)targetId
                      messageUId:(NSString *)messageUId
                      readerList:(NSDictionary *)userIdList {
    NSDictionary *statusDic = @{
        @"targetId" : targetId,
        @"conversationType" : @(conversationType),
        @"messageUId" : messageUId,
        @"readerList" : userIdList
    };
    [self.channel invokeMethod:RCMethodCallBackKeyReceiptResponse arguments:statusDic];
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    NSString *LOG_TAG =  @"onConnectionStatusChanged";
    [RCLog i:[NSString stringWithFormat:@"%@",LOG_TAG]];
    NSDictionary *dic = @{@"status":@(status)};
    [self.channel invokeMethod:RCMethodCallBackKeyConnectionStatusChange arguments:dic];
}

#pragma mark - RCTypingStatusDelegate
- (void)onTypingStatusChanged:(RCConversationType)conversationType targetId:(NSString *)targetId status:(NSArray *)userTypingStatusList {
    
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (RCUserTypingStatus *status in userTypingStatusList) {
        NSString *statusStr = [RCFlutterMessageFactory typingStatus2String:status];
        [statusArray addObject:statusStr];
    }
    
    NSDictionary *statusDic = @{
        @"conversationType" : @(conversationType),
        @"targetId" : targetId,
        @"typingStatus" : [statusArray copy]
    };
    
    [self.channel invokeMethod:RCMethodCallBackKeyTypingStatusChangedCallBack arguments:statusDic];
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
    if([objName isEqualToString:@"RC:ImgMsg"] || [objName isEqualToString:@"RC:HQVCMsg"] || [objName isEqualToString:@"RC:SightMsg"]) {
        return YES;
    }
    return NO;
}

- (NSString *)getCorrectLocalPath:(NSString *)localPath {
    localPath = [localPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [RCLog i:[NSString stringWithFormat:@"sendMediaMessage localPath:%@",localPath]];
    return localPath;
}
@end
