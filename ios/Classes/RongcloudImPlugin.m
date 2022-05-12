#import "RongcloudImPlugin.h"
#import "RCIMFlutterWrapper.h"
#import <RongIMLibCore/RongIMLibCore.h>

@implementation RongcloudImPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"rongcloud_im_plugin"
                                                              binaryMessenger:[registrar messenger]];
  RongcloudImPlugin* instance = [[RongcloudImPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
  [[RCIMFlutterWrapper sharedWrapper] setFlutterChannel:channel];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RCIMFlutterWrapper sharedWrapper] setFlutterChannel:nil];
    });
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[RCIMFlutterWrapper sharedWrapper] handleMethodCall:call result:result];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[RCCoreClient sharedCoreClient] setDeviceTokenData:deviceToken];
}

@end
