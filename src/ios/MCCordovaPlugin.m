#import "MCCordovaPlugin.h"
#import "ETPush.h"

@implementation MCCordovaPlugin

#pragma mark - sdk

- (void)enableVerboseLogging:(CDVInvokedUrlCommand*)command {
    [ETPush setETLoggerToRequiredState:YES];
}

- (void)disableVerboseLogging:(CDVInvokedUrlCommand*)command {
    [ETPush setETLoggerToRequiredState:NO];
}

- (void)getSystemToken:(CDVInvokedUrlCommand*)command {
    NSString *systemToken = [[ETPush pushManager] deviceToken];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:systemToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Push
    
- (void)registerPush:(CDVInvokedUrlCommand*)command {
    // register for push notifications - enable all notification types, no categories
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                            UIUserNotificationTypeBadge |
                                            UIUserNotificationTypeSound |
                                            UIUserNotificationTypeAlert
                                            categories:nil];

    [[ETPush pushManager] registerUserNotificationSettings:settings];
    [[ETPush pushManager] registerForRemoteNotifications];
}

- (void)isPushEnabled:(CDVInvokedUrlCommand*)command {
    BOOL pushEnabled = [ETPush isPushEnabled];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:pushEnabled];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    [[ETPush pushManager] updateET];
}

- (void)disablePush:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

    [[ETPush pushManager] updateET];
}

#pragma mark - Attributes

- (void)setAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *value = [command.arguments objectAtIndex:1];
    
    BOOL success = [[ETPush pushManager] addAttributeNamed:name value:value];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:success];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    
    NSString *result = [[ETPush pushManager] removeAttributeNamed:name];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getAttributes:(CDVInvokedUrlCommand*)command {
    NSDictionary* attributes = [[ETPush pushManager] getAttributes];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:attributes];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Contact Key

- (void)getContactKey:(CDVInvokedUrlCommand*)command {
    NSString* contactKey = [[ETPush pushManager] getSubscriberKey];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:contactKey];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setContactKey:(CDVInvokedUrlCommand*)command {
    NSString *contactKey = [command.arguments objectAtIndex:0];
    BOOL success = [[ETPush pushManager] setSubscriberKey:contactKey];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:success];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Tags

- (void)addTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command.arguments objectAtIndex:0];
    
    BOOL success = [[ETPush pushManager] addTag:tag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:success];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command.arguments objectAtIndex:0];
    
    NSString *result = [[ETPush pushManager] removeTag:tag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getTags:(CDVInvokedUrlCommand*)command {
    NSSet * setTags = [[ETPush pushManager] getTags];
    NSMutableArray *arrayTags = [NSMutableArray arrayWithArray:[setTags allObjects]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:arrayTags];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
