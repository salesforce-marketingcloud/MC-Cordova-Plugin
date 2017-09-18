
#import <objc/runtime.h>
#import "AppDelegate+MCPushSDKPush.h"
#import "ETPush.h"
#import "MCPushSDKPush.h"


@implementation AppDelegate (MCPushSDKPush)

// its dangerous to override a method from within a category.
// Instead, we will use method swizzling.
+ (void)load
{
	Method original, swizzled;

	original = class_getInstanceMethod(self, @selector(init));
	swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
	method_exchangeImplementations(original, swizzled);
}

// Swizzle the init, this will be executed after UIApplicationDidFinishLaunchingNotification with
// added functionality to create the notification checker for the ET SDK.
- (AppDelegate *)swizzled_init
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNotificationChecker:)
	 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
	return [self swizzled_init];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:.
- (void)createNotificationChecker:(NSNotification *)notification
{
	if (notification) {
		NSDictionary *launchOptions = [notification userInfo];
		[self application:[UIApplication sharedApplication] shouldInitETSDKWithOptions:launchOptions];
	}
}

// Init the SDK with options set by the cordova plugin add command
- (BOOL)application:(UIApplication *)application shouldInitETSDKWithOptions:(NSDictionary *)launchOptions
{
	BOOL successful = NO;
	NSError *error = nil;

	NSBundle *mainBundle = [NSBundle mainBundle];
	NSDictionary *ETSettings = [mainBundle objectForInfoDictionaryKey:@"MarketingCloudSdkSettings"];

    BOOL useAnalytics = NO;
    NSString *analytics = [ETSettings objectForKey:@"MCANALYTICS"];
    if (analytics != nil) {
        analytics = [analytics lowercaseString];
        if ([analytics isEqualToString:@"yes") {
            useAnalytics = YES;
        }
    }
             
	// configure and set initial settings of the JB4ASDK
	successful = [[ETPush pushManager] 
		configureSDKWithAppID:[ETSettings objectForKey:@"APPID"] 
		andAccessToken:[ETSettings objectForKey:@"ACCESSTOKEN"] 
		withAnalytics:useAnalytics
		andLocationServices:NO 
		andProximityServices:NO 
		andCloudPages:NO 
		withPIAnalytics:NO 
		error:&error ];

	//
	// if configureSDKWithAppID returns NO, check the error object for detailed failure info. See PushConstants.h for codes.
	// the features of the JB4ASDK will NOT be useable unless configureSDKWithAppID returns YES.
	//
	if (!successful) {
		dispatch_async(dispatch_get_main_queue(), ^ {
			// something failed in the configureSDKWithAppID call - show what the error is
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed configureSDKWithAppID!", @"Failed configureSDKWithAppID!")
			message:[error localizedDescription]
			delegate:nil
			cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
			otherButtonTitles:nil] show];
		});
	} else {
		// register for push notifications - enable all notification types, no categories
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
																						UIUserNotificationTypeBadge |
																						UIUserNotificationTypeSound |
																						UIUserNotificationTypeAlert
																						categories:nil];

		[[ETPush pushManager] registerUserNotificationSettings:settings];
		[[ETPush pushManager] registerForRemoteNotifications];

		// inform the JB4ASDK of the launch options - possibly UIApplicationLaunchOptionsRemoteNotificationKey or UIApplicationLaunchOptionsLocalNotificationKey
		[[ETPush pushManager] applicationLaunchedWithOptions:launchOptions];
	}

	return YES;
}

// Handle local notifications. Location-based push notifications are downloaded when the app starts. When
// a device gets near this notifications, a local notification is used instead of a standard remote
// push notification
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	NSLog(@"### GOT LOCAL NOTIFICATION: %@", notification);
	[self notificationReceivedWithUserInfo:notification.userInfo messageType:@"Location" alertText:notification.alertBody];
	[[ETPush pushManager] handleLocalNotification:notification];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
	[[ETPush pushManager] didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", deviceToken);

	[[ETPush pushManager] registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	[[ETPush pushManager] applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[[ETPush pushManager] resetBadgeCount];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
	[self notificationReceivedWithUserInfo:userInfo messageType:@"Outbound" alertText:nil];
	[[ETPush pushManager] handleNotification:userInfo forApplicationState:application.applicationState];

	handler(UIBackgroundFetchResultNoData);
}


#pragma mark - Custom message handlers

- (void)notificationReceivedWithUserInfo:(NSDictionary *)userInfo messageType:(NSString *)messageType alertText:(NSString *)alertText
{
	NSLog(@"### USERINFO: %@", userInfo);
	NSLog(@"### alertText: %@", alertText);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"kCDVPushReceivedNotification"
	 object:self
	 userInfo:nil];
}


@end
