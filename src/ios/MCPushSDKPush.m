#import "MCPushSDKPush.h"
#import "ETPush.h"

@implementation MCPushSDKPush

#pragma mark - sdk

- (void)getSystemToken:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *systemToken = [[ETPush pushManager] deviceToken];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:systemToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Push
    
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        BOOL pushEnabled = [ETPush isPushEnabled];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:pushEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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

- (void)addAttributes:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *value = [command.arguments objectAtIndex:1];
    
    [self.commandDelegate runInBackground:^{
        BOOL success = [[ETPush pushManager] addAttributeNamed:name value:value];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:success];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        NSString *result = [[ETPush pushManager] removeAttributeNamed:name];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getAttributes:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSDictionary* attributes = [[ETPush pushManager] getAttributes];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:attributes];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
