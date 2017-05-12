package com.salesforce.etpush;

import android.app.Application;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.content.pm.ApplicationInfo;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.preference.PreferenceManager;
import android.content.SharedPreferences;
import java.util.LinkedHashSet;
import org.json.JSONObject;
import java.util.Set;
import android.os.Bundle;
import org.json.JSONException;
import android.support.v4.app.NotificationManagerCompat;

import com.exacttarget.etpushsdk.ETException;
import com.exacttarget.etpushsdk.ETLogListener;
import com.exacttarget.etpushsdk.ETPush;
import com.exacttarget.etpushsdk.ETPushConfig;
import com.exacttarget.etpushsdk.ETPushConfigureSdkListener;
import com.exacttarget.etpushsdk.ETRequestStatus;
import com.exacttarget.etpushsdk.data.Attribute;
import com.exacttarget.etpushsdk.event.*;
import com.exacttarget.etpushsdk.util.EventBus;
import com.exacttarget.etpushsdk.adapter.CloudPageListAdapter;
import com.exacttarget.etpushsdk.ETNotifications;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;



public class ETPushCordovaApplication extends Application implements ETLogListener, ETPushConfigureSdkListener {

	private static final String TAG = CONSTS.LOG_TAG;

	public static CDVCloudPageListAdapter cloudPageListAdapter;
	public static boolean isNotificationEnabledStatus;
	private static final LinkedHashSet<EtPushListener> listeners = new LinkedHashSet<>();
	private static ETPush etPush;
	private String devEtAppId, devAccessToken, devGcmSenderId, prodEtAppId, prodAccessToken, prodGcmSenderId;
	private Boolean analyticsEnabled, piAnalyticsEnabled, locationEnabled, proximityEnabled, cloudPagesEnabled, overrideNotifications;
	private static Context context;



	/**
	 * If ETPush is null then hold on to a reference of the listener so we can notify them when push
	 * is ready.
	 *
	 * @param etPushListener our object that cares about ETPush
	 * @return ETPush or null
	 */
	public static ETPush getEtPush(@NonNull final EtPushListener etPushListener) {
		if (etPush == null) {
			listeners.add(etPushListener);
		}
		return etPush;
	}

	/**
	 * The onCreate() method initialize your app.
	 * <p/>
	 * It registers the application to listen for events posted to a private communication bus
	 * by the SDK and calls `ETPush.readyAimFire` to configures the SDK to point to the correct code
	 * application and to initialize the ETPush, according to the constants defined before.
	 * <p/>
	 * When ReadyAimFire() is called for the first time for a device, it will get a device token
	 * from Google and send to the MarketingCloud.
	 * <p/>
	 * In ETPush.readyAimFire() you must set several parameters:
	 * <ul>
	 * <li>
	 * AppId and AccessToken: these values are taken from the Marketing Cloud definition for your app.
	 * </li>
	 * <li>
	 * GcmSenderId for the push notifications: this value is taken from the Google API console.
	 * </li>
	 * <li>
	 * You also set whether you enable LocationManager, CloudPages, and Analytics.
	 * </li>
	 * </ul>
	 * <p/>
	 * <p/>
	 * The application keys are stored in a separate file (secrets.xml) in order to provide
	 * centralized access to these keys and to ensure you use the appropriate keys when
	 * compiling the test and production versions.
	 **/
	@Override
	public void onCreate() {
		super.onCreate();
		ETPushCordovaApplication.context = getApplicationContext();

		/**
		 * Register the application to listen for events posted to a private communication bus
		 * by the SDK.
		 */
		EventBus.getInstance().register(this);

		


		ETPushConfig pushConfig = null;
		try {

			//Get ETSDK configuration from secrets.xml resource
			devEtAppId = this.getResources().getString(this.getResources().getIdentifier("ETPUSH_DEV_APPID", "string", this.getPackageName()));
			if (devEtAppId == null || devEtAppId.isEmpty()) throw new RuntimeException("Unable to find ETPUSH_DEV_APPID in secrets.xml");
			devAccessToken = this.getResources().getString(this.getResources().getIdentifier("ETPUSH_DEV_ACCESSTOKEN", "string", this.getPackageName()));
			if (devAccessToken == null || devAccessToken.isEmpty()) throw new RuntimeException("Unable to find ETPUSH_DEV_ACCESSTOKEN in secrets.xml");
			devGcmSenderId = this.getResources().getString(this.getResources().getIdentifier("ETPUSH_DEV_GCMSENDERID", "string", this.getPackageName()));
			if (devGcmSenderId == null || devGcmSenderId.isEmpty()) throw new RuntimeException("Unable to find ETPUSH_DEV_GCMSENDERID in secrets.xml");
			prodEtAppId = this.getResources().getString(this.getResources().getIdentifier("ETPUSH_PROD_APPID", "string", this.getPackageName()));
			if (prodEtAppId == null || prodEtAppId.isEmpty()) throw new RuntimeException("Unable to find ETPUSH_PROD_APPID in secrets.xml");
			prodAccessToken = this.getResources().getString(this.getResources().getIdentifier("ETPUSH_PROD_ACCESSTOKEN", "string", this.getPackageName()));
			if (prodAccessToken == null || prodAccessToken.isEmpty()) throw new RuntimeException("Unable to find ETPUSH_PROD_ACCESSTOKEN in secrets.xml");
			prodGcmSenderId = this.getResources().getString(this.getResources().getIdentifier("ETPUSH_PROD_GCMSENDERID", "string", this.getPackageName()));
			if (prodGcmSenderId == null || prodGcmSenderId.isEmpty()) throw new RuntimeException("Unable to find ETPUSH_PROD_GCMSENDERID in secrets.xml");
			analyticsEnabled = this.getResources().getBoolean(this.getResources().getIdentifier("ETPUSH_ANALYTICS_ENABLED", "bool", this.getPackageName()));
			if (analyticsEnabled == null) throw new RuntimeException("Unable to find ETPUSH_ANALYTICS_ENABLED in secrets.xml");
			piAnalyticsEnabled = this.getResources().getBoolean(this.getResources().getIdentifier("ETPUSH_WAMA_ENABLED", "bool", this.getPackageName()));
			if (piAnalyticsEnabled == null) throw new RuntimeException("Unable to find ETPUSH_WAMA_ENABLED in secrets.xml");
			locationEnabled = this.getResources().getBoolean(this.getResources().getIdentifier("ETPUSH_LOCATION_ENABLED", "bool", this.getPackageName()));
			if (locationEnabled == null) throw new RuntimeException("Unable to find ETPUSH_LOCATION_ENABLED in secrets.xml");
			proximityEnabled = this.getResources().getBoolean(this.getResources().getIdentifier("ETPUSH_PROXIMITY_ENABLED", "bool", this.getPackageName()));
			if (proximityEnabled == null) throw new RuntimeException("Unable to find ETPUSH_PROXIMITY_ENABLED in secrets.xml");
			cloudPagesEnabled = this.getResources().getBoolean(this.getResources().getIdentifier("ETPUSH_CLOUDPAGES_ENABLED", "bool", this.getPackageName()));
			if (cloudPagesEnabled == null) throw new RuntimeException("Unable to find ETPUSH_CLOUDPAGES_ENABLED in secrets.xml");
			overrideNotifications = this.getResources().getBoolean(this.getResources().getIdentifier("ETPUSH_OVERRIDE_NTFN_ENABLED", "bool", this.getPackageName()));
			if (overrideNotifications == null) throw new RuntimeException("Unable to find ETPUSH_OVERRIDE_NTFN_ENABLED in secrets.xml");



			String etAppId;
			String accessToken;
			String gcmSenderId;
			boolean isDebuggable = (0 != (this.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE));
			if (isDebuggable) {
				ETPush.setLogLevel(Log.DEBUG);
				etAppId = devEtAppId;
				accessToken = devAccessToken;
				gcmSenderId = devGcmSenderId;
			} else {
				etAppId = prodEtAppId;
				accessToken = prodAccessToken;
				gcmSenderId = prodGcmSenderId;
			}

			//Build ETPushConfig with Options
			pushConfig = new ETPushConfig.Builder(this)
			.setEtAppId(etAppId)
			.setAccessToken(accessToken)
			.setGcmSenderId(gcmSenderId)
			.setAnalyticsEnabled(analyticsEnabled)
			.setPiAnalyticsEnabled(piAnalyticsEnabled)
			.setLocationEnabled(locationEnabled)
			.setProximityEnabled(proximityEnabled)
			.setCloudPagesEnabled(cloudPagesEnabled)
			.setLogLevel(Log.DEBUG)
			.build();

			//isNotificationEnabledStatus = NotificationManagerCompat.from(this).areNotificationsEnabled();

		} catch (Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}

		try {
			//Init ETSDK with ETPush.readyAimFire
			if (pushConfig != null) {
				ETPush.configureSdk(pushConfig, this);
			} else {
				Log.e(TAG, "ETPushConfig is null");
			}
		} catch (ETException e) {
			Log.e(TAG, e.getMessage(), e);
		}

		cloudPageListAdapter = new CDVCloudPageListAdapter(getApplicationContext());
	}

	/**
	 * Called when configureSdk() has successfully completed.
	 * <p/>
	 * When the readyAimFire() initialization is completed, start watching at beacon messages.
	 *
	 * @param etPush          a ready-to-use instance of ETPush.
	 * @param etRequestStatus an additional status field regarding SDK readiness.
	 */
	@Override
	public void onETPushConfigurationSuccess(final ETPush etPush, final ETRequestStatus etRequestStatus) {
		ETPushCordovaApplication.etPush = etPush;

		// If there was an user recoverable issue with Google Play Services then show a notification to the user
		int googlePlayServicesStatus = etRequestStatus.getGooglePlayServiceStatusCode();
		if (googlePlayServicesStatus != ConnectionResult.SUCCESS && GoogleApiAvailability.getInstance().isUserResolvableError(googlePlayServicesStatus)) {
			GoogleApiAvailability.getInstance().showErrorNotification(this, googlePlayServicesStatus);
		}

		//Overriding default notification handler if set to true
		if(overrideNotifications)
			ETNotifications.setNotificationBuilder(new ETNotificationsCordova());

		String sdkState;
		try {
			sdkState = ETPush.getInstance().getSDKState();
		} catch (ETException e) {
			sdkState = e.getMessage();
		}
		Log.v(TAG, sdkState); // Write the current SDK State to the Logs.

		if (!listeners.isEmpty()) { // Tell our listeners that the SDK is ready for use
			for (EtPushListener listener : listeners) {
				if (listener != null) {
					listener.onReadyForPush(etPush);
				}
			}
			listeners.clear();
		}
	}

	/**
	   * Called when the SDK failed to initialized.
	   *
	   * @param etException an exception containing the reason/message regarding the failure.
	   */
	@Override
	public void onETPushConfigurationFailed(ETException etException) {
		Log.e(TAG, etException.getMessage(), etException);
	}

	/**
	 * Listens for a RegistrationEvent on EventBus callback.
	 * <p/>
	 * This method is one of several methods to log notifications when an event occurs in the SDK.
	 * Different attributes indicate which event has occurred.
	 * <p/>
	 * RegistrationEvent will be triggered when the SDK receives the response from the
	 * registration as triggered by the com.google.android.c2dm.intent.REGISTRATION intent.
	 * <p/>
	 * These events are only called if EventBus.getInstance().register() is called.
	 * <p/>
	 *
	 * @param event contains attributes which identify the type of event and are logged.
	 */
	@SuppressWarnings({"unused", "unchecked"})
	public void onEvent(final RegistrationEvent event) {
		if (ETPush.getLogLevel() <= Log.DEBUG) {
			Log.d(TAG, "Marketing Cloud update occurred.");
			Log.d(TAG, "Device ID:" + event.getDeviceId());
			Log.d(TAG, "Device Token:" + event.getSystemToken());
			Log.d(TAG, "Subscriber key:" + event.getSubscriberKey());
			for (Object attribute : event.getAttributes()) {
				Log.d(TAG, "Attribute " + ((Attribute) attribute).getKey() + ": [" + ((Attribute) attribute).getValue() + "]");
			}
			Log.d(TAG, "Tags: " + event.getTags());
			Log.d(TAG, "Language: " + event.getLocale());
			Log.d(TAG, String.format("Last sent: %1$d", System.currentTimeMillis()));
		}
	}

	@SuppressWarnings({"unused", "unchecked"})
	public void onEvent(final PushReceivedEvent event) {
		if (ETPush.getLogLevel() <= Log.DEBUG) {
			Log.d(TAG, "Marketing Cloud push received.");
			Log.d(TAG, "Payload:" + event.getPayload());
			
		}
		Bundle bundle = event.getPayload();
		JSONObject json = new JSONObject();
		Set<String> keys = bundle.keySet();
		for (String key : keys) {
    		try {
        		// json.put(key, bundle.get(key)); see edit below
        		json.put(key, JSONObject.wrap(bundle.get(key)));
    		} catch(JSONException e) {
        //Handle exception here
    			Log.d(TAG, "JSONException:" + e.getMessage());
    		}
		}
		//Set the json into the SharedPreference
	  	SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(ETPushCordovaApplication.getAppContext());
      	SharedPreferences.Editor spEditor = sp.edit();
      	spEditor.putString(CONSTS.KEY_MC_PAYLOAD, json.toString());
      	spEditor.commit();

		ETPushCordovaPlugin.notificationReceived(json);
	}

	@Override
	public void out(int severity, String tag, String message, @Nullable Throwable throwable) {
		/*
		 * Using this method you can interact with SDK log output.
		 * Severity is populated with log levels like Log.VERBOSE, Log.INFO etc.
		 * Message, is populated with the actual log output text.
		 * Tag, is a free form string representing the log tag you've selected.
		 * Finally, the optional Throwable Throwable represents a thrown exception.
		 */

		/*
		 * Assuming you have crashytics enabled for your app, the following code would send
		 * log data to Crashytics in the event that the log's severity is ERROR or ASSERT
		 */

		if (throwable != null) {
			// We have an exception to log:
			// Commenting out all references to Crashlytics.
			// Crashlytics.logException(throwable);
		}

		switch (severity) {
		case Log.ERROR:
			Log.e(tag, message);
			// Crashlytics.log(severity, tag, message);
			break;
		case Log.ASSERT:
			Log.wtf(tag, message);
			// Crashlytics.log(severity, tag, message);
			try {
				// If we're logging a failed ASSERT, also grab the getSDKState() data and log that as well
				Log.v("SDKState Information", ETPush.getInstance().getSDKState());
				// Crashlytics.log(ETPush.getInstance().getSDKState());
			} catch (ETException etException) {
				Log.v("ErrorGettingSDKState", etException.getMessage());
				// Crashlytics.log(String.format(Locale.ENGLISH, "Error Getting SDK State: %s", etException.getMessage()));
			}
			break;
		default:
			Log.v(tag, message);
		}
	}

	/*
	 * Public interface for the main activity to implement
	 */
	public interface EtPushListener {
		void onReadyForPush(ETPush etPush);
	}

	/**
	 * Instantiate this class to get a handle on the CloudPageListAdapter
	 */
	private class CDVCloudPageListAdapter extends CloudPageListAdapter {
		public CDVCloudPageListAdapter(Context appContext) {
			super(appContext);
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			return null;
		}
	}

	public static Context getAppContext() {
        return ETPushCordovaApplication.context;
    }
}