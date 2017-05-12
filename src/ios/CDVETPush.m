

#import "CDVETPush.h"
#import "ETPush.h"
#import "CDVETPush_ExactTargetEnhancedPushDataSource.h"
#import "ETMessage.h"


@interface CDVETPush () {}
@end

@implementation CDVETPush

@synthesize notificationMessage;
@synthesize isInline;
@synthesize messagesHandler;

@synthesize notificationCallbackId;
@synthesize clearBadge;
@synthesize openDirectMethod;
@synthesize cloudPageMethod;
@synthesize pushMethod;

#pragma mark - sdk

- (void)getSdkVersionName:(CDVInvokedUrlCommand*)command {
     [self.commandDelegate runInBackground:^{
         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     }];
}
 
#pragma mark - subscriber

- (void)setSubscriberKey:(CDVInvokedUrlCommand*)command {
    NSString* subKey = [command.arguments objectAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        [[ETPush pushManager] setSubscriberKey:subKey];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:subKey];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getSubscriberKey:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *subKey = [[ETPush pushManager] getSubscriberKey];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:subKey];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getSystemToken:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSString *systemToken = [[ETPush pushManager] deviceToken];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:systemToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Attributes

- (void)addAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *value = [command.arguments objectAtIndex:1];
    
    [self.commandDelegate runInBackground:^{
        [[ETPush pushManager] addAttributeNamed:name value:value];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    [self.commandDelegate runInBackground:^{
        [[ETPush pushManager] removeAttributeNamed:name];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getAttributes:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSDictionary* attributes = [[ETPush pushManager] allAttributes];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:attributes];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Tags

#define TAGIFY(x) [x stringByReplacingOccurrencesOfString:@" " withString:@"_"]
- (void)addTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command.arguments objectAtIndex:0];
    
    [self.commandDelegate runInBackground:^{
        [[ETPush pushManager] addTag:TAGIFY(tag)];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:tag];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)removeTag:(CDVInvokedUrlCommand*)command {
    NSString* tag = [command.arguments objectAtIndex:0];
    [self.commandDelegate runInBackground:^{
        
        [[ETPush pushManager] removeTag:TAGIFY(tag)];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:tag];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getTags:(CDVInvokedUrlCommand*)command {
    NSSet* tags = [[ETPush pushManager] allTags];
    
    [self.commandDelegate runInBackground:^{
        NSArray* result = [tags allObjects];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Push

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)disablePush:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)isPushEnabled:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        BOOL pushEnabled = [ETPush isPushEnabled];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:pushEnabled];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Cloud Page, open direct, notifications

- (void)setNotificationHandler:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        self.pushMethod = command.callbackId;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
    }];
}

- (void)setCloudPageHandler:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        self.cloudPageMethod = command.callbackId;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
    }];
}

- (void)setOpenDirectHandler:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        self.openDirectMethod = command.callbackId;
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [pluginResult setKeepCallbackAsBool:YES];
    }];
}


#pragma mark - push notification send to client

- (void)sendNotification {
    if (notificationMessage) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:notificationMessage];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.pushMethod];
        }];
    }
}


- (void)sendCloudPage {
    if (notificationMessage) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[notificationMessage objectForKey:@"webPageUrl"]];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cloudPageMethod];
        }];
    }
}

- (void)sendOpenDirect {
    if (notificationMessage) {
        [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[notificationMessage objectForKey:@"webPageUrl"]];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.openDirectMethod];
        }];
    }
}

#pragma mark - Messages

- (void)getInboxMessages:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        if(!self.messagesHandler) {
            self.messagesHandler = [[CDVETPush_ExactTargetEnhancedPushDataSource alloc] init];
        }
        NSMutableDictionary *inboxMessages = [self.messagesHandler getInboxMessages];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:inboxMessages];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)markAsDeleted:(CDVInvokedUrlCommand*)command {
    
    [self.commandDelegate runInBackground:^{
        if(!self.messagesHandler) {
            self.messagesHandler = [[CDVETPush_ExactTargetEnhancedPushDataSource alloc] init];
        }
        NSString* messageId = [command.arguments objectAtIndex:0];
        NSMutableDictionary *inboxMessages = [self.messagesHandler markAsDeleted:messageId];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:inboxMessages];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)markAsRead:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        if(!self.messagesHandler) {
            self.messagesHandler = [[CDVETPush_ExactTargetEnhancedPushDataSource alloc] init];
        }
        NSString* messageId = [command.arguments objectAtIndex:0];
        NSMutableDictionary *inboxMessages = [self.messagesHandler markAsRead:messageId];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:inboxMessages];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// Location
- (void)startWatchingLocation:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [[ETLocationManager locationManager] startWatchingLocation];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)stopWatchingLocation:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [[ETLocationManager locationManager] stopWatchingLocation];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)isWatchingLocation:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        BOOL isWatching = [[ETLocationManager locationManager] getWatchingLocation];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isWatching];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
