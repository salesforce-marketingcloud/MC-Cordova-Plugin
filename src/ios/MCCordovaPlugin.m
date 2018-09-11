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
#import "MarketingCloudSDK/MarketingCloudSDK.h"

@implementation MCCordovaPlugin

- (void)pluginInitialize {
    if ([MarketingCloudSDK sharedInstance] == nil) {
        // failed to access the MarketingCloudSDK
        os_log_error(OS_LOG_DEFAULT, "Failed to access the MarketingCloudSDK");
    } else {
        NSDictionary *pluginSettings = self.commandDelegate.settings;

        MarketingCloudSDKConfigBuilder *configBuilder = [MarketingCloudSDKConfigBuilder new];
        [configBuilder
            sfmc_setApplicationId:[pluginSettings
                                      objectForKey:@"com.salesforce.marketingcloud.app_id"]];
        [configBuilder
            sfmc_setAccessToken:[pluginSettings
                                    objectForKey:@"com.salesforce.marketingcloud.access_token"]];

        BOOL analytics =
            [[pluginSettings objectForKey:@"com.salesforce.marketingcloud.analytics"] boolValue];
        [configBuilder sfmc_setAnalyticsEnabled:[NSNumber numberWithBool:analytics]];

        NSString *tse =
            [pluginSettings objectForKey:@"com.salesforce.marketingcloud.tenant_specific_endpoint"];
        if (tse != nil) {
            [configBuilder sfmc_setMarketingCloudServerUrl:tse];
        }

        NSError *configError = nil;
        if ([[MarketingCloudSDK sharedInstance]
                sfmc_configureWithDictionary:[configBuilder sfmc_build]
                                       error:&configError]) {
            [self setDelegate];
            [[MarketingCloudSDK sharedInstance] sfmc_addTag:@"Cordova"];
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
