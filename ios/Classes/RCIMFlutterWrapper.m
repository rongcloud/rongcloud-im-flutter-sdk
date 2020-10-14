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

@interface RCIMFlutterWrapper ()<RCIMClientReceiveMessageDelegate,RCConnectionStatusChangeDelegate,RCTypingStatusDelegate, RCMessageDestructDelegate, RCChatRoomKVStatusChangeDelegate, RCMessageExpansionDelegate>
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
    }
    else {
        result(FlutterMethodNotImplemented);
    }
    
}




#pragma mark - selector
- (void)initWithRCIMAppKey:(id)arg {
//    NSString *LOG_TAG =  @"init";
//    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *appkey = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] initWithAppKey:appkey];
        
        /// imlib 默认检测到小视频 SDK，才会注册小视频消息，但是这里没有小视频 SDK
        [[RCIMClient sharedRCIMClient] registerMessageType:RCSightMessage.class];
        
        [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
        [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
        [[RCIMClient sharedRCIMClient] setRCTypingStatusDelegate:self];
        [[RCIMClient sharedRCIMClient] setRCMessageDestructDelegate:self];
        [[RCIMClient sharedRCIMClient] setRCChatRoomKVStatusChangeDelegate:self];
        [[RCIMClient sharedRCIMClient] setMessageExpansionDelegate:self];
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
//    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *token = (NSString *)arg;
        [[RCIMClient sharedRCIMClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
            [RCLog i:[NSString stringWithFormat:@"%@ dbOpened，code: %@",LOG_TAG, @(code)]];
        } success:^(NSString *userId) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:userId forKey:@"userId"];
            [dic setObject:@(0) forKey:@"code"];
            result(dic);
        } error:^(RCConnectErrorCode errorCode) {
            [RCLog i:[NSString stringWithFormat:@"%@ fail %@",LOG_TAG,@(errorCode)]];
            result(@{@"code":@(errorCode), @"userId":@""});
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
        } else if ([objName isEqualToString:RCLocationMessageTypeIdentifier]) {
            RCUserInfo *sendUserInfo = nil;
            RCMentionedInfo *mentionedInfo = nil;
            NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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
//            NSString *thumbnailBase64String = [msgDic valueForKey:@"content"];
            double latitude = [[msgDic valueForKey:@"latitude"] doubleValue];
            double longitude = [[msgDic valueForKey:@"longitude"] doubleValue];
            NSString *imageUri = [msgDic valueForKey:@"mImgUri"];
            UIImage *image = [UIImage imageWithContentsOfFile:imageUri];
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
            NSString *poi = [msgDic valueForKey:@"poi"];
            RCLocationMessage *locationMessage = [RCLocationMessage messageWithLocationImage:image location:location locationName:poi];
            locationMessage.senderUserInfo = sendUserInfo;
            locationMessage.mentionedInfo = mentionedInfo;
            content = locationMessage;
        } else {
            content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        }
        if(content == nil) {
            [RCLog e:[NSString stringWithFormat:@"%@  message content is nil",LOG_TAG]];
            result(nil);
            return;
        }
        
        __weak typeof(self) ws = self;
        if (param[@"disableNotification"]) {
            BOOL disableNotification = [param[@"disableNotification"] boolValue];
            RCMessage *message = [[RCMessage alloc] initWithType:type targetId:targetId direction:MessageDirection_SEND messageId:0 content:content];
            message.messageConfig.disableNotification = disableNotification;
            message = [[RCIMClient sharedRCIMClient] sendMessage:message pushContent:pushContent pushData:pushData successBlock:^(RCMessage *successMessage) {
                [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(successMessage.messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_SENT) forKey:@"status"];
                [dic setObject:@(0) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
                [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(errorMessage.messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
                [dic setObject:@(nErrorCode) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            }];
            message.senderUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId ?: @"";
            NSString *jsonString = [RCFlutterMessageFactory message2String:message];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:jsonString forKey:@"message"];
            [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
            [dic setObject:@(message.messageId) forKey:@"messageId"];
            [dic setObject:@(-1) forKey:@"code"];
            result(dic);
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } else {
            RCMessage *message = [[RCIMClient sharedRCIMClient] sendMessage:type targetId:targetId content:content pushContent:pushContent pushData:pushData success:^(long messageId) {
                [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
                NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:@(messageId) forKey:@"messageId"];
                [dic setObject:@(SentStatus_SENT) forKey:@"status"];
                [dic setObject:@(0) forKey:@"code"];
                if (timestamp > 0) {
                    [dic setObject:@(timestamp) forKey:@"timestamp"];
                }
                [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            } error:^(RCErrorCode nErrorCode, long messageId) {
                [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
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
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
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
        message = [[RCIMClient sharedRCIMClient] sendMessage:message pushContent:pushContent pushData:pushData successBlock:^(RCMessage *successMessage) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(successMessage.messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
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
    
    if([message.content isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)message.content;
        if(sightMsg.duration > 10) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(-1) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(RC_SIGHT_MSG_DURATION_LIMIT_EXCEED) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            NSLog(@"%s 小视频时间超限",__func__);
            [self.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            return;
        }
    }
    
    __weak typeof(self) ws = self;
    message = [[RCIMClient sharedRCIMClient] sendMediaMessage:message pushContent:pushContent pushData:pushData progress:^(int progress, RCMessage *progressMessage) {
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
    message.senderUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId ?: @"";
    NSString *jsonString = [RCFlutterMessageFactory message2String:message];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:jsonString forKey:@"message"];
    [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
    [dic setObject:@(message.messageId) forKey:@"messageId"];
    [dic setObject:@(-1) forKey:@"code"];
    result(dic);
    [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
}

- (void)sendMediaMessage:(id)arg result:(FlutterResult)result {
    NSDictionary *param = (NSDictionary *)arg;
    NSString *objName = param[@"objectName"];
    RCConversationType type = [param[@"conversationType"] integerValue];
    NSString *targetId = param[@"targetId"];
    NSString *contentStr = param[@"content"];
    NSString *pushContent = param[@"pushContent"];
    long long timestamp = [param[@"timestamp"] longLongValue];
    if(pushContent.length <= 0) {
        pushContent = nil;
    }
    NSString *pushData = param[@"pushData"];
    if(pushData.length <= 0) {
        pushData = nil;
    }
    RCMessageContent *content = nil;
    RCUserInfo *sendUserInfo = nil;
    RCMentionedInfo *mentionedInfo = nil;
    NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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
        NSLog(@"%s 非法的媒体消息类型",__func__);
        return;
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
    
    if([content isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)content;
        if(sightMsg.duration > 10) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(-1) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
            [dic setObject:@(RC_SIGHT_MSG_DURATION_LIMIT_EXCEED) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            NSLog(@"%s 小视频时间超限",__func__);
            [self.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
            return;
        }
    }
    
    __weak typeof(self) ws = self;
    if (param[@"disableNotification"]) {
        BOOL disableNotification = [param[@"disableNotification"] boolValue];
        RCMessage *message = [[RCMessage alloc] initWithType:type targetId:targetId direction:MessageDirection_SEND messageId:0 content:content];
        message.messageConfig.disableNotification = disableNotification;
        message = [[RCIMClient sharedRCIMClient] sendMediaMessage:message pushContent:pushContent pushData:pushData progress:^(int progress, RCMessage *progressMessage) {
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
        message.senderUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId ?: @"";
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(SentStatus_SENDING) forKey:@"status"];
        [dic setObject:@(message.messageId) forKey:@"messageId"];
        [dic setObject:@(-1) forKey:@"code"];
        result(dic);
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } else {
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
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } error:^(RCErrorCode errorCode, long messageId) {
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
        NSArray *userIdList = param[@"userIdList"];
        NSString *contentStr = param[@"content"];
        NSString *pushContent = param[@"pushContent"];
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
        RCMessage *message = [[RCIMClient sharedRCIMClient] sendDirectionalMessage:type targetId:targetId toUserIdList:userIdList content:content pushContent:pushContent pushData:pushData success:^(long messageId) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [dic setObject:@(0) forKey:@"code"];
            if (timestamp > 0) {
                [dic setObject:@(timestamp) forKey:@"timestamp"];
            }
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
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
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessage arguments:callbackDic];
        } success:^(NSString *mediaPath) {
            RCMessage *tempMessage = [[RCIMClient sharedRCIMClient] getMessage:message.messageId];
            NSString *messageString = [RCFlutterMessageFactory message2String:tempMessage];
            NSDictionary *callbackDic = @{@"messageId": @(tempMessage.messageId), @"message": messageString, @"code": @(0)};
            [self.channel invokeMethod:RCMethodCallBackKeyDownloadMediaMessage arguments:callbackDic];
        } error:^(RCErrorCode errorCode) {
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
        [dict setObject:startTime?:@"" forKey:@"startTime"];
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

#pragma mark - 阅后即焚
- (void)messageBeginDestruct:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"messageBeginDestruct";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        [[RCIMClient sharedRCIMClient] messageBeginDestruct:message];
    }
}

- (void)messageStopDestruct:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"downloadMediaMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        
        NSDictionary *messageDic = param[@"message"];
        RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
        
        [[RCIMClient sharedRCIMClient] messageStopDestruct:message];;
    }
}

- (void)setReconnectKickEnable:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setReconnectKickEnable";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    BOOL enable = (BOOL)arg;
    [[RCIMClient sharedRCIMClient] setReconnectKickEnable:enable];
}

- (void)getConnectionStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getConnectionStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    result(@(status));
}

- (void)cancelDownloadMediaMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"cancelDownloadMediaMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    long messageId = (long)arg;
    [[RCIMClient sharedRCIMClient] cancelDownloadMediaMessage:messageId];
}

- (void)getRemoteChatroomHistoryMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getRemoteChatroomHistoryMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *targetId = param[@"targetId"];
        long long recordTime = [param[@"recordTime"] longLongValue];
        int count = [param[@"count"] intValue];
        RCTimestampOrder order = [param[@"order"] intValue];
        
        [[RCIMClient sharedRCIMClient] getRemoteChatroomHistoryMessages:targetId recordTime:recordTime count:count order:order success:^(NSArray *messages, long long syncTime) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
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
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setObject:@(status) forKey:@"code"];
            [callbackDic setObject:@(-1) forKey:@"syncTime"];
            result(callbackDic);
        }];
    }
}

- (void)getMessageByUId:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getMessageByUId";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSString class]]) {
        NSString *messageUId = (NSString *)arg;
        RCMessage *message = [[RCIMClient sharedRCIMClient] getMessageByUId:messageUId];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(jsonString);
    }
}

- (void)getFirstUnreadMessage:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getFirstUnreadMessage";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
         NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"]?:@"";
        RCMessage *message = [[RCIMClient sharedRCIMClient] getFirstUnreadMessage:type targetId:targetId];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        result(jsonString);
    }
}

#pragma mark - 聊天室状态存储 (使用前必须先联系商务开通)
- (void)setChatRoomEntry:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setChatRoomEntry";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        NSString *value = param[@"value"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        BOOL autoDelete = [param[@"autoDelete"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] setChatRoomEntry:chatRoomId key:key value:value sendNotification:sendNotification autoDelete:autoDelete notificationExtra:notificationExtra success:^{
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
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        NSString *value = param[@"value"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        BOOL autoDelete = [param[@"autoDelete"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] forceSetChatRoomEntry:chatRoomId key:key value:value sendNotification:sendNotification autoDelete:autoDelete notificationExtra:notificationExtra success:^{
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
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        
        [[RCIMClient sharedRCIMClient] getChatRoomEntry:chatRoomId key:key success:^(NSDictionary *entry) {
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
        NSString *chatRoomId = param[@"chatRoomId"];
        
        [[RCIMClient sharedRCIMClient] getAllChatRoomEntries:chatRoomId success:^(NSDictionary *entry) {
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
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] removeChatRoomEntry:chatRoomId key:key sendNotification:sendNotification notificationExtra:notificationExtra success:^{
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
        NSString *chatRoomId = param[@"chatRoomId"];
        NSString *key = param[@"key"];
        BOOL sendNotification = [param[@"sendNotification"] boolValue];
        NSString *notificationExtra = param[@"notificationExtra"];
        
        [[RCIMClient sharedRCIMClient] forceRemoveChatRoomEntry:chatRoomId key:key sendNotification:sendNotification notificationExtra:notificationExtra success:^{
            result(@(0));
        } error:^(RCErrorCode nErrorCode) {
            result(@(nErrorCode));
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
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSDictionary *expansionDic = param[@"expansionDic"];
        NSString *messageUId = param[@"messageUId"];
        [[RCIMClient sharedRCIMClient] updateMessageExpansion:expansionDic messageUId:messageUId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)removeMessageExpansionForKey:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"removeMessageExpansionForKey";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        NSArray *keyArray = param[@"keyArray"];
        NSString *messageUId = param[@"messageUId"];
        [[RCIMClient sharedRCIMClient] removeMessageExpansionForKey:keyArray messageUId:messageUId success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
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

- (void)deleteRemoteMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"deleteRemoteMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSArray *messageMapList = param[@"messages"];
        NSMutableArray *messageList = [NSMutableArray arrayWithCapacity:messageMapList.count];
        for (NSDictionary *messageDic in messageMapList) {
            RCMessage *message = [RCFlutterMessageFactory dic2Message:messageDic];
            [messageList addObject:message];
        }
        
        [[RCIMClient sharedRCIMClient] deleteRemoteMessage:type targetId:targetId messages:messageList success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } error:^(RCErrorCode status) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(status)]];
            result(@(status));
        }];
    }
}

- (void)clearMessages:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"clearMessages";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        BOOL success = [[RCIMClient sharedRCIMClient] clearMessages:type targetId:targetId];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog i:[NSString stringWithFormat:@"%@ error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)setMessageExtra:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setMessageExtra";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        long messageId = [param[@"messageId"] longValue];
        NSString *value = param[@"value"];
        
        BOOL success = [[RCIMClient sharedRCIMClient] setMessageExtra:messageId value:value];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog i:[NSString stringWithFormat:@"%@ error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)setMessageReceivedStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setMessageReceivedStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        long messageId = [param[@"messageId"] longValue];
        RCReceivedStatus receivedStatus = [param[@"receivedStatus"] intValue];
        
        BOOL success = [[RCIMClient sharedRCIMClient] setMessageReceivedStatus:messageId receivedStatus:receivedStatus];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog i:[NSString stringWithFormat:@"%@ error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)setMessageSentStatus:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setMessageSentStatus";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        long messageId = [param[@"messageId"] longValue];
        RCSentStatus receivedStatus = [param[@"sentStatus"] intValue];
        
        BOOL success = [[RCIMClient sharedRCIMClient] setMessageSentStatus:messageId sentStatus:receivedStatus];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog i:[NSString stringWithFormat:@"%@ error",LOG_TAG]];
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
        BOOL success = [[RCIMClient sharedRCIMClient] clearConversations:conversationType];
        if (success) {
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@(0));
        } else {
            [RCLog i:[NSString stringWithFormat:@"%@ error",LOG_TAG]];
            result(@(-1));
        }
    }
}

- (void)getDeltaTime:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getDeltaTime";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    
    long long deltaTime = [[RCIMClient sharedRCIMClient] getDeltaTime];
    result(@(deltaTime));
}

- (void)setOfflineMessageDuration:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"setOfflineMessageDuration";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        int duration = [param[@"duration"] intValue];
        
        [[RCIMClient sharedRCIMClient] setOfflineMessageDuration:duration success:^{
            [RCLog i:[NSString stringWithFormat:@"%@ success",LOG_TAG]];
            result(@{@"code":@(0)});
        } failure:^(RCErrorCode nErrorCode) {
            [RCLog e:[NSString stringWithFormat:@"%@ %@",LOG_TAG,@(nErrorCode)]];
            result(@{@"code":@(nErrorCode)});
        }];
    }
}

- (void)getOfflineMessageDuration:(id)arg result:(FlutterResult)result {
    NSString *LOG_TAG = @"getOfflineMessageDuration";
    [RCLog i:[NSString stringWithFormat:@"%@ start param:%@",LOG_TAG,arg]];
    int duration = [[RCIMClient sharedRCIMClient] getOfflineMessageDuration];
    result(@(duration));
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

- (void)onMessageRecalled:(long)messageId {
    RCMessage *recalledMsg = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    NSString *jsonString = [RCFlutterMessageFactory message2String:recalledMsg];
    NSDictionary *dict = @{@"message": jsonString};
    [self.channel invokeMethod:RCMethodCallBackKeyRecallMessage arguments:dict];
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
        NSLog(@"创建语音消息失败：语音文件路径不存在:%@",localPath);
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
    [RCLog i:[NSString stringWithFormat:@"sendMediaMessage localPath:%@",localPath]];
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

@end
