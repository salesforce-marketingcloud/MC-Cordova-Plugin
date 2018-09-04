#import "MCCordovaPlugin.h"
#import "MarketingCloudSDK/MarketingCloudSDK.h"

@implementation MCCordovaPlugin

- (void)pluginInitialize {
    NSString* appId = [self.commandDelegate.settings
        objectForKey:[@"com.salesforce.marketingcloud.app_id" lowercaseString]];
    NSString* accessToken = [self.commandDelegate.settings
        objectForKey:[@"com.salesforce.marketingcloud.access_token" lowercaseString]];
    BOOL analytics = [self.commandDelegate.settings
        objectForKey:[@"com.salesforce.marketingcloud.analytics" lowercaseString]];
    NSMutableDictionary* config = [[NSMutableDictionary alloc] init];
    [config setValue:appId forKey:@"appid"];
    [config setValue:accessToken forKey:@"accesstoken"];
    [config setValue:(analytics) ? @"true" : @"false" forKey:@"etanalytics"];

    NSLog(@"config: %@", config);
}

- (void)enableVerboseLogging:(CDVInvokedUrlCommand*)command {
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:YES];
}

- (void)disableVerboseLogging:(CDVInvokedUrlCommand*)command {
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:NO];
}

- (void)getSystemToken:(CDVInvokedUrlCommand*)command {
    NSString* systemToken = [[MarketingCloudSDK sharedInstance] sfmc_deviceToken];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:systemToken]
                                callbackId:command.callbackId];
}

- (void)isPushEnabled:(CDVInvokedUrlCommand*)command {
    BOOL enabled = [[MarketingCloudSDK sharedInstance] sfmc_pushEnabled];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(enabled) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:YES];
}

- (void)disablePush:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

    [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:NO];
}

- (void)setAttribute:(CDVInvokedUrlCommand*)command {
    NSString* name = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_setAttributeNamed:name value:value];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)clearAttribute:(CDVInvokedUrlCommand*)command {
    NSString* name = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_clearAttributeNamed:name];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)getAttributes:(CDVInvokedUrlCommand*)command {
    NSDictionary* attributes = [[MarketingCloudSDK sharedInstance] sfmc_attributes];

    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                       messageAsDictionary:(attributes != nil) ? attributes : @{}]
              callbackId:command.callbackId];
}

- (void)getContactKey:(CDVInvokedUrlCommand*)command {
    NSString* contactKey = [[MarketingCloudSDK sharedInstance] sfmc_contactKey];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsString:contactKey]
                                callbackId:command.callbackId];
}

- (void)setContactKey:(CDVInvokedUrlCommand*)command {
    NSString* contactKey = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_setContactKey:contactKey];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)addTag:(CDVInvokedUrlCommand*)command {
    NSString* tag = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_addTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand*)command {
    NSString* tag = [command.arguments objectAtIndex:0];

    BOOL success = [[MarketingCloudSDK sharedInstance] sfmc_removeTag:tag];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsInt:(success) ? 1 : 0]
                                callbackId:command.callbackId];
}

- (void)getTags:(CDVInvokedUrlCommand*)command {
    NSSet* setTags = [[MarketingCloudSDK sharedInstance] sfmc_tags];
    NSMutableArray* arrayTags = [NSMutableArray arrayWithArray:[setTags allObjects]];

    [self.commandDelegate
        sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                            messageAsArray:(arrayTags != nil) ? arrayTags : @[]]
              callbackId:command.callbackId];
}

@end
