#import "MCCordovaPlugin.h"
#import "MarketingCloudSDK/MarketingCloudSDK.h"

@implementation MCCordovaPlugin

static NSString *const CURRENT_CORDOVA_VERSION_NAME = @"MC_Cordova_v2.0.0";

/**
 * TODO REMOVE!
 */
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

/**
 * TODO REMOVE!
 */
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

/**
 * TODO REMOVE!
 */
- (NSURL *)readStringFileLocation {
    // Build the path...
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                              YES) objectAtIndex:0];
    NSString *fileName = @"tempJSON.json";
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];

    NSURL *url = [NSURL fileURLWithPath:fileAtPath];

    return url;
}

- (void)pluginInitialize {
    if ([MarketingCloudSDK sharedInstance] == nil) {
        // failed to access the MarketingCloudSDK
        os_log_error(OS_LOG_DEFAULT, "Failed to access the MarketingCloudSDK");
    } else {
        NSString *appId = [self.commandDelegate.settings
            objectForKey:[@"com.salesforce.marketingcloud.app_id" lowercaseString]];
        NSString *accessToken = [self.commandDelegate.settings
            objectForKey:[@"com.salesforce.marketingcloud.access_token" lowercaseString]];
        BOOL analytics = [self.commandDelegate.settings
            objectForKey:[@"com.salesforce.marketingcloud.analytics" lowercaseString]];
        NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
        [config setValue:appId forKey:@"appid"];
        [config setValue:accessToken forKey:@"accesstoken"];
        [config setValue:(analytics) ? @"true" : @"false" forKey:@"etanalytics"];

        NSLog(@"config: %@", config);

        [self writeStringToFile:[self buildPayloadString:config]];

        // TODO Remove completion handler since it not helpful.
        NSError *configError = nil;
        if ([[MarketingCloudSDK sharedInstance] sfmc_configureWithURL:[self readStringFileLocation]
                                                   configurationIndex:@(0)
                                                                error:&configError]) {
            [self setDelegate];
            [self setDefaultTag];
            [self requestPushPermission];
        } else if (configError != nil) {
            os_log_debug(OS_LOG_DEFAULT, "%@", configError);
        }
    }
}

- (void)setDelegate {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[UIApplication sharedApplication].delegate
            respondsToSelector:@selector(sfmc_setNotificationDelegate)] == YES) {
        [[UIApplication sharedApplication].delegate
            performSelector:@selector(sfmc_setNotificationDelegate)
                 withObject:nil];
    }
#pragma clang diagnostic pop
}

- (void)requestPushPermission {
    if (@available(iOS 10, *)) {
        [[UNUserNotificationCenter currentNotificationCenter]
            requestAuthorizationWithOptions:UNAuthorizationOptionAlert |
                                            UNAuthorizationOptionSound | UNAuthorizationOptionBadge
                          completionHandler:^(BOOL granted, NSError *_Nullable error) {
                            if (granted) {
                                os_log_info(OS_LOG_DEFAULT, "Authorized for notifications = %s",
                                            granted ? "YES" : "NO");

                                dispatch_async(dispatch_get_main_queue(), ^{
                                  // we are authorized to use
                                  // notifications, request a device
                                  // token for remote notifications
                                  [[UIApplication sharedApplication]
                                      registerForRemoteNotifications];
                                });
                            } else if (error != nil) {
                                os_log_debug(OS_LOG_DEFAULT, "%@", error);
                            }
                          }];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
            settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound |
                             UIUserNotificationTypeAlert
                  categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
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

- (void)enableVerboseLogging:(CDVInvokedUrlCommand *)command {
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:YES];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)disableVerboseLogging:(CDVInvokedUrlCommand *)command {
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:NO];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)getSystemToken:(CDVInvokedUrlCommand *)command {
    NSString *systemToken = [[MarketingCloudSDK sharedInstance] sfmc_deviceToken];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:systemToken]
                                callbackId:command.callbackId];
}

- (void)isPushEnabled:(CDVInvokedUrlCommand *)command {
    BOOL enabled = [[MarketingCloudSDK sharedInstance] sfmc_pushEnabled];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(enabled) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand *)command {
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:YES];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)disablePush:(CDVInvokedUrlCommand *)command {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

    [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:NO];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)setAttribute:(CDVInvokedUrlCommand *)command {
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *value = [command.arguments objectAtIndex:1];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_setAttributeNamed:name value:value];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)clearAttribute:(CDVInvokedUrlCommand *)command {
    NSString *name = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_clearAttributeNamed:name];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)getAttributes:(CDVInvokedUrlCommand *)command {
    NSDictionary *attributes = [[MarketingCloudSDK sharedInstance] sfmc_attributes];

    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                       messageAsDictionary:(attributes != nil) ? attributes : @{}]
              callbackId:command.callbackId];
}

- (void)getContactKey:(CDVInvokedUrlCommand *)command {
    NSString *contactKey = [[MarketingCloudSDK sharedInstance] sfmc_contactKey];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:contactKey]
                                callbackId:command.callbackId];
}

- (void)setContactKey:(CDVInvokedUrlCommand *)command {
    NSString *contactKey = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_setContactKey:contactKey];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)addTag:(CDVInvokedUrlCommand *)command {
    NSString *tag = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_addTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand *)command {
    NSString *tag = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_removeTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)getTags:(CDVInvokedUrlCommand *)command {
    NSSet *setTags = [[MarketingCloudSDK sharedInstance] sfmc_tags];
    NSMutableArray *arrayTags = [NSMutableArray arrayWithArray:[setTags allObjects]];

    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsArray:(arrayTags != nil) ? arrayTags : @[]]
              callbackId:command.callbackId];
}

@end
