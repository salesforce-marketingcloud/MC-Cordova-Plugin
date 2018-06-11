# Salesforce Marketing Cloud Cordova Plugin

Use this plugin to implement the Marketing Cloud MobilePush SDK for your [iOS](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/) and [Android](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/) applications.

## Release History

### Version 1.0.3
_Released Apr 23, 2018_
> For iOS: Depends on the Marketing Cloud Mobile Push iOS SDK v5.1.x<br>
> For Android: Depends on the Marketing Cloud Mobile Push Android SDK v5.5.x, the latest version of Cordova, and Android Cordova platform 6.40.

* Added support for Cordova iOS cross-platform (CLI) workflow<br>

### Version 1.0.2
_Released Jan 22, 2018_
> For iOS: Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x<br>
> For Android: Depends on the Marketing Cloud Mobile Push Android SDK v5.3.x, the latest version of Cordova, and Android Cordova platform 6.40.

* Updated Android SDK to v5.3.+<br>

### Version 1.0.1
_Released Nov 29, 2017_
> Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x<br>
> Depends on the Marketing Cloud Mobile Push Android SDK v5.2.x

* Updated Android SDK to v5.2.+<br>

### Version 1.0.0
_Released October 27, 2017_
> Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x<br>
> Depends on the Marketing Cloud Mobile Push Android SDK v5.0.x

* [Basic Push Notification Functionality](#using-the-plugin) w/Audience Segmentation via [Contact Key](#contact-key), [Attributes](#attributes) and [Tags](#tags).
* [Logging](#logging) - Enable/Disable Underlying SDK verbose logging

## Install the Plugin

1. Create your iOS app in Marketing Cloud MobilePush and provision it.

* [Connect your iOS app to MobilePush](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/get-started/apple.html)
* [Connect your Android app to MobilePush](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/create-apps/create-apps-overview.html)

2. Use this command to install the plugin in your Cordova project.

```Bash
cordova plugin add ../sdk-cordova-plugin
--variable APPID={YOUR_APP_ID}
--variable ACCESSTOKEN={YOUR_ACCESS_TOKEN}
--variable GCMSENDERID={YOUR_GCM_SENDER_ID}
--variable ETANALYTICS={enabled|disabled}
--variable CHANNELNAME={YOUR_CHANNEL_NAME}
--variable MARKETINGCLOUDSERVERURL={YOUR_MARKETING_CLOUD_SERVER_URL}
--nosave
--nofetch
```
> You must explicitly enable or disable `ETANALYTICS`. `ETANALYTICS` enables or disables collection of analytics, such as notification displayed, opened, etc. for your app.

> These variables refer to your app in MobilePush.

## Cordova Configuration

You can develop in Cordova using one of two different approaches: 1) Cross-platform, or command-line interface (CLI) workflow or 2) platform-centered workflow. See the Cordova [Development Paths documentation section](http://cordova.apache.org/docs/en/7.x/guide/overview/index.html) for more information.

### CLI Workflow

For iOS, you can either use Apple's Xcode or use the CLI workflow. For Android, you can either use Android Studio or the CLI workflow.

To use the CLI workflow, follow these steps.

1. For iOS, create an Xcode project. For Android, install the [gradle build tool](https://gradle.org/install/#manually).

> When you install the gradle build tool, make sure that you set your gradle environment variable by following the instructions at the link. If you don’t, it will fail.

2. For iOS, configure your Xcode environment for push notifications and build settings.

3. Modify the following shell script to fit your needs. For example, replace placeholder text with the name of your project.

4. Run the modified shell script. The shell script builds both iOS and Android.

```
//This script assumes that you have an existing Cordova project. Back up the platforms directory.
cp -a ./platforms/ ./platformsBck

//Remove the original platforms directory so that Cordova can generate the platforms from scratch.
rm -R ./platforms/

//Add the MarketingCloud-Cordova-Plugin with appropriate values.
cordova plugin add ../sdk-cordova-plugin —variable APPID={YOUR_APP_ID} —variable ACCESSTOKEN={YOUR_ACCESS_TOKEN} —variable GCMSENDERID={YOUR_GCM_SENDER_ID} —variable ETANALYTICS={enabled|disable} —variable CHANNELNAME={YOUR_CHANNEL_NAME} —variable MARKETINGCLOUDSERVERURL={YOUR_MARKETING_CLOUD_SERVER_URL} —nosave —nofetch

//Execute the plugin prepare step to set up your new platforms.
cordova prepare

//Copy only the AndroidManifest.xml file inside the backed-up platforms directory.
cp -a ./platformsBck/android/ ./platforms/android/

//Copy the specific iOS platform files needed. These files contain your original project configuration files and the entitlements files required for push notifications.
cp -a ./platformsBck/ios/cordova/build.xcconfig ./platforms/ios/cordova/build.xcconfig
rm -R ./platforms/ios/YOUR_PROJECT_NAME.xcodeproj
cp -a ./platformsBck/ios/YOUR_PROJECT_NAME.xcodeproj ./platforms/ios/YOUR_PROJECT_NAME.xcodeproj
cp -a ./platformsBck/ios/YOUR_PROJECT_NAME/Entitlements-Debug.plist ./platforms/ios/YOUR_PROJECT_NAME/Entitlements-Debug.plist
cp -a ./platformsBck/ios/YOUR_PROJECT_NAME/Entitlements-Release.plist ./platforms/ios/YOUR_PROJECT_NAME/Entitlements-Release.plist

//Remove your backup dir.
rm -R ./platformsBck/

//Set your configuration environment variable for the Android platform. Follow the instructions and get the latest gradle version here: https://gradle.org/install/#manually
export PATH=$PATH:/opt/gradle/gradle-X.X/bin

//Build and run for the selected platform.
cordova run android --verbose --device

//or

cordova run ios --verbose --device
```

## Plugin Features

After installing your Cordova platform and the plugin, you can use these features of the Marketing Cloud MobilePush SDK within your Cordova app javascript.

All of the following methods belong to the `MCCordovaPlugin` object. use `MCCordovaPlugin.methodname()` in your app Javascript on or after the device ready or platform ready event. The MarketingCloudSdk configuration and registration calls complete behind the scenes.

### Contact Key
#### setContactKey

Sets the Contact Key for this device.

```javascript
MCCordovaPlugin.setContactKey(successCallback, errorCallback, contactKey);
```

#### getContactKey

Gets the Contact Key for this device.

```javascript
MCCordovaPlugin.getContactKey(successCallback, errorCallback);
```

The successCallback will include a result parameter in this format: `"contactKey"`

### Attributes
#### setAttribute

Adds an attribute to current user's Contact model.

```javascript
MCCordovaPlugin.setAttribute(successCallback, errorCallback, attributeName, attributeValue);
```

The successCallback includes a result parameter of "true" or "false":
```javascript
"true"
```

#### clearAttribute

Removes an attribute from current user's Contact model.

```javascript
MCCordovaPlugin.clearAttribute(successCallback, errorCallback, attributeName);
```

The successCallback returns the removed key value. For example:
```javascript
"First Name"
```

#### getAttributes

Gets the list of attributes from the current user's Contact model.

```javascript
MCCordovaPlugin.getAttributes(successCallback, errorCallback);
```

The successCallback includes a result parameter in this format:
```json
{
	"attributeName1": "attributeValue1",
	"attributeName2": "attributeValue2",		
	"attributeName3": "attributeValue3"
}
```

### Tags
#### addTag

Adds a tag to the current user's Contact model.

```javascript
MCCordovaPlugin.addTag(successCallback, errorCallback, tagName);
```

#### removeTag

Removes a tag to the current user's Contact model.

```javascript
MCCordovaPlugin.removeTag(successCallback, errorCallback, tagName);
```

#### getTags

Gets a list of tags from the current user's Contact model.

```javascript
MCCordovaPlugin.getTags(successCallback, errorCallback);
```

The successCallback includes a result parameter in this format:
```json
[
	"tag1",
	"tag2",
	"tag3"
]
```

### Logging
#### enableVerboseLogging

Enables internal Marketing Cloud SDK logging

```javascript
MCCordovaPlugin.enableVerboseLogging(successCallback, errorCallback);
```

#### disableVerboseLogging

Disables internal Marketing Cloud SDK logging.

```javascript
MCCordovaPlugin.disableVerboseLogging(successCallback, errorCallback);
```

### Misc
#### isPushEnabled

Checks persistent preferences for the state of Push.

```javascript
MCCordovaPlugin.isPushEnabled(successCallback, errorCallback);
```

The successCallback will include a result parameter in this format: `true/false`

#### getSystemToken

Gets the system token of the Marketing Cloud SDK.

```javascript
MCCordovaPlugin.getSystemToken(successCallback, errorCallback);
```

The successCallback includes a result parameter in this format: `"systemToken"`

#### enablePush

Enables push and push accessories in the Marketing Cloud SDK.

```javascript
MCCordovaPlugin.enablePush();
```

> To use push notifications in iOS, call `enablePush`. **Push is not enabled by default on start up.**

#### disablePush

Disables push and push accessories in the Marketing Cloud SDK.

```javascript
MCCordovaPlugin.disablePush();
```
