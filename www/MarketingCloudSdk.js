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
  }
}
