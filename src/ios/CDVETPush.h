
#import <UIKit/UIKit.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import "CDVETPush_ExactTargetEnhancedPushDataSource.h"

@interface CDVETPush : CDVPlugin {
    NSDictionary *notificationMessage;
    BOOL clearBadge;
    BOOL ready;
}

@property (nonatomic, copy) NSMutableDictionary *notificationCallbackId;
@property (nonatomic, copy) NSString *openDirectMethod;
@property (nonatomic, copy) NSString *cloudPageMethod;
@property (nonatomic, copy) NSString *pushMethod;

@property (nonatomic, strong) CDVETPush_ExactTargetEnhancedPushDataSource *messagesHandler;
@property (nonatomic, strong) NSDictionary *notificationMessage;

@property BOOL isInline;
@property BOOL clearBadge;


// sdk
- (void)getSdkVersionName:(CDVInvokedUrlCommand*)command;

// subscriber
- (void)setSubscriberKey:(CDVInvokedUrlCommand*)command;
- (void)getSubscriberKey:(CDVInvokedUrlCommand*)command;

// Attributes
- (void)addAttribute:(CDVInvokedUrlCommand*)command;
- (void)removeAttribute:(CDVInvokedUrlCommand*)command;
- (void)getAttributes:(CDVInvokedUrlCommand*)command;

// Tags
- (void)addTag:(CDVInvokedUrlCommand*)command;
- (void)removeTag:(CDVInvokedUrlCommand*)command;
- (void)getTags:(CDVInvokedUrlCommand*)command;

// Push
- (void)enablePush:(CDVInvokedUrlCommand*)command;
- (void)disablePush:(CDVInvokedUrlCommand*)command;
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command;

// Open Direct, cloud pages, etc
- (void)setNotificationHandler:(CDVInvokedUrlCommand*)command;
- (void)setCloudPageHandler:(CDVInvokedUrlCommand*)command;
- (void)setOpenDirectHandler:(CDVInvokedUrlCommand*)command;

- (void)sendNotification;
- (void)sendCloudPage;
- (void)sendOpenDirect;

// Messages
- (void)getInboxMessages:(CDVInvokedUrlCommand*)command;
- (void)markAsRead:(CDVInvokedUrlCommand*)command;
- (void)markAsDeleted:(CDVInvokedUrlCommand*)command;

// Location
- (void)startWatchingLocation:(CDVInvokedUrlCommand*)command;
- (void)stopWatchingLocation:(CDVInvokedUrlCommand*)command;
- (void)isWatchingLocation:(CDVInvokedUrlCommand*)command;


@end
