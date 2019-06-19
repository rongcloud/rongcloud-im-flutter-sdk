#import "RongcloudImPlugin.h"
#import "RCIMFlutterWrapper.h"
#import "RCFlutterViewFactory.h"

@implementation RongcloudImPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"rongcloud_im_plugin"
            binaryMessenger:[registrar messenger]];
  RongcloudImPlugin* instance = [[RongcloudImPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [[RCIMFlutterWrapper sharedWrapper] addFlutterChannel:channel];
    [registrar registerViewFactory:[[RCFlutterViewFactory alloc] initWithMessenger:registrar.messenger] withId:@"rc_chat_view"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[RCIMFlutterWrapper sharedWrapper] handleMethodCall:call result:result];
}

@end
