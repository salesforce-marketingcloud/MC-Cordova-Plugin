#import "MCPushSDKPush.h"
#import "ETPush.h"

@implementation MCPushSDKPush

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

@end
