package com.salesforce.etpush;
 
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;



import com.exacttarget.etpushsdk.ETException;
import com.exacttarget.etpushsdk.ETPush;
import com.exacttarget.etpushsdk.ETPushConfig;
import com.exacttarget.etpushsdk.data.Attribute;
import com.exacttarget.etpushsdk.data.Message;
import com.exacttarget.etpushsdk.event.ReadyAimFireInitCompletedEvent;
import com.exacttarget.etpushsdk.event.RegistrationEvent;
import com.exacttarget.etpushsdk.util.EventBus;
import com.exacttarget.etpushsdk.ETLocationManager;
import com.exacttarget.etpushsdk.adapter.CloudPageListAdapter;

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
	public static final String ACTION_GET_SDK_VERSION_CODE = "getSdkVersionCode";

	public static final String ACTION_SET_SUBSCRIBER_KEY = "setSubscriberKey";
	public static final String ACTION_GET_SUBSCRIBER_KEY = "getSubscriberKey";
	public static final String ACTION_GET_SYSTEM_TOKEN = "getSystemToken";

	public static final String ACTION_ENABLE_PUSH = "enablePush";
	public static final String ACTION_DISABLE_PUSH = "disablePush";
	public static final String ACTION_IS_PUSH_ENABLED = "isPushEnabled";
	public static final String ACTION_IS_NOTIFICATION_ENABLED = "isNotificationEnabled";

	public static final String ACTION_ADD_ATTRIBUTE = "addAttribute";
	public static final String ACTION_REMOVE_ATTRIBUTE = "removeAttribute";
	public static final String ACTION_GET_ATTRIBUTES = "getAttributes";

	public static final String ACTION_ADD_TAG = "addTag";
	public static final String ACTION_REMOVE_TAG = "removeTag";
	public static final String ACTION_GET_TAGS = "getTags";

	public static final String ACTION_SET_OPEN_DIRECT_HANDLER = "setOpenDirectHandler";
	public static final String ACTION_SET_CLOUD_PAGE_HANDLER = "setCloudPageHandler";
	public static final String ACTION_SET_NOTIFICATION_HANDLER = "setNotificationHandler";

	public static final String ACTION_GET_INBOX_MESSAGES = "getInboxMessages";
	public static final String ACTION_MARK_AS_READ = "markAsRead";
	public static final String ACTION_MARK_AS_DELETED = "markAsDeleted";

	public static final String ACTION_START_WATCHING_LOCATION = "startWatchingLocation";
	public static final String ACTION_STOP_WATCHING_LOCATION = "stopWatchingLocation";
	public static final String ACTION_IS_WATCHING_LOCATION = "isWatchingLocation";

	public static final String ACTION_START_WATCHING_PROXIMITY = "startWatchingProximity";
	public static final String ACTION_STOP_WATCHING_PROXIMITY = "stopWatchingProximity";
	public static final String ACTION_IS_WATCHING_PROXIMITY = "isWatchingProximity";

	public static final String ACTION_GET_MC_PAYLOAD = "getMCPayload";
	public static final String ACTION_REMOVE_MC_PAYLOAD = "removeMCPayload";

  private static CallbackContext cloudPageCallback;
  private static CallbackContext openDirectCallback;
  private static CallbackContext notificationCallback;
  private static CallbackContext inboxCallback;
  private static CallbackContext notificationStatusCallback;

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
  				versionName = ETPush.getInstance().getSdkVersionName();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, versionName));
	      return true; 	

		  } else if (ACTION_GET_SDK_VERSION_CODE.equals(action)) {

  			String versionCode;
  			try {
  				versionCode = String.valueOf(ETPush.getInstance().getSdkVersionCode());
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, versionCode));
	      return true; 		

			} else if (ACTION_SET_SUBSCRIBER_KEY.equals(action)) { 
			
				String subscriberKey = args.getString(0);
				if (subscriberKey != null && !subscriberKey.isEmpty()) {

	  			try {
	  				ETPush.getInstance().setSubscriberKey(subscriberKey);
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting subscriberKey (string).");
		    	return false;
		 		}		      

			} else if (ACTION_GET_SYSTEM_TOKEN.equals(action)) { 
				String systemToken;
				try {
	  				systemToken = ETPush.getInstance().getSystemToken();
	        	} catch (ETException e) {
	          	Log.e(TAG, e.getMessage(), e);
				    callbackContext.error(e.getMessage());
				    return false;          	
        		}

			  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, systemToken));
		      return true;


			}else if (ACTION_GET_SUBSCRIBER_KEY.equals(action)) { 

				// As of 4.0.7, getSubscriberKey not available in Android version of JB4A SDK
				// String subscriberKey;
				// 	try {
				// 		subscriberKey = ETPush.getInstance().getSubscriberKey();
				//   	} catch (ETException e) {
				//     	Log.e(TAG, e.getMessage(), e);
				//   	callbackContext.error(e.getMessage());
				//   	return false;          	
				//   	}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "getSubscriberKey not available in Android version of JB4A SDK"));
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
  				ETPush.getInstance().enablePush();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

	      callbackContext.success();
	      return true;

		  } else if (ACTION_DISABLE_PUSH.equals(action)) {

  			try {
  				ETPush.getInstance().disablePush();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

	      callbackContext.success();
	      return true;

	  } else if(ACTION_GET_MC_PAYLOAD.equals(action)) {
	  		String payload;
	  		try {

	  			SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ETPushCordovaApplication.getAppContext());
      			payload = sp.getString(CONSTS.KEY_MC_PAYLOAD, null);
      			Log.d(TAG, "PAYLOAD IS:"+payload);
	  		} catch(Exception e) {
	  			Log.e(TAG, e.getMessage(), e);
			    callbackContext.error(e.getMessage());
			    return false; 
	  		}
	  		 callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, payload));
		      return true; 
		} else if(ACTION_REMOVE_MC_PAYLOAD.equals(action)) {
	  		boolean removed=true;
	  		try {

	  			SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ETPushCordovaApplication.getAppContext());
      			SharedPreferences.Editor spEditor = sp.edit();
      			spEditor.remove(CONSTS.KEY_MC_PAYLOAD);
      			spEditor.commit();
	  		} catch(Exception e) {
	  			Log.e(TAG, e.getMessage(), e);
			    callbackContext.error(e.getMessage());
			    return false; 
	  		}
	  		 callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, removed));
		      return true; 	  

		  } else if (ACTION_IS_PUSH_ENABLED.equals(action)) {

	  			Boolean isPushEnabled;
	  			try {
	  				isPushEnabled = ETPush.getInstance().isPushEnabled();
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

			  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isPushEnabled));
		      return true; 	  

		  } else if (ACTION_ADD_TAG.equals(action)) {

				String tag = args.getString(0);
				if (tag != null && !tag.isEmpty()) {

	  			try {
	  				ETPush.getInstance().addTag(tag);
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting tag (string).");
		    	return false;
		 		}

		  } else if (ACTION_REMOVE_TAG.equals(action)) {

				String tag = args.getString(0);
				if (tag != null && !tag.isEmpty()) {

	  			try {
	  				ETPush.getInstance().removeTag(tag);
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting tag (string).");
		    	return false;
		 		}		 		

		  } else if (ACTION_GET_TAGS.equals(action)) {

	  			TreeSet<String> tags;
	  			try {
	  				tags = ETPush.getInstance().getTags();
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

					callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, tags.toString()));
		      return true; 

			} else if (ACTION_ADD_ATTRIBUTE.equals(action)) { 
			
				String attributeName = args.getString(0);
				String attributeValue = args.getString(1);
				if (attributeName != null && attributeValue != null && !attributeName.isEmpty() && !attributeValue.isEmpty()) {

	  			try {
	  				ETPush.getInstance().addAttribute(attributeName, attributeValue);
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting attributeName (string), attributeValue (string).");
		    	return false;
		 		}

		 	} else if (ACTION_REMOVE_ATTRIBUTE.equals(action)) { 
			
				String attributeName = args.getString(0);
				if (attributeName != null && !attributeName.isEmpty()) {

	  			try {
	  				ETPush.getInstance().removeAttribute(attributeName);
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting attributeName (string).");
		    	return false;
		 		}

		  } else if (ACTION_GET_ATTRIBUTES.equals(action)) {

	  			ArrayList<Attribute> attributes;
	  			try {
	  				attributes = ETPush.getInstance().getAttributes();
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

					StringBuilder result = new StringBuilder();
					result.append("{");
					for (Attribute attrib : attributes)	{
					  result.append("'" + attrib.getKey() + "'");
					  result.append(":");
					  result.append("'" + attrib.getValue() + "',");
					}
					result = result.deleteCharAt(result.length()-1);
					result.append("}");

					callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result.toString()));
		      return true; 

		  } else if (ACTION_SET_OPEN_DIRECT_HANDLER.equals(action)) {

            if (openDirectCallback != null) {
                callbackContext.error( "OpenDirect handler already running.");
                return true;
            }
            openDirectCallback = callbackContext;

            // Don't return any result now, since status results will be sent when events come in from broadcast receiver
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
		  	return true;

		  } else if (ACTION_SET_CLOUD_PAGE_HANDLER.equals(action)) {

            if (cloudPageCallback != null) {
                callbackContext.error( "CloudPage handler already running.");
                return true;
            }
            cloudPageCallback = callbackContext;

            // Don't return any result now, since status results will be sent when events come in from broadcast receiver
            PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            pluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(pluginResult);
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

		 	} else if (ACTION_GET_INBOX_MESSAGES.equals(action)) { 
			
				JSONObject json;
				try {
		 			json = getInboxMessagesFromAdapter();
      	} catch (Exception e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

      	if (json == null) {
		    	callbackContext.error("Unable to get Inbox Cloud Pages from Adapter.");
		    	return false;      		
      	} else {
					callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, json));
		      return true;
	    	}

		 	} else if (ACTION_MARK_AS_READ.equals(action)) { 
			
				String messageId = args.getString(0);
				if (messageId != null && !messageId.isEmpty()) {

					CloudPageListAdapter cloudPageListAdapter = ETPushCordovaApplication.cloudPageListAdapter;
	  			try {
	  				for (int i=0; i < cloudPageListAdapter.getCount(); i++) {
	  					Message message = (Message) cloudPageListAdapter.getItem(i);
	  					if (messageId.equals(message.getId())) {
	  						cloudPageListAdapter.setMessageRead(message);

								JSONObject json = getInboxMessagesFromAdapter();
				      	if (json == null) {
						    	callbackContext.error("Unable to get Inbox Cloud Pages from Adapter.");
						    	return false;      		
				      	} else {
									callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, json));
						      return true;
					    	}	  						
	  					} 
	  				}
        	} catch (Exception e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting messageId (string).");
		    	return false;
		 		}	

		 	} else if (ACTION_MARK_AS_DELETED.equals(action)) { 
			
				String messageId = args.getString(0);
				if (messageId != null && !messageId.isEmpty()) {

					CloudPageListAdapter cloudPageListAdapter = ETPushCordovaApplication.cloudPageListAdapter;
	  			try {
	  				for (int i=0; i < cloudPageListAdapter.getCount(); i++) {
	  					Message message = (Message) cloudPageListAdapter.getItem(i);
	  					if (messageId.equals(message.getId())) {
	  						cloudPageListAdapter.deleteMessage(message);

								JSONObject json = getInboxMessagesFromAdapter();
				      	if (json == null) {
						    	callbackContext.error("Unable to get Inbox Cloud Pages from Adapter.");
						    	return false;      		
				      	} else {
									callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, json));
						      return true;
					    	}	 
	  					} 
	  				}
        	} catch (Exception e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

		      callbackContext.success();
		      return true;
		    } else {
		    	callbackContext.error("Argument(s) missing: Expecting messageId (string).");
		    	return false;
		 		}		

		  } else if (ACTION_START_WATCHING_LOCATION.equals(action)) {

  			try {
  				ETLocationManager.getInstance().startWatchingLocation();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

	      callbackContext.success();
	      return true;	

		  } else if (ACTION_STOP_WATCHING_LOCATION.equals(action)) {

  			try {
  				ETLocationManager.getInstance().stopWatchingLocation();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

	      callbackContext.success();
	      return true;	

		  } else if (ACTION_IS_WATCHING_LOCATION.equals(action)) {

  			Boolean isWatchingLocation;
  			try {
  				isWatchingLocation = ETLocationManager.getInstance().isWatchingLocation();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

				callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isWatchingLocation));
	      return true; 	

		  } else if (ACTION_START_WATCHING_PROXIMITY.equals(action)) {

  			try {
  				ETLocationManager.getInstance().startWatchingProximity();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

	      callbackContext.success();
	      return true;		 	

		  } else if (ACTION_STOP_WATCHING_PROXIMITY.equals(action)) {

  			try {
  				ETLocationManager.getInstance().stopWatchingProximity();
      	} catch (ETException e) {
        	Log.e(TAG, e.getMessage(), e);
		    	callbackContext.error(e.getMessage());
		    	return false;          	
      	}

	      callbackContext.success();
	      return true;	

		  } else if (ACTION_IS_WATCHING_PROXIMITY.equals(action)) {

	  			Boolean isWatchingProximity;
	  			try {
	  				isWatchingProximity = ETLocationManager.getInstance().isWatchingProximity();
        	} catch (ETException e) {
          	Log.e(TAG, e.getMessage(), e);
			    	callbackContext.error(e.getMessage());
			    	return false;          	
        	}

					callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isWatchingProximity));
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

  /**
   * Method called from setOpenDirectRecipient java class
   */
  public static void openDirectReceived(JSONObject info) {
    if (openDirectCallback != null) {
      PluginResult result = new PluginResult(PluginResult.Status.OK, info);
      result.setKeepCallback(true);
      openDirectCallback.sendPluginResult(result);
    }
  }	

  /**
   * Method called from setCloudPageRecipient java class
   */
  public static void cloudPageReceived(JSONObject info) {
    if (cloudPageCallback != null) {
      PluginResult result = new PluginResult(PluginResult.Status.OK, info);
      result.setKeepCallback(true);
      cloudPageCallback.sendPluginResult(result);
    }
  }	

  /**
   * Method called from EventBus PushReceivedEvent event in Application class
   */
  public static void notificationReceived(JSONObject info) {
    if (notificationCallback != null) {
      
      Log.d(TAG, "Notification Received in ETPushCordovaPlugin:"+info);
      PluginResult result = new PluginResult(PluginResult.Status.OK, info);
      result.setKeepCallback(true);
      notificationCallback.sendPluginResult(result);
    }else{
    	 Log.d(TAG, "Notification callback is null:"+info);
    }
  }	 

 
  /**
   * Private Method to construct JSONObject representing cloud pages app inbox
   */
  private JSONObject getInboxMessagesFromAdapter () {

		CloudPageListAdapter cloudPageListAdapter = ETPushCordovaApplication.cloudPageListAdapter;

  	JSONObject json = new JSONObject();

		try {
	  	json.put("count", cloudPageListAdapter.getCount());

	  	int unread = 0;
			JSONArray messages = new JSONArray();
	  	for (int i=0; i < cloudPageListAdapter.getCount(); i++) {
	  		Message message = (Message) cloudPageListAdapter.getItem(i);

	  		if (!message.getRead()) unread++;

	  		JSONObject jsonMsg = new JSONObject();
	  		jsonMsg.put("id", message.getId());
	  		jsonMsg.put("isRead", message.getRead());
	  		jsonMsg.put("subject", message.getSubject());
	  		jsonMsg.put("webPageUrl", message.getUrl());
			  messages.put(jsonMsg);
			}
			json.put("unread", unread);
	  	json.put("messages", messages);
	  	return json;
  	} catch (JSONException e) {
    	Log.e(TAG, e.getMessage(), e);      	 
  	}

  	return null;
  }
}