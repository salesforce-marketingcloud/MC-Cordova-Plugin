package com.salesforce.mcpush;

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

import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.registration.Registration;
import com.salesforce.marketingcloud.registration.RegistrationManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;

import java.util.Locale;

public class MCPushCordovaApplication extends Application implements MCLogListener,RegistrationManager.RegistrationEventListener {

	private static final String TAG = CONSTS.LOG_TAG;

	public static boolean isNotificationEnabledStatus;
	private String devEtAppId, devAccessToken, devGcmSenderId, prodEtAppId, prodAccessToken, prodGcmSenderId;
	private Boolean analyticsEnabled, piAnalyticsEnabled, locationEnabled, proximityEnabled, cloudPagesEnabled, overrideNotifications;
	private static Context context;

	/**
	 * The onCreate() method initialize your app.
	 * <p/>
	 * It registers the application to listen for events posted to a private communication bus
	 * by the SDK and calls `MCPush.readyAimFire` to configures the SDK to point to the correct code
	 * application and to initialize the MCPush, according to the constants defined before.
	 * <p/>
	 * When ReadyAimFire() is called for the first time for a device, it will get a device token
	 * from Google and send to the MarketingCloud.
	 * <p/>
	 * In MCPush.readyAimFire() you must set several parameters:
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
		MCPushCordovaApplication.context = getApplicationContext();

		/**
		 * Register the application to listen for events posted to a private communication bus
		 * by the SDK.
		 */

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
				//MCPush.setLogLevel(Log.DEBUG);
				etAppId = devEtAppId;
				accessToken = devAccessToken;
				gcmSenderId = devGcmSenderId;
			} else {
				etAppId = prodEtAppId;
				accessToken = prodAccessToken;
				gcmSenderId = prodGcmSenderId;
			}

			MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE);
			MarketingCloudSdk.setLogListener(new MCLogListener.AndroidLogListener());
			//if (pushConfig != null) {
				MarketingCloudSdk.init(this, MarketingCloudConfig.builder()
		        .setApplicationId(etAppId)
		        .setAccessToken(accessToken)
		        .setGcmSenderId(gcmSenderId)
		        //Enable any other feature desired.
		        .build(), new MarketingCloudSdk.InitializationListener() {
			      @Override public void complete(InitializationStatus status) {
			        if (status.isUsable()) {
			          if (status.status() == InitializationStatus.Status.COMPLETED_WITH_DEGRADED_FUNCTIONALITY) {
			            // While the SDK is usable, something happened during init that you should address.
			            // This could include:
			            if (status.locationsError()) {
			                final GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
			                Log.i(TAG, String.format(Locale.ENGLISH, "Google Play Services Availability: %s", googleApiAvailability.getErrorString(status.locationPlayServicesStatus())));
			                if (googleApiAvailability.isUserResolvableError(status.locationPlayServicesStatus())) {
			                    googleApiAvailability.showErrorNotification(MCPushCordovaApplication.this, status.locationPlayServicesStatus());
			                }
			            }
			          }
			        } else {
			          //Something went wrong with init that makes the SDK unusable.

			        }

					MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
						@Override
						public void ready(MarketingCloudSdk sdk) {
						  sdk.getRegistrationManager().registerForRegistrationEvents(MCPushCordovaApplication.this);
						}
					});
			      }
			    });
			/*} else {
				Log.e(TAG, "MCPushConfig is null");
			}*/
		} catch (Exception e) {
			Log.e(TAG, e.getMessage(), e);
		}

		//cloudPageListAdapter = new CDVCloudPageListAdapter(getApplicationContext());
	}

	/**
	 * Listens for Registrations
	 * <p/>
	 * This method is one of several methods to log notifications when an event occurs in the SDK.
	 * Different attributes indicate which event has occurred.
	 * <p/>
	 * RegistrationEvent will be triggered when the SDK receives the response from the
	 * registration as triggered by the com.google.android.c2dm.intent.REGISTRATION intent.
	 */
	@Override
	public void onRegistrationReceived(@NonNull Registration registration) {
		MarketingCloudSdk.getInstance().getAnalyticsManager().trackPageView("data://RegistrationEvent", "Registration Event Completed");
		if (MarketingCloudSdk.getLogLevel() <= Log.DEBUG) {
			Log.d(TAG, "Marketing Cloud update occurred.");
			Log.d(TAG, "Device ID:" + registration.deviceId());
			Log.d(TAG, "Device Token:" + registration.systemToken());
			Log.d(TAG, "Language: " + registration.locale());
			Log.d(TAG, String.format("Last sent: %1$d", System.currentTimeMillis()));
		}
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
				/*MarketingCloudSdk cloudSdk = MarketingCloudSdk.getInstance();
				Log.v("SDKState Information", cloudSdk.getSdkState());*/
				// Crashlytics.log(MCPush.getInstance().getSDKState());
			} catch (Exception e) {
				//Log.v("ErrorGettingSDKState", etException.getMessage());
				// Crashlytics.log(String.format(Locale.ENGLISH, "Error Getting SDK State: %s", etException.getMessage()));
			}
			break;
		default:
			Log.v(tag, message);
		}
	}

	public static Context getAppContext() {
        return MCPushCordovaApplication.context;
    }
}