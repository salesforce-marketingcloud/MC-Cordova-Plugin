
#import <objc/runtime.h>
#import "AppDelegate+ETPush.h"
#import "ETPush.h"
#import "CDVETPush.h"


@implementation AppDelegate (ETPush)

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
	NSDictionary *ETSettings = [mainBundle objectForInfoDictionaryKey:@"ETPushSettings"];

	NSLog(@"LOCATION ENABLED: %d", [[ETSettings objectForKey:@"ETPUSH_LOCATION_ENABLED"] boolValue]);
#ifdef DEBUG
	// Set to YES to enable logging while debugging
	[ETPush setETLoggerToRequiredState:YES];
	// configure and set initial settings of the JB4ASDK
	successful = [[ETPush pushManager] configureSDKWithAppID:[ETSettings objectForKey:@"ETPUSH_DEV_APPID"]
								andAccessToken:[ETSettings objectForKey:@"ETPUSH_DEV_ACCESSTOKEN"]
								withAnalytics:[[ETSettings objectForKey:@"ETPUSH_ANALYTICS_ENABLED"] boolValue]
								andLocationServices:[[ETSettings objectForKey:@"ETPUSH_LOCATION_ENABLED"] boolValue]
								andProximityServices:[[ETSettings objectForKey:@"PROXIMITY_ENABLED"] boolValue]
								andCloudPages:[[ETSettings objectForKey:@"ETPUSH_CLOUDPAGES_ENABLED"] boolValue]
								withPIAnalytics:[[ETSettings objectForKey:@"ETPUSH_WAMA_ENABLED"] boolValue]
								error:&error];
#else
	// configure and set initial settings of the JB4ASDK
	successful = [[ETPush pushManager] configureSDKWithAppID:[ETSettings objectForKey:@"ETPUSH_PROD_APPID"]
								andAccessToken:[ETSettings objectForKey:@"ETPUSH_PROD_ACCESSTOKEN"]
								withAnalytics:[[ETSettings objectForKey:@"ETPUSH_ANALYTICS_ENABLED"] boolValue]
								andLocationServices:[[ETSettings objectForKey:@"ETPUSH_LOCATION_ENABLED"] boolValue]
								andProximityServices:[[ETSettings objectForKey:@"PROXIMITY_ENABLED"] boolValue]
								andCloudPages:[[ETSettings objectForKey:@"ETPUSH_CLOUDPAGES_ENABLED"] boolValue]
								withPIAnalytics:[[ETSettings objectForKey:@"ETPUSH_WAMA_ENABLED"] boolValue]
								error:&error];
#endif
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

		// start watching the location - used for iBeacons and location-based push notifications
		if ([[ETSettings objectForKey:@"ETPUSH_LOCATION_ENABLED"] boolValue]) {
			[[ETLocationManager locationManager] startWatchingLocation];
		}
		// register for push notifications - enable all notification types, no categories
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
																						UIUserNotificationTypeBadge |
																						UIUserNotificationTypeSound |
																						UIUserNotificationTypeAlert
																						categories:nil];

		[[ETPush pushManager] registerUserNotificationSettings:settings];
		[[ETPush pushManager] registerForRemoteNotifications];

		// The OpenDirect Delegate must be set in order for OpenDirect to work with URL schemes other than http or https.
		[[ETPush pushManager] setOpenDirectDelegate:self];

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

	// inform the JB4ASDK that the device received a remote notification
	[self notificationReceivedWithUserInfo:userInfo messageType:@"Outbound" alertText:nil];
	[[ETPush pushManager] handleNotification:userInfo forApplicationState:application.applicationState];

	if (userInfo[@"aps"][@"content-available"]) {
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
	} else {
		[[ETPush pushManager] resetBadgeCount];
	}

	handler(UIBackgroundFetchResultNoData);
}


#pragma mark - OpenDirect delegate implementation

- (BOOL)shouldDeliverOpenDirectMessageIfAppIsRunning
{
	return YES;
}

- (void)didReceiveOpenDirectMessageWithContents:(NSString *)payload
{
	[self handleOpenDirectPayload:payload];
}

- (void)handleOpenDirectPayload:(NSString *)payload
{
	CDVETPush *pushHandler = [self.viewController getCommandInstance:@"ETPush"];
	pushHandler.notificationMessage = [NSDictionary dictionaryWithObjectsAndKeys:payload, @"webPageUrl", nil];
	[pushHandler sendOpenDirect];
}

#pragma mark - Custom message handlers

- (void)notificationReceivedWithUserInfo:(NSDictionary *)userInfo messageType:(NSString *)messageType alertText:(NSString *)alertText
{
	NSLog(@"### USERINFO: %@", userInfo);
	NSLog(@"### alertText: %@", alertText);

	BOOL hasDiscountCodeCustomKey = ([userInfo objectForKey:@"discount_code"] != nil);
	BOOL hasOpenDirectPayload = ([userInfo objectForKey:@"_od"] != nil);
	BOOL hasCloudPagePayload = ([userInfo objectForKey:@"_x"] != nil);
	BOOL isLocationMessage = ([messageType isEqualToString:@"Location"]);

	// get the cordova plugin instance
	CDVETPush *pushHandler = [self.viewController getCommandInstance:@"ETPush"];

	// based on what's in the payload, call the appropriate plugin method
	// open direct pages are handled by the open direct delegate above
	if (hasCloudPagePayload) {
		NSLog(@"hit cloud page");
		pushHandler.notificationMessage = userInfo;
		[pushHandler sendCloudPage];
	} else if ([userInfo objectForKey:@"fenceIdentifier"]) {
		// Build a message in the same structure as a typical message so the client can handle it in a
		// standardized manner
		NSDictionary *alert = [[NSDictionary alloc] initWithObjectsAndKeys:alertText, @"alert", nil];
		NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:alert, @"aps", nil];
		pushHandler.notificationMessage = message;
		[pushHandler sendNotification];
	} else if (!hasOpenDirectPayload) {
		pushHandler.notificationMessage = userInfo;
		[pushHandler sendNotification];
	}
	// Posting "Push Received Notification" notification to refresh views (CDVMessageReceivedTableViewController)
	[[NSNotificationCenter defaultCenter] postNotificationName:@"kCDVPushReceivedNotification"
	 object:self
	 userInfo:nil];

}


@end