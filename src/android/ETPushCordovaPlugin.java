package com.salesforce.etpush;
 
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;



//import com.exacttarget.etpushsdk.ETException;
//import com.salesforce.marketingcloud.messages.push;
//import com.exacttarget.etpushsdk.ETPush;
//import com.exacttarget.etpushsdk.ETPushConfig;
//import com.exacttarget.etpushsdk.data.Attribute;
//import com.exacttarget.etpushsdk.data.Message;
//import com.exacttarget.etpushsdk.event.ReadyAimFireInitCompletedEvent;
//import com.exacttarget.etpushsdk.event.RegistrationEvent;
//import com.salesforce.marketingcloud.registration;
//import com.exacttarget.etpushsdk.util.EventBus;
//import com.exacttarget.etpushsdk.ETLocationManager;
//import com.exacttarget.etpushsdk.adapter.CloudPageListAdapter;
import com.salesforce.marketingcloud.messages.push.PushMessageManager;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.registration.RegistrationManager;

import android.content.Context;
import android.app.Application;
import android.app.Activity;
import android.support.v4.app.NotificationManagerCompat;
import android.preference.PreferenceManager;
import android.content.SharedPreferences;

import android.util.Log;
import org.apache.cordova.*;

import java.util.Set;
import java.util.TreeSet;
import java.util.ArrayList;

public class ETPushCordovaPlugin extends CordovaPlugin {
	
	private static final String TAG = CONSTS.LOG_TAG;

	public static final String ACTION_GET_SDK_VERSION_NAME = "getSdkVersionName";
	//public static final String ACTION_GET_SDK_VERSION_CODE = "getSdkVersionCode";

	/*public static final String ACTION_SET_SUBSCRIBER_KEY = "setSubscriberKey";
	public static final String ACTION_GET_SUBSCRIBER_KEY = "getSubscriberKey";*/
	public static final String ACTION_GET_SYSTEM_TOKEN = "getSystemToken";

	public static final String ACTION_ENABLE_PUSH = "enablePush";
	public static final String ACTION_DISABLE_PUSH = "disablePush";
	public static final String ACTION_IS_PUSH_ENABLED = "isPushEnabled";
	public static final String ACTION_IS_NOTIFICATION_ENABLED = "isNotificationEnabled";

	/*public static final String ACTION_ADD_ATTRIBUTE = "addAttribute";
	public static final String ACTION_REMOVE_ATTRIBUTE = "removeAttribute";
	public static final String ACTION_GET_ATTRIBUTES = "getAttributes";

	public static final String ACTION_ADD_TAG = "addTag";
	public static final String ACTION_REMOVE_TAG = "removeTag";
	public static final String ACTION_GET_TAGS = "getTags";

	public static final String ACTION_SET_OPEN_DIRECT_HANDLER = "setOpenDirectHandler";
	public static final String ACTION_SET_CLOUD_PAGE_HANDLER = "setCloudPageHandler";*/
	public static final String ACTION_SET_NOTIFICATION_HANDLER = "setNotificationHandler";

	/*public static final String ACTION_GET_INBOX_MESSAGES = "getInboxMessages";
	public static final String ACTION_MARK_AS_READ = "markAsRead";
	public static final String ACTION_MARK_AS_DELETED = "markAsDeleted";

	public static final String ACTION_START_WATCHING_LOCATION = "startWatchingLocation";
	public static final String ACTION_STOP_WATCHING_LOCATION = "stopWatchingLocation";
	public static final String ACTION_IS_WATCHING_LOCATION = "isWatchingLocation";

	public static final String ACTION_START_WATCHING_PROXIMITY = "startWatchingProximity";
	public static final String ACTION_STOP_WATCHING_PROXIMITY = "stopWatchingProximity";
	public static final String ACTION_IS_WATCHING_PROXIMITY = "isWatchingProximity";*/

	/*public static final String ACTION_GET_MC_PAYLOAD = "getMCPayload";
	public static final String ACTION_REMOVE_MC_PAYLOAD = "removeMCPayload";*/

  /*private static CallbackContext cloudPageCallback;
  private static CallbackContext openDirectCallback;*/
  private static CallbackContext notificationCallback;
  //private static CallbackContext inboxCallback;
  //private static CallbackContext notificationStatusCallback;

  /**
   * Main CordovaPlugin execute function
   */
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
	  
	  Log.d(TAG, "EXECUTING " + action);	
		
		try {
			if (ACTION_GET_SDK_VERSION_NAME.equals(action)) {

				String versionName;
				try {
					versionName = MarketingCloudSdk.getInstance().getSdkVersionName();
				} catch (Exception e) {
					Log.e(TAG, e.getMessage(), e);
					callbackContext.error(e.getMessage());
					return false;          	
				}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, versionName));
				return true; 	

			} else if (ACTION_GET_SYSTEM_TOKEN.equals(action)) { 
				String systemToken;
				try {
						systemToken = MarketingCloudSdk.getInstance().getRegistrationManager().getSystemToken();
				} catch (Exception e) {
					Log.e(TAG, e.getMessage(), e);
				    callbackContext.error(e.getMessage());
				    return false;          	
				}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, systemToken));
				return true;

		    } else if(ACTION_IS_NOTIFICATION_ENABLED.equals(action)){
		  		boolean notificationStatus;
		  		try {
		  			Context ctx = ETPushCordovaApplication.getAppContext();

		  			//isNotificationEnabledStatus = NotificationManagerCompat.from(ctx).areNotificationsEnabled();
		  			//notificationStatus = ETPushCordovaApplication.isNotificationEnabledStatus;
		  			notificationStatus = NotificationManagerCompat.from(ctx).areNotificationsEnabled();
		  		}catch(Exception e){
		  			Log.e(TAG, e.getMessage(), e);
		    		callbackContext.error(e.getMessage());
		    		return false; 
		  		}
		  		callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, notificationStatus));
		      	return true;

			}else if (ACTION_ENABLE_PUSH.equals(action)) {

				try {
					MarketingCloudSdk.getInstance().getPushMessageManager().enablePush();
				} catch (Exception e) {
					Log.e(TAG, e.getMessage(), e);
					callbackContext.error(e.getMessage());
					return false;          	
				}

				callbackContext.success();
				return true;

			} else if (ACTION_DISABLE_PUSH.equals(action)) {

	  			try {
	  				MarketingCloudSdk.getInstance().getPushMessageManager().disablePush();
		      	} catch (Exception e) {
		        	Log.e(TAG, e.getMessage(), e);
				    	callbackContext.error(e.getMessage());
				    	return false;          	
		      	}

				callbackContext.success();
				return true;	  

			} else if (ACTION_IS_PUSH_ENABLED.equals(action)) {

				Boolean isPushEnabled;
				try {
					isPushEnabled = MarketingCloudSdk.getInstance().getPushMessageManager().isPushEnabled();
				} catch (Exception e) {
					Log.e(TAG, e.getMessage(), e);
					callbackContext.error(e.getMessage());
					return false;          	
				}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isPushEnabled));
				return true; 	  

			} else if (ACTION_SET_NOTIFICATION_HANDLER.equals(action)) {

				if (notificationCallback != null) {
				    callbackContext.error( "Notification handler already running.");
				    return true;
				}
				notificationCallback = callbackContext;
				Log.d(TAG, "EXECUTING ACTION_SET_NOTIFICATION_HANDLER");
				// Don't return any result now, since status results will be sent when events come in from broadcast receiver
				PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
				pluginResult.setKeepCallback(true);
				callbackContext.sendPluginResult(pluginResult);
				return true;

			} else {
				//INVALID ACTION
				callbackContext.error("Invalid action");
				return false;
			} 
		} catch(Exception e) {
		System.err.println("Exception: " + e.getMessage());
		callbackContext.error(e.getMessage());
		return false;
		}
	}
}