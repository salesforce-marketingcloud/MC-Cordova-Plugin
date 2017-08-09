
#import <UIKit/UIKit.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
/*#import "CDVMarketingCloudSdk_ExactTargetEnhancedPushDataSource.h"*/

@interface CDVMarketingCloudSdk : CDVPlugin {
    NSDictionary *notificationMessage;
    BOOL ready;
}

@property (nonatomic, copy) NSMutableDictionary *notificationCallbackId;
@property (nonatomic, copy) NSString *pushMethod;

@property (nonatomic, strong) NSDictionary *notificationMessage;

@property BOOL isInline;
@property BOOL clearBadge;


// sdk
- (void)getSystemToken:(CDVInvokedUrlCommand*)command;
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command;


@end
