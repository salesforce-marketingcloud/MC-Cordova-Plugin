var exec = require('cordova/exec');

module.exports = {

  //push
  enablePush: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "enablePush", []);
  },
  disablePush: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "disablePush", []);
  },
  isPushEnabled: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "isPushEnabled", []);
  },

  //Get system token.
  getSystemToken: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "getSystemToken", []);
  },

  //Attributes
  getAttributes: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "getAttributes", []);
  },         
  setAttribute: function(successCallback, errorCallback, key, value) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "setAttribute", [key,value]);
  },           
  clearAttribute: function(successCallback, errorCallback, key) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "clearAttribute", [key]);
  },
    
  //ContactKey           
  setContactKey: function(successCallback, errorCallback, contactKey) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "setContactKey", [contactKey]);
  }, 
  getContactKey: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "MarketingCloudSdk", "getContactKey", []);
  }
}
