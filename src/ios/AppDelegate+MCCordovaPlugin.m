
#import <objc/runtime.h>
#import "AppDelegate+MCCordovaPlugin.h"
#import "MCCordovaPlugin.h"

#import "MarketingCloudSDK/MarketingCloudSDK.h"

@implementation AppDelegate (MCCordovaPlugin)

static NSString *const CURRENT_CORDOVA_VERSION_NAME = @"MC_Cordova_v1.1.0";

// its dangerous to override a method from within a category.
// Instead, we will use method swizzling.
+ (void)load {
    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    method_exchangeImplementations(original, swizzled);
}

// Swizzle the init, this will be executed after UIApplicationDidFinishLaunchingNotification with
// added functionality to create the notification checker for the ET SDK.
- (AppDelegate *)swizzled_init {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createNotificationChecker:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification"
                                               object:nil];
    return [self swizzled_init];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:.
- (void)createNotificationChecker:(NSNotification *)notification {
    if (notification) {
        NSDictionary *launchOptions = [notification userInfo];
        [self application:[UIApplication sharedApplication]
            shouldInitMCSDKWithOptions:launchOptions];
    }
}

- (NSString *)buildPayloadString:(NSDictionary *)dictionary {
    NSMutableString *objStr = [NSMutableString string];
    [objStr appendString:@"[{"];

    __block int count = 0;
    [dictionary
        enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
          NSString *formatStr;
          if (count == 0) {
              formatStr = [NSString stringWithFormat:@"\"%@\": \"%@\"", key, obj];
          } else {
              formatStr = [NSString stringWithFormat:@", \"%@\": \"%@\"", key, obj];
          }
          [objStr appendString:formatStr];

          count += 1;
        }];
    [objStr appendString:@"}]"];

    return objStr;
}

// Init the SDK with options set by the cordova plugin add command
- (BOOL)application:(UIApplication *)application
    shouldInitMCSDKWithOptions:(NSDictionary *)launchOptions {
    // weak reference to avoid retain cycle within block
    __weak __typeof__(self) weakSelf = self;

    if ([MarketingCloudSDK sharedInstance] == nil) {
        // failed to access the MarketingCloudSDK
        os_log_error(OS_LOG_DEFAULT, "Failed to access the MarketingCloudSDK");
    } else {
        MCCordovaPlugin *plugin = [self.viewController getCommandInstance:@"mccordovaplugin"];

        NSString *appId = [plugin.commandDelegate.settings
            objectForKey:[@"com.salesforce.marketingcloud.app_id" lowercaseString]];
        NSString *accessToken = [plugin.commandDelegate.settings
            objectForKey:[@"com.salesforce.marketingcloud.access_token" lowercaseString]];
        BOOL analytics = [plugin.commandDelegate.settings
            objectForKey:[@"com.salesforce.marketingcloud.analytics" lowercaseString]];
        NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
        [config setValue:appId forKey:@"appid"];
        [config setValue:accessToken forKey:@"accesstoken"];
        [config setValue:(analytics) ? @"true" : @"false" forKey:@"etanalytics"];

        NSLog(@"config: %@", config);

        NSError *configureError;

        [self writeStringToFile:[self buildPayloadString:config]];

        // start the configuration of the Marketing Cloud SDK - use explicit URL to configuration
        if ([[MarketingCloudSDK sharedInstance]
                sfmc_configureWithURL:[self readStringFileLocation]
                   configurationIndex:@(0)
                                error:&configureError
                    completionHandler:^(BOOL success, NSString *_Nonnull appId,
                                        NSError *_Nonnull error) {
                      if (success == YES) {
                          if (@available(iOS 10.0, *)) {
                              // set the delegate if needed then ask if we are authorized - the
                              // delegate must be set here if used
                              [UNUserNotificationCenter currentNotificationCenter].delegate =
                                  weakSelf;

                              [[UNUserNotificationCenter currentNotificationCenter]
                                  requestAuthorizationWithOptions:UNAuthorizationOptionAlert |
                                                                  UNAuthorizationOptionSound |
                                                                  UNAuthorizationOptionBadge
                                                completionHandler:^(BOOL granted,
                                                                    NSError *_Nullable error) {
                                                  if (error == nil) {
                                                      if (granted == YES) {
                                                          os_log_info(
                                                              OS_LOG_DEFAULT,
                                                              "Authorized for notifications = %s",
                                                              granted ? "YES" : "NO");

                                                          dispatch_async(
                                                              dispatch_get_main_queue(), ^{
                                                                // we are authorized to use
                                                                // notifications, request a device
                                                                // token for remote notifications
                                                                [[UIApplication sharedApplication]
                                                                    registerForRemoteNotifications];
                                                              });

                                                          [self setDefaultTag];
                                                      }
                                                  }
                                                }];
                          } else {
                              UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                  settingsForTypes:UIUserNotificationTypeBadge |
                                                   UIUserNotificationTypeSound |
                                                   UIUserNotificationTypeAlert
                                        categories:nil];
                              [[UIApplication sharedApplication]
                                  registerUserNotificationSettings:settings];
                              [[UIApplication sharedApplication] registerForRemoteNotifications];

                              [self setDefaultTag];
                          }
                      }
                    }] == NO) {
            // synchronous configuration portion failed
            os_log_debug(OS_LOG_DEFAULT, "%@", configureError);
        } else {
            // synchronous configuration portion succeeded
        }
    }

    return YES;
}

- (void)writeStringToFile:(NSString *)aString {
    // Build the path, and create if needed.
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                              YES) objectAtIndex:0];
    NSString *fileName = @"tempJSON.json";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }

    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}

- (NSURL *)readStringFileLocation {
    // Build the path...
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                              YES) objectAtIndex:0];
    NSString *fileName = @"tempJSON.json";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    NSURL *url = [NSURL fileURLWithPath:fileAtPath];

    return url;
}

- (void)setDefaultTag {
    NSSet *tagsSet = [[MarketingCloudSDK sharedInstance] sfmc_tags];
    for (NSString *tag in tagsSet) {
        NSRange range = [tag rangeOfString:@"MC_Cordova_v"];
        // Is this string at index 0 meaning its a valid Tag prefix.
        if (range.location != NSNotFound && range.location == 0) {
            [[MarketingCloudSDK sharedInstance] sfmc_removeTag:tag];  // remove old tag version
        }
    }

    [[MarketingCloudSDK sharedInstance]
        sfmc_addTag:CURRENT_CORDOVA_VERSION_NAME];  // add new tag version
}

// This method is REQUIRED for correct functionality of the SDK.
// This method will be called on the delegate when the application receives a silent push

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
