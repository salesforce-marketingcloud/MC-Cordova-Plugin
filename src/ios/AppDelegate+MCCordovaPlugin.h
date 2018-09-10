#import "AppDelegate.h"
#import "MarketingCloudSDK/MarketingCloudSDK.h"

@interface AppDelegate (MCCordovaPlugin)<UNUserNotificationCenterDelegate>
- (void) sfmc_setNotificationDelegate;
@end
