var exec = require('cordova/exec'),
    argsCheck = require('cordova/argscheck');

var PLUGIN_NAME = 'MCCordovaPlugin';

function _exec(successCallback, errorCallback, methodName, args) {
    args = args || []
    exec(successCallback, errorCallback, PLUGIN_NAME, methodName, args)
}

var MCCordovaPlugin = {

    isPushEnabled: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.isPushEnabled`, arguments);
        _exec(successCallback, errorCallback, 'isPushEnabled');
    },

    enablePush: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.enablePush`, arguments);
        _exec(successCallback, errorCallback, 'enablePush');
    },

    disablePush: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.disablePush`, arguments);
        _exec(successCallback, errorCallback, 'disablePush');
    },

    getSystemToken: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getSystemToken`, arguments);
        _exec(successCallback, errorCallback, 'getSystemToken');
    },

    getAttributes: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getAttributes`, arguments);
        _exec(successCallback, errorCallback, 'getAttributes');
    },

    setAttribute: function (key, value, successCallback, errorCallback) {
        argsCheck.checkArgs('ssfF', `${PLUGIN_NAME}.setAttribute`, arguments);
        _exec(successCallback, errorCallback, 'setAttribute', [key, value]);
    },

    clearAttribute: function (key, successCallback, errorCallback) {
        argsCheck.checkArgs('sfF', `${PLUGIN_NAME}.clearAttribute`, arguments);
        _exec(successCallback, errorCallback, 'clearAttribute', [key]);
    },

    addTag: function (tag, successCallback, errorCallback) {
        argsCheck.checkArgs('sfF', `${PLUGIN_NAME}.addTag`, arguments);
        _exec(successCallback, errorCallback, 'addTag', [tag]);
    },

    removeTag: function (tag, successCallback, errorCallback) {
        argsCheck.checkArgs('sfF', `${PLUGIN_NAME}.removeTag`, arguments);
        _exec(successCallback, errorCallback, 'removeTag', [tag]);
    },

    getTags: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getTags`, arguments);
        _exec(successCallback, errorCallback, 'getTags');
    },

    setContactKey: function (contactKey, successCallback, errorCallback) {
        argsCheck.checkArgs('sfF', `${PLUGIN_NAME}.setContactKey`, arguments);
        _exec(successCallback, errorCallback, 'setContactKey', [contactKey]);
    },

    getContactKey: function (successCallback, errorCallback) {
        argsCheck.checkArgs('fF', `${PLUGIN_NAME}.getContactKey`, arguments);
        _exec(successCallback, errorCallback, 'getContactKey');
    }

    //TODO Logging
    //enableVerboseLogging
    //disableVerboseLogging

};

module.exports = MCCordovaPlugin;
