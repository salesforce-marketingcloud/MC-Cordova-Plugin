# Salesforce Marketing Cloud Cordova Plugin

This plugin implements the Marketing Cloud Mobile Push SDK for your applications built for [iOS](http://salesforce-marketingcloud.github.io/JB4A-SDK-iOS/) and [Android](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/).

## Release History

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


## Android Only Features
#### enablePush (android only)

Enables push and push accessories in the SDK.

```javascript
MCCordovaPlugin.enablePush(successCallback, errorCallback);
```

#### disablePush (android only)

Disables push and push accessories in the SDK.

```javascript
MCCordovaPlugin.disablePush(successCallback, errorCallback);
```
