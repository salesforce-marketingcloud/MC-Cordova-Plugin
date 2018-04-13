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

2. For iOS apps, set the attributes in the MarketingCloudSDKConfiguration.json file found in the .../src/ios/MCPushSDK/ directory before installing the plugin.

```
[{
"name": "production",
"appid": "YOUR_APPID_HERE",
"accesstoken": "YOUR_ACCESSTOKEN_HERE",
"analytics": true
}]
```

3. Use this command to install the plugin in your Cordova project.

```Bash
cordova plugin add ../MarketingCloudSdk-Cordova-Plugin
--variable APPID={YOUR_APP_ID}
--variable ACCESSTOKEN={YOUR_ACCESS_TOKEN}
--variable GCMSENDERID={YOUR_GCM_SENDER_ID}
--variable MCANALYTICS={enabled|disabled}
--variable CHANNELNAME={YOUR_CHANNEL_NAME}
--nosave
--nofetch
```
> You must explicitly enable or disable `MCANALYTICS`. `MCANALYTICS` enables or disables collection of analytics, such as notification displayed, opened, etc. for your app.

> These variables refer to your app in MobilePush.

## Cordova Configuration

You can develop in Cordova using one of two different approaches: 1) Cross-platform, or command-line interface (CLI) workflow or 2) platform-centered workflow. See the Cordova [Development Paths documentation section](http://cordova.apache.org/docs/en/7.x/guide/overview/index.html) for more information.

### iOS CLI Workflow

You can either use Apple's Xcode or use the CLI workflow. To use the CLI workflow, follow these steps.

1. Locate the build.xcconfig file, typically found in YOUR_CORDOVA_PROJECT/platforms/ios/cordova/build.xcconfig.

1. Create a copy of the build.xcconfig file.

1. Edit the copy to add the following attributes.
```
DEVELOPMENT_TEAM = *YOUR_TEAM_VALUE*

ARCHS = arm64 armv7 armv7s

VALID_ARCHS = arm64 armv7 armv7s
```
> armv7 and armv7s support older 32 bit systems. They allow for greater range when included with the arm64 64-bit supported architectures. See [Apple’s documentation](https://developer.apple.com/library/content/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/DeviceCompatibilityMatrix/DeviceCompatibilityMatrix.html) for more information.

1. Copy the edited file and overwrite Cordova's version using the "cordova prepare" command.

```
cp -a ./platforms/ ./platformsBck
rm -R ./platforms/
cordova plugin add ../MarketingCloudSdk-Cordova-Plugin —variable APPID={YOUR_APP_ID} —variable ACCESSTOKEN={YOUR_ACCESS_TOKEN} —variable GCMSENDERID={YOUR_GCM_SENDER_ID} —variable MCANALYTICS={enabled|disable} —variable CHANNELNAME={YOUR_CHANNEL_NAME} —nosave —nofetch
cordova prepare
cp -a ./platformsBck/android/ ./platforms/android/
cp -a ./platformsBck/ios/cordova/build.xcconfig ./platforms/ios/cordova/build.xcconfig
rm -R ./platforms/ios/YOUR_PROJECT_NAME.xcodeproj
cp -a ./platformsBck/ios/YOUR_PROJECT_NAME.xcodeproj ./platforms/ios/YOUR_PROJECT_NAME.xcodeproj
cp -a ./platformsBck/ios/YOUR_PROJECT_NAME/Entitlements-Debug.plist ./platforms/ios/YOUR_PROJECT_NAME/Entitlements-Debug.plist
cp -a ./platformsBck/ios/YOUR_PROJECT_NAME/Entitlements-Release.plist ./platforms/ios/YOUR_PROJECT_NAME/Entitlements-Release.plist
rm -R ./platformsBck/
export PATH=$PATH:/opt/gradle/gradle-4.4/bin
cordova run ios -verbose —device
```

### Android CLI Workflow

You can either use Android Studio or use the CLI workflow. If you use the CLI workflow, follow these steps.

1. Install the [gradle build tool](https://gradle.org/install/#manually).

>Gradle is a required dependency.

1. Set the following environment variables path.
`export PATH=$PATH:/opt/gradle/gradle-4.4.1/bin`

1. Build and run your project with the plugin.

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

> To use push notifications in iOS, call `enablePush`. Push is not enabled by default on start up.

#### disablePush

Disables push and push accessories in the Marketing Cloud SDK.

```javascript
MCCordovaPlugin.disablePush();
```
