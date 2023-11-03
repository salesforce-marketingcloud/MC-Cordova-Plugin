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
#import "NSDictionary+SFMCEvent.h"
#import <UserNotifications/UserNotifications.h>

@interface MCCordovaPlugin()<UNUserNotificationCenterDelegate>
@end


@implementation MCCordovaPlugin

const int LOG_LENGTH = 800;

@synthesize eventsCallbackId;
@synthesize notificationOpenedSubscribed;
@synthesize cachedNotification;

+ (NSMutableDictionary *_Nullable)dataForNotificationReceived:(NSNotification *)notification {
    NSMutableDictionary *notificationData = nil;
    if (notification.userInfo != nil) {
        UNNotificationRequest *userNotificationRequest =
        notification.userInfo
        [@"SFMCFoundationUNNotificationReceivedNotificationKeyUNNotificationRequest"];
        if (userNotificationRequest != nil) {
            notificationData = [userNotificationRequest.content.userInfo mutableCopy];
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
    if (self.logger == nil) {
        self.logger = os_log_create("com.salesforce.marketingcloud.marketingcloudsdk", "Cordova");
    }
    os_log_info(self.logger, "%{public}@", msg);
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
    if ([SFMCSdk mp] == nil) {
        // failed to access the MarketingCloudSDK
        os_log_error(OS_LOG_DEFAULT, "Failed to access the MarketingCloudSDK");
    } else {
        NSDictionary *pluginSettings = self.commandDelegate.settings;
        
        PushConfigBuilder *configBuilder = [[PushConfigBuilder alloc]
                                            initWithAppId:pluginSettings[@"com.salesforce.marketingcloud.app_id"]];
        [configBuilder
         setAccessToken:pluginSettings[@"com.salesforce.marketingcloud.access_token"]];
        
        BOOL analytics = [pluginSettings[@"com.salesforce.marketingcloud.analytics"] boolValue];
        [configBuilder setAnalyticsEnabled:analytics];
        
        BOOL delayRegistrationUntilContactKeyIsSet = [pluginSettings
                                                      [@"com.salesforce.marketingcloud.delay_registration_until_contact_key_is_set"]
                                                      boolValue];
        [configBuilder
         setDelayRegistrationUntilContactKeyIsSet:delayRegistrationUntilContactKeyIsSet];
        
        NSURL *tse =
        [NSURL URLWithString:pluginSettings
         [@"com.salesforce.marketingcloud.tenant_specific_endpoint"]];
        if (tse != nil) {
            [configBuilder setMarketingCloudServerUrl:tse];
        }
        
        NSError *configError = nil;
        [SFMCSdk initializeSdk:
         [[[SFMCSdkConfigBuilder new]
           setPushWithConfig:[configBuilder build]
           onCompletion:^(SFMCSdkOperationResult result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == SFMCSdkOperationResultSuccess) {
                    [self setDelegate];
                    [[SFMCSdk mp] setURLHandlingDelegate:self];
                    [[SFMCSdk mp] addTag:@"Cordova"];
                    [self requestPushPermission];
                } else {
                    // SFMC sdk configuration failed.
                    NSLog(@"SFMC sdk configuration failed.");
                }
            });
        }] build]];
        
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupCapacitor:) name:UIApplicationDidFinishLaunchingNotification object:nil];
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
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound |
     UNAuthorizationOptionBadge
     completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (granted) {
            os_log_info(OS_LOG_DEFAULT, "Authorized for notifications = %s",
                        granted ? "YES" : "NO");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // we are authorized to use
                // notifications, request a device
                // token for remote notifications
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        } else if (error != nil) {
            os_log_debug(OS_LOG_DEFAULT, "%@", error);
        }
    }];
}

- (void)enableLogging:(CDVInvokedUrlCommand *)command {
    [SFMCSdk setLoggerWithLogLevel:SFMCSdkLogLevelDebug logOutputter:[SFMCSdkLogOutputter new]];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)disableLogging:(CDVInvokedUrlCommand *)command {
    [SFMCSdk setLoggerWithLogLevel:SFMCSdkLogLevelFault logOutputter:[SFMCSdkLogOutputter new]];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)logSdkState:(CDVInvokedUrlCommand *)command {
    [self splitLog:[SFMCSdk state]];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)getSystemToken:(CDVInvokedUrlCommand *)command {
    NSString *systemToken = [[SFMCSdk mp] deviceToken];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:systemToken]
                                callbackId:command.callbackId];
}

- (void)getDeviceId:(CDVInvokedUrlCommand *)command {
    NSString *deviceId = [[SFMCSdk mp] deviceIdentifier];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:deviceId]
                                callbackId:command.callbackId];
}

- (void)isPushEnabled:(CDVInvokedUrlCommand *)command {
    BOOL enabled = [[SFMCSdk mp] pushEnabled];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(enabled) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand *)command {
    [[SFMCSdk mp] setPushEnabled:YES];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)disablePush:(CDVInvokedUrlCommand *)command {
    [[SFMCSdk mp] setPushEnabled:NO];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                callbackId:command.callbackId];
}

- (void)setAttribute:(CDVInvokedUrlCommand *)command {
    NSString *name = command.arguments[0];
    NSString *value = command.arguments[1];

    [[SFMCSdk identity] setProfileAttributes:@{name: value}];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:1]
                                callbackId:command.callbackId];
}

- (void)clearAttribute:(CDVInvokedUrlCommand *)command {
    NSString *name = command.arguments[0];

    [[SFMCSdk identity] clearProfileAttributeWithKey:name];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:1]
                                callbackId:command.callbackId];
}

- (void)getAttributes:(CDVInvokedUrlCommand *)command {
    NSDictionary *attributes = [[SFMCSdk mp] attributes];
    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                       messageAsDictionary:(attributes != nil) ? attributes : @{}]
              callbackId:command.callbackId];
}

- (void)getContactKey:(CDVInvokedUrlCommand *)command {
    NSString *contactKey = [[SFMCSdk mp] contactKey];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:contactKey]
                                callbackId:command.callbackId];
}

- (void)setContactKey:(CDVInvokedUrlCommand *)command {
    NSString *contactKey = command.arguments[0];

    [[SFMCSdk identity] setProfileId:contactKey];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:1]
                                callbackId:command.callbackId];
}

- (void)addTag:(CDVInvokedUrlCommand *)command {
    NSString *tag = command.arguments[0];

    BOOL success =  [[SFMCSdk mp] addTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand *)command {
    NSString *tag = command.arguments[0];

    BOOL success = [[SFMCSdk mp] removeTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)getTags:(CDVInvokedUrlCommand *)command {
    NSArray *arrayTags = [[[SFMCSdk mp] tags] allObjects];

    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsArray:(arrayTags != nil) ? arrayTags : @[]]
              callbackId:command.callbackId];
}

- (void)track:(CDVInvokedUrlCommand *)command {
    NSDictionary *event = command.arguments[0];
    [SFMCSdk trackWithEvent:[NSDictionary SFMCEvent:event]];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
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

- (BOOL)isCapacitor {
    UIViewController *vc = UIApplication.sharedApplication.delegate.window.rootViewController;
    NSString *className =  NSStringFromClass(vc.class);
    NSString *superClassName =  NSStringFromClass(vc.superclass);
    
    return [className containsString:@"CAPBridgeViewController"] ||[superClassName containsString:@"CAPBridgeViewController"];
}

-(void) setupCapacitor:(NSNotification *)notification {
    if ([self isCapacitor]) {
       UNUserNotificationCenter.currentNotificationCenter.delegate =  self;
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    // tell the MarketingCloudSDK about the notification
    [[SFMCSdk mp] setNotificationRequest:response.notification.request];
    
    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    if (completionHandler != nil) {
        completionHandler(UNNotificationPresentationOptionAlert);
    }
}

- (void)setAnalyticsEnabled:(CDVInvokedUrlCommand *)command {
    BOOL analyticsEnabled = [command.arguments[0] boolValue];
    [[SFMCSdk mp] setAnalyticsEnabled:analyticsEnabled];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)isAnalyticsEnabled:(CDVInvokedUrlCommand *)command {
    BOOL isEnabled = [[SFMCSdk mp] isAnalyticsEnabled];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled] callbackId:command.callbackId];
}

- (void)setPiAnalyticsEnabled:(CDVInvokedUrlCommand *)command {
    BOOL piAnalyticsEnabled = [command.arguments[0] boolValue];
    [[SFMCSdk mp] setPiAnalyticsEnabled:piAnalyticsEnabled];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)isPiAnalyticsEnabled:(CDVInvokedUrlCommand *)command {
    BOOL isEnabled = [[SFMCSdk mp] isPiAnalyticsEnabled];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isEnabled] callbackId:command.callbackId];
}

@end
