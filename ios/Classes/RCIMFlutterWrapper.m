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
#import "RCUltraGroupClient.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@interface RCCombineMessage : RCMediaMessageContent
/*!
 转发的消息展示的缩略内容列表 (格式是发送者 ：缩略内容)
 */
@property (nonatomic, strong) NSArray *summaryList;

/*!
 转发的全部消息的发送者名称列表 （单聊是经过排重的，群聊是群组名称）
 */
@property (nonatomic, strong) NSArray *nameList;

/*!
 转发的消息会话类型 （目前仅支持单聊和群聊）
 */
@property (nonatomic, assign) RCConversationType conversationType;

/*!
 转发的消息 消息的附加信息
 */
@property (nonatomic, copy) NSString *extra;

/*!
 初始化 RCCombineMessage 消息
 
 @param summaryList         转发的消息展示的缩略内容列表
 @param nameList            转发的全部消息的发送者名称列表 （单聊是经过排重的，群聊是群组名称）
 @param conversationType    转发的消息会话类型
 @param content             转发的内容
 
 @return                    消息对象
 */
+ (instancetype)messageWithSummaryList:(NSArray *)summaryList
                              nameList:(NSArray *)nameList
                      conversationType:(RCConversationType)conversationType
                               content:(NSString *)content;
@end

@interface RCIMFlutterWrapper () <RCIMClientReceiveMessageDelegate,
RCConnectionStatusChangeDelegate,
RCTypingStatusDelegate,
RCMessageDestructDelegate,
RCChatRoomKVStatusChangeDelegate,
RCMessageExpansionDelegate,
RCChatRoomStatusDelegate,
RCTagDelegate,
RCMessageBlockDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) RCFlutterConfig *config;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSMutableArray *registerMessages;
@end

@implementation RCIMFlutterWrapper


static NSString * const VER = @"5.1.8";

+ (void)load {
    [RCUtilities setModuleName:@"imflutter" version:VER];
}

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
        _registerMessages = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessageHasReadNotification:) name:RCLibDispatchReadReceiptNotification object:nil];
    }
    return self;
}

- (void)setFlutterChannel:(FlutterMethodChannel *)channel {
    self.channel = channel;
    
    [[RCUltraGroupClient sharedClient] setFlutterChannel:channel];
    [[RCCoreClient sharedCoreClient] removeReceiveMessageDelegate:self];
    [[RCCoreClient sharedCoreClient] removeConnectionStatusChangeDelegate:self];
    [[RCChatRoomClient sharedChatRoomClient] removeChatRoomKVStatusChangeDelegate:self];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([RCMethodKeyInit isEqualToString:call.method]){
        [self initWithRCIMAppKey:call.arguments];
        result(nil);
    }else if([RCMethodKeyConfig isEqualToString:call.method]){
        [self config:call.arguments];
        result(nil);
    }else if([RCMethodKeySetServerInfo isEqualToString:call.method]) {
        [self setServerInfo:call.arguments];
        result(nil);
    }else if([RCMethodKeyConnect isEqualToString:call.method]) {
        [self connectWithToken:call.arguments result:result];
    }else if([RCMethodKeyDisconnect isEqualToString:call.method]) {
        [self disconnect:call.arguments];
        result(nil);
    }else if([RCMethodKeyRefreshUserInfo isEqualToString:call.method]) {
        [self refreshUserInfo:call.arguments];
        result(nil);
    }else if([RCMethodKeySendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments result:result];
    }else if([RCMethodKeyJoinChatRoom isEqualToString:call.method]) {
        [self joinChatRoom:call.arguments];
        result(nil);
    }else if([RCMethodKeyJoinExistChatRoom isEqualToString:call.method]) {
        [self joinExistChatRoom:call.arguments];
        result(nil);
    }else if([RCMethodKeyQuitChatRoom isEqualToString:call.method]) {
        [self quitChatRoom:call.arguments];
        result(nil);
    }else if([RCMethodKeyGetHistoryMessage isEqualToString:call.method]) {
        [self getHistoryMessage:call.arguments result:result];
    }else if([RCMethodKeyGetHistoryMessages.lowercaseString isEqualToString:call.method.lowercaseString]) {
        [self getHistoryMessages:call.arguments result:result];
    }else if ([RCMethodKeyGetMessage isEqualToString:call.method]) {
        [self getMessage:call.arguments result:result];
    }else if ([RCMethodKeyGetMessages isEqualToString:call.method]) {
        [self getMessages:call.arguments result:result];
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
        result(nil);
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
    }else if ([RCMethodKeySetChatRoomEntries isEqualToString:call.method]) {
        [self setChatRoomEntries:call.arguments result:result];
    }else if ([RCMethodKeyRemoveChatRoomEntries isEqualToString:call.method]) {
        [self removeChatRoomEntries:call.arguments result:result];
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
    }else if([RCMethodKeySendDirectionalMessage isEqualToString:call.method]) {
        [self sendDirectionalMessage:call.arguments result:result];
    }else if([RCMethodKeyMessageBeginDestruct isEqualToString:call.method]) {
        [self messageBeginDestruct:call.arguments result:result];
    }else if([RCMethodKeyMessageStopDestruct isEqualToString:call.method]) {
        [self messageStopDestruct:call.arguments result:result];
    }else if([RCMethodKeySetReconnectKickEnable isEqualToString:call.method]) {
        [self setReconnectKickEnable:call.arguments result:result];
    }else if([RCMethodKeyGetConnectionStatus isEqualToString:call.method]) {
        [self getConnectionStatus:call.arguments result:result];
    }else if([RCMethodKeyCancelDownloadMediaMessage isEqualToString:call.method]) {
        [self cancelDownloadMediaMessage:call.arguments result:result];
    }else if([RCMethodKeyGetRemoteChatRoomHistoryMessages isEqualToString:call.method]) {
        [self getRemoteChatroomHistoryMessages:call.arguments result:result];
    }else if([RCMethodKeyGetMessageByUId isEqualToString:call.method]) {
        [self getMessageByUId:call.arguments result:result];
    }else if([RCMethodKeyDeleteRemoteMessages isEqualToString:call.method]) {
        [self deleteRemoteMessages:call.arguments result:result];
    }else if([RCMethodKeyClearMessages isEqualToString:call.method]) {
        [self clearMessages:call.arguments result:result];
    }else if([RCMethodKeySetMessageExtra isEqualToString:call.method]) {
        [self setMessageExtra:call.arguments result:result];
    }else if([RCMethodKeySetMessageReceivedStatus isEqualToString:call.method]) {
        [self setMessageReceivedStatus:call.arguments result:result];
    }else if([RCMethodKeySetMessageSentStatus isEqualToString:call.method]) {
        [self setMessageSentStatus:call.arguments result:result];
    }else if([RCMethodKeyClearConversations isEqualToString:call.method]) {
        [self clearConversations:call.arguments result:result];
    }else if([RCMethodKeyGetDeltaTime isEqualToString:call.method]) {
        [self getDeltaTime:call.arguments result:result];
    }else if([RCMethodKeySetOfflineMessageDuration isEqualToString:call.method]) {
        [self setOfflineMessageDuration:call.arguments result:result];
    }else if([RCMethodKeyGetOfflineMessageDuration isEqualToString:call.method]) {
        [self getOfflineMessageDuration:call.arguments result:result];
    }else if([RCMethodKeyGetFirstUnreadMessage isEqualToString:call.method]) {
        [self getFirstUnreadMessage:call.arguments result:result];
    }else if([RCMethodKeySendIntactMessage isEqualToString:call.method]) {
        [self sendIntactMessage:call.arguments result:result];
    }else if([RCMethodKeyUpdateMessageExpansion isEqualToString:call.method]) {
        [self updateMessageExpansion:call.arguments result:result];
    }else if([RCMethodKeyRemoveMessageExpansionForKey isEqualToString:call.method]) {
        [self removeMessageExpansionForKey:call.arguments result:result];
    }else if([RCMethodKeyBatchInsertMessage isEqualToString:call.method]) {
        [self batchInsertMessage:call.arguments result:result];
    }else if([RCMethodKeyImageCompressConfig isEqualToString:call.method]) {
        [self imageCompressConfig:call.arguments result:result];
    }else if([RCMethodKeyTypingUpdateSeconds isEqualToString:call.method]) {
        [self typingUpdateSeconds:call.arguments result:result];
    }else if([RCMethodKeyAddTag isEqualToString:call.method]) {
        [self addTag:call.arguments result:result];
    }else if([RCMethodKeyRemoveTag isEqualToString:call.method]) {
        [self removeTag:call.arguments result:result];
    }else if([RCMethodKeyUpdateTag isEqualToString:call.method]) {
        [self updateTag:call.arguments result:result];
    }else if([RCMethodKeyGetTags isEqualToString:call.method]) {
        [self getTags:call.arguments result:result];
    }else if([RCMethodKeyAddConversationsToTag isEqualToString:call.method]) {
        [self addConversationsToTag:call.arguments result:result];
    }else if([RCMethodKeyRemoveConversationsFromTag isEqualToString:call.method]){
        [self removeConversationsFromTag:call.arguments result:result];
    }else if([RCMethodKeyRemoveTagsFromConversation isEqualToString:call.method]){
        [self removeTagsFromConversation:call.arguments result:result];
    }else if([RCMethodKeyGetTagsFromConversation isEqualToString:call.method]){
        [self getTagsFromConversation:call.arguments result:result];
    }else if([RCMethodKeyGetConversationsFromTagByPage isEqualToString:call.method]){
        [self getConversationsFromTagByPage:call.arguments result:result];
    }else if([RCMethodKeyGetUnreadCountByTag isEqualToString:call.method]){
        [self getUnreadCountByTag:call.arguments result:result];
    }else if([RCMethodKeySetConversationToTopInTag isEqualToString:call.method]){
        [self setConversationToTopInTag:call.arguments result:result];
    }else if([RCMethodKeyGetConversationTopStatusInTag isEqualToString:call.method]){
        [self getConversationTopStatusInTag:call.arguments result:result];
    }else if ([RCMethodKeySetAndroidPushConfig isEqualToString:call.method]){
        //配合安卓做的安卓推送。这里不写会抛异常。所以写了个空方法
        result(nil);
    }else if ([RCMethodKeySetStatisticServer isEqualToString:call.method]) {
        [self setStatisticServer:call.arguments];
        result(nil);
    }else if ([call.method hasPrefix:RCUltraGroup]) {
        // 处理超级群相关业务
        [[RCUltraGroupClient sharedClient] handleMethodCall:call result:result];
    }else if ([RCMethodKeyCancelSendMediaMessage isEqualToString:call.method]) {
        [self cancelSendMediaMessage:call.arguments result:result];
    }else {
        result(FlutterMethodNotImplemented);
    }
    
}

#pragma mark - selector

- (void)initWithRCIMAppKey:(id)arg {
    NSString *LOG_TAG =  @"initWithRCIMAppKey";
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *conf = (NSDictionary *)arg;
        NSString *appkey = [conf objectForKey:@"appkey"];
        [RCChannelClient sharedChannelManager];
        [[RCCoreClient sharedCoreClient] initWithAppKey:appkey];
        
        /// imlib 默认检测到小视频 SDK，才会注册小视频消息，但是这里没有小视频 SDK
        [[RCCoreClient sharedCoreClient] registerMessageType:RCSightMessage.class];
        
        [[RCCoreClient sharedCoreClient] removeReceiveMessageDelegate:self];
        [[RCCoreClient sharedCoreClient] removeConnectionStatusChangeDelegate:self];
        [[RCChatRoomClient sharedChatRoomClient] removeChatRoomKVStatusChangeDelegate:self];
        
        [[RCCoreClient sharedCoreClient] addReceiveMessageDelegate:self];
        [[RCCoreClient sharedCoreClient] addConnectionStatusChangeDelegate:self];
        [[RCChatRoomClient sharedChatRoomClient] addChatRoomKVStatusChangeDelegate:self];
        
        [[RCCoreClient sharedCoreClient] setRCTypingStatusDelegate:self];
        [[RCCoreClient sharedCoreClient] setRCMessageDestructDelegate:self];
        [[RCChatRoomClient sharedChatRoomClient] setChatRoomStatusDelegate:self];
        [[RCCoreClient sharedCoreClient] setMessageExpansionDelegate:self];
        [RCCoreClient sharedCoreClient].tagDelegate = self;
        [[RCCoreClient sharedCoreClient] setMessageBlockDelegate:self];
        
        [[RCUltraGroupClient sharedClient] setUltraGroupDelegate];
        self.sdkVersion = [conf objectForKey:@"version"];
    }else {
        [RCLog e:[NSString stringWithFormat:@"%@,非法参数",LOG_TAG]];
    }
}

- (void)registerMessageType:(Class)messageClass {
    if (!messageClass) {
        return;
    }else {
        [self.registerMessages addObject:messageClass];
    }
}

- (void)config:(id)arg {
    NSString *LOG_TAG =  @"config";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *conf = (NSDictionary *)arg;
        RCFlutterConfig *config = [[RCFlutterConfig alloc] init];
        [config updateConf:conf];
        self.config = config;
        [self updateIMConfig];
    }else {
        [RCLog e:[NSString stringWithFormat:@"%@,非法参数",LOG_TAG]];
    }
}

- (void)setServerInfo:(id)arg {
    NSString *LOG_TAG =  @"setServerInfo";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *naviServer = dic[@"naviServer"];
        NSString *fileServer = dic[@"fileServer"];
        [[RCCoreClient sharedCoreClient] setServerInfo:naviServer fileServer:fileServer];
    }
}

- (void)setStatisticServer:(id)arg {
    NSString *LOG_TAG = @"setStatisticServer";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if(![arg isKindOfClass:[NSDictionary class]]) {
        [RCLog e:@"arguments invalid"];
        return;
    }
    NSDictionary *dic = (NSDictionary *)arg;
    NSString *statisticServer = dic[@"statisticServer"];
    [[RCCoreClient sharedCoreClient] setStatisticServer:statisticServer];
}

- (void)cancelSendMediaMessage:(id)arg result:(FlutterResult)result {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        BOOL res = [[RCCoreClient sharedCoreClient] cancelSendMediaMessage:message.messageId];
        result(@(res ? 0 : -1));
    }
}

- (void)connectWithToken:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"connect";
    //    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]]
    if (self.registerMessages && self.registerMessages.count > 0) {
        for (Class message in self.registerMessages) {
            [[RCCoreClient sharedCoreClient] registerMessageType:message];
        }
        [self.registerMessages removeAllObjects];
    }
    if([arg isKindOfClass:[NSString class]]) {
        NSString *token = (NSString *)arg;
        [[RCCoreClient sharedCoreClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
            [RCLog i:[NSString stringWithFormat:@"%@, dbOpened，code: %@",LOG_TAG, @(code)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(0) forKey:@"code"];
            [self.channel invokeMethod:RCMethodCallBackDatabaseOpened arguments:dic];
        } success:^(NSString *userId) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:userId forKey:@"userId"];
            [dic setObject:@(0) forKey:@"code"];
            result(dic);
        } error:^(RCConnectErrorCode errorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, fail %@",LOG_TAG,@(errorCode)]];
            result(@{@"code":@(errorCode), @"userId":@""});
        }];
    }
}

- (void)disconnect:(id)arg  {
    NSString *LOG_TAG =  @"disconnect";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSNumber class]]) {
        BOOL needPush = [((NSNumber *) arg) boolValue];
        [[RCCoreClient sharedCoreClient] disconnect:needPush];
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
            [[RCCoreClient sharedCoreClient] setCurrentUserInfo:user];
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
            //            [[RCCoreClient sharedCoreClient] refreshUserInfoCache:user withUserId:userId];
        }
    }
}

- (void)sendMessage:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG =  @"sendMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *objName = param[@"objectName"];
        NSString *contentStr = param[@"content"];
        long long timestamp = [param[@"timestamp"] longLongValue];
        // 如果 remoteUrl 不为空，走 sendMessage
        if(![self isForwardMessage:contentStr objName:objName] && [self isMediaMessage:objName]) {
            //        if([self isMediaMessage:objName]) {
            [self sendMediaMessage:arg result:result];
            return;
        }
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
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
        } else {
            content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        }
        if(content == nil) {
            [RCLog e:[NSString stringWithFormat:@"%@,  message content is nil",LOG_TAG]];
            result(nil);
            return;
        }
        
        __weak typeof(self) ws = self;
        if (param[@"disableNotification"]) {
            BOOL disableNotification = [param[@"disableNotification"] boolValue];
            RCMessage *message = [[RCMessage alloc] initWithType:type targetId:targetId direction:MessageDirection_SEND messageId:0 content:content];
            message.channelId = channelId;
            message.messageConfig.disableNotification = disableNotification;
            message = [[RCCoreClient sharedCoreClient] sendMessage:message pushContent:pushContent pushData:pushData successBlock:^(RCMessage *successMessage) {
                [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(successMessage.messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_SENT) forKey:@"status"];
                [dic setObject:@(0) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
                [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(errorMessage.messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
                [dic setObject:@(nErrorCode) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            }];
            message.senderUserId = [RCCoreClient sharedCoreClient].currentUserInfo.userId ?: @"";
            NSString *jsonString = [RCFlutterMessageFactory message2String:message];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:jsonString forKey:@"message"];
            [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
            [dic setObject:@(message.messageId) forKey:@"messageId"];
            [dic setObject:@(-1) forKey:@"code"];
            result(dic);
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } else {
            RCMessage *message = [[RCCoreClient sharedCoreClient] sendMessage:type targetId:targetId content:content pushContent:pushContent pushData:pushData success:^(long messageId) {
                [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_SENT) forKey:@"status"];
                [dic setObject:@(0) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            } error:^(RCErrorCode nErrorCode, long messageId) {
                [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
                [dic setObject:@(nErrorCode) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            }];
            NSString *jsonString = [RCFlutterMessageFactory message2String:message];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:jsonString forKey:@"message"];
            [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
            [dic setObject:@(message.messageId) forKey:@"messageId"];
            [dic setObject:@(-1) forKey:@"code"];
            result(dic);
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        }
    }
}

- (void)sendIntactMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"sendIntactMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCMessage *message = [RCFlutterMessageFactory dic2Message:param];
        NSString *objName = param[@"objectName"];
        NSString *contentStr = param[@"content"];
        long long timestamp = [param[@"timestamp"] longLongValue];
        // 如果 remoteUrl 不为空，走 sendMessage
        if(![self isForwardMessage:contentStr objName:objName] && [self isMediaMessage:objName]) {
            [self sendMediaMessageWithMessage:arg result:result];
            return;
        }
        
        NSString *pushContent = param[@"pushContent"];
        if(pushContent.length <= 0) {
            pushContent = nil;
        }
        NSString *pushData = param[@"pushData"];
        if(pushData.length <= 0) {
            pushData = nil;
        }
        
        __weak typeof(self) ws = self;
        message = [[RCCoreClient sharedCoreClient] sendMessage:message pushContent:pushContent pushData:pushData successBlock:^(RCMessage *successMessage) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(successMessage.messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(errorMessage.messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(nErrorCode) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        }];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
        [dic setObject:@(message.messageId) forKey:@"messageId"];
        [dic setObject:@(-1) forKey:@"code"];
        result(dic);
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    }
}

- (void)sendMediaMessageWithMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"sendMediaMessageWithMessage";
    NSDictionary *param = (NSDictionary *)arg;
    RCMessage *message = [RCFlutterMessageFactory dic2Message:param];
    long long timestamp = [param[@"timestamp"] longLongValue];
    NSString *pushContent = param[@"pushContent"];
    if(pushContent.length <= 0) {
        pushContent = nil;
    }
    NSString *pushData = param[@"pushData"];
    if(pushData.length <= 0) {
        pushData = nil;
    }
    
    RCMessageContent *content = [self converMessageContent:param];
    if (content) {
        message.content = content;
    } else {
        [RCLog e:[NSString stringWithFormat:@"%@ content is nil",LOG_TAG]];
        return;
    }
    
    if([message.content isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)message.content;
        if(sightMsg.duration > 120) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(-1) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(RC_SIGHT_MSG_DURATION_LIMIT_EXCEED) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [RCLog e:[NSString stringWithFormat:@"%@, 小视频时间超限",LOG_TAG]];
            [self.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            return;
        }
    }
    
    __weak typeof(self) ws = self;
    message = [[RCCoreClient sharedCoreClient] sendMediaMessage:message pushContent:pushContent pushData:pushData progress:^(int progress, RCMessage *progressMessage) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(progressMessage.messageId) forKey:@"messageId"];
        [dic setObject:@(progress) forKey:@"progress"];
        [ws.channel invokeMethod:RCMethodCallBackKeyUploadMediaProgress arguments:dic];
    } successBlock:^(RCMessage *successMessage) {
        [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(successMessage.messageId) forKey:@"messageId"];
        [dic setObject:@(SentStatus_SENT) forKey:@"status"];
        [dic setObject:@(0) forKey:@"code"];
        if (timestamp > 0) {
            [dic setObject:@(timestamp) forKey:@"timestamp"];
        }
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(errorMessage.messageId) forKey:@"messageId"];
        [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
        [dic setObject:@(nErrorCode) forKey:@"code"];
        if (timestamp > 0) {
            [dic setObject:@(timestamp) forKey:@"timestamp"];
        }
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } cancel:^(RCMessage *cancelMessage) {
        
    }];
    message.senderUserId = [RCCoreClient sharedCoreClient].currentUserInfo.userId ?: @"";
    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:jsonString forKey:@"message"];
    [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
    [dic setObject:@(message.messageId) forKey:@"messageId"];
    [dic setObject:@(-1) forKey:@"code"];
    result(dic);
    [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
}

- (RCMediaMessageContent *)converMessageContent:(NSDictionary *)param {
    NSString *LOG_TAG = @"converMessageContent";
    NSString *contentStr = param[@"content"];
    NSString *objName = param[@"objectName"];
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    RCMediaMessageContent *content = nil;
    RCUserInfo *sendUserInfo = nil;
    RCMentionedInfo *mentionedInfo = nil;
    NSString *remoteUrl = @"";
    
    if ([msgDic valueForKey:@"remoteUrl"]) {
        remoteUrl = msgDic[@"remoteUrl"];
    }
    if ([msgDic valueForKey:@"user"]) {
        NSDictionary *userDict = [msgDic valueForKey:@"user"];
        NSString *userId = [userDict valueForKey:@"id"] ?: @"";
        NSString *name = [userDict valueForKey:@"name"] ?: @"";
        NSString *portraitUri = [userDict valueForKey:@"portrait"] ?: @"";
        NSString *extra = [userDict valueForKey:@"extra"] ?: @"";
        sendUserInfo = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portraitUri];
        sendUserInfo.extra = extra;
    }
    
    if ([msgDic valueForKey:@"mentionedInfo"]) {
        NSDictionary *mentionedInfoDict = [msgDic valueForKey:@"mentionedInfo"];
        RCMentionedType type = [[mentionedInfoDict valueForKey:@"type"] intValue] ?: 1;
        NSArray *userIdList = [mentionedInfoDict valueForKey:@"userIdList"] ?: @[];
        NSString *mentionedContent = [mentionedInfoDict valueForKey:@"mentionedContent"] ?: @"";
        mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:type userIdList:userIdList mentionedContent:mentionedContent];
    }
    
    NSString *localPath = [msgDic valueForKey:@"localPath"] ?: @"";
    if (!localPath || [localPath isKindOfClass:[NSNull class]]) {
        localPath = @"";
    }
    localPath = [self getCorrectLocalPath:localPath];
    
    NSInteger burnDuration = [[msgDic valueForKey:@"burnDuration"] integerValue];
    if([objName isEqualToString:@"RC:ImgMsg"]) {
        NSString *extra = [msgDic valueForKey:@"extra"];
        if ([msgDic objectForKey:@"imageUri"]) {
            remoteUrl = msgDic[@"imageUri"];
        }
        content = [RCImageMessage messageWithImageURI:localPath];
        RCImageMessage *imgMsg = (RCImageMessage *)content;
        imgMsg.extra = extra;
    } else if ([objName isEqualToString:@"RC:HQVCMsg"]) {
        long duration = [[msgDic valueForKey:@"duration"] longValue];
        NSString *extra = [msgDic valueForKey:@"extra"];
        content = [RCHQVoiceMessage messageWithPath:localPath duration:duration];
        RCHQVoiceMessage *hqVoiceMsg = (RCHQVoiceMessage *)content;
        hqVoiceMsg.extra = extra;
    } else if ([objName isEqualToString:@"RC:SightMsg"]) {
        long duration = [[msgDic valueForKey:@"duration"] longValue];
        if ([msgDic objectForKey:@"sightUrl"]) {
            remoteUrl = msgDic[@"sightUrl"];
        }
        NSString *extra = [msgDic valueForKey:@"extra"];
        NSString *thumbnailBase64String = [msgDic valueForKey:@"content"];
        UIImage *thumbImg = [RCFlutterUtil getVideoPreViewImage:localPath];
        if (!thumbImg) {
            thumbImg = [RCFlutterUtil getThumbnailImage:thumbnailBase64String];
        }
        content = [RCSightMessage messageWithLocalPath:localPath thumbnail:thumbImg duration:duration];
        RCSightMessage *sightMsg = (RCSightMessage *)content;
        sightMsg.extra = extra;
    } else if ([objName isEqualToString:@"RC:FileMsg"]) {
        if ([msgDic objectForKey:@"fileUrl"]) {
            remoteUrl = msgDic[@"fileUrl"];
        }
        NSString *extra = [msgDic valueForKey:@"extra"] ?: @"";
        content = [RCFileMessage messageWithFile:localPath];
        RCFileMessage *fileMsg = (RCFileMessage *)content;
        fileMsg.extra = extra;
    } else if ([objName isEqualToString:@"RC:GIFMsg"]) {
        NSString *extra = [msgDic valueForKey:@"extra"];
        long width = [[msgDic valueForKey:@"width"] longValue];
        long height = [[msgDic valueForKey:@"height"] longValue];
        if (width <= 0 || height <= 0) {
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            width = image.size.width;
            height = image.size.height;
        }
        content = [RCGIFMessage messageWithGIFURI:localPath width:width height:height];
        RCGIFMessage *gifMsg = (RCGIFMessage *)content;
        gifMsg.extra = extra;
    } else if ([objName isEqualToString:@"RC:CombineMsg"]) {
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        localPath = [self getCorrectLocalPath:localPath];
        NSString *extra = [msgDic valueForKey:@"extra"];
        NSArray * nameList = @[];
        if (![[msgDic valueForKey:@"nameList"] isKindOfClass:[NSNull class]]) {
            nameList = [msgDic valueForKey:@"nameList"];
        }
        NSArray * summaryList = [msgDic valueForKey:@"summaryList"] ?: @[];
        RCConversationType type = [param[@"conversationType"] integerValue];
        
        content = [RCCombineMessage messageWithSummaryList:summaryList nameList:nameList conversationType:type content:@""];
        RCCombineMessage *combineMsg = (RCCombineMessage *)content;
        combineMsg.localPath = localPath;
        combineMsg.extra = extra;
    } else {
        [RCLog e:[NSString stringWithFormat:@"%@, 非法的媒体消息类型",LOG_TAG]];
        return nil;
    }
    
    if (sendUserInfo) {
        content.senderUserInfo = sendUserInfo;
    }
    if (mentionedInfo) {
        content.mentionedInfo = mentionedInfo;
    }
    
    if (burnDuration > 0) {
        content.destructDuration = burnDuration;
    } else {
        content.destructDuration = 0;
    }
    
    if (!remoteUrl || [remoteUrl isKindOfClass:[NSNull class]]) {
        content.remoteUrl = @"";
    } else {
        content.remoteUrl = remoteUrl;
    }
    
    return content;
}

- (void)sendMediaMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"sendMediaMessage";
    NSDictionary *param = (NSDictionary *)arg;
    RCConversationType type = [param[@"conversationType"] integerValue];
    NSString *targetId = param[@"targetId"];
    NSString *channelId = param[@"channelId"];
    NSString *pushContent = param[@"pushContent"];
    long long timestamp = [param[@"timestamp"] longLongValue];
    if(pushContent.length <= 0) {
        pushContent = nil;
    }
    NSString *pushData = param[@"pushData"];
    if(pushData.length <= 0) {
        pushData = nil;
    }
    RCMediaMessageContent *content = [self converMessageContent:param];
    
    if([content isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)content;
        if(sightMsg.duration > 120) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(-1) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(RC_SIGHT_MSG_DURATION_LIMIT_EXCEED) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [RCLog e:[NSString stringWithFormat:@"%@, 小视频时间超限",LOG_TAG]];
            [self.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            return;
        }
    }
    
    __weak typeof(self) ws = self;
    if (param[@"disableNotification"]) {
        BOOL disableNotification = [param[@"disableNotification"] boolValue];
        RCMessage *message = [[RCMessage alloc] initWithType:type targetId:targetId direction:MessageDirection_SEND messageId:0 content:content];
        message.messageConfig.disableNotification = disableNotification;
        message.channelId = channelId;
        message = [[RCCoreClient sharedCoreClient] sendMediaMessage:message pushContent:pushContent pushData:pushData progress:^(int progress, RCMessage *progressMessage) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(progressMessage.messageId) forKey:@"messageId"];
            [dic setObject:@(progress) forKey:@"progress"];
            [ws.channel invokeMethod:RCMethodCallBackKeyUploadMediaProgress arguments:dic];
        } successBlock:^(RCMessage *successMessage) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(successMessage.messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(errorMessage.messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(nErrorCode) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } cancel:^(RCMessage *cancelMessage) {
            
        }];
        message.senderUserId = [RCCoreClient sharedCoreClient].currentUserInfo.userId ?: @"";
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
        [dic setObject:@(message.messageId) forKey:@"messageId"];
        [dic setObject:@(-1) forKey:@"code"];
        result(dic);
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } else {
        
        
        RCMessage *message = [[RCChannelClient sharedChannelManager] sendMediaMessage:type targetId:targetId channelId:channelId content:content pushContent:pushContent pushData:pushData progress:^(int progress, long messageId) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(progress) forKey:@"progress"];
            [ws.channel invokeMethod:RCMethodCallBackKeyUploadMediaProgress arguments:dic];
        } success:^(long messageId) {
            [RCLog i:[NSString stringWithFormat:@"%@, sucess ,messageId %@",LOG_TAG,@(messageId)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } error:^(RCErrorCode errorCode, long messageId) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(errorCode)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(errorCode) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } cancel:^(long messageId) {
            
        }];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
        [dic setObject:@(message.messageId) forKey:@"messageId"];
        [dic setObject:@(-1) forKey:@"code"];
        result(dic);
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        
    }
}

- (void)sendDirectionalMessage:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG = @"sendDirectionalMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *objName = param[@"objectName"];
        if([self isMediaMessage:objName]) {
            [self sendMediaMessage:arg result:result];
            return;
        }
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        NSArray *userIdList = param[@"userIdList"];
        NSString *contentStr = param[@"content"];
        NSString *pushContent = param[@"pushContent"];
        bool   isVoIPPush = param[@"option"];
        RCSendMessageOption *option = [[RCSendMessageOption alloc] init];
        option.isVoIPPush = isVoIPPush;
        long long timestamp = [param[@"timestamp"] longLongValue];
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
        
        
        RCMessage *message = [[RCChannelClient sharedChannelManager] sendDirectionalMessage:type targetId:targetId channelId:channelId toUserIdList:userIdList content:content pushContent:pushContent pushData:pushData option:option  success:^(long messageId) {
            [RCLog i:[NSString stringWithFormat:@"%@, success, messageId %@",LOG_TAG ,@(messageId)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(nErrorCode) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        }];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
        result(dic);
    }
}

- (void)joinChatRoom:(id)arg {
    NSString *LOG_TAG =  @"joinChatRoom";
    [RCLog i:[NSString stringWithFormat:@"%@ ,start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        int msgCount = [dic[@"messageCount"] intValue];
        
        __weak typeof(self) ws = self;
        [[RCChatRoomClient sharedChatRoomClient] joinChatRoom:targetId messageCount:msgCount success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ ,success",LOG_TAG]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(status) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        }];
    }
}

- (void)joinExistChatRoom:(id)arg {
    NSString *LOG_TAG =  @"joinExistChatRoom";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        int msgCount = [dic[@"messageCount"] intValue];
        
        if ([targetId isKindOfClass:[NSNull class]]) {
            [RCLog e:[NSString stringWithFormat:@"%@, targetId is nil",LOG_TAG]];
            return;
        }
        
        __weak typeof(self) ws = self;
        [[RCChatRoomClient sharedChatRoomClient] joinExistChatRoom:targetId messageCount:msgCount success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(status) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        }];
    }
}

- (void)quitChatRoom:(id)arg {
    NSString *LOG_TAG =  @"quitChatRoom";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        
        __weak typeof(self) ws = self;
        [[RCChatRoomClient sharedChatRoomClient] quitChatRoom:targetId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyQuitChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            [RCLog i:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(status) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyQuitChatRoom arguments:callbackDic];
        }];
    }
}

- (void)getHistoryMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getHistoryMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        NSString *channelId = dic[@"channelId"];
        int messageId = [dic[@"messageId"] intValue];
        int count = [dic[@"count"] intValue];
        NSArray <RCMessage *> *msgs = [[RCChannelClient sharedChannelManager] getHistoryMessages:type targetId:targetId channelId:channelId oldestMessageId:messageId count:count];
        //        NSArray <RCMessage *> *msgs = [[RCCoreClient sharedCoreClient] getHistoryMessages:type targetId:targetId oldestMessageId:messageId count:count];
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        NSString *channelId = dic[@"channelId"];
        long long sentTime = [dic[@"sentTime"] longLongValue];
        int beforeCount = [dic[@"beforeCount"] intValue];
        int afterCount = [dic[@"afterCount"] intValue];
        
        //        NSArray <RCMessage *> *msgs = [[RCCoreClient sharedCoreClient] getHistoryMessages:type targetId:targetId sentTime:sentTime beforeCount:beforeCount afterCount:afterCount];
        NSArray <RCMessage *> *msgs = [[RCChannelClient sharedChannelManager] getHistoryMessages:type targetId:targetId channelId:channelId sentTime:sentTime beforeCount:beforeCount afterCount:afterCount];
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        int messageId = [dic[@"messageId"] intValue];
        RCMessage *message = [[RCCoreClient sharedCoreClient] getMessage:messageId];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(jsonString);
    }
}

- (void)getMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getMessages";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        NSString *channelId = dic[@"channelId"];
        long recordTime = [dic[@"recordTime"] longValue];
        int count = [dic[@"count"] intValue];
        int order = [dic[@"order"] intValue];
        RCHistoryMessageOption *option = [[RCHistoryMessageOption alloc] init];
        option.count = count;
        option.recordTime = recordTime;
        option.order = order;
        
        [[RCChannelClient sharedChannelManager] getMessages:type targetId:targetId channelId:channelId option:option complete:^(NSArray *messages, long long timestamp, BOOL isRemaining, RCErrorCode code) {
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            
            
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSMutableArray *msgsArray = [NSMutableArray new];
            if (messages &&messages.count > 0) {
                for(RCMessage *message in messages) {
                    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
                    [msgsArray addObject:jsonString];
                }
            }
            [callbackDic setObject:@(code) forKey:@"code"];
            [callbackDic setObject:msgsArray.copy forKey:@"messages"];
            [callbackDic setObject:@(timestamp) forKey:@"timestamp"];
            [callbackDic setObject:@(isRemaining) forKey:@"isRemaining"];
            result(callbackDic);
        } error:^(RCErrorCode status) {
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(status) forKey:@"code"];
            result(callbackDic);
        }];
    }
}

- (void)getRemoteHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getRemoteHistoryMessages";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        NSString *channelId = dic[@"channelId"];
        long recordTime = [dic[@"recordTime"] longValue];
        int count = [dic[@"count"] intValue];
        
        [[RCChannelClient sharedChannelManager] getRemoteHistoryMessages:type targetId:targetId channelId:channelId recordTime:recordTime count:count success:^(NSArray *messages, BOOL isRemaining) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
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
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(status) forKey:@"code"];
            result(callbackDic);
        }];
    }
}

- (void)getConversationList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationList";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        NSString *channelId = param[@"channelId"];
        
        //        NSArray *conversations = [[RCCoreClient sharedCoreClient] getConversationList:typeArray];
        NSArray *conversations = [[RCChannelClient sharedChannelManager] getConversationList:typeArray channelId:channelId];
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        NSLog(@"getConversationListByPage count : %ld",typeArray.count);
        int count = [param[@"count"] intValue];
        NSString *channelId = param[@"channelId"];
        long long startTime = [param[@"startTime"] longLongValue];
        
        //        NSArray *conversations = [[RCCoreClient sharedCoreClient] getConversationList:typeArray count:count startTime:startTime];
        
        NSArray *conversations = [[RCChannelClient sharedChannelManager] getConversationList:typeArray channelId:channelId count:count startTime:startTime];
        
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType conversationType = [param[@"conversationType"] intValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        
        //        RCConversation *con = [[RCCoreClient sharedCoreClient] getConversation:conversationType targetId:targetId];
        RCConversation *con = [[RCChannelClient sharedChannelManager] getConversation:conversationType targetId:targetId channelId:channelId];
        NSString *conStr = @"";
        if(con) {
            conStr = [RCFlutterMessageFactory conversation2String:con];
        }
        result(conStr);
    }
}

- (void)getChatRoomInfo:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getChatRoomInfo";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        int memberCount = [dic[@"memeberCount"] intValue];
        int memberOrder = [dic[@"memberOrder"] intValue];
        [[RCChatRoomClient sharedChatRoomClient] getChatRoomInfo:targetId count:memberCount order:memberOrder success:^(RCChatRoomInfo *chatRoomInfo) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSDictionary *resultDic = [RCFlutterMessageFactory chatRoomInfo2Dictionary:chatRoomInfo];
            result(resultDic);
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(nil);
        }];
        
    }
}

- (void)clearMessagesUnreadStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"clearMessagesUnreadStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type = (RCConversationType)[dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        NSString *channelId = dic[@"channelId"];
        //        BOOL rc = [[RCCoreClient sharedCoreClient] clearMessagesUnreadStatus:type targetId:targetId];
        BOOL rc = [[RCChannelClient sharedChannelManager] clearMessagesUnreadStatus:type targetId:targetId channelId:channelId];
        if (rc) {
            NSLog(@"清除成功了");
        } else {
            NSLog(@"清除失败了");
        }
        result([NSNumber numberWithBool:rc]);
    }
}

- (void)imageCompressConfig:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"imageCompressConfig";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        CGFloat maxSize = (CGFloat)[param[@"maxSize"] floatValue];
        CGFloat minSize = (CGFloat)[param[@"minSize"] floatValue];
        CGFloat quality = (CGFloat)[param[@"quality"] floatValue];
        RCImageCompressConfig *config = [[RCImageCompressConfig alloc] init];
        config.maxSize= maxSize;
        config.minSize= minSize;
        config.quality= quality;
        [RCCoreClient sharedCoreClient].imageCompressConfig = config;
    }
}

- (void)typingUpdateSeconds:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"typingUpdateSeconds";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSInteger  typingUpdateSeconds = [param[@"typingUpdateSeconds"] integerValue];
        [RCCoreClient sharedCoreClient].typingUpdateSeconds = typingUpdateSeconds;
    }
}

#pragma mark -  标签变化监听器
- (void)onTagChanged {
    [self.channel invokeMethod:RCMethodCallBackOnTagChanged arguments:nil];
}

#pragma mark -  敏感消息拦截监听
- (void)messageDidBlock:(RCBlockedMessageInfo *)info {
    NSDictionary *arguments = @{ @"conversationType" : @(info.type),
                                 @"targetId" : info.targetId,
                                 @"blockMsgUId" : info.blockedMsgUId,
                                 @"blockType" : @(info.blockType),
                                 @"extra" : info.extra ? info.extra : @"" };
    [self.channel invokeMethod:RCMethodCallBackOnMessageBlocked arguments:arguments];
}

#pragma mark - 会话标签
- (void)addTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"addTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        NSString *tagName = param[@"tagName"];
        NSInteger count = [param[@"count"] integerValue];
        NSString *timestamp = param[@"timestamp"];
        RCTagInfo *tagInfo = [[RCTagInfo alloc] init];
        tagInfo.tagId = tagId;
        tagInfo.tagName = tagName;
        tagInfo.count = count;
        tagInfo.timestamp = [timestamp longLongValue];
        [[RCCoreClient sharedCoreClient] addTag:tagInfo success:^{
            result(@{@"code":@(0)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code":@(errorCode)});
        }];
    }
}

- (void)removeTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        [[RCCoreClient sharedCoreClient] removeTag:tagId success:^{
            result(@{@"code":@(0)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code":@(errorCode)});
        }];
    }
}

- (void)updateTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"updateTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        NSString *tagName = param[@"tagName"];
        NSInteger count = [param[@"count"] integerValue];
        NSString *timestamp = param[@"timestamp"];
        RCTagInfo *tagInfo = [[RCTagInfo alloc] init];
        tagInfo.tagId = tagId;
        tagInfo.tagName = tagName;
        tagInfo.count = count;
        tagInfo.timestamp = [timestamp longLongValue];
        [[RCCoreClient sharedCoreClient] updateTag:tagInfo success:^{
            result(@{@"code":@(0)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code":@(errorCode)});
        }];
    }
}

- (void)getTags:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getTags";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    NSArray *tags =  [RCCoreClient sharedCoreClient].getTags;
    if (tags.count > 0) {
        NSMutableArray *arr = [NSMutableArray new];
        for(RCTagInfo *info in tags) {
            NSString *conStr = [RCFlutterMessageFactory tagInfo2String:info];
            [arr addObject:conStr];
        }
        result(@{@"code": @(0), @"getTags": [arr copy]});
    }else {
        result(@{@"code": @(0), @"getTags": @[]});
    }
}

- (void)addConversationsToTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"addConversationsToTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        NSArray *indentifers = param[@"identifiers"];
        NSMutableArray *indentiferArr =[[NSMutableArray alloc] init];
        for (NSDictionary * dict in indentifers) {
            RCConversationIdentifier *identifer = [RCFlutterMessageFactory dict2ConversationIdentifier:dict];
            [indentiferArr addObject:identifer];
        }
        [[RCCoreClient sharedCoreClient] addConversationsToTag:tagId conversationIdentifiers:[indentiferArr copy] success:^{
            result(@{@"code": @(0), @"result": @(YES)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code": @(errorCode), @"result": @(NO)});
        }];
    }
}

- (void)removeConversationsFromTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeConversationsFromTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        NSArray *indentifers = param[@"identifiers"];
        NSMutableArray *indentiferArr =[[NSMutableArray alloc] init];
        for (NSDictionary * dict in indentifers) {
            RCConversationIdentifier *identifer = [RCFlutterMessageFactory dict2ConversationIdentifier:dict];
            [indentiferArr addObject:identifer];
        }
        [[RCCoreClient sharedCoreClient] removeConversationsFromTag:tagId conversationIdentifiers:[indentiferArr copy] success:^{
            result(@{@"code": @(0), @"result": @(YES)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code": @(errorCode), @"result": @(NO)});
        }];
    }
}

- (void)removeTagsFromConversation:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeTagsFromConversation";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType conversationType = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *tagIds = param[@"tagIds"];
        RCConversationIdentifier *indentifer = [[RCConversationIdentifier alloc] init];
        indentifer.type = conversationType;
        indentifer.targetId = targetId;
        [[RCCoreClient sharedCoreClient] removeTagsFromConversation:indentifer tagIds:tagIds success:^{
            result(@{@"code": @(0), @"result": @(YES)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code": @(errorCode), @"result": @(NO)});
        }];
    }
}

- (void)getTagsFromConversation:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getTagsFromConversation";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType conversationType = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        RCConversationIdentifier *indentifer = [[RCConversationIdentifier alloc] init];
        indentifer.type = conversationType;
        indentifer.targetId = targetId;
        NSArray *tagInfos = [[RCCoreClient sharedCoreClient] getTagsFromConversation:indentifer];
        if (tagInfos.count > 0) {
            NSMutableArray *arr = [NSMutableArray new];
            for(RCConversationTagInfo *info in tagInfos) {
                NSString *conStr = [RCFlutterMessageFactory conversationTagInfo2String:info];
                [arr addObject:conStr];
            }
            result(@{@"code": @(0), @"ConversationTagInfoList": [arr copy]});
        }else {
            result(@{@"code": @(0), @"ConversationTagInfoList": @[]});
        }
    }
}

- (void)getConversationsFromTagByPage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationsFromTagByPage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        long long timestamp = [param[@"ts"] longLongValue];
        int count = [param[@"count"] intValue];
        NSArray *conversations = [[RCCoreClient sharedCoreClient] getConversationsFromTagByPage:tagId timestamp:timestamp count:count];
        if (conversations.count > 0) {
            NSMutableArray *arr = [NSMutableArray new];
            for(RCConversation *conversation in conversations) {
                NSString *conStr = [RCFlutterMessageFactory conversation2String:conversation];
                [arr addObject:conStr];
            }
            result(@{@"code": @(0), @"ConversationList": [arr copy]});
        }else {
            result(@{@"code": @(0), @"ConversationList": @[]});
        }
    }
}

- (void)getUnreadCountByTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getUnreadCountByTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        BOOL containBlocked = [param[@"containBlocked"] boolValue];
        int count = [[RCCoreClient sharedCoreClient] getUnreadCountByTag:tagId containBlocked:containBlocked];
        result(@{@"code": @(0), @"result": @(count)});
    }
}

- (void)setConversationToTopInTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"setConversationToTopInTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        NSString *targetId = param[@"targetId"];
        RCConversationType conversationType = [param[@"conversationType"] integerValue];
        BOOL isTop = [param[@"isTop"] boolValue];
        RCConversationIdentifier *indentifer = [[RCConversationIdentifier alloc] init];
        indentifer.type = conversationType;
        indentifer.targetId = targetId;
        [[RCCoreClient sharedCoreClient] setConversationToTopInTag:tagId conversationIdentifier:indentifer isTop:isTop success:^{
            result(@{@"code": @(0), @"result": @(YES)});
        } error:^(RCErrorCode errorCode) {
            result(@{@"code": @(errorCode), @"result": @(NO)});
        }];
    }
}

- (void)getConversationTopStatusInTag:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationTopStatusInTag";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *tagId = param[@"tagId"];
        NSString *targetId = param[@"targetId"];
        RCConversationType conversationType = [param[@"conversationType"] integerValue];
        RCConversationIdentifier *indentifer = [[RCConversationIdentifier alloc] init];
        indentifer.type = conversationType;
        indentifer.targetId = targetId;
        BOOL flag = [[RCCoreClient sharedCoreClient] getConversationTopStatusInTag:indentifer tagId:tagId];
        result(@{@"code": @(0), @"result": @(flag)});
    }
}

#pragma mark - 插入消息

- (void)insertOutgoingMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"insertOutgoingMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
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
            [RCLog e:[NSString stringWithFormat:@"%@, message content is nil",LOG_TAG]];
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        long sendTime = [param[@"sendTime"] longValue];
        
        //        RCMessage *message = [[RCCoreClient sharedCoreClient] insertOutgoingMessage:type targetId:targetId sentStatus:sendStatus content:content sentTime:sendTime];
        RCMessage *message = [[RCChannelClient sharedChannelManager] insertOutgoingMessage:type targetId:targetId channelId:channelId sentStatus:sendStatus content:content sentTime:sendTime];
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
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
            [RCLog e:[NSString stringWithFormat:@"%@, message content is nil",LOG_TAG]];
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        long sendTime = [param[@"sendTime"] longValue];
        
        //        RCMessage *message = [[RCCoreClient sharedCoreClient] insertIncomingMessage:type targetId:targetId senderUserId:senderUserId receivedStatus:receivedStatus content:content sentTime:sendTime];
        
        RCMessage *message = [[RCChannelClient sharedChannelManager] insertIncomingMessage:type targetId:targetId channelId:channelId senderUserId:senderUserId receivedStatus:receivedStatus content:content sentTime:sendTime];
        if (!message) {
            result(@{@"code":@(INVALID_PARAMETER)});
            return;
        }
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(@{@"message":jsonString,@"code":@(0)});
    }
}

- (void)batchInsertMessage:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG =  @"batchInsertMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *msgs = param[@"messageMapList"];
        NSMutableArray *msgList = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in msgs) {
            RCMessage *message = [RCFlutterMessageFactory dic2Message:dict];
            [msgList addObject:message];
        }
        BOOL flag = [[RCCoreClient sharedCoreClient] batchInsertMessage:[msgList copy]];
        result(@{@"code": @(0), @"result": @(flag)});
    }else{
        result(@{@"code": @(INVALID_PARAMETER), @"result": @(false)});
    }
}

#pragma mark -- 未读数

- (void)getTotalUnreadCount:(FlutterResult)result{
    NSString *LOG_TAG =  @"getTotalUnreadCount";
    int count = [[RCCoreClient sharedCoreClient] getTotalUnreadCount];
    [RCLog i:[NSString stringWithFormat:@"%@, count:%d",LOG_TAG,count]];
    result(@{@"count":@(count),@"code":@(0)});
}

- (void)getUnreadCountTargetId:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getUnreadCountTargetId";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type =  [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        
        //        int count = [[RCCoreClient sharedCoreClient] getUnreadCount:type targetId:targetId];
        int count = [[RCChannelClient sharedChannelManager] getUnreadCount:type targetId:targetId channelId:channelId];
        result(@{@"count":@(count),@"code":@(0)});
    }
}

- (void)getUnreadCountConversationTypeList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getUnreadCountConversationTypeList";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        NSString *channelId = param[@"channelId"];
        BOOL isContain = [param[@"isContain"] boolValue];
        //        int count = [[RCCoreClient sharedCoreClient] getUnreadCount:typeArray containBlocked:isContain];
        int count = [[RCChannelClient sharedChannelManager] getUnreadCount:typeArray channelId:channelId containBlocked:isContain];
        result(@{@"count":@(count),@"code":@(0)});
    }
}

- (void)deleteMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"deleteMessages";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        RCConversationType type =  [dic[@"conversationType"] integerValue];
        NSString *targetId = dic[@"targetId"];
        NSString *channelId = dic[@"channelId"];
        //        [[RCCoreClient sharedCoreClient] deleteMessages:type targetId:targetId success:^{
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@(0));
        //        } error:^(RCErrorCode status) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, error:%@",LOG_TAG,@(status)]];
        //            result(@(status));
        //        }];
        
        [[RCChannelClient sharedChannelManager] deleteMessages:type targetId:targetId channelId:channelId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, error:%@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)deleteMessageByIds:(id)arg result:(FlutterResult)result{
    NSString *LOG_TAG =  @"deleteMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSArray *messageIds = dic[@"messageIds"];
        BOOL success = [[RCCoreClient sharedCoreClient] deleteMessages:messageIds];
        if(success) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        }else {
            [RCLog e:[NSString stringWithFormat:@"%@, error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)removeConversation:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeConversation";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type =  [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        //        BOOL success = [[RCCoreClient sharedCoreClient] removeConversation:type targetId:targetId];
        BOOL success = [[RCChannelClient sharedChannelManager] removeConversation:type targetId:targetId channelId:channelId];
        result(@(success));
    }
}

- (void)clearHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"clearHistoryMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type =  [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        long long recordTime = [param[@"recordTime"] longLongValue];
        BOOL clearRemote = [param[@"clearRemote"] boolValue];
        //        [[RCCoreClient sharedCoreClient] clearHistoryMessages:type targetId:targetId recordTime:recordTime clearRemote:clearRemote success:^{
        //            result(@(0));
        //        } error:^(RCErrorCode status) {
        //            result(@(status));
        //        }];
        
        [[RCChannelClient sharedChannelManager] clearHistoryMessages:type targetId:targetId channelId:channelId recordTime:recordTime clearRemote:clearRemote success:^{
            result(@(0));
            
        } error:^(RCErrorCode status) {
            result(@(status));
            
        }];
    }
}

- (void)recallMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"recallMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSDictionary *messageDic = param[@"message"];
        NSString *pushContent = param[@"pushContent"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [[RCCoreClient sharedCoreClient] recallMessage:message pushContent:pushContent success:^(long messageId) {
            [RCLog i:[NSString stringWithFormat:@"%@ success ,messageId %@",LOG_TAG,@(messageId)]];
            RCMessage *message = [[RCCoreClient sharedCoreClient] getMessage:messageId];
            RCRecallNotificationMessage *recallNotificationMessage = (RCRecallNotificationMessage *)message.content;
            
            [dic setObject:[RCFlutterMessageFactory messageContent2String:recallNotificationMessage] forKey:@"recallNotificationMessage"];
            [dic setObject:@(0) forKey:@"errorCode"];
            result(dic);
        } error:^(RCErrorCode errorcode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorcode:%@",LOG_TAG,@(errorcode)]];
            result(@{@"recallNotificationMessage":@"", @"errorCode":@(errorcode)});
        }];
    }
}

- (void)syncConversationReadStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"syncConversationReadStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        long long timestamp = [param[@"timestamp"] longLongValue];
        
        [[RCChannelClient sharedChannelManager] syncConversationReadStatus:type targetId:targetId channelId:channelId time:timestamp success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorcode:%@",LOG_TAG,@(nErrorCode)]];
            result(@(nErrorCode));
        }];
        //        [[RCCoreClient sharedCoreClient] syncConversationReadStatus:type targetId:targetId time:timestamp success:^{
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@(0));
        //        } error:^(RCErrorCode nErrorCode) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, errorcode:%@",LOG_TAG,@(nErrorCode)]];
        //            result(@(nErrorCode));
        //        }];
    }
}

#pragma mark - 草稿
- (void)getTextMessageDraft:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getTextMessageDraft";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        
        NSString *draft = [[RCChannelClient sharedChannelManager] getTextMessageDraft:type targetId:targetId channelId:channelId];
        //        NSString *draft = [[RCCoreClient sharedCoreClient] getTextMessageDraft:type targetId:targetId];
        result(draft?:@"");
    }
}

- (void)saveTextMessageDraft:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"saveTextMessageDraft";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        NSString *content = param[@"content"];
        BOOL isSuccess = [[RCChannelClient sharedChannelManager] saveTextMessageDraft:type targetId:targetId channelId:channelId content:content];
        //        BOOL isSuccess = [[RCCoreClient sharedCoreClient] saveTextMessageDraft:type targetId:targetId content:content];
        result(@(isSuccess));
    }
}

#pragma mark - 搜索
- (void)searchConversations:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"searchConversations";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *keyword = param[@"keyword"];
        NSArray *conversationTypes = param[@"conversationTypes"];
        NSString *channelId = param[@"channelId"];
        NSArray *objectNames = param[@"objectNames"];
        
        if (conversationTypes && objectNames) {
            NSArray *results = [[RCChannelClient sharedChannelManager] searchConversations:conversationTypes channelId:channelId messageType:objectNames keyword:keyword];
            //            NSArray *results = [[RCCoreClient sharedCoreClient] searchConversations:conversationTypes messageType:objectNames keyword:keyword];
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        int count = [param[@"count"] intValue];
        long long beginTime = [param[@"beginTime"] longLongValue];
        NSString *keyword = param[@"keyword"];
        NSString *channelId = param[@"channelId"];
        
        NSArray *results = [[RCChannelClient sharedChannelManager] searchMessages:type targetId:targetId channelId:channelId keyword:keyword count:count startTime:beginTime];
        //        NSArray *results = [[RCCoreClient sharedCoreClient] searchMessages:type targetId:targetId keyword:keyword count:count startTime:beginTime];
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
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *typingContentType = param[@"typingContentType"];
        NSString *channelId = param[@"channelId"];
        
        //        [[RCCoreClient sharedCoreClient] sendTypingStatus:type targetId:targetId contentType:typingContentType];
        [[RCChannelClient sharedChannelManager] sendTypingStatus:type targetId:targetId channelId:channelId contentType:typingContentType];
    }
}

- (void)downloadMediaMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"downloadMediaMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        [[RCCoreClient sharedCoreClient] downloadMediaMessage:message.messageId progress:^(int progress) {
            NSDictionary *callbackDic = @{@"messageId": @(message.messageId), @"progress": @(progress), @"code": @(10)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessage arguments:callbackDic];
        } success:^(NSString *mediaPath) {
            [RCLog i:[NSString stringWithFormat:@"%@, success ,mediaPath:%@",LOG_TAG,mediaPath]];
            RCMessage *tempMessage = [[RCCoreClient sharedCoreClient] getMessage:message.messageId];
            NSString *messageString = [RCFlutterMessageFactory message2String:tempMessage];
            NSDictionary *callbackDic = @{@"messageId": @(tempMessage.messageId), @"message": messageString, @"code": @(0)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessage arguments:callbackDic];
        } error:^(RCErrorCode errorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorCode:%@",LOG_TAG,@(errorCode)]];
            NSDictionary *callbackDic = @{@"messageId": @(message.messageId), @"code": @(errorCode)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessage arguments:callbackDic];
        } cancel:^{
            NSDictionary *callbackDic = @{@"messageId": @(message.messageId), @"code": @(20)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessage arguments:callbackDic];
        }];
    }
}


#pragma mark - 全局消息提醒
- (void)setNotificationQuietHours:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setNotificationQuietHours";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSString *startTime = param[@"startTime"];
        int spanMins = [param[@"spanMins"] intValue];
        [[RCCoreClient sharedCoreClient] setNotificationQuietHours:startTime spanMins:spanMins success:^{
            result(@(0));
        } error:^(RCErrorCode status) {
            result(@(status));
        }];
    }
}

- (void)removeNotificationQuietHours:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeNotificationQuietHours";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    [[RCCoreClient sharedCoreClient] removeNotificationQuietHours:^{
        result(@(0));
    } error:^(RCErrorCode status) {
        result(@(status));
    }];
}

- (void)getNotificationQuietHours:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"sendTypingStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    [[RCCoreClient sharedCoreClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        [RCLog i:[NSString stringWithFormat:@"%@ startTime:%@ spansMin:%@",LOG_TAG,startTime,@(spansMin)]];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [dict setObject:@(0) forKey:@"code"];
        [dict setObject:startTime?:@"" forKey:@"startTime"];
        [dict setObject:@(spansMin) forKey:@"spansMin"];
        result(dict);
    } error:^(RCErrorCode status) {
        [RCLog e:[NSString stringWithFormat:@"%@, status:%@",LOG_TAG,@(status)]];
        result(@{@"code": @(0)});
    }];
}

- (void)getUnreadMentionedMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getUnreadMentionedMessages";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        NSArray *messages = [[RCChannelClient sharedChannelManager] getUnreadMentionedMessages:type targetId:targetId channelId:channelId];
        
        //        NSArray *messages = [[RCCoreClient sharedCoreClient] getUnreadMentionedMessages:type targetId:targetId];
        NSMutableArray *arr = [NSMutableArray new];
        for(RCMessage *msg in messages) {
            NSString *msgStr = [RCFlutterMessageFactory message2String:msg];
            [arr addObject:msgStr];
        }
        result(arr);
    }
}

#pragma mark - 阅后即焚
- (void)messageBeginDestruct:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"messageBeginDestruct";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        [[RCCoreClient sharedCoreClient] messageBeginDestruct:message];
    }
}

- (void)messageStopDestruct:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"downloadMediaMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        [[RCCoreClient sharedCoreClient] messageStopDestruct:message];;
    }
}

- (void)setReconnectKickEnable:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setReconnectKickEnable";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    BOOL enable = (BOOL)arg;
    [[RCCoreClient sharedCoreClient] setReconnectKickEnable:enable];
}

- (void)getConnectionStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getConnectionStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    
    RCConnectionStatus status = [[RCCoreClient sharedCoreClient] getConnectionStatus];
    result(@(status));
}

- (void)cancelDownloadMediaMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"cancelDownloadMediaMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    long messageId = (long)arg;
    [[RCCoreClient sharedCoreClient] cancelDownloadMediaMessage:messageId];
}

- (void)getRemoteChatroomHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getRemoteChatroomHistoryMessages";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *targetId = param[@"targetId"];
        long long recordTime = [param[@"recordTime"] longLongValue];
        int count = [param[@"count"] intValue];
        RCTimestampOrder order = [param[@"order"] intValue];
        
        [[RCChatRoomClient sharedChatRoomClient] getRemoteChatroomHistoryMessages:targetId recordTime:recordTime count:count order:order success:^(NSArray *messages, long long syncTime) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            NSMutableArray *msgsArray = [NSMutableArray new];
            for(RCMessage *message in messages) {
                NSString *jsonString = [RCFlutterMessageFactory message2String:message];
                [msgsArray addObject:jsonString];
            }
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(0) forKey:@"code"];
            [callbackDic setObject:msgsArray forKey:@"messages"];
            [callbackDic setObject:@(syncTime) forKey:@"syncTime"];
            result(callbackDic);
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(status) forKey:@"code"];
            [callbackDic setObject:@(-1) forKey:@"syncTime"];
            result(callbackDic);
        }];
    }
}

- (void)getMessageByUId:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getMessageByUId";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *messageUId = param[@"messageUId"];
        RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:messageUId];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(jsonString);
    }
}

- (void)getFirstUnreadMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getFirstUnreadMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"]?:@"";
        NSString *channelId = param[@"channelId"];
        RCMessage *message = [[RCChannelClient sharedChannelManager] getFirstUnreadMessage:type targetId:targetId channelId:channelId];
        //        RCMessage *message = [[RCCoreClient sharedCoreClient] getFirstUnreadMessage:type targetId:targetId];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(jsonString);
    }
}


#pragma mark - 聊天室状态回调
- (void)onChatRoomDestroyed:(NSString *)chatroomId type:(RCChatRoomDestroyType)type {
    NSDictionary *statusDic = @{@"targetId": chatroomId,@"type" : @(type)};
    [self.channel invokeMethod:RCMethodCallBackKeyOnChatRoomDestroyed arguments:statusDic];
}

- (void)onChatRoomReset:(NSString *)chatroomId {
    NSDictionary *statusDic = @{ @"targetId" : chatroomId };
    [self.channel invokeMethod:RCMethodCallBackKeyOnChatRoomReset arguments:statusDic];
}

#pragma mark - 聊天室状态存储 (使用前必须先联系商务开通)
- (void)setChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        NSString *value = param[@"value"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        BOOL autoDelete = [param[@"autoDelete"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCChatRoomClient sharedChatRoomClient] setChatRoomEntry:chatRoomId key:key value:value sendNotification:sendNotification autoDelete:autoDelete notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorCode:%@",LOG_TAG,@(nErrorCode)]];
            result(@(nErrorCode));
        }];
    }
}

- (void)forceSetChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"forceSetChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        NSString *value = param[@"value"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        BOOL autoDelete = [param[@"autoDelete"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:chatRoomId key:key value:value sendNotification:sendNotification autoDelete:autoDelete notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorCode:%@",LOG_TAG,@(nErrorCode)]];
            result(@(nErrorCode));
        }];
    }
}

- (void)getChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        
        [[RCChatRoomClient sharedChatRoomClient] getChatRoomEntry:chatRoomId key:key success:^(NSDictionary *entry) {
            [RCLog i:[NSString stringWithFormat:@"%@, entry:%@",LOG_TAG,entry]];
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (entry) {
                [dict setObject:entry forKey:@"entry"];
            }
            [dict setObject:@(0) forKey:@"code"];
            result(dict);
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@,errorCode:%@",LOG_TAG,@(nErrorCode)]];
            result(@{@"entry":@{}, @"code": @(nErrorCode)});
        }];
    }
}

- (void)getAllChatRoomEntries:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getAllChatRoomEntries";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        
        [[RCChatRoomClient sharedChatRoomClient] getAllChatRoomEntries:chatRoomId success:^(NSDictionary *entry) {
            [RCLog i:[NSString stringWithFormat:@"%@, entry:%@",LOG_TAG,entry]];
            NSMutableDictionary *dict = [NSMutableDictionary new];
            if (entry) {
                [dict setObject:entry forKey:@"entry"];
            }
            [dict setObject:@(0) forKey:@"code"];
            result(dict);
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorCode:%@",LOG_TAG,@(nErrorCode)]];
            result(@{@"entry":@{}, @"code": @(nErrorCode)});
        }];
    }
}

- (void)removeChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        [[RCChatRoomClient sharedChatRoomClient] removeChatRoomEntry:chatRoomId key:key sendNotification:sendNotification notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorCode:%@",LOG_TAG,@(nErrorCode)]];
            result(@(nErrorCode));
        }];
    }
}

- (void)forceRemoveChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"forceRemoveChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCChatRoomClient sharedChatRoomClient] forceRemoveChatRoomEntry:chatRoomId key:key sendNotification:sendNotification notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, errorCode:%@",LOG_TAG,@(nErrorCode)]];
            result(@(nErrorCode));
        }];
    }
}

- (void)setChatRoomEntries:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setChatRoomEntries";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSDictionary *chatRoomEntryMap = param[@"chatRoomEntryMap"];
        BOOL autoRemove = [param[@"autoRemove"] boolValue];
        BOOL overWrite = [param[@"overWrite"] boolValue];
        
        [[RCChatRoomClient sharedChatRoomClient] setChatRoomEntries:chatRoomId
                                                            entries:chatRoomEntryMap
                                                            isForce:overWrite
                                                         autoDelete:autoRemove
                                                            success:^{
            result(@{@"code":@(0)});
        }
                                                              error:^(RCErrorCode nErrorCode, NSDictionary * _Nonnull entries) {
            result(@{@"code":@(nErrorCode), @"errors":entries});
        }];
    }
}

- (void)removeChatRoomEntries:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeChatRoomEntries";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSArray *chatRoomEntryList = param[@"chatRoomEntryList"];
        BOOL force = [param[@"force"] boolValue];
        
        [[RCChatRoomClient sharedChatRoomClient] removeChatRoomEntries:chatRoomId
                                                                  keys:chatRoomEntryList
                                                               isForce:force
                                                               success:^{
            result(@{@"code":@(0)});
        }
                                                                 error:^(RCErrorCode nErrorCode, NSDictionary * _Nonnull entries) {
            result(@{@"code":@(nErrorCode), @"errors":entries});
        }];
    }
}

- (void)chatRoomKVDidSync:(NSString *)roomId {
    if (roomId) {
        NSDictionary *statusDic =
        @{ @"roomId" : roomId };
        [self.channel invokeMethod:RCMethodCallBackKeyChatRoomKVDidSync arguments:statusDic];
    }
}

- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    if (roomId && entry) {
        NSDictionary *statusDic =
        @{ @"roomId" : roomId,
           @"entry" : entry };
        [self.channel invokeMethod:RCMethodCallBackKeyChatRoomKVDidUpdate arguments:statusDic];
    }
}

- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    if (roomId && entry) {
        NSDictionary *statusDic =
        @{ @"roomId" : roomId,
           @"entry" : entry };
        [self.channel invokeMethod:RCMethodCallBackKeyChatRoomKVDidRemove arguments:statusDic];
    }
}

#pragma mark - 会话提醒

- (void)setConversationNotificationStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"setConversationNotificationStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        BOOL isBlocked = [param[@"isBlocked"] boolValue];
        
        [[RCChannelClient sharedChannelManager] setConversationNotificationStatus:type targetId:targetId channelId:channelId isBlocked:isBlocked success:^(RCConversationNotificationStatus nStatus) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@{@"status":@(nStatus),@"code":@(0)});
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@{@"code":@(status)});
        }];
        
        //        [[RCCoreClient sharedCoreClient] setConversationNotificationStatus:type targetId:targetId isBlocked:isBlocked success:^(RCConversationNotificationStatus nStatus) {
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@{@"status":@(nStatus),@"code":@(0)});
        //        } error:^(RCErrorCode status) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
        //            result(@{@"code":@(status)});
        //        }];
    }
}

- (void)getConversationNotificationStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getConversationNotificationStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        
        [[RCChannelClient sharedChannelManager] getConversationNotificationStatus:type targetId:targetId channelId:channelId success:^(RCConversationNotificationStatus nStatus) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@{@"status":@(nStatus),@"code":@(0)});
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@{@"code":@(status)});
        }];
        //        [[RCCoreClient sharedCoreClient] getConversationNotificationStatus:type targetId:targetId success:^(RCConversationNotificationStatus nStatus) {
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@{@"status":@(nStatus),@"code":@(0)});
        //        } error:^(RCErrorCode status) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
        //            result(@{@"code":@(status)});
        //        }];
    }
}

- (void)getBlockedConversationList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getBlockedConversationList";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        NSString *channelId = param[@"channelId"];
        
        NSArray *conversationArray = [[RCChannelClient sharedChannelManager] getBlockedConversationList:typeArray channelId:channelId];
        //        NSArray *conversationArray = [[RCCoreClient sharedCoreClient] getBlockedConversationList:typeArray];
        NSMutableArray *arr = [NSMutableArray new];
        for(RCConversation *con in conversationArray) {
            NSString *conStr = [RCFlutterMessageFactory conversation2String:con];
            [arr addObject:conStr];
        }
        result(@{@"conversationList":arr,@"code":@(0)});
    }
}

#pragma mark - 会话置顶

- (void)setConversationToTop:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"setConversationToTop";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        BOOL isTop = [param[@"isTop"] boolValue];
        NSString *channelId = param[@"channelId"];
        
        BOOL status = [[RCChannelClient sharedChannelManager] setConversationToTop:type targetId:targetId channelId:channelId isTop:isTop];
        //        BOOL status = [[RCCoreClient sharedCoreClient] setConversationToTop:type targetId:targetId isTop:isTop];
        result(@{@"status":@(status),@"code":@(0)});
    }
}

- (void)getTopConversationList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getTopConversationList";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *typeArray = param[@"conversationTypeList"];
        NSString *channelId = param[@"channelId"];
        
        NSArray *conversationArray = [[RCChannelClient sharedChannelManager] getTopConversationList:typeArray channelId:channelId];
        //        NSArray *conversationArray = [[RCCoreClient sharedCoreClient] getTopConversationList:typeArray];
        NSMutableArray *arr = [NSMutableArray new];
        for(RCConversation *con in conversationArray) {
            NSString *conStr = [RCFlutterMessageFactory conversation2String:con];
            [arr addObject:conStr];
        }
        result(@{@"conversationList":arr,@"code":@(0)});
    }
}

#pragma mark - 消息扩展
- (void)updateMessageExpansion:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"updateMessageExpansion";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSDictionary *expansionDic = param[@"expansionDic"];
        NSString *messageUId = param[@"messageUId"];
        [[RCCoreClient sharedCoreClient] updateMessageExpansion:expansionDic messageUId:messageUId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)removeMessageExpansionForKey:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeMessageExpansionForKey";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *keyArray = param[@"keyArray"];
        NSString *messageUId = param[@"messageUId"];
        [[RCCoreClient sharedCoreClient] removeMessageExpansionForKey:keyArray messageUId:messageUId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

#pragma mark - 黑名单
- (void)addToBlackList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"addToBlackList";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        [[RCCoreClient sharedCoreClient] addToBlacklist:userId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)removeFromBlackList:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"removeFromBlackList";
    [RCLog i:[NSString stringWithFormat:@"%@ ,start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        [[RCCoreClient sharedCoreClient] removeFromBlacklist:userId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)getBlackListStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"getBlackListStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *userId = dic[@"userId"];
        [[RCCoreClient sharedCoreClient] getBlacklistStatus:userId success:^(int bizStatus) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            if(bizStatus == 101) {//和 Android 保持一致
                bizStatus = 1;
            }
            result(@{@"status":@(bizStatus),@"code":@(0)});
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@{@"status":@(status),@"code":@(status)});
        }];
    }
}

- (void)getBlackList:(FlutterResult)result {
    NSString *LOG_TAG =  @"getBlackList";
    [RCLog i:[NSString stringWithFormat:@"%@ ,start ",LOG_TAG]];
    [[RCCoreClient sharedCoreClient] getBlacklist:^(NSArray *blockUserIds) {
        [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        if(!blockUserIds) {
            blockUserIds = [NSArray new];
        }
        result(@{@"userIdList":blockUserIds,@"code":@(0)});
    } error:^(RCErrorCode status) {
        [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
        result(@{@"userIdList":[NSArray new],@"code":@(0)});
    }];
}


- (void)sendReadReceiptMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"sendReadReceiptMessage";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        long long timestamp = [param[@"timestamp"] longLongValue];
        
        [[RCChannelClient sharedChannelManager] sendReadReceiptMessage:type targetId:targetId channelId:channelId time:timestamp success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@{@"code":@(0)});
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
        //        [[RCCoreClient sharedCoreClient] sendReadReceiptMessage:type targetId:targetId time:timestamp success:^{
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@{@"code":@(0)});
        //        } error:^(RCErrorCode nErrorCode) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
        //            result(@{@"code":@(nErrorCode)});
        //        }];
    }
}

- (void)sendReadReceiptRequest:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"sendReadReceiptRequest";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSDictionary *messageDic = param[@"messageMap"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        [[RCCoreClient sharedCoreClient] sendReadReceiptRequest:message success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@{@"code":@(0)});
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
    }
}

- (void)sendReadReceiptResponse:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG =  @"sendReadReceiptResponse";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        NSArray *messageMapList = param[@"messageMapList"];
        NSMutableArray *messageList = [NSMutableArray arrayWithCapacity:messageMapList.count];
        for (NSDictionary *messageDic in messageMapList) {
            RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
            [messageList addObject:message];
        }
        
        [[RCChannelClient sharedChannelManager] sendReadReceiptResponse:type targetId:targetId channelId:channelId messageList:messageList success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@{@"code":@(0)});
        } error:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
        //        [[RCCoreClient sharedCoreClient] sendReadReceiptResponse:type targetId:targetId messageList:messageList success:^{
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@{@"code":@(0)});
        //        } error:^(RCErrorCode nErrorCode) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(nErrorCode)]];
        //            result(@{@"code":@(nErrorCode)});
        //        }];
    }
}

- (void)deleteRemoteMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"deleteRemoteMessages";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        NSArray *messageMapList = param[@"messages"];
        NSMutableArray *messageList = [NSMutableArray arrayWithCapacity:messageMapList.count];
        for (NSDictionary *messageDic in messageMapList) {
            RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
            [messageList addObject:message];
        }
        
        //        [[RCCoreClient sharedCoreClient] deleteRemoteMessage:type targetId:targetId messages:messageList success:^{
        //            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
        //            result(@(0));
        //        } error:^(RCErrorCode status) {
        //            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
        //            result(@(status));
        //        }];
        //
        [[RCChannelClient sharedChannelManager] deleteRemoteMessage:type targetId:targetId channelId:channelId messages:messageList success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@, %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)clearMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"clearMessages";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSString *channelId = param[@"channelId"];
        
        BOOL success = [[RCChannelClient sharedChannelManager] clearMessages:type targetId:targetId channelId:channelId];
        //        BOOL success = [[RCCoreClient sharedCoreClient] clearMessages:type targetId:targetId];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog e:[NSString stringWithFormat:@"%@, error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)setMessageExtra:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setMessageExtra";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        long messageId = [param[@"messageId"] longValue];
        NSString *value = param[@"value"];
        BOOL success = [[RCCoreClient sharedCoreClient] setMessageExtra:messageId value:value];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog e:[NSString stringWithFormat:@"%@, error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)setMessageReceivedStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setMessageReceivedStatus";
    [RCLog i:[NSString stringWithFormat:@"%@, start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        long messageId = [param[@"messageId"] longValue];
        RCReceivedStatus receivedStatus = [param[@"receivedStatus"] intValue];
        
        BOOL success = [[RCCoreClient sharedCoreClient] setMessageReceivedStatus:messageId receivedStatus:receivedStatus];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog e:[NSString stringWithFormat:@"%@, error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)setMessageSentStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setMessageSentStatus";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        long messageId = [param[@"messageId"] longValue];
        RCSentStatus receivedStatus = [param[@"sentStatus"] intValue];
        
        BOOL success = [[RCCoreClient sharedCoreClient] setMessageSentStatus:messageId sentStatus:receivedStatus];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog e:[NSString stringWithFormat:@"%@, error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)clearConversations:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"clearConversations";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *conversationType = param[@"conversationTypes"];
        NSString *channelId = param[@"channelId"];
        BOOL success = [[RCChannelClient sharedChannelManager] clearConversations:conversationType channelId:channelId];
        //        BOOL success = [[RCCoreClient sharedCoreClient] clearConversations:conversationType];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog e:[NSString stringWithFormat:@"%@, error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)getDeltaTime:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getDeltaTime";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,arg]];
    long long deltaTime = [[RCCoreClient sharedCoreClient] getDeltaTime];
    result(@(deltaTime));
}

- (void)setOfflineMessageDuration:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setOfflineMessageDuration";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        int duration = [param[@"duration"] intValue];
        [[RCCoreClient sharedCoreClient] setOfflineMessageDuration:duration success:^{
            [RCLog i:[NSString stringWithFormat:@"%@, success",LOG_TAG]];
            result(@{@"code":@(0)});
        } failure:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@,%@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
    }
}

- (void)getOfflineMessageDuration:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getOfflineMessageDuration";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,arg]];
    int duration = [[RCCoreClient sharedCoreClient] getOfflineMessageDuration];
    result(@(duration));
}

- (void)receiveMessageHasReadNotification:(NSNotification *)notification {
    NSDictionary *dict = @{@"cType":[notification.userInfo objectForKey:@"cType"],
                           @"messageTime":[notification.userInfo objectForKey:@"messageTime"],
                           @"tId":[notification.userInfo objectForKey:@"tId"],
                           @"fId":[notification.userInfo objectForKey:@"fId"],
                           
    };
    NSString *LOG_TAG =  @"receiveMessageHasReadNotification";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,dict]];
    [self.channel invokeMethod:RCMethodCallBackKeyReceiveReadReceipt arguments:dict];
}

#pragma mark - 传递数据
- (void)sendDataToFlutter:(NSDictionary *)userInfo {
    NSString *LOG_TAG =  @"sendDataToFlutter";
    [RCLog i:[NSString stringWithFormat:@"%@,start param:%@",LOG_TAG,userInfo]];
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

- (void)onMessageRecalled:(long)messageId {
    RCMessage *recalledMsg = [[RCCoreClient sharedCoreClient] getMessage:messageId];
    NSString *jsonString = [RCFlutterMessageFactory message2String:recalledMsg];
    NSDictionary *dict = @{@"message": jsonString};
    [self.channel invokeMethod:RCMethodCallBackKeyRecallMessage arguments:dict];
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    NSString *LOG_TAG =  @"onConnectionStatusChanged";
    [RCLog i:[NSString stringWithFormat:@"%@,status:%@",LOG_TAG,@(status)]];
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
    
    [self.channel invokeMethod:RCMethodCallBackKeyTypingStatusChanged arguments:statusDic];
}

#pragma mark - RCMessageDestructDelegate
- (void)onMessageDestructing:(RCMessage *)message remainDuration:(long long)remainDuration {
    NSString *LOG_TAG = @"onMessageDestructing";
    [RCLog i:[NSString stringWithFormat:@"%@",LOG_TAG]];
    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
    NSDictionary *dic = @{@"message": jsonString, @"remainDuration": @(remainDuration)};
    [self.channel invokeMethod:RCMethodCallBackKeyDestructMessage arguments:dic];
}

#pragma mark - RCMessageExpansionDelegate

- (void)messageExpansionDidUpdate:(NSDictionary<NSString *,NSString *> *)expansionDic message:(RCMessage *)message{
    NSString *LOG_TAG = @"messageExpansionDidUpdate";
    [RCLog i:[NSString stringWithFormat:@"%@",LOG_TAG]];
    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
    NSDictionary *dic = @{@"expansionDic": expansionDic, @"message": jsonString};
    [self.channel invokeMethod:RCMethodCallBackKeyMessageExpansionDidUpdate arguments:dic];
}

- (void)messageExpansionDidRemove:(NSArray<NSString *> *)keyArray message:(RCMessage *)message{
    NSString *LOG_TAG = @"messageExpansionDidRemove";
    [RCLog i:[NSString stringWithFormat:@"%@",LOG_TAG]];
    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
    NSDictionary *dic = @{@"keyArray": keyArray, @"message": jsonString};
    [self.channel invokeMethod:RCMethodCallBackKeyMessageExpansionDidRemove arguments:dic];
}


#pragma mark - util
- (void)updateIMConfig {
    //    [RCIM sharedRCIM].enablePersistentUserInfoCache = self.config.enablePersistentUserInfoCache;
}

- (RCMessageContent *)getVoiceMessage:(NSData *)data {
    NSString *LOG_TAG = @"getVoiceMessage";
    NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    RCUserInfo *sendUserInfo = nil;
    RCMentionedInfo *mentionedInfo = nil;
    if ([contentDic valueForKey:@"user"]) {
        NSDictionary *userDict = [contentDic valueForKey:@"user"];
        NSString *userId = [userDict valueForKey:@"id"] ?: @"";
        NSString *name = [userDict valueForKey:@"name"] ?: @"";
        NSString *portraitUri = [userDict valueForKey:@"portrait"] ?: @"";
        NSString *extra = [userDict valueForKey:@"extra"] ?: @"";
        sendUserInfo = [[RCUserInfo alloc] initWithUserId:userId name:name portrait:portraitUri];
        sendUserInfo.extra = extra;
    }
    
    if ([contentDic valueForKey:@"mentionedInfo"]) {
        NSDictionary *mentionedInfoDict = [contentDic valueForKey:@"mentionedInfo"];
        RCMentionedType type = [[mentionedInfoDict valueForKey:@"type"] intValue] ?: 1;
        NSArray *userIdList = [mentionedInfoDict valueForKey:@"userIdList"] ?: @[];
        NSString *mentionedContent = [mentionedInfoDict valueForKey:@"mentionedContent"] ?: @"";
        mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:type userIdList:userIdList mentionedContent:mentionedContent];
    }
    NSString *localPath = contentDic[@"localPath"];
    int duration = [contentDic[@"duration"] intValue];
    if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [RCLog e:[NSString stringWithFormat:@"%@,创建语音消息失败,语音文件路径不存在%@",LOG_TAG,localPath]];
        return nil;
    }
    NSData *voiceData= [NSData dataWithContentsOfFile:localPath];
    RCVoiceMessage *msg = [RCVoiceMessage messageWithAudio:voiceData duration:duration];
    msg.senderUserInfo = sendUserInfo;
    msg.mentionedInfo = mentionedInfo;
    return msg;
}

#pragma mark - private method

- (BOOL)isMediaMessage:(NSString *)objName {
    if([objName isEqualToString:@"RC:ImgMsg"] || [objName isEqualToString:@"RC:HQVCMsg"] || [objName isEqualToString:@"RC:SightMsg"] || [objName isEqualToString:@"RC:FileMsg"] || [objName isEqualToString:@"RC:GIFMsg"] || [objName isEqualToString:@"RC:CombineMsg"]) {
        return YES;
    }
    return NO;
}

- (NSString *)getCorrectLocalPath:(NSString *)localPath {
    localPath = [localPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [RCLog i:[NSString stringWithFormat:@"sendMediaMessage, localPath:%@",localPath]];
    return localPath;
}

- (BOOL)isForwardMessage:(NSString *)contentStr objName:(NSString *)objName {
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *localPath = [msgDic valueForKey:@"localPath"];
    //    NSString *remoteUrl = @"";
    if (!localPath || [localPath isKindOfClass:[NSNull class]]) {
        localPath = @"";
    }
    //    if ([objName isEqualToString:@"RC:ImgMsg"]) {
    //        remoteUrl = [msgDic valueForKey:@"imageUri"];
    //    } else if ([objName isEqualToString:@"RC:HQVCMsg"]) {
    //        remoteUrl = [msgDic valueForKey:@"remoteUrl"];
    //    } else if ([objName isEqualToString:@"RC:SightMsg"]) {
    //        remoteUrl = [msgDic valueForKey:@"sightUrl"];
    //    } else if ([objName isEqualToString:@"RC:FileMsg"]) {
    //        remoteUrl = [msgDic valueForKey:@"fileUrl"];
    //    } else if ([objName isEqualToString:@"RC:GIFMsg"]) {
    //        remoteUrl = [msgDic valueForKey:@"remoteUrl"];
    //    }
    //    if (localPath.length == 0 && remoteUrl.length > 0) {
    if (localPath.length == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)getVersion {
    return [RCIMFlutterWrapper sharedWrapper].sdkVersion;
}

@end
