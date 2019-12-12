/**
 * @license
 * Copyright 2018 Salesforce, Inc
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

var exec = require('cordova/exec');
var argsCheck = require('cordova/argscheck');

var PLUGIN_NAME = 'MCCordovaPlugin';

var onNotificationOpened;
var onUrlAction;

function registerEvents() {
    var onEventsCallback = function(event) {
        switch (event.type) {
            case 'notificationOpened':
                if (onNotificationOpened !== undefined) {
                    onNotificationOpened(event);
                }
                break;
            case 'urlAction':
                if (onUrlAction !== undefined) {
                    onUrlAction(event);
                }
        }
    };

    _exec(onEventsCallback, null, 'registerEventsChannel');
}

document.addEventListener('deviceready', registerEvents);

function _exec(successCallback, errorCallback, methodName, args) {
    args = args || [];
    exec(successCallback, errorCallback, PLUGIN_NAME, methodName, args);
}

/**
 * @exports MCCordovaPlugin
 */
var MCCordovaPlugin = {
    /**
     * The current state of the pushEnabled flag in the native Marketing Cloud
     * SDK.
     * @param  {function(enabled)} successCallback
     * @param  {boolean} successCallback.enabled - Whether push is enabled.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#isPushEnabled()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_pushEnabled|iOS Docs}
     */
    isPushEnabled: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', PLUGIN_NAME + '.isPushEnabled', arguments);
        _exec(successCallback, errorCallback, 'isPushEnabled');
    },

    /**
     * Enables push messaging in the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#enablePush()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setPushEnabled:|iOS Docs}
     */
    enablePush: function(successCallback = undefined, errorCallback = undefined) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.enablePush`, arguments);
        _exec(successCallback, errorCallback, 'enablePush');
    },

    /**
     * Disables push messaging in the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#disablePush()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setPushEnabled:|iOS Docs}
     */
    disablePush: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', PLUGIN_NAME + '.disablePush', arguments);
        _exec(successCallback, errorCallback, 'disablePush');
    },

    /**
     * Returns the token used by the Marketing Cloud to send push messages to
     * the device.
     * @param  {function(token)} successCallback
     * @param  {string} successCallback.token - The token used for push
     *     messaging.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/messages/push/PushMessageManager.html#getPushToken()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_deviceToken|iOS Docs}
     */
    getSystemToken: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', PLUGIN_NAME + '.getSystemToken', arguments);
        _exec(successCallback, errorCallback, 'getSystemToken');
    },

    /**
     * Returns the maps of attributes set in the registration.
     * @param  {function(attributes)} successCallback
     * @param  {Object.<string, string>} successCallback.attributes - The
     *     key/value map of attributes set in the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.html#getAttributes()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_attributes|iOS Docs}
     */
    getAttributes: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', PLUGIN_NAME + '.getAttributes', arguments);
        _exec(successCallback, errorCallback, 'getAttributes');
    },
    /**
     * Sets the value of an attribute in the registration.
     * @param  {string} key - The name of the attribute to be set in the
     *     registration.
     * @param  {string} value - The value of the `key` attribute to be set in
     *     the registration.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the attribute value was
     *     set in the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#setAttribute(java.lang.String,%20java.lang.String)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setAttributeNamed:value:|iOS Docs}
     */
    setAttribute: function(key, value, successCallback, errorCallback) {
        argsCheck.checkArgs('ssFF', PLUGIN_NAME + '.setAttribute', arguments);
        _exec(successCallback, errorCallback, 'setAttribute', [key, value]);
    },
    /**
     * Clears the value of an attribute in the registration.
     * @param  {string} key - The name of the attribute whose value should be
     *     cleared from the registration.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the value of the `key`
     *     attribute was cleared from the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#clearAttribute(java.lang.String)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_clearAttributeNamed:|iOS Docs}
     */
    clearAttribute: function(key, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', PLUGIN_NAME + '.clearAttribute', arguments);
        _exec(successCallback, errorCallback, 'clearAttribute', [key]);
    },
    /**
     * @param  {string} tag - The tag to be added to the list of tags in the
     *     registration.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the value passed in for
     *     `tag` was saved in the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#addTag(java.lang.String)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_addTag:|iOS Docs}
     */
    addTag: function(tag, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', PLUGIN_NAME + '.addTag', arguments);
        _exec(successCallback, errorCallback, 'addTag', [tag]);
    },
    /**
     * @param  {string} tag - The tag to be removed from the list of tags in the
     *     registration.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the value passed in for
     *     `tag` was cleared from the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#removeTag(java.lang.String)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_removeTag:|iOS Docs}
     */
    removeTag: function(tag, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', PLUGIN_NAME + '.removeTag', arguments);
        _exec(successCallback, errorCallback, 'removeTag', [tag]);
    },
    /**
     * Returns the tags currently set on the device.
     * @param  {function(tags)} successCallback
     * @param  {string[]} successCallback.tags - The array of tags currently set
     *     in the native SDK.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.html#getTags()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_tags|iOS Docs}
     */
    getTags: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', PLUGIN_NAME + '.getTags', arguments);
        _exec(successCallback, errorCallback, 'getTags');
    },
    /**
     * Sets the contact key for the device's user.
     * @param  {string} contactKey - The value to be set as the contact key of
     *     the device's user.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the value passed in for
     *     `contactKey` was saved in the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.Editor.html#setContactKey(java.lang.String)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setContactKey:|iOS Docs}
     */
    setContactKey: function(contactKey, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', PLUGIN_NAME + '.setContactKey', arguments);
        _exec(successCallback, errorCallback, 'setContactKey', [contactKey]);
    },
    /**
     * Returns the contact key currently set on the device.
     * @param  {function(contactKey)} successCallback
     * @param  {string} successCallback.contactKey - The current contact key.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/registration/RegistrationManager.html#getContactKey()|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_contactKey|iOS Docs}
     */
    getContactKey: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', PLUGIN_NAME + '.getContactKey', arguments);
        _exec(successCallback, errorCallback, 'getContactKey');
    },
    /**
     * Enables verbose logging within the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/MarketingCloudSdk.html#setLogLevel(int)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setDebugLoggingEnabled:|iOS Docs}
     */
    enableVerboseLogging: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.enableVerboseLogging`, arguments);
        _exec(successCallback, errorCallback, 'enableVerboseLogging');
    },
    /**
     * Disables verbose logging within the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/6.0/reference/com/salesforce/marketingcloud/MarketingCloudSdk.html#setLogLevel(int)|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/Classes/MarketingCloudSDK.html#//api/name/sfmc_setDebugLoggingEnabled:|iOS Docs}
     */
    disableVerboseLogging: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.disableVerboseLogging`, arguments);
        _exec(successCallback, errorCallback, 'disableVerboseLogging');
    },
    /**
     * @param {function(event)} notificationOpenedListener
     * @param {MCCordovaPlugin~notificationOpenedCallback}
     *     notificationOpenedListener.event
     * @since 6.1.0
     */
    setOnNotificationOpenedListener: function(notificationOpenedListener) {
        argsCheck.checkArgs('f', `${PLUGIN_NAME}.setOnNotificationOpenedListener`, arguments);
        onNotificationOpened = notificationOpenedListener;
        _exec(undefined, undefined, 'subscribe', ['notificationOpened']);
    },

    /**
     * @callback module:MCCordovaPlugin~notificationOpenedCallback
     * @param {number} timeStamp - Time since epoch when the push message was
     *     opened.
     * @param {Object} values - The values of the notification message.
     * @param {string} values.alert - The alert text of the notification
     *     message.
     * @param {string} [values.title] - The title text of the notification
     *     message.
     * @param {string} [values.url] - The url associated with the notification
     *     message. This can be either a cloud-page url or an open-direct url.
     * @param {string} values.type - Indicates the type of notification message.
     *     Possible values: 'cloudPage', 'openDirect' or 'other'
     */

    /**
     * @param {function(event)} urlActionListener
     * @param {MCCordovaPlugin~urlActionCallback} urlActionListener.event
     * @since 6.3.0
     */
    setOnUrlActionListener: function(urlActionListener) {
        argsCheck.checkArgs('f', `${PLUGIN_NAME}.setOnUrlActionListener`, arguments);
        onUrlAction = urlActionListener;
        _exec(undefined, undefined, 'subscribe', ['urlAction']);
    },

    /**
     * @callback module:MCCordovaPlugin~urlActionCallback
     * @param {string} url - The url associated with the action taken by the user.
     */

    /**
     * Instructs the native SDK to log the SDK state to the native logging system (Logcat for
     * Android and Xcode/Console.app for iOS).  This content can help diagnose most issues within
     * the SDK and will be requested by the Marketing Cloud support team.
     *
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @since 6.3.1
     */
    logSdkState: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.logSdkState`, arguments);
        _exec(successCallback, errorCallback, 'logSdkState');
    },

    /**
     * Geofence messaging - start watching location
     *
     * @param   {function}  successCallback  returns empty result
     * @param   {function}  errorCallback    [errorCallback description]
     *
     * @return  {function}                   [return description]
     */
    startWatchingLocation: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.startWatchingLocation`, arguments);
        _exec(successCallback, errorCallback, 'startWatchingLocation');
    },

    /**
     * Geofence messaging - stop watching location
     *
     * @param   {function}  successCallback  returns empty result
     * @param   {function}  errorCallback    [errorCallback description]
     *
     * @return  {function}                   [return description]
     */
    stopWatchingLocation: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.stopWatchingLocation`, arguments);
        _exec(successCallback, errorCallback, 'stopWatchingLocation');
    },

    /**
     * Geofence messaging - watching location
     *
     * @param   {[type]}  successCallback  returns whether watching location is enabled
     * @param   {[type]}  errorCallback    [errorCallback description]
     *
     * @return  {[type]}                   [return description]
     */
    watchingLocation: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.watchingLocation`, arguments);
        _exec(successCallback, errorCallback, 'watchingLocation');
    },

    /**
     * Geofence messaging - check if location is enabled
     *
     * @param   {function}  successCallback  Returns boolean with status
     * @param   {function}  errorCallback    [errorCallback description]
     *
     * @return  {[type]}                   [return description]
     * 
     * !!WARN: iOS Only
     * TODO: implement Andoid functionality
     */
    locationEnabled: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.locationEnabled`, arguments);
        _exec(successCallback, errorCallback, 'locationEnabled');
    },

    /**
     * Geofence messaging - access the device’s last known location
     *
     * @param   {[type]}  successCallback  returns last knwon location
     * @param   {[type]}  errorCallback    [errorCallback description]
     *
     * @return  {[type]}                   [return description]
     * 
     * !!WARN: iOS Only
     * TODO: implement Andoid functionality 
     */
    lastKnownLocation: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.lastKnownLocation`, arguments);
        _exec(successCallback, errorCallback, 'lastKnownLocation');
    }

};

module.exports = MCCordovaPlugin;
