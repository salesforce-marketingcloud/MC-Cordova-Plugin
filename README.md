# Salesforce Marketing Cloud Cordova Plugin

This plugin implements the Marketing Cloud Mobile Push SDK for your applications built for [iOS](http://salesforce-marketingcloud.github.io/JB4A-SDK-iOS/) and [Android](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/).

## Release History

### Version 1.0.3
_Released Apr 9, 2018_
> Depends on the Marketing Cloud Mobile Push iOS SDK v5.1.x<br>
> Depends on the Marketing Cloud Mobile Push Android SDK v5.4.x

* Support for Cordova iOS Cross-platform (CLI) workflow<br>

### Version 1.0.2
_Released Jan 22, 2018_
> Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x<br>
> Depends on the Marketing Cloud Mobile Push Android SDK v5.3.x

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

## Installing the Plugin

In order to connect this plugin to your Marketing Cloud account, you must follow these provisioning and app creation steps:

* [Connecting Marketing Cloud Account to your iOS App](http://salesforce-marketingcloud.github.io/JB4A-SDK-iOS/create-apps/create-apps-overview.html)
* [Connecting Marketing Cloud Account to your Android App](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/create-apps/create-apps-overview.html)

Once provisioning and your AppCenter app(s) are setup, install the plugin into your Cordova project with the following command:

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
>Be sure to replace the values with your App's ID, Access Token, GCM Sender ID and Channel Name.  Also, you must explicitely choose enabled or disabled for `MCANALYTICS`.

The following variables should be used in the `cordova plugin add` command:

| Name | Description |
| ---- | ----------- |
| APPID | The `Application ID` for your Salesforce Marketing Cloud AppCenter App |
| ACCESSTOKEN | The `Access Token` for your Salesforce Marketing Cloud AppCenter App |
| GCMSENDERID | The `GCM Sender ID` for your Salesforce Marketing Cloud AppCenter App |
| MCANALYTICS | Whether or not you wish to collect notification displayed, opened, etc. analytics |
| CHANNELNAME | The `Channel Name` for your Salesforce Marketing Cloud AppCenter App |

## Using the Plugin

After successful installation of your Cordova platform(s) and the plugin, you can begin using the following features of the Marketing Cloud SDK within your javascript in your Cordova app. 

## Cordova CLI iOS Configuration

Cordova allows you to develop using one of two different approaches. *Cross-platform (CLI) workflow *or* Platform-centered workflow. (See Developement Paths:http://cordova.apache.org/docs/en/7.x/guide/overview/index.html) *If you are going to use the CLI workflow with iOS development then there are a couple things that you will need to do. 

1. The first thing you will need to do is leverage the build.xcconfig file that iOS platform uses for specific configuration settings. Since we are not using platform centered workflow and therefore not using xcode, we will need to make sure we configure some values ourselves for CLI to be able to build and run your project. 
    
    *Note*: You will need to make a back-up copy of this file, edit it and then replace the original. See helper script below.
    Your build.xcconfig file is typically found here: YOUR_CORDOVA_PROJECT/platforms/ios/cordova/build.xcconfig
    
 2. You will need to edit or add these attributes to the build.xcconfig file.

	*Note*: iOS supports 3 architecture types. The armv7 and armv7s support older 32 bit systems and allow for greater range when included with the arm64 64-bit supported architectures. Ref: https://developer.apple.com/library/content/documentation/DeviceInformation/Reference/iOSDeviceCompatibility/DeviceCompatibilityMatrix/DeviceCompatibilityMatrix.html
    
    ```
    DEVELOPMENT_TEAM = *YOUR_TEAM_VALUE*
    
    ARCHS = arm64 armv7 armv7s
    
    VALID_ARCHS = arm64 armv7 armv7s
    ```

Once you add these attributes and save your back-up copy you will need to copy this back-up file and overwrite Cordova's version generated with the “cordova prepare” command. 
Sample shell script:


```
cp -a ./platforms/ ./platformsBck
rm -R ./platforms/
cordova plugin add ../MarketingCloudSdk-Cordova-Plugin —variable APPID={YOUR_APP_ID} —variable ACCESSTOKEN={YOUR_ACCESS_TOKEN} —variable GCMSENDERID={YOUR_GCM_SENDER_ID} —variable MCANALYTICS={enabled|disable} —variable CHANNELNAME={YOUR_CHANNEL_NAME} —nosave —nofetch
cordova prepare
cp -a ./platformsBck/android/ ./platforms/android/
cp -a ./platformsBck/ios/cordova/build.xcconfig ./platforms/ios/cordova/build.xcconfig
rm -R ./platforms/ios/MarketingCloudSdk-Cordova-Plugin-Tester.xcodeproj
cp -a ./platformsBck/ios/MarketingCloudSdk-Cordova-Plugin-Tester.xcodeproj ./platforms/ios/MarketingCloudSdk-Cordova-Plugin-Tester.xcodeproj
cp -a ./platformsBck/ios/MarketingCloudSdk-Cordova-Plugin-Tester/Entitlements-Debug.plist ./platforms/ios/MarketingCloudSdk-Cordova-Plugin-Tester/Entitlements-Debug.plist
cp -a ./platformsBck/ios/MarketingCloudSdk-Cordova-Plugin-Tester/Entitlements-Release.plist ./platforms/ios/MarketingCloudSdk-Cordova-Plugin-Tester/Entitlements-Release.plist
rm -R ./platformsBck/
export PATH=$PATH:/opt/gradle/gradle-4.4/bin
cordova run ios -verbose —device
```

## Requirements for using plugin

If you are building Cordova for the Android Platform, installing Android Studio is not required. However, gradle is required as a dependancy and you will be required to install the gradle build tool. https://gradle.org/install/#manually

Once you have installed the Gradle build tool, make sure you have also set the enviornment variables path. 
export PATH=$PATH:/opt/gradle/gradle-4.4.1/bin

When you have completed this, you should be able to build and run your project with the MarketingCloud-Cordova-Plugin.

### MCCordovaPlugin

Use the `MCCordovaPlugin` object in your javascript on or after the device ready or platform ready event. All of the methods below belong to the MCCordovaPlugin object that is automatically provided by the plugin. The MarketingCloudSdk configuration and registration calls will complete behind the scenes. You can just start using MCCordovaPlugin.methodname() within your app.

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

The successCallback will include a result parameter in the following format: `"contactKey"`

### Attributes
#### setAttribute

Adds an attribute to current user's Contact model.

```javascript
MCCordovaPlugin.setAttribute(successCallback, errorCallback, attributeName, attributeValue);
```

The successCallback will include a result parameter of "true" or "false":
```javascript
"true"
```

#### clearAttribute

Removes an attribute from current user's Contact model.

```javascript
MCCordovaPlugin.clearAttribute(successCallback, errorCallback, attributeName);
```

The successCallback will return the key value that has been removed:
```javascript
"First Name"
```

#### getAttributes

Gets the list of attributes from the current user's Contact model.

```javascript
MCCordovaPlugin.getAttributes(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
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

The successCallback will include a result parameter in the following format:
```json
[
	"tag1",
	"tag2",
	"tag3"
]
```

### Logging
#### enableVerboseLogging

Enable internal Marketing Cloud SDK logging

```javascript
MCCordovaPlugin.enableVerboseLogging(successCallback, errorCallback);
```

#### disableVerboseLogging

Disable internal Marketing Cloud SDK logging.

```javascript
MCCordovaPlugin.disableVerboseLogging(successCallback, errorCallback);
```

### Misc
#### isPushEnabled

Checks persistent preferences for the state of Push.

```javascript
MCCordovaPlugin.isPushEnabled(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `true/false`

#### getSystemToken

Get the System Token of the Marketing Cloud SDK.

```javascript
MCCordovaPlugin.getSystemToken(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"systemToken"`


#### enablePush

Enables push and push accessories in the SDK.

```javascript
MCCordovaPlugin.enablePush(successCallback, errorCallback);
```

#### disablePush

Disables push and push accessories in the SDK.

```javascript
MCCordovaPlugin.disablePush(successCallback, errorCallback);
```
