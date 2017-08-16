# Salesforce Marketing Cloud <br/>Journey Builder for Apps SDK (JB4A) <br/>Cordova/PhoneGap Plugin

This Cordova plugin implements the Salesforce Marketing Cloud Journey Builder for Apps SDK (JB4A) for your Phonegap/Cordova applications build for iOS and Android. This plugin is not *NOT* an official product release, hence comes with limited support.

## Release History

### Version 2.0.0
_Released March 16, 2017_

* Initial Release (public)
* Uses iOS SDK version 4.5.0 and Android version 4.8.5

### Version 1.0.0
_Released November 3, 2015_

* Initial Release (public)
* Uses iOS SDK version 4.0.2 and Android version 4.0.7

## Installing the Plugin

In order to connect this plugin to your Marketing Cloud account, you must follow these provisioning and app creation steps:

* [Connecting Marketing Cloud Account to your iOS App](http://salesforce-marketingcloud.github.io/JB4A-SDK-iOS/create-apps/create-apps-overview.html)
* [Connecting Marketing Cloud Account to your Android App](http://salesforce-marketingcloud.github.io/JB4A-SDK-Android/create-apps/create-apps-overview.html)

Once provisioning and your AppCenter app(s) are setup, install the plugin into your Cordova project with the following command:

***Be sure to replace the values below with your App Ids, Access Tokens and GCM Sender IDs***

```Bash
cordova plugin add https://github.exacttarget.com/Mobile/cordova-push.git
    --variable APPID=1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p 
    --variable ACCESSTOKEN=1q2w3e4r5t6y7u8i9o0p
    --variable GCMSENDERID=1234567890
```

The following variables should be used in the `cordova plugin add` command:

| Name | Description |
| ---- | ----------- |
| APPID | The `Application ID` for your Salesforce Marketing Cloud AppCenter App |
| ACCESSTOKEN | The `Access Token` for your Salesforce Marketing Cloud AppCenter App |
| GCMSENDERID | The `GCM Sender ID` for your Salesforce Marketing Cloud AppCenter App |

## Using the Plugin

After successful installation of your Cordova platform(s) and the plugin, you can begin using the following features of the JB4A SDK within your javascript in your Cordova app. 

### MarketingCloudSdk

Use the `MarketingCloudSdk` object in your javascript on or after the device ready or platform ready event. All of the methods below belong to the MarketingCloudSdk object that is automatically provided by the plugin. The JB4A configuration and registration calls will complete behind the scenes. You can just start using MarketingCloudSdk.methodname() within your app.

### setOpenDirectHandler

Sets javascript callbacks to handle when Open Direct alerts are received. This can be used to display Open Direct urls within your app (e.g. show in an in-app browser).

```javascript
MarketingCloudSdk.setOpenDirectHandler(openDirectHandlerCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```bash
{
	"webPageUrl": "http://opendirecturl.com"
}
```

Example:
```javascript
    MarketingCloudSdk.setOpenDirectHandler(openDirectReceived, function(){ console.log('### open direct failed'); });

    function openDirectReceived(data) {
      console.log('### openDirectReceived: ' + JSON.stringify(data));

      if (data) {
        $cordovaInAppBrowser.open(data.webPageUrl, '_blank');
      }
    }
```

### setCloudPageHandler

Sets javascript callbacks to handle when Cloud Page alerts are received. This can be used to display Cloud Pages within your app (e.g. show the Cloud Page in an in-app browser).

```javascript
MarketingCloudSdk.setCloudPageHandler(cloudPageHandlerCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
{
	"webPageUrl": "http://cloudpageurl.com"
}
```

Example:
```javascript
    MarketingCloudSdk.setCloudPageHandler(cloudPageReceived, function(){ console.log('### open direct failed'); });

    function cloudPageReceived(data) {
      console.log('### cloudPageReceived: ' + JSON.stringify(data));

      if (data) {
        $cordovaInAppBrowser.open(data.webPageUrl, '_blank');
      }
    }
```
### setNotificationHandler

Sets javascript callbacks to handle when push notifications are received. This can be used to handle push notifications when your app is open, as well as actions based on Custom Keys sent from the Marketing Cloud. 

```javascript
MarketingCloudSdk.setNotificationHandler(notificationHandlerCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
{
	"alert": "This is an alert with a Custom Key defined",
	"customKey1": "1234",
	"customKey2": "vip"
}
```

Example:
```javascript
    MarketingCloudSdk.setNotificationHandler(notificationReceived, function(){ console.log('### notification handler failed'); });

    function notificationReceived(data) {
      console.log('### notificationReceived: ' + JSON.stringify(data));

      if (data && data.dealId) {
      	//todo: automatically route to product detail page
        $ionicPopup.show({
          title: 'Custom Key(s)',
          template: '<div style="width: 100%; text-align: center;">dealId: ' + data.dealId + '</div>',
          buttons: [{ text: '<b>Do Something</b>', type: 'button-positive' }]
        });
      }
    }
```

### getSDKVersionName (android only)

Get the version name of the ET Push SDK

```javascript
MarketingCloudSdk.getSDKVersionName(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"versionName"`


### setSubscriberKey

Sets the Subscriber Key for this device.

```javascript
MarketingCloudSdk.setSubscriberKey(successCallback, errorCallback, subscriberKey);
```

### getSubscriberKey (ios only)

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

### removeAttribute

Removes an attribute from current user's Contact model.

```javascript
MarketingCloudSdk.removeAttribute(successCallback, errorCallback, attributeName);
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

A sample AngularJS/Ionic application can be found [here](https://github.exacttarget.com/Mobile/cordova-push-tester.git) that demonstrates the full lifecycle use of this plugin.
