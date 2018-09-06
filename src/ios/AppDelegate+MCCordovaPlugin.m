
#import <objc/runtime.h>
#import "AppDelegate+MCCordovaPlugin.h"
#import "MCCordovaPlugin.h"

#import "MarketingCloudSDK/MarketingCloudSDK.h"

@implementation AppDelegate (MCCordovaPlugin)

-(void) sfmc_setNotificationDelegate {
     if (@available(iOS 10, *)) {
         [UNUserNotificationCenter currentNotificationCenter].delegate = self;
     }
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (@available(iOS 10, *)) {
        UNMutableNotificationContent *theSilentPushContent =
            [[UNMutableNotificationContent alloc] init];
        theSilentPushContent.userInfo = userInfo;
        UNNotificationRequest *theSilentPushRequest =
            [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString
                                                 content:theSilentPushContent
                                                 trigger:nil];

        [[MarketingCloudSDK sharedInstance] sfmc_setNotificationRequest:theSilentPushRequest];
    } else {
        [[MarketingCloudSDK sharedInstance] sfmc_setNotificationUserInfo:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // save the device token
    [[MarketingCloudSDK sharedInstance] sfmc_setDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    os_log_debug(OS_LOG_DEFAULT, "didFailToRegisterForRemoteNotificationsWithError = %@", error);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {
    // tell the MarketingCloudSDK about the notification
    [[MarketingCloudSDK sharedInstance] sfmc_setNotificationRequest:response.notification.request];

    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:
             (void (^)(UNNotificationPresentationOptions options))completionHandler {
    // tell the MarketingCloudSDK about the notification
    [[MarketingCloudSDK sharedInstance] sfmc_setNotificationRequest:notification.request];

    if (completionHandler != nil) {
        completionHandler(UNNotificationPresentationOptionAlert);
    }
}

#pragma mark - Custom message handlers

- (void)notificationReceivedWithUserInfo:(NSDictionary *)userInfo
                             messageType:(NSString *)messageType
                               alertText:(NSString *)alertText {
    NSLog(@"### USERINFO: %@", userInfo);
    NSLog(@"### alertText: %@", alertText);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCDVPushReceivedNotification"
                                                        object:self
                                                      userInfo:nil];
}

@end
