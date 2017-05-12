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
cordova plugin add https://github.com/tharrington/cordova-etpush
    --variable DEV_APPID=1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p 
    --variable DEV_ACCESSTOKEN=1q2w3e4r5t6y7u8i9o0p
    --variable DEV_GCMSENDERID=1234567890
    --variable PROD_APPID=1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p 
    --variable PROD_ACCESSTOKEN=1q2w3e4r5t6y7u8i9o0p
    --variable PROD_GCMSENDERID=1234567890
    --variable LOCATION_ENABLED=true
    --variable PROXIMITY_ENABLED=true
    --variable ANALYTICS_ENABLED=true
    --variable WAMA_ENABLED=true
    --variable CLOUDPAGES_ENABLED=true
    --variable OVERRIDE_NTFN_ENABLED=false (Android only)
```

The following variables should be used in the `cordova plugin add` command:

| Name | Description |
| ---- | ----------- |
| DEV_APPID | The `Application ID` for your Salesforce Marketing Cloud AppCenter development (non-production) App |
| DEV_ACCESSTOKEN | The `Access Token` for your Salesforce Marketing Cloud AppCenter development (non-production) App |
| DEV_GCMSENDERID | The `GCM Sender ID` for your Salesforce Marketing Cloud AppCenter development (non-production) App |
| PROD_APPID | The `Application ID` for your Salesforce Marketing Cloud AppCenter production App |
| PROD_ACCESSTOKEN | The `Access Token` for your Salesforce Marketing Cloud AppCenter production App |
| PROD_GCMSENDERID | The `GCM Sender ID` for your Salesforce Marketing Cloud AppCenter production App |
| LOCATION_ENABLED | Set to `true` to enable Location Manager and Geofencing (if you have subscribed to this feature) |
| PROXIMITY_ENABLED | Set to `true` to enable Proximity and Beacon monitoring (if you have subscribed to this feature) |
| ANALYTICS_ENABLED | Set to `true` to enable Salesforce Marketing Cloud Analytics (if you have subscribed to this feature) |
| WAMA_ENABLED | Set to `true` to enable Web and Mobile Analytics (if you have subscribed to this feature) |
| CLOUDPAGES_ENABLED | Set to `true` to enable CloudPage Inbox (if you have subscribed to this feature) |
| OVERRIDE_NTFN_ENABLED | Set to `true` only if you want to override the default notification handler (Android only) |

## Using the Plugin

After successful installation of your Cordova platform(s) and the plugin, you can begin using the following features of the JB4A SDK within your javascript in your Cordova app. 

### ETPush

Use the `ETPush` object in your javascript on or after the device ready or platform ready event. All of the methods below belong to the ETPush object that is automatically provided by the plugin. The JB4A configuration and registration calls will complete behind the scenes. You can just start using ETPush.methodname() within your app.

### setOpenDirectHandler

Sets javascript callbacks to handle when Open Direct alerts are received. This can be used to display Open Direct urls within your app (e.g. show in an in-app browser).

```javascript
ETPush.setOpenDirectHandler(openDirectHandlerCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```bash
{
	"webPageUrl": "http://opendirecturl.com"
}
```

Example:
```javascript
    ETPush.setOpenDirectHandler(openDirectReceived, function(){ console.log('### open direct failed'); });

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
ETPush.setCloudPageHandler(cloudPageHandlerCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
{
	"webPageUrl": "http://cloudpageurl.com"
}
```

Example:
```javascript
    ETPush.setCloudPageHandler(cloudPageReceived, function(){ console.log('### open direct failed'); });

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
ETPush.setNotificationHandler(notificationHandlerCallback, errorCallback);
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
    ETPush.setNotificationHandler(notificationReceived, function(){ console.log('### notification handler failed'); });

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

### getSdkVersionName (android only)

Get the version name of the ET Push SDK

```javascript
ETPush.getSdkVersionName(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"versionName"`

### getSdkVersionCode (android only)

Get the version code of the ET Push SDK

```javascript
ETPush.getSdkVersionCode(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"versionCode"`

### setSubscriberKey

Sets the Subscriber Key for this device.

```javascript
ETPush.setSubscriberKey(successCallback, errorCallback, subscriberKey);
```

### getSubscriberKey (ios only)

Gets the Subscriber Key for this device.

```javascript
ETPush.getSubscriberKey(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `"subscriberKey"`

### addTag

Adds a tag to the current user's Contact model.

```javascript
ETPush.addTag(successCallback, errorCallback, tagName);
```

### removeTag

Removes a tag to the current user's Contact model.

```javascript
ETPush.removeTag(successCallback, errorCallback, tagName);
```

### getTags

Gets a list of tags from the current user's Contact model.

```javascript
ETPush.getTags(successCallback, errorCallback);
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
ETPush.addAttribute(successCallback, errorCallback, attributeName, attributeValue);
```

### removeAttribute

Removes an attribute from current user's Contact model.

```javascript
ETPush.removeAttribute(successCallback, errorCallback, attributeName);
```

### getAttributes

Gets the list of attributes from the current user's data.

```javascript
ETPush.getAttributes(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
{
	"attributeName1": "attributeValue1",
	"attributeName2": "attributeValue2",		
	"attributeName3": "attributeValue3"
}
```

### getInboxMessages

Gets CloudPage Inbox messages object.

```javascript
ETPush.getInboxMessages(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format:
```json
{
	"count": 2,
	"unread": 1,		
	"messages": [
		{
			"id": "1a2bc34d5e",
			"isRead": false,
			"subject": "CloudPage Subject Line 1",
			"url": "http://cloudpageurl1"
		},
		{
			"id": "6f7g8h9j0k",
			"isRead": true,
			"subject": "CloudPage Subject Line 2",
			"url": "http://cloudpageurl2"
		}
	]
}
```

### markAsRead

Sets a message to read status.

```javascript
ETPush.markAsRead(successCallback, errorCallback, messageId);
```

The successCallback will include a result parameter that represents the inbox state after this call in the following format:
```json
{
	"count": 2,
	"unread": 0,		
	"messages": [
		{
			"id": "1a2bc34d5e",
			"isRead": true,
			"subject": "CloudPage Subject Line 1",
			"url": "http://cloudpageurl1"
		},
		{
			"id": "6f7g8h9j0k",
			"isRead": true,
			"subject": "CloudPage Subject Line 2",
			"url": "http://cloudpageurl2"
		}
	]
}
```

### markAsDeleted

Sets a message to deleted, so when new messages are downloaded, it won't be re-added.

```javascript
ETPush.markAsDeleted(successCallback, errorCallback, messageId);
```

The successCallback will include a result parameter that represents the inbox state after this call in the following format:
```json
{
	"count": 2,
	"unread": 1,		
	"messages": [
		{
			"id": "1a2bc34d5e",
			"isRead": false,
			"subject": "CloudPage Subject Line 1",
			"url": "http://cloudpageurl1"
		},
		{
			"id": "6f7g8h9j0k",
			"isRead": true,
			"subject": "CloudPage Subject Line 2",
			"url": "http://cloudpageurl2"
		}
	]
}
```

### enablePush (android only)

Enables push and push accessories in the SDK.

```javascript
ETPush.enablePush(successCallback, errorCallback);
```

### disablePush (android only)

Disables push and push accessories in the SDK.

```javascript
ETPush.disablePush(successCallback, errorCallback);
```

### isPushEnabled

Checks persistent preferences for the state of Push.

```javascript
ETPush.isPushEnabled(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `true/false`

### startWatchingLocation

Start monitoring geofences.

```javascript
ETPush.startWatchingLocation(successCallback, errorCallback);
```

### stopWatchingLocation

Stop monitoring geofences.

```javascript
ETPush.stopWatchingLocation(successCallback, errorCallback);
```

### isWatchingLocation

Gets the current status for geofence monitoring

```javascript
ETPush.isWatchingLocation(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `true/false`

### startWatchingProximity (android only)

Start monitoring proximity and beacons.

```javascript
ETPush.startWatchingProximity(successCallback, errorCallback);
```

### stopWatchingProximity (android only)

Stop monitoring proximity and beacons.

```javascript
ETPush.stopWatchingProximity(successCallback, errorCallback);
```

### isWatchingProximity (android only)

Gets the current status for monitoring proximity and beacons.

```javascript
ETPush.isWatchingProximity(successCallback, errorCallback);
```

The successCallback will include a result parameter in the following format: `true/false`

## Sample Application

A sample AngularJS/Ionic application can be found [here](https://github.com/tharrington/daily-deals) that demonstrates the full lifecycle use of this plugin.
