#import "RongcloudImPlugin.h"
#import "RCIMFlutterWrapper.h"

@implementation RongcloudImPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"rongcloud_im_plugin"
            binaryMessenger:[registrar messenger]];
  RongcloudImPlugin* instance = [[RongcloudImPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [[RCIMFlutterWrapper sharedWrapper] addFlutterChannel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[RCIMFlutterWrapper sharedWrapper] handleMethodCall:call result:result];
}

@end
