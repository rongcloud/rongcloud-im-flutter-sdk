#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDTestMessage.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    [[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
