# Integrating MarketingCloud Cordova Plugin with Capacitor or Ionic 

## Steps to integrate MarketingCloud Cordova with Capacitor or Ionic  (Ionic Capacitor Based)

Please follow the [ReadMe](https://github.com/salesforce-marketingcloud/MC-Cordova-Plugin) guide for API details. Below additional steps are required to integrate capacitor/ionic apps with MarketingCloud Cordova Plugin.

## Modify your application's  capacitor config  to configure the plugin

**For Ionic:** Modify `capacitor.config.ts` and add prefrences under `cordova`.

```
const config: CapacitorConfig = {
  appId: 'io.ionic.starter', //Your app id
  appName: 'ionicapp',  //Your app name
  webDir: 'build',
  bundledWebRuntime: false,
  cordova: {
    preferences: { //Salesforce Marketing Cloud Config
      "com.salesforce.marketingcloud.app_id":"{Marketing Cloud application id}",
      "com.salesforce.marketingcloud.access_token":"{Marketing Cloud access token}",
      "com.salesforce.marketingcloud.tenant_specific_endpoint":"{URL retrieved from Marketing Cloud adminstration page}",
      "com.salesforce.marketingcloud.analytics": "{true|false}",
      "com.salesforce.marketingcloud.delay_registration_until_contact_key_is_set": "{true|false}",
      "com.salesforce.marketingcloud.notification_small_icon": "ic_launcher_foreground"        
    }
  }
};
```

**For capacitor:** Modify `capacitor.config.json` and add prefrences under `cordova`.

```
  {
  "appId": "com.example.app",  //Your app id
  "appName": "testSFMC",  //Your app name
  "bundledWebRuntime": false,
  "webDir": "dist",
  "plugins": {
    "SplashScreen": {
      "launchShowDuration": 0
    }
  },
  "cordova": { 
    "preferences": { //Salesforce Marketing Cloud Config
      "com.salesforce.marketingcloud.app_id":"{Marketing Cloud application id}",
      "com.salesforce.marketingcloud.access_token":"{Marketing Cloud access token}",
      "com.salesforce.marketingcloud.tenant_specific_endpoint":"{URL retrieved from Marketing Cloud adminstration page}",
      "com.salesforce.marketingcloud.analytics": "{true|false}",
      "com.salesforce.marketingcloud.delay_registration_until_contact_key_is_set": "{true|false}",
      "com.salesforce.marketingcloud.notification_small_icon": "ic_launcher_foreground"        
    }
  }
}
```

> These steps will need to be done each time the platform is added to your Capacitor application.

## Android

### 1. Copy the google-services.json file
Copy the `google-services.json` file to `YOUR_APP/android/app/` directory



## iOS

### 1. Enable push notifications in your target’s Capabilities settings in Xcode.

Click on `+ Capability` and select `Push Notifications`



![push enablement](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/assets/SDKConfigure6.png)



### 2. Enable iOS Push

### Add the following code in AppDelegate

```
//Add following imports
//Other imports...
import SFMCSDK
import MarketingCloudSDK
```


Add this at the end of AppDelegate.swift file
```
//SFMCSDK PushNotification
extension AppDelegate {    
    // MobilePush SDK: REQUIRED IMPLEMENTATION
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SFMCSdk.mp.setDeviceToken(deviceToken)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }

    // MobilePush SDK: REQUIRED IMPLEMENTATION
    /** This delegate method offers an opportunity for applications with the "remote-notification" background mode to fetch appropriate new data in response to an incoming remote notification. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
    This method will be invoked even if the application was launched or resumed because of the remote notification. The respective delegate methods will be invoked first. Note that this behavior is in contrast to application:didReceiveRemoteNotification:, which is not called in those cases, and which will not be invoked if this method is implemented. **/
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {   
        SFMCSdk.mp.setNotificationUserInfo(userInfo)
        completionHandler(.newData)
    }
    
}
```

## Usage
If you're using typescript declare the plugin before calling the APIs. For API details  follow the [ReadMe](https://github.com/salesforce-marketingcloud/MC-Cordova-Plugin) guide.
```

//Declare the plugin.(for typescript) 
declare let MCCordovaPlugin: any;
declare let SFMCEvent: any;

//Call plugin APIs
MCCordovaPlugin.enableLogging();
MCCordovaPlugin.enablePush();
//Other APIs...
```
