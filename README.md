# Salesforce Marketing Cloud <br/>Salesforce Marketing Cloud SDK <br/>Cordova/PhoneGap Plugin

This Cordova plugin implements the Salesforce Marketing Cloud SDK for your Phonegap/Cordova applications build for iOS and Android. This plugin is not *NOT* an official product release, hence comes with limited support.

## Release History

### Version 1.0.0
_Released October 27, 2017_

* Initial Release (public)
* Uses iOS SDK version 4.9.6 and Android version 5.x

## Installing the Plugin

In order to connect this plugin to your Marketing Cloud account, you must follow these provisioning and app creation steps:

* [Connecting Marketing Cloud Account to your iOS App](http://salesforce-marketingcloud.github.io/JB4A-SDK-iOS/create-apps/create-apps-overview.html)
* [Connecting Marketing Cloud Account to your Android App](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/create-apps/create-apps-overview.html)

Once provisioning and your AppCenter app(s) are setup, install the plugin into your Cordova project with the following command:

***Be sure to replace the values below with your App Ids, Access Tokens and GCM Sender IDs***

```Bash
cordova plugin add ../MarketingCloudSdk-Cordova-Plugin 
--variable APPID={YOUR_APP_ID} 
--variable ACCESSTOKEN={YOUR_ACCESS_TOKEN} 
--variable GCMSENDERID={YOUR_GCM_SENDER_ID} 
--nosave 
--nofetch
```

The following variables should be used in the `cordova plugin add` command:

| Name | Description |
| ---- | ----------- |
| APPID | The `Application ID` for your Salesforce Marketing Cloud AppCenter App |
| ACCESSTOKEN | The `Access Token` for your Salesforce Marketing Cloud AppCenter App |
| GCMSENDERID | The `GCM Sender ID` for your Salesforce Marketing Cloud AppCenter App |

## Using the Plugin

After successful installation of your Cordova platform(s) and the plugin, you can begin using the following features of the Marketing Cloud SDK within your javascript in your Cordova app. 

### MarketingCloudSdk

Use the `MarketingCloudSdk` object in your javascript on or after the device ready or platform ready event. All of the methods below belong to the MarketingCloudSdk object that is automatically provided by the plugin. The MarketingCloudSdk configuration and registration calls will complete behind the scenes. You can just start using MarketingCloudSdk.methodname() within your app.


### getSystemToken

Get the System Token of the Marketing Cloud SDK

```javascript
MarketingCloudSdk.getSystemToken(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"systemToken"`


### setSubscriberKey

Sets the Subscriber Key for this device.

```javascript
MarketingCloudSdk.setSubscriberKey(successCallback, errorCallback, subscriberKey);
```

### getSubscriberKey

Gets the Subscriber Key for this device.

```javascript
MarketingCloudSdk.getSubscriberKey(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"subscriberKey"`

### addTag

Adds a tag to the current user's Contact model.

```javascript
MarketingCloudSdk.addTag(successCallback, errorCallback, tagName);
```

### removeTag

Removes a tag to the current user's Contact model.

```javascript
MarketingCloudSdk.removeTag(successCallback, errorCallback, tagName);
```

### getTags

Gets a list of tags from the current user's Contact model.

```javascript
MarketingCloudSdk.getTags(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
[
	"tag1",
	"tag2",
	"tag3"
]
```

### addAttribute

Adds an attribute to current user's Contact model.

```javascript
MarketingCloudSdk.addAttribute(successCallback, errorCallback, attributeName, attributeValue);
```

The successCallback will include a result parameter of "true" or "false":
```javascript
{
true
}

### removeAttribute

Removes an attribute from current user's Contact model.

```javascript
MarketingCloudSdk.removeAttribute(successCallback, errorCallback, attributeName);
```

The successCallback will return the key value that has been removed:
```javascript
First Name
```

### getAttributes

Gets the list of attributes from the current user's data.

```javascript
MarketingCloudSdk.getAttributes(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
{
	"attributeName1": "attributeValue1",
	"attributeName2": "attributeValue2",		
	"attributeName3": "attributeValue3"
}
```

### enablePush (android only)

Enables push and push accessories in the SDK.

```javascript
MarketingCloudSdk.enablePush(successCallback, errorCallback);
```

### disablePush (android only)

Disables push and push accessories in the SDK.

```javascript
MarketingCloudSdk.disablePush(successCallback, errorCallback);
```

### isPushEnabled

Checks persistent preferences for the state of Push.

```javascript
MarketingCloudSdk.isPushEnabled(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `true/false`


## Sample Application

A sample application can be found [here](https://github.exacttarget.com/Mobile/MarketingCloudSdk-Cordova-Plugin-Tester.git) that demonstrates the full lifecycle use of this plugin.
