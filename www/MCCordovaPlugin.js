var exec = require('cordova/exec');

module.exports = {

  //Logging
  enableVerboseLogging: function(successCallback, errorCallback){
    cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "enableVerboseLogging");
  },

  disableVerboseLogging: function(successCallback, errorCallback){
    cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "disableVerboseLogging");
  },

  //push
  registerPush: function(successCallback, errorCallback) {
	cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "registerPush", []);
  },

  enablePush: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "enablePush", []);
  },
  disablePush: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "disablePush", []);
  },
  isPushEnabled: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "isPushEnabled", []);
  },

  //Get system token.
  getSystemToken: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "getSystemToken", []);
  },

  //Attributes
  getAttributes: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "getAttributes", []);
  },         
  setAttribute: function(successCallback, errorCallback, key, value) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "setAttribute", [key,value]);
  },           
  clearAttribute: function(successCallback, errorCallback, key) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "clearAttribute", [key]);
  },
    
  //ContactKey           
  setContactKey: function(successCallback, errorCallback, contactKey) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "setContactKey", [contactKey]);
  }, 
  getContactKey: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "getContactKey", []);
  },

  //Tags           
  addTag: function(successCallback, errorCallback, tag) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "addTag", [tag]);
  }, 
  removeTag: function(successCallback, errorCallback, tag) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "removeTag", [tag]);
  }, 
  getTags: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MCCordovaPlugin", "getTags", []);
  }
}
