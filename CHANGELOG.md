Change Log
==========
### Version 7.3.0
* Updated to the 7.3.x versions of the Android and iOS Marketing Cloud SDK.

### Version 7.2.0
* Updated to the 7.2.x versions of the Android and iOS Marketing Cloud SDK.

### Version 7.1.0
* Updated to the 7.1.x versions of the Android and iOS Marketing Cloud SDK.

### Version 7.0.0
* Updated to the 7.0.x versions of the Android and iOS Marketing Cloud SDK.

### Version 6.4.0
* Updated to the 6.4.x versions of the Android and iOS Marketing Cloud SDK.

### Version 6.3.1
* Added support for logging the SDK state to the native platform logging system (Android: Logcat, iOS: Console).
* Added documentation for setting up push for iOS.

### Version 6.3.0

* Updated to the 6.3.x versions of the Android and iOS Marketing Cloud SDK.
* The plugin now utilizes Cocoapods for the iOS SDK integration.
* Support In-App Messaging functionality of the MobilePush SDK.

### Version 6.2.1

* Updated to the 6.2.x versions of the Android and iOS Marketing Cloud SDK.
* Added support to delay registration until contact key has been set. Refer to the [config documentation](README.md#config) for more details.
* Require Tenant Specific Endpoint in the  `config.xml` file. If a Tenant Specific Endpoint is not specified an exception is thrown.

### Version 6.1.0

* Updated to the 6.1.x versions of the Android and iOS Marketing Cloud SDK.
* Added support for listening to notification opened events.  This will allow you to take action when a user clicks a notification, such as loading the url from an Open Direct or Cloud Page message.  

### Version 6.0.0

In this release we have greatly simplified the Cordova plugin for our MobilePush SDK.  For greatest success, if you are upgrading from a prior release, we suggest following the integration instructions as if this were a new plugin.

All functionality of this plugin remains the same as the preceding versions.

* The plugin version number will now match with the `major`.`minor` version of the SDK release.
* The plugin is now published to npm for easier installation
* The Javascript API has been updated to allow for optional parameters where applicable.  Refer to the [API Reference](README.md#reference) for more details.
* Moved SDK configuration values from command line arguments passed in while installing the SDK into the `config.xml` file.

### Version 1.1.0
_Released July 11, 2018_
> For Android: Depends on Android Cordova platform 6.4.0.

* Updated Android SDK to 5.6.x
* Updated iOS SDK to 5.2.x

### Version 1.0.3
_Released Apr 23, 2018_
> For iOS: Depends on the Marketing Cloud Mobile Push iOS SDK v5.1.x
> For Android: Depends on the Marketing Cloud Mobile Push Android SDK v5.5.x, the latest version of Cordova, and Android Cordova platform 6.4.0.

* Added support for Cordova iOS cross-platform (CLI) workflow

### Version 1.0.2
_Released Jan 22, 2018_
> For iOS: Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x
> For Android: Depends on the Marketing Cloud Mobile Push Android SDK v5.3.x, the latest version of Cordova, and Android Cordova platform 6.4.0.

* Updated Android SDK to v5.3.+

### Version 1.0.1
_Released Nov 29, 2017_
> Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x
> Depends on the Marketing Cloud Mobile Push Android SDK v5.2.x

* Updated Android SDK to v5.2.+

### Version 1.0.0
_Released October 27, 2017_
> Depends on the Marketing Cloud Mobile Push iOS SDK v4.9.x
> Depends on the Marketing Cloud Mobile Push Android SDK v5.0.x
