//
//  RCIMFlutterWrapper.m
//  Pods-Runner
//
//  Created by Sin on 2019/6/5.
//

#import "RCIMFlutterWrapper.h"
#import <RongIMKit/RongIMKit.h>
#import "RCIMFlutterDefine.h"
#import "RCFlutterChatListViewController.h"
#import "RCFlutterChatViewController.h"
#import "RCFlutterConfig.h"
#import "RCFlutterMessageFactory.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@interface RCIMFlutterWrapper ()<RCIMUserInfoDataSource,RCIMReceiveMessageDelegate>
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
    }else if([RCMethodKeyConnect isEqualToString:call.method]) {
        [self connectWithToken:call.arguments result:result];
    }else if([RCMethodKeyDisconnect isEqualToString:call.method]) {
        [self disconnect:call.arguments];
    }else if([RCMethodKeyPushToConversationList isEqualToString:call.method]){
        [self pushToRCConversationList:call.arguments];
    }else if([RCMethodKeyPushToConversation isEqualToString:call.method]){
        [self pushToRCConversation:call.arguments];
    }else if([RCMethodKeyRefreshUserInfo isEqualToString:call.method]) {
        [self refreshUserInfo:call.arguments];
    }else if([RCMethodKeySendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments result:result];
    }else if([RCMethodKeyJoinChatRoom isEqualToString:call.method]) {
        [self joinChatRoom:call.arguments];
    }else if([RCMethodKeyQuitChatRoom isEqualToString:call.method]) {
        [self quitChatRoom:call.arguments];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - selector
- (void)initWithRCIMAppKey:(id)arg {
    if([arg isKindOfClass:[NSString class]]) {
        NSString *appkey = (NSString *)arg;
        [[RCIM sharedRCIM] initWithAppKey:appkey];
        NSLog(@"appkey %@",(NSString *)arg);
    }else {
        NSLog(@"init 非法参数类型");
    }
}

- (void)config:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *conf = (NSDictionary *)arg;
        RCFlutterConfig *config = [[RCFlutterConfig alloc] init];
        [config updateConf:conf];
        self.config = config;
        NSLog(@"RCFlutterConfig %@",conf);
        [self updateIMConfig];
        
        [RCIM sharedRCIM].userInfoDataSource = self;
        [RCIM sharedRCIM].receiveMessageDelegate = self;
    }else {
        NSLog(@"RCFlutterConfig 非法参数类型");
    }
}

- (void)connectWithToken:(id)arg result:(FlutterResult)result {
    if([arg isKindOfClass:[NSString class]]) {
        NSLog(@"connect start");
        NSString *token = (NSString *)arg;
        [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
            result(0);
            NSLog(@"connect end success");
        } error:^(RCConnectErrorCode status) {
            result(@(status));
            NSLog(@"connect end error %@",@(status));
        } tokenIncorrect:^{
            result(@(RC_CONN_TOKEN_INCORRECT));
            NSLog(@"connect end error %@",@(RC_CONN_TOKEN_INCORRECT));
        }];
        NSLog(@"appkey %@",(NSString *)arg);
    }else {
        NSLog(@"connect 非法参数类型");
    }
}

- (void)disconnect:(id)arg  {
    if([arg isKindOfClass:[NSNumber class]]) {
        BOOL needPush = [((NSNumber *) arg) boolValue];
        [[RCIM sharedRCIM] disconnect:needPush];
    }
}

- (void)pushToRCConversationList:(id)arg {
    if([arg isKindOfClass:[NSArray class]]) {
        NSArray *conTypes = (NSArray *)arg;
        RCFlutterChatListViewController *vc = [[RCFlutterChatListViewController alloc] init];
        vc.displayConversationTypeArray = conTypes;
        [self pushToVC:vc];
    }
}

- (void)pushToRCConversation:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        RCFlutterChatViewController *vc = [[RCFlutterChatViewController alloc] initWithConversationType:type targetId:targetId];
        [self pushToVC:vc];
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
            [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
        }
        
    }
}

- (void)sendMessage:(id)arg result:(FlutterResult)result{
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
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:objName];
        
        RCMessageContent *content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        __weak typeof(self) ws = self;
        RCMessage *message = [[RCIM sharedRCIM] sendMessage:type targetId:targetId content:content pushContent:nil pushData:nil success:^(long messageId) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_SENT) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@(messageId) forKey:@"messageId"];
            [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
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
    RCMessageContent *content = nil;
    if([objName isEqualToString:@"RC:ImgMsg"]) {
        NSData *data = [contentStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *localPath = [msgDic valueForKey:@"localPath"];
        content = [RCImageMessage messageWithImageURI:localPath];
    }else {
        NSLog(@"%s 非法的媒体消息类型",__func__);
        return;
    }
    
    __weak typeof(self) ws = self;
    RCMessage *message =  [[RCIM sharedRCIM] sendMediaMessage:type targetId:targetId content:content pushContent:nil pushData:nil progress:^(int progress, long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(messageId) forKey:@"messageId"];
        [dic setObject:@(progress) forKey:@"progress"];
        [ws.channel invokeMethod:RCMethodCallBackKeyUploadMediaProgress arguments:dic];
    } success:^(long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(messageId) forKey:@"messageId"];
        [dic setObject:@(SentStatus_SENT) forKey:@"status"];
        [ws.channel invokeMethod:RCMethodCallBackKeySendMessage arguments:dic];
    } error:^(RCErrorCode errorCode, long messageId) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@(messageId) forKey:@"messageId"];
        [dic setObject:@(SentStatus_FAILED) forKey:@"status"];
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
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        int msgCount = [dic[@"messageCount"] intValue];
        
        __weak typeof(self) ws = self;
        [[RCIMClient sharedRCIMClient] joinChatRoom:targetId messageCount:msgCount success:^{
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(1) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyJoinChatRoom arguments:callbackDic];
        }];
    }
}

- (void)quitChatRoom:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)arg;
        NSString *targetId = dic[@"targetId"];
        
        __weak typeof(self) ws = self;
        [[RCIMClient sharedRCIMClient] quitChatRoom:targetId success:^{
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(0) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyQuitChatRoom arguments:callbackDic];
        } error:^(RCErrorCode status) {
            NSMutableDictionary *callbackDic = [NSMutableDictionary new];
            [callbackDic setValue:targetId forKey:@"targetId"];
            [callbackDic setValue:@(1) forKey:@"status"];
            [ws.channel invokeMethod:RCMethodCallBackKeyQuitChatRoom arguments:callbackDic];
        }];
    }
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    [self.channel invokeMethod:RCMethodCallBackKeyRefreshUserInfo arguments:userId];
}

#pragma mark - RCIMReceiveMessageDelegate
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    @autoreleasepool {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSString *jsonString = [RCFlutterMessageFactory message2String:message];
        [dic setObject:jsonString forKey:@"message"];
        [dic setObject:@(left) forKey:@"left"];
        
        [self.channel invokeMethod:RCMethodCallBackKeyReceiveMessage arguments:dic];
    }
    
}

#pragma mark - util
- (void)updateIMConfig {
    [RCIM sharedRCIM].enablePersistentUserInfoCache = self.config.enablePersistentUserInfoCache;
}

#pragma mark - private method

- (BOOL)isMediaMessage:(NSString *)objName {
    if([objName isEqualToString:@"RC:ImgMsg"]) {
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
