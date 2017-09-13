
#import <UIKit/UIKit.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface MCPushSDKPush : CDVPlugin 

- (void)enableVerboseLogging:(CDVInvokedUrlCommand*)command;
- (void)disableVerboseLogging:(CDVInvokedUrlCommand*)command;

- (void)getSystemToken:(CDVInvokedUrlCommand*)command;
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command;
- (void)enablePush:(CDVInvokedUrlCommand*)command;
- (void)disablePush:(CDVInvokedUrlCommand*)command;

- (void)setAttribute:(CDVInvokedUrlCommand*)command;
- (void)clearAttribute:(CDVInvokedUrlCommand*)command;
- (void)getAttributes:(CDVInvokedUrlCommand*)command;

- (void)setContactKey:(CDVInvokedUrlCommand*)command;
- (void)getContactKey:(CDVInvokedUrlCommand*)command;

- (void)setTag:(CDVInvokedUrlCommand*)command;
- (void)clearTag:(CDVInvokedUrlCommand*)command;
- (void)getTags:(CDVInvokedUrlCommand*)command;

@end
