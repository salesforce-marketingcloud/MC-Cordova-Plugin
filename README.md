# Salesforce Marketing Cloud Cordova Plugin

Use this plugin to implement the Marketing Cloud MobilePush SDK for your [iOS](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/) and [Android](http://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/) applications.

## Release Notes

Release notes for the plugin can be found [here](CHANGELOG.md)

## Installation

#### 1. Add plugin to your application via [npm](https://www.npmjs.com/package/cordova-plugin-marketingcloudsdk)

```shell
cordova plugin add cordova-plugin-marketingcloudsdk
```

**Required for iOS**

You must have [Cocoapods](https://cocoapods.org/) installed for the iOS platform integration.  Execute the following commands from terminal to install:
```shell
sudo gem install cocoapods
pod repo update
```

#### 2. Modify your application's `config.xml` to configure the plugin <a name="config"></a>

```xml
<!-- Required -->
<preference name="com.salesforce.marketingcloud.app_id" value="{Marketing Cloud application id}" />
<preference name="com.salesforce.marketingcloud.access_token" value="{Marketing Cloud access token}" />
<preference name="com.salesforce.marketingcloud.tenant_specific_endpoint" value="{URL retrieved from Marketing Cloud adminstration page}" />

<!-- Required - Android Only -->
<platform name="android">
  <preference name="com.salesforce.marketingcloud.notification_small_icon" value="ic_notification" />
</platform>

<!-- Optional -->
<preference name="com.salesforce.marketingcloud.analytics" value="{true|false}" />
<preference name="com.salesforce.marketingcloud.delay_registration_until_contact_key_is_set" value="{true|false}" />
```

#### 3. Provide FCM credentials

To enable push support for the Android platform you will need to include the google-services.json file.  

1. Download the file from your application's [Firebase console](https://console.firebase.google.com/) and place it in your project's root folder.  
2. Add following to Android element in your `config.xml`:

```xml
<platform name="android">
  <resource-file src="google-services.json" target="app/google-services.json" />
</platform>
```

#### 4. Enable iOS Push

Follow [these instructions](./ios_push.md) to enable push for iOS.

## API Reference <a name="reference"></a>


* [MCCordovaPlugin](#module_MCCordovaPlugin)
    * _static_
        * [.isPushEnabled(successCallback, [errorCallback])](#module_MCCordovaPlugin.isPushEnabled)
        * [.enablePush([successCallback], [errorCallback])](#module_MCCordovaPlugin.enablePush)
        * [.disablePush([successCallback], [errorCallback])](#module_MCCordovaPlugin.disablePush)
        * [.getSystemToken(successCallback, [errorCallback])](#module_MCCordovaPlugin.getSystemToken)
        * [.getAttributes(successCallback, [errorCallback])](#module_MCCordovaPlugin.getAttributes)
        * [.setAttribute(key, value, [successCallback], [errorCallback])](#module_MCCordovaPlugin.setAttribute)
        * [.clearAttribute(key, [successCallback], [errorCallback])](#module_MCCordovaPlugin.clearAttribute)
        * [.addTag(tag, [successCallback], [errorCallback])](#module_MCCordovaPlugin.addTag)
        * [.removeTag(tag, [successCallback], [errorCallback])](#module_MCCordovaPlugin.removeTag)
        * [.getTags(successCallback, [errorCallback])](#module_MCCordovaPlugin.getTags)
        * [.setContactKey(contactKey, [successCallback], [errorCallback])](#module_MCCordovaPlugin.setContactKey)
        * [.getContactKey(successCallback, [errorCallback])](#module_MCCordovaPlugin.getContactKey)
        * [.enableVerboseLogging([successCallback], [errorCallback])](#module_MCCordovaPlugin.enableVerboseLogging)
        * [.disableVerboseLogging([successCallback], [errorCallback])](#module_MCCordovaPlugin.disableVerboseLogging)
        * [.setOnNotificationOpenedListener(notificationOpenedListener)](#module_MCCordovaPlugin.setOnNotificationOpenedListener)
        * [.setOnUrlActionListener(urlActionListener)](#module_MCCordovaPlugin.setOnUrlActionListener)
        * [.logSdkState([successCallback], [errorCallback])](#module_MCCordovaPlugin.logSdkState)
    * _inner_
        * [~notificationOpenedCallback](#module_MCCordovaPlugin..notificationOpenedCallback) : <code>function</code>
        * [~urlActionCallback](#module_MCCordovaPlugin..urlActionCallback) : <code>function</code>


---

<a name="module_MCCordovaPlugin"></a>

## MCCordovaPlugin
<a name="module_MCCordovaPlugin.isPushEnabled"></a>

### MCCordovaPlugin.isPushEnabled(successCallback, [errorCallback])
The current state of the pushEnabled flag in the native Marketing Cloud
SDK.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#isPushEnabled())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_pushEnabled)


| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>function</code> |  |
| successCallback.enabled | <code>boolean</code> | Whether push is enabled. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.enablePush"></a>

### MCCordovaPlugin.enablePush([successCallback], [errorCallback])
Enables push messaging in the native Marketing Cloud SDK.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#enablePush())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setPushEnabled:)


| Param | Type |
| --- | --- |
| [successCallback] | <code>function</code> | 
| [errorCallback] | <code>function</code> | 

<a name="module_MCCordovaPlugin.disablePush"></a>

### MCCordovaPlugin.disablePush([successCallback], [errorCallback])
Disables push messaging in the native Marketing Cloud SDK.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#disablePush())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setPushEnabled:)


| Param | Type |
| --- | --- |
| [successCallback] | <code>function</code> | 
| [errorCallback] | <code>function</code> | 

<a name="module_MCCordovaPlugin.getSystemToken"></a>

### MCCordovaPlugin.getSystemToken(successCallback, [errorCallback])
Returns the token used by the Marketing Cloud to send push messages to
the device.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#getPushToken())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_deviceToken)


| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>function</code> |  |
| successCallback.token | <code>string</code> | The token used for push     messaging. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.getAttributes"></a>

### MCCordovaPlugin.getAttributes(successCallback, [errorCallback])
Returns the maps of attributes set in the registration.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.html#getAttributes())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_attributes)


| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>function</code> |  |
| successCallback.attributes | <code>Object.&lt;string, string&gt;</code> | The     key/value map of attributes set in the registration. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.setAttribute"></a>

### MCCordovaPlugin.setAttribute(key, value, [successCallback], [errorCallback])
Sets the value of an attribute in the registration.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#setAttribute(java.lang.String,%20java.lang.String))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setAttributeNamed:value:)


| Param | Type | Description |
| --- | --- | --- |
| key | <code>string</code> | The name of the attribute to be set in the     registration. |
| value | <code>string</code> | The value of the `key` attribute to be set in     the registration. |
| [successCallback] | <code>function</code> |  |
| successCallback.saved | <code>boolean</code> | Whether the attribute value was     set in the registration. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.clearAttribute"></a>

### MCCordovaPlugin.clearAttribute(key, [successCallback], [errorCallback])
Clears the value of an attribute in the registration.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#clearAttribute(java.lang.String))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_clearAttributeNamed:)


| Param | Type | Description |
| --- | --- | --- |
| key | <code>string</code> | The name of the attribute whose value should be     cleared from the registration. |
| [successCallback] | <code>function</code> |  |
| successCallback.saved | <code>boolean</code> | Whether the value of the `key`     attribute was cleared from the registration. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.addTag"></a>

### MCCordovaPlugin.addTag(tag, [successCallback], [errorCallback])
**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#addTag(java.lang.String))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_addTag:)


| Param | Type | Description |
| --- | --- | --- |
| tag | <code>string</code> | The tag to be added to the list of tags in the     registration. |
| [successCallback] | <code>function</code> |  |
| successCallback.saved | <code>boolean</code> | Whether the value passed in for     `tag` was saved in the registration. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.removeTag"></a>

### MCCordovaPlugin.removeTag(tag, [successCallback], [errorCallback])
**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#removeTag(java.lang.String))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_removeTag:)


| Param | Type | Description |
| --- | --- | --- |
| tag | <code>string</code> | The tag to be removed from the list of tags in the     registration. |
| [successCallback] | <code>function</code> |  |
| successCallback.saved | <code>boolean</code> | Whether the value passed in for     `tag` was cleared from the registration. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.getTags"></a>

### MCCordovaPlugin.getTags(successCallback, [errorCallback])
Returns the tags currently set on the device.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.html#getTags())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_tags)


| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>function</code> |  |
| successCallback.tags | <code>Array.&lt;string&gt;</code> | The array of tags currently set     in the native SDK. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.setContactKey"></a>

### MCCordovaPlugin.setContactKey(contactKey, [successCallback], [errorCallback])
Sets the contact key for the device's user.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#setContactKey(java.lang.String))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setContactKey:)


| Param | Type | Description |
| --- | --- | --- |
| contactKey | <code>string</code> | The value to be set as the contact key of     the device's user. |
| [successCallback] | <code>function</code> |  |
| successCallback.saved | <code>boolean</code> | Whether the value passed in for     `contactKey` was saved in the registration. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.getContactKey"></a>

### MCCordovaPlugin.getContactKey(successCallback, [errorCallback])
Returns the contact key currently set on the device.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.html#getContactKey())
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_contactKey)


| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>function</code> |  |
| successCallback.contactKey | <code>string</code> | The current contact key. |
| [errorCallback] | <code>function</code> |  |

<a name="module_MCCordovaPlugin.enableVerboseLogging"></a>

### MCCordovaPlugin.enableVerboseLogging([successCallback], [errorCallback])
Enables verbose logging within the native Marketing Cloud SDK.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/MarketingCloudSdk.html#setLogLevel(int))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setDebugLoggingEnabled:)


| Param | Type |
| --- | --- |
| [successCallback] | <code>function</code> | 
| [errorCallback] | <code>function</code> | 

<a name="module_MCCordovaPlugin.disableVerboseLogging"></a>

### MCCordovaPlugin.disableVerboseLogging([successCallback], [errorCallback])
Disables verbose logging within the native Marketing Cloud SDK.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**See**

- [Android Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/MarketingCloudSdk.html#setLogLevel(int))
- [iOS Docs](https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setDebugLoggingEnabled:)


| Param | Type |
| --- | --- |
| [successCallback] | <code>function</code> | 
| [errorCallback] | <code>function</code> | 

<a name="module_MCCordovaPlugin.setOnNotificationOpenedListener"></a>

### MCCordovaPlugin.setOnNotificationOpenedListener(notificationOpenedListener)
**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**Since**: 6.1.0  

| Param | Type |
| --- | --- |
| notificationOpenedListener | <code>function</code> | 
| notificationOpenedListener.event | <code>MCCordovaPlugin~notificationOpenedCallback</code> | 

<a name="module_MCCordovaPlugin.setOnUrlActionListener"></a>

### MCCordovaPlugin.setOnUrlActionListener(urlActionListener)
**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**Since**: 6.3.0  

| Param | Type |
| --- | --- |
| urlActionListener | <code>function</code> | 
| urlActionListener.event | <code>MCCordovaPlugin~urlActionCallback</code> | 

<a name="module_MCCordovaPlugin.logSdkState"></a>

### MCCordovaPlugin.logSdkState([successCallback], [errorCallback])
Instructs the native SDK to log the SDK state to the native logging system (Logcat for
Android and Xcode/Console.app for iOS).  This content can help diagnose most issues within
the SDK and will be requested by the Marketing Cloud support team.

**Kind**: static method of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  
**Since**: 6.3.1  

| Param | Type |
| --- | --- |
| [successCallback] | <code>function</code> | 
| [errorCallback] | <code>function</code> | 

<a name="module_MCCordovaPlugin..notificationOpenedCallback"></a>

### MCCordovaPlugin~notificationOpenedCallback : <code>function</code>
**Kind**: inner typedef of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  

| Param | Type | Description |
| --- | --- | --- |
| timeStamp | <code>number</code> | Time since epoch when the push message was     opened. |
| values | <code>Object</code> | The values of the notification message. |
| values.alert | <code>string</code> | The alert text of the notification     message. |
| [values.title] | <code>string</code> | The title text of the notification     message. |
| [values.url] | <code>string</code> | The url associated with the notification     message. This can be either a cloud-page url or an open-direct url. |
| values.type | <code>string</code> | Indicates the type of notification message.     Possible values: 'cloudPage', 'openDirect' or 'other' |

<a name="module_MCCordovaPlugin..urlActionCallback"></a>

### MCCordovaPlugin~urlActionCallback : <code>function</code>
**Kind**: inner typedef of [<code>MCCordovaPlugin</code>](#module_MCCordovaPlugin)  

| Param | Type | Description |
| --- | --- | --- |
| url | <code>string</code> | The url associated with the action taken by the user. |

---

### 3rd Party Product Language Disclaimers
Where possible, we changed noninclusive terms to align with our company value of Equality. We retained noninclusive terms to document a third-party system, but we encourage the developer community to embrace more inclusive language. We can update the term when it’s no longer required for technical accuracy.
