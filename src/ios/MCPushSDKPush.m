#import "MCPushSDKPush.h"
#import "ETPush.h"
#import "ETMessage.h"

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

@end
