
#import <UIKit/UIKit.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface MCPushSDKPush : CDVPlugin 

- (void)getSystemToken:(CDVInvokedUrlCommand*)command;
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command;
- (void)enablePush:(CDVInvokedUrlCommand*)command;
- (void)disablePush:(CDVInvokedUrlCommand*)command;

- (void)addAttribute:(CDVInvokedUrlCommand*)command;
- (void)removeAttribute:(CDVInvokedUrlCommand*)command;
- (void)getAttributes:(CDVInvokedUrlCommand*)command;

@end
