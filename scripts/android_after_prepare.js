#!/usr/bin/env node

module.exports = function(context) {

  var fs = context.requireCordovaModule('fs'),
    path = context.requireCordovaModule('path');

  var platformRoot = path.join(context.opts.projectRoot, 'platforms/android');

  //throw new Error('context: ' + JSON.stringify(context));
  //console.log('context:', JSON.stringify(context));


  var manifestFile = path.join(platformRoot, 'app/src/main/AndroidManifest.xml');
  var applicationName;

  if (fs.existsSync(manifestFile)) {

    fs.readFile(manifestFile, 'utf8', function (err,data) {
      if (err) {
        throw new Error('Unable to find AndroidManifest.xml: ' + err);
      }

      var appClass = 'com.salesforce.marketingcloud.cordovaplugin.MCCordovaPluginApplication';
      try{
        packageName = data.match(/package=".+?"/g)[0].replace('package=\"',"").replace('\"',"");
        updatePluginjava(packageName);
      } catch(ex){
        console.error('could not parse package name from manifest, please update', ex);
      }     

      if (data.indexOf(appClass) == -1) {

        var result = data.replace(/<application/g, '<application android:name="' + appClass + '"');

        fs.writeFile(manifestFile, result, 'utf8', function (err) {
          if (err) throw new Error('Unable to write into AndroidManifest.xml: ' + err);
        })
      }
    });
  }

  function updatePluginjava(packageName){

    var pluginApplication = path.join(platformRoot, 'app/src/main/java/com/salesforce/marketingcloud/cordovaplugin/MCCordovaPluginApplication.java');
    
    if (fs.existsSync(pluginApplication) && packageName) {
      fs.readFile(pluginApplication, 'utf8', function (err,data) {

        if (err) {
          throw new Error('Unable to find MCCordovaPluginApplication.java: ' + err);
        }

        if (data.indexOf(packageName) == -1) {

          var result = data.replace(/packagename/g, packageName);

          fs.writeFile(pluginApplication, result, 'utf8', function (err) {
            if (err) throw new Error('Unable to write into MCCordovaPluginApplication.java: ' + err);
          })
        }
      });
    }
  }
};
