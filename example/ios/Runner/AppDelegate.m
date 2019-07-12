#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDTestMessage.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    [[RCIMClient sharedRCIMClient] registerMessageType:[RCDTestMessage class]];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
