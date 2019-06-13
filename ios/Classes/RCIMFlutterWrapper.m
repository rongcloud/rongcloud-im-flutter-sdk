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

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
- (Class)messageClassWithTypeIdenfifier:(NSString *)identifier;
- (RCMessageContent *)messageContentWithClass:(Class)messageClass fromData:(NSData *)jsonData;
@end

@interface RCIMFlutterWrapper ()<RCIMUserInfoDataSource>
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
    }else if([RCMethodKeyPushToConversationList isEqualToString:call.method]){
        [self pushToRCConversationList:call.arguments];
    }else if([RCMethodKeyPushToConversation isEqualToString:call.method]){
        [self pushToRCConversation:call.arguments];
    }else if([RCMethodKeyRefreshUserInfo isEqualToString:call.method]) {
        [self refreshUserInfo:call.arguments];
    }else if([RCMethodKeySendMessage isEqualToString:call.method]) {
        [self sendMessage:call.arguments];
    }else{
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

- (void)sendMessage:(id)arg {
    if([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *param = (NSDictionary *)arg;
        RCConversationType type = [param[@"conversationType"] integerValue];
        NSString *targetId = param[@"targetId"];
        NSDictionary *cDic = param[@"content"];
        NSString *objName = param[@"objectName"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:cDic options:NSJSONWritingPrettyPrinted error:nil];
        Class clazz = [[RCMessageMapper sharedMapper] messageClassWithTypeIdenfifier:objName];
        
        RCMessageContent *content = [[RCMessageMapper sharedMapper] messageContentWithClass:clazz fromData:data];
        [[RCIM sharedRCIM] sendMessage:type targetId:targetId content:content pushContent:nil pushData:nil success:^(long messageId) {
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
            
        }];
        
    }
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    [self.channel invokeMethod:RCMethodKeyFetchUserInfo arguments:userId];
}

#pragma mark - util
- (void)updateIMConfig {
    [RCIM sharedRCIM].enablePersistentUserInfoCache = self.config.enablePersistentUserInfoCache;
}

#pragma mark - private method

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
