var exec = require('cordova/exec');

module.exports = {

	//set callback handlers
  setOpenDirectHandler: function(successCallback, errorCallback, options) {
      cordova.exec(successCallback, errorCallback, "ETPush", "setOpenDirectHandler", [options]);
  },

  setCloudPageHandler: function(successCallback, errorCallback, options) {
      cordova.exec(successCallback, errorCallback, "ETPush", "setCloudPageHandler", [options]);
  },

  setNotificationHandler: function(successCallback, errorCallback, options) {
      cordova.exec(successCallback, errorCallback, "ETPush", "setNotificationHandler", [options]);
  },

  //sdk
  getSdkVersionName: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getSdkVersionName", []);
  },
  getSdkVersionCode: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getSdkVersionCode", []);
  },

  //subscriber    
  setSubscriberKey: function(successCallback, errorCallback, subscriberKey) {
      cordova.exec(successCallback, errorCallback, "ETPush", "setSubscriberKey", [subscriberKey]);
  },
  getSubscriberKey: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getSubscriberKey", []);
  },

  //push
  enablePush: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "enablePush", []);
  },
  disablePush: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "disablePush", []);
  },
  isPushEnabled: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "isPushEnabled", []);
  },

  //Android only implementation to retrieve payload from SharedPreferences
  getMCPayload: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getMCPayload", []);
  },

  //Android only implementation to retrieve payload from SharedPreferences
  removeMCPayload: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "removeMCPayload", []);
  },
  
  //Implementation to check for OS level notification status, this is Android only implementation
  isNotificationEnabled: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "isNotificationEnabled", []);
  },
  
  //Get system token. iOS needs testing.
  getSystemToken: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getSystemToken", []);
  },

  //tags
  addTag: function(successCallback, errorCallback, tag) {
      cordova.exec(successCallback, errorCallback, "ETPush", "addTag", [tag]);
  },
  removeTag: function(successCallback, errorCallback, tag) {
      cordova.exec(successCallback, errorCallback, "ETPush", "removeTag", [tag]);
  },
  getTags: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getTags", []);
  },

  //attributes
  addAttribute: function(successCallback, errorCallback, attributeName, attributeValue) {
      cordova.exec(successCallback, errorCallback, "ETPush", "addAttribute", [attributeName, attributeValue]);
  },
  removeAttribute: function(successCallback, errorCallback, attributeName, attributeValue) {
      cordova.exec(successCallback, errorCallback, "ETPush", "removeAttribute", [attributeName]);
  },
  getAttributes: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getAttributes", []);
  },

  //inbox
  getInboxMessages: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getInboxMessages", []);
  },
  markAsRead: function(successCallback, errorCallback, messageId) {
      cordova.exec(successCallback, errorCallback, "ETPush", "markAsRead", [messageId]);
  },
  markAsDeleted: function(successCallback, errorCallback, messageId) {
      cordova.exec(successCallback, errorCallback, "ETPush", "markAsDeleted", [messageId]);
  },

  //location
  startWatchingLocation: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "startWatchingLocation", []);
  },
  stopWatchingLocation: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "stopWatchingLocation", []);
  },
  isWatchingLocation: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "isWatchingLocation", []);
  },

  //proximity
  startWatchingProximity: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "startWatchingProximity", []);
  },
  stopWatchingProximity: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "stopWatchingProximity", []);
  },
  isWatchingProximity: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "isWatchingProximity", []);
  }    
}
