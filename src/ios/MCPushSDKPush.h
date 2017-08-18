
#import <UIKit/UIKit.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface MCPushSDKPush : CDVPlugin 

// sdk
- (void)getSystemToken:(CDVInvokedUrlCommand*)command;
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command;


@end
