#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDTestMessage.h"
#import <rongcloud_im_plugin/RCIMFlutterWrapper.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    /**
     //注册自定义消息流程
     用户只需要调用以下方法注册自定义消息。SDK 内部会在 connectWithToken: 方法里，链接 IM 之前 把所有自定义消息注册到底层 SDK。
     */
    [[RCIMFlutterWrapper sharedWrapper] registerMessageType:[RCDTestMessage class]];
    
    /**
     * 推送处理1 (申请推送权限)
     */
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    /**
     // 远程推送的内容
     NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
     // 传递远程推送数据
     if (remoteNotificationUserInfo != nil) {
     //远程推送的数据，延时之后再调用该接口，防止Flutter尚未初始化就调用，导致Flutter无法接受数据
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [[RCIMFlutterWrapper sharedWrapper] sendDataToFlutter:remoteNotificationUserInfo];
     });
     }
     */
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

/**
 * 推送处理2
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
   // 如果您的 SDK 版本已升级到 2.9.25，请使用下面这种方式:
    [[RCIMClient sharedRCIMClient] setDeviceTokenData:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
//    [[RCIMFlutterWrapper sharedWrapper] sendDataToFlutter:userInfo];
}




@end
