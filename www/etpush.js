var exec = require('cordova/exec');

module.exports = {

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

  //Get system token. iOS needs testing.
  getSystemToken: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "ETPush", "getSystemToken", []);
  }
}
