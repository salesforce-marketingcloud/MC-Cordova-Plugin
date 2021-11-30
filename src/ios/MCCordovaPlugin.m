// MCCordovaPlugin.m
//
// Copyright (c) 2018 Salesforce, Inc
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer. Redistributions in binary
// form must reproduce the above copyright notice, this list of conditions and
// the following disclaimer in the documentation and/or other materials
// provided with the distribution. Neither the name of the nor the names of
// its contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "MCCordovaPlugin.h"

@implementation MCCordovaPlugin

const int LOG_LENGTH = 800;

@synthesize eventsCallbackId;
@synthesize notificationOpenedSubscribed;
@synthesize cachedNotification;

+ (NSMutableDictionary *_Nullable)dataForNotificationReceived:(NSNotification *)notification {
    NSMutableDictionary *notificationData = nil;

    if (notification.userInfo != nil) {
        if (@available(iOS 10.0, *)) {
            UNNotificationRequest *userNotificationRequest =
                notification.userInfo
                    [@"SFMCFoundationUNNotificationReceivedNotificationKeyUNNotificationRequest"];
            if (userNotificationRequest != nil) {
                notificationData = [userNotificationRequest.content.userInfo mutableCopy];
            }
        }
        if (notificationData == nil) {
            NSDictionary *userNotificationUserInfo =
                notification.userInfo[@"SFMCFoundationNotificationReceivedNotificationKeyUserInfo"];
            notificationData = [userNotificationUserInfo mutableCopy];
        }
    }

    if (notificationData != nil) {
        if ([notificationData[@"aps"] objectForKey:@"content-available"] != nil) {
            // Making the same assumption as the SDK would here.
            // if silent push, bail out so that the data is not returned as "notification opened"
            return nil;
        }
        NSString *alert = nil;
        NSString *title = nil;
        NSString *subtitle = nil;
        if ([notificationData[@"aps"][@"alert"] isKindOfClass:[NSString class]]) {
            alert = notificationData[@"aps"][@"alert"];
        } else if ([notificationData[@"aps"][@"alert"] isKindOfClass:[NSDictionary class]]) {
            // if not a silent push, pull out the rest of the alert values
            if ([notificationData[@"aps"][@"alert"] isEqualToDictionary:@{}] == NO) {
                alert = notificationData[@"aps"][@"alert"][@"body"];
                title = notificationData[@"aps"][@"alert"][@"title"];
                subtitle = notificationData[@"aps"][@"alert"][@"subtitle"];
            }
        }
        if (alert != nil) {
            [notificationData setValue:alert forKey:@"alert"];
        }
        if (title != nil) {
            [notificationData setValue:title forKey:@"title"];
        }
        if (subtitle != nil) {
            [notificationData setValue:subtitle forKey:@"subtitle"];
        }
        [notificationData removeObjectForKey:@"aps"];
    }

    return notificationData;
}

- (void)log:(NSString *)msg {
    if (@available(iOS 10, *)) {
        if (self.logger == nil) {
            self.logger =
                os_log_create("com.salesforce.marketingcloud.marketingcloudsdk", "Cordova");
        }
        os_log_info(self.logger, "%@", msg);
    } else {
        NSLog(@"%@", msg);
    }
}

- (void)splitLog:(NSString *)msg {
    NSInteger length = msg.length;
    for (int i = 0; i < length; i += LOG_LENGTH) {
        NSInteger rangeLength = MIN(length - i, LOG_LENGTH);
        [self log:[msg substringWithRange:NSMakeRange((NSUInteger)i, (NSUInteger)rangeLength)]];
    }
}

- (void)sfmc_handleURL:(NSURL *)url type:(NSString *)type {
    if ([type isEqualToString:@"action"] && self.eventsCallbackId != nil) {
        CDVPluginResult *result = [CDVPluginResult
               resultWithStatus:CDVCommandStatus_OK
            messageAsDictionary:@{@"type" : @"urlAction", @"url" : url.absoluteString}];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.eventsCallbackId];
    }
}

- (void)pluginInitialize {
    if ([MarketingCloudSDK sharedInstance] == nil) {
        // failed to access the MarketingCloudSDK
        os_log_error(OS_LOG_DEFAULT, "Failed to access the MarketingCloudSDK");
    } else {
        NSDictionary *pluginSettings = self.commandDelegate.settings;

        MarketingCloudSDKConfigBuilder *configBuilder = [MarketingCloudSDKConfigBuilder new];
        [configBuilder
            sfmc_setApplicationId:pluginSettings[@"com.salesforce.marketingcloud.app_id"]];
        [configBuilder
            sfmc_setAccessToken:pluginSettings[@"com.salesforce.marketingcloud.access_token"]];

        BOOL analytics = [pluginSettings[@"com.salesforce.marketingcloud.analytics"] boolValue];
        [configBuilder sfmc_setAnalyticsEnabled:@(analytics)];

        BOOL delayRegistrationUntilContactKeyIsSet = [pluginSettings
                [@"com.salesforce.marketingcloud.delay_registration_until_contact_key_is_set"]
            boolValue];
        [configBuilder
            sfmc_setDelayRegistrationUntilContactKeyIsSet:@(delayRegistrationUntilContactKeyIsSet)];

        NSString *tse = pluginSettings[@"com.salesforce.marketingcloud.tenant_specific_endpoint"];
        if (tse != nil) {
            [configBuilder sfmc_setMarketingCloudServerUrl:tse];
        }

        NSString *gfm = pluginSettings[@"com.salesforce.marketingcloud.geofence_messaging"];
        if ([gfm caseInsensitiveCompare:@"true"] == NSOrderedSame) {
            [configBuilder sfmc_setLocationEnabled:@YES];
        }

        NSError *configError = nil;
        if ([[MarketingCloudSDK sharedInstance]
                sfmc_configureWithDictionary:[configBuilder sfmc_build]
                                       error:&configError]) {
            [self setDelegate];
            [[MarketingCloudSDK sharedInstance] sfmc_setURLHandlingDelegate:self];
            [[MarketingCloudSDK sharedInstance] sfmc_addTag:@"Cordova"];
            [self requestPushPermission];
        } else if (configError != nil) {
            os_log_debug(OS_LOG_DEFAULT, "%@", configError);
            if (configError.code == configureInvalidAppEndpointError) {
                NSException *tseException = [NSException
                    exceptionWithName:
                        @"cordova-plugin-marketingcloudsdk:Tenant Specific Endpoint Exception"
                               reason:@"configureInvalidAppEndpointError"
                             userInfo:configError.userInfo];
                @throw tseException;
            }
        }

        [[NSNotificationCenter defaultCenter]
            addObserverForName:SFMCFoundationUNNotificationReceivedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *_Nonnull note) {
                      NSMutableDictionary *userInfo =
                          [MCCordovaPlugin dataForNotificationReceived:note];
                      if (userInfo != nil) {
                          NSString *url = nil;
                          NSString *type = nil;
                          if ((url = userInfo[@"_od"])) {
                              type = @"openDirect";
                          } else if ((url = userInfo[@"_x"])) {
                              type = @"cloudPage";
                          } else {
                              type = @"other";
                          }

                          if (url != nil) {
                              [userInfo setValue:url forKey:@"url"];
                          }
                          [userInfo setValue:type forKey:@"type"];

                          [self sendNotificationEvent:@{
                              @"timeStamp" :
                                  @((long)([[NSDate date] timeIntervalSince1970] * 1000)),
                              @"values" : userInfo,
                              @"type" : @"notificationOpened"
                          }];
                      }
                    }];
    }
}

- (void)sendNotificationEvent:(NSDictionary *)notification {
    if (self.notificationOpenedSubscribed && self.eventsCallbackId != nil) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsDictionary:notification];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.eventsCallbackId];
    } else {
        self.cachedNotification = notification;
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

- (void)logSdkState:(CDVInvokedUrlCommand *)command {
    [self splitLog:[[MarketingCloudSDK sharedInstance] sfmc_getSDKState]];
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
    NSString *name = command.arguments[0];
    NSString *value = command.arguments[1];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_setAttributeNamed:name value:value];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)clearAttribute:(CDVInvokedUrlCommand *)command {
    NSString *name = command.arguments[0];

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
    NSString *contactKey = command.arguments[0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_setContactKey:contactKey];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)addTag:(CDVInvokedUrlCommand *)command {
    NSString *tag = command.arguments[0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_addTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand *)command {
    NSString *tag = command.arguments[0];

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

- (void)registerEventsChannel:(CDVInvokedUrlCommand *)command {
    self.eventsCallbackId = command.callbackId;
    if (self.notificationOpenedSubscribed) {
        [self sendCachedNotification];
    }
}

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    if (command.arguments != nil && [command.arguments count] > 0) {
        NSString *eventName = command.arguments[0];

        if ([eventName isEqualToString:@"notificationOpened"]) {
            self.notificationOpenedSubscribed = YES;
            if (self.eventsCallbackId != nil) {
                [self sendCachedNotification];
            }
        }
    }
}

- (void)sendCachedNotification {
    if (self.cachedNotification != nil) {
        [self sendNotificationEvent:self.cachedNotification];
        self.cachedNotification = nil;
    }
}

- (void)locationEnabled:(CDVInvokedUrlCommand *)command {
	BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_locationEnabled];
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
	                                        messageAsInt:(success) ? 1 : 0]
	 callbackId:command.callbackId];
}

- (void)startWatchingLocation:(CDVInvokedUrlCommand *)command {
    [[MarketingCloudSDK sharedInstance] sfmc_startWatchingLocation];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)sfmc_stopWatchingLocation:(CDVInvokedUrlCommand *)command {
    [[MarketingCloudSDK sharedInstance] sfmc_stopWatchingLocation];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)watchingLocation:(CDVInvokedUrlCommand *)command {
	BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_watchingLocation];
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
	                                        messageAsInt:(success) ? 1 : 0]
	 callbackId:command.callbackId];
}

- (void)lastKnownLocation:(CDVInvokedUrlCommand *)command {
	NSDictionary<NSString *, NSString *> *lastLocation = [[MarketingCloudSDK sharedInstance] sfmc_lastKnownLocation];
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
	                                        messageAsDictionary:lastLocation]
	 callbackId:command.callbackId];
}

@end
