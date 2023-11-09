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
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.messages.push/-push-message-manager/is-push-enabled.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)pushEnabled|iOS Docs}
     */
    isPushEnabled: function(successCallback, errorCallback = undefined) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.isPushEnabled`, arguments);
        _exec(successCallback, errorCallback, 'isPushEnabled');
    },
    /**
     * Enables push messaging in the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.messages.push/-push-message-manager/enable-push.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)setPushEnabled:|iOS Docs}
     */
    enablePush: function(successCallback = undefined, errorCallback = undefined) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.enablePush`, arguments);
        _exec(successCallback, errorCallback, 'enablePush');
    },
    /**
     * Disables push messaging in the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.messages.push/-push-message-manager/disable-push.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)setPushEnabled:|iOS Docs}
     */
    disablePush: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.disablePush`, arguments);
        _exec(successCallback, errorCallback, 'disablePush');
    },
    /**
     * Returns the token used by the Marketing Cloud to send push messages to
     * the device.
     * @param  {function(token)} successCallback
     * @param  {string} successCallback.token - The token used for push
     *     messaging.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/get-system-token.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)deviceToken|iOS Docs}
     */
    getSystemToken: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getSystemToken`, arguments);
        _exec(successCallback, errorCallback, 'getSystemToken');
    },
    /**
     * Returns the deviceId used by the Marketing Cloud SDK.
     * @param  {function(token)} successCallback
     * @param  {string} successCallback.deviceId - The deviceId used by Marketing Cloud
     *     messaging.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/get-device-id.html|Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)deviceIdentifier|iOS Docs}
     */
    getDeviceId: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getDeviceId`, arguments);
        _exec(successCallback, errorCallback, 'getDeviceId');
    },
    /**
     * Returns the maps of attributes set in the registration.
     * @param  {function(attributes)} successCallback
     * @param  {Object.<string, string>} successCallback.attributes - The
     *     key/value map of attributes set in the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/get-attributes.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)attributes|iOS Docs}
     */
    getAttributes: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getAttributes`, arguments);
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
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/SFMCSdk/8.0/com.salesforce.marketingcloud.sfmcsdk.components.identity/-identity/set-profile-attribute.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/IDENTITY.html#/c:@M@SFMCSDK@objc(cs)SFMCSdkIDENTITY(im)setProfileAttributes:|iOS Docs}
     */
    setAttribute: function(key, value, successCallback, errorCallback) {
        argsCheck.checkArgs('ssFF', `${PLUGIN_NAME}.setAttribute`, arguments);
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
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/-editor/clear-attribute.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/IDENTITY.html#/c:@M@SFMCSDK@objc(cs)SFMCSdkIDENTITY(im)clearProfileAttributeWithKey:|iOS Docs}
     */
    clearAttribute: function(key, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', `${PLUGIN_NAME}.clearAttribute`, arguments);
        _exec(successCallback, errorCallback, 'clearAttribute', [key]);
    },
    /**
     * @param  {string} tag - The tag to be added to the list of tags in the
     *     registration.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the value passed in for
     *     `tag` was saved in the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/-editor/add-tag.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)addTag:|iOS Docs}
     */
    addTag: function(tag, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', `${PLUGIN_NAME}.addTag`, arguments);
        _exec(successCallback, errorCallback, 'addTag', [tag]);
    },
    /**
     * @param  {string} tag - The tag to be removed from the list of tags in the
     *     registration.
     * @param  {function(saved)} [successCallback]
     * @param  {boolean} successCallback.saved - Whether the value passed in for
     *     `tag` was cleared from the registration.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/-editor/remove-tag.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)removeTag:|iOS Docs}
     */
    removeTag: function(tag, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', `${PLUGIN_NAME}.removeTag`, arguments);
        _exec(successCallback, errorCallback, 'removeTag', [tag]);
    },
    /**
     * Returns the tags currently set on the device.
     * @param  {function(tags)} successCallback
     * @param  {string[]} successCallback.tags - The array of tags currently set
     *     in the native SDK.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/get-tags.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)tags|iOS Docs}
     */
    getTags: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getTags`, arguments);
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
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/SFMCSdk/8.0/com.salesforce.marketingcloud.sfmcsdk.components.identity/-identity/set-profile-id.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/IDENTITY.html#/c:@M@SFMCSDK@objc(cs)SFMCSdkIDENTITY(im)setProfileId:|iOS Docs}
     */
    setContactKey: function(contactKey, successCallback, errorCallback) {
        argsCheck.checkArgs('sFF', `${PLUGIN_NAME}.setContactKey`, arguments);
        _exec(successCallback, errorCallback, 'setContactKey', [contactKey]);
    },
    /**
     * Returns the contact key currently set on the device.
     * @param  {function(contactKey)} successCallback
     * @param  {string} successCallback.contactKey - The current contact key.
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/MarketingCloudSdk/8.0/com.salesforce.marketingcloud.registration/-registration-manager/get-contact-key.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/MarketingCloudSdk/8.0/Classes/PushModule.html#/c:@M@MarketingCloudSDK@objc(cs)SFMCSdkPushModule(im)contactKey|iOS Docs}
     */
    getContactKey: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getContactKey`, arguments);
        _exec(successCallback, errorCallback, 'getContactKey');
    },
    /**
     * Enables verbose logging within the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/trouble-shooting/loginterface.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/SFMCSdk.html#/c:@M@SFMCSDK@objc(cs)SFMCSdk(cm)setLoggerWithLogLevel:logOutputter:|iOS Docs}
     */
    enableLogging: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.enableLogging`, arguments);
        _exec(successCallback, errorCallback, 'enableLogging');
    },
    /**
     * Disables verbose logging within the native Marketing Cloud SDK.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/trouble-shooting/loginterface.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/SFMCSdk.html#/c:@M@SFMCSDK@objc(cs)SFMCSdk(cm)setLoggerWithLogLevel:logOutputter:|iOS Docs}
     */
    disableLogging: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.disableLogging`, arguments);
        _exec(successCallback, errorCallback, 'disableLogging');
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
     *
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/javadocs/SFMCSdk/8.0/com.salesforce.marketingcloud.sfmcsdk/-s-f-m-c-sdk/get-sdk-state.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/SFMCSdk.html#/c:@M@SFMCSDK@objc(cs)SFMCSdk(cm)setLoggerWithLogLevel:logOutputter:https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledocs/SFMCSdk/8.0/Classes/SFMCSdk.html#/c:@M@SFMCSDK@objc(cs)SFMCSdk(cm)state|iOS Docs}
     *
     * @since 6.3.1
     */
    logSdkState: function(successCallback, errorCallback) {
        argsCheck.checkArgs('FF', `${PLUGIN_NAME}.logSdkState`, arguments);
        _exec(successCallback, errorCallback, 'logSdkState');
    },

    /**
     * Method to track events, which could result in actions such as an InApp Message being
     * displayed.
     * @param {CustomEvent | EngagementEvent | IdentityEvent | SystemEvent | CartEvent | OrderEvent | CatalogObjectEvent} event - The event to be tracked.
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/event-tracking/event-tracking-event-tracking.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/event-tracking/event-tracking-event-tracking.html|iOS Docs}
     */
    track: function(event) {
        argsCheck.checkArgs('oFF', `${PLUGIN_NAME}.track`, arguments);
        _exec(undefined, undefined, 'track', [event]);
    },

    /**
     * Enables or disables analytics in the native Marketing Cloud SDK.
     * @param  {boolean} enabled - Whether analytics should be enabled.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * 
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/sdk-implementation/runtime-toggles.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/sdk-implementation/runtime-toggles.html |iOS Docs}
     */
    setAnalyticsEnabled: function(enabled, successCallback, errorCallback) {
        argsCheck.checkArgs('*FF', `${PLUGIN_NAME}.setAnalyticsEnabled`, arguments);
        _exec(successCallback, errorCallback, 'setAnalyticsEnabled', [enabled]);
    },

    /**
     * Checks if analytics are enabled in the native Marketing Cloud SDK.
     * @param  {function(enabled)} successCallback
     * @param  {function} [errorCallback]
     * 
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/sdk-implementation/runtime-toggles.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/sdk-implementation/runtime-toggles.html |iOS Docs}
     */
    isAnalyticsEnabled: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.isAnalyticsEnabled`, arguments);
        _exec(successCallback, errorCallback, 'isAnalyticsEnabled');
    },

    /**
     * Enables or disables PI analytics in the native Marketing Cloud SDK.
     * @param  {boolean} enabled - Whether PI analytics should be enabled.
     * @param  {function} [successCallback]
     * @param  {function} [errorCallback]
     * 
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/sdk-implementation/runtime-toggles.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/sdk-implementation/runtime-toggles.html |iOS Docs}
     */
    setPiAnalyticsEnabled: function(enabled, successCallback, errorCallback) {
        argsCheck.checkArgs('*FF', `${PLUGIN_NAME}.setPiAnalyticsEnabled`, arguments);
        _exec(successCallback, errorCallback, 'setPiAnalyticsEnabled', [enabled]);
    },

    /**
     * Checks if PI analytics are enabled in the native Marketing Cloud SDK.
     * @param  {function(enabled)} successCallback
     * @param  {function} [errorCallback]
     * 
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-Android/sdk-implementation/runtime-toggles.html |Android Docs}
     * @see  {@link https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/sdk-implementation/runtime-toggles.html |iOS Docs}
     */
    isPiAnalyticsEnabled: function(successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.isPiAnalyticsEnabled`, arguments);
        _exec(successCallback, errorCallback, 'isPiAnalyticsEnabled');
    },
};

module.exports = MCCordovaPlugin;
