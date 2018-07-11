#import "MCCordovaPlugin.h"
#import "MarketingCloudSDK/MarketingCloudSDK.h"

@interface MCCordovaPlugin ()
@property (nonatomic, strong) MarketingCloudSDK *sfmcSDK;
@end

@implementation MCCordovaPlugin

#pragma mark - sdk
- (void)enableVerboseLogging:(CDVInvokedUrlCommand*)command {
    //[ETPush setETLoggerToRequiredState:YES];
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:YES];
}

- (void)disableVerboseLogging:(CDVInvokedUrlCommand*)command {
    //[ETPush setETLoggerToRequiredState:NO];
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:NO];
}

- (void)getSystemToken:(CDVInvokedUrlCommand*)command {
    //NSString *systemToken = [[ETPush pushManager] deviceToken];
    NSString *systemToken = [[MarketingCloudSDK sharedInstance] sfmc_deviceToken];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:systemToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Push
    
- (void)isPushEnabled:(CDVInvokedUrlCommand*)command {
    BOOL success= [[MarketingCloudSDK sharedInstance] sfmc_pushEnabled];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:success];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)enablePush:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:YES];
}

- (void)disablePush:(CDVInvokedUrlCommand*)command {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

    [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:NO];
}

#pragma mark - Attributes

- (void)setAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    NSString *value = [command.arguments objectAtIndex:1];
    
    CDVPluginResult* pluginResult;
    if(true == [[MarketingCloudSDK sharedInstance] sfmc_setAttributeNamed:name value:value])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error: setAttribute failed."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearAttribute:(CDVInvokedUrlCommand*)command {
    NSString *name = [command.arguments objectAtIndex:0];
    
    CDVPluginResult* pluginResult;
    if(true == [[MarketingCloudSDK sharedInstance] sfmc_clearAttributeNamed:name])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error: clearAttribute failed."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getAttributes:(CDVInvokedUrlCommand*)command {
    //NSDictionary* attributes = [[ETPush pushManager] getAttributes];
    NSDictionary* attributes = [[MarketingCloudSDK sharedInstance] sfmc_attributes];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:attributes];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Contact Key

- (void)getContactKey:(CDVInvokedUrlCommand*)command {
    //NSString* contactKey = [[ETPush pushManager] getSubscriberKey];
    //TODO: This would be good to add to the docs header description that contact key is the old subscriberkey Ex: "subscriber key has renamed to contact key"
    NSString* contactKey = [[MarketingCloudSDK sharedInstance] sfmc_contactKey];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:contactKey];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setContactKey:(CDVInvokedUrlCommand*)command {
    NSString *contactKey = [command.arguments objectAtIndex:0];

    CDVPluginResult* pluginResult;
    if(true == [[MarketingCloudSDK sharedInstance] sfmc_setContactKey:contactKey])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error: setContactKey failed."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Tags

- (void)addTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command.arguments objectAtIndex:0];
    
    CDVPluginResult* pluginResult;
    if(true == [[MarketingCloudSDK sharedInstance] sfmc_addTag:tag])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error: addTag failed."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand*)command {
    NSString *tag = [command.arguments objectAtIndex:0];

    CDVPluginResult* pluginResult;
    if(true == [[MarketingCloudSDK sharedInstance] sfmc_removeTag:tag])
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
    }else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Error: removeTag failed."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getTags:(CDVInvokedUrlCommand*)command {
    //NSSet * setTags = [[ETPush pushManager] getTags];
    NSSet *setTags = [[MarketingCloudSDK sharedInstance] sfmc_tags];
    NSMutableArray *arrayTags = [NSMutableArray arrayWithArray:[setTags allObjects]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:arrayTags];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
