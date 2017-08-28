package com.salesforce.marketingcloudsdk;
import android.support.v4.app.NotificationManagerCompat;
import android.util.Log;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import java.util.Locale;

public class MarketingCloudSdkCordovaPlugin extends CordovaPlugin {
    private static final String TAG = "~#MCSdkCordovaPlugin";
    private static final String ACTION_GET_SYSTEM_TOKEN = "getSystemToken";
    private static final String ACTION_ENABLE_PUSH = "enablePush";
    private static final String ACTION_DISABLE_PUSH = "disablePush";
    private static final String ACTION_IS_PUSH_ENABLED = "isPushEnabled";
    private static CallbackContext notificationCallback;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.v(TAG, String.format(Locale.ENGLISH, "EXECUTING ACTION: %s", action));

        switch (action) {
            case ACTION_GET_SYSTEM_TOKEN:
                return handleGetSystemToken(callbackContext);
            case ACTION_ENABLE_PUSH:
                return handleEnablePush(callbackContext);
            case ACTION_DISABLE_PUSH:
                return handleDisablePush(callbackContext);
            case ACTION_IS_PUSH_ENABLED:
                return handleIsPushEnabled(callbackContext);
            default:
                callbackContext.error("Invalid action");
                return false;
        }
    }

    private boolean handleIsPushEnabled(final CallbackContext callbackContext) {
        final Boolean isPushEnabled;
        try {
            isPushEnabled = MarketingCloudSdk.getInstance().getPushMessageManager().isPushEnabled();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isPushEnabled));
            }
        });
        return true;
    }

    private boolean handleDisablePush(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.getInstance().getPushMessageManager().disablePush();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                callbackContext.success();
            }
        });
        return true;
    }

    private boolean handleEnablePush(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.getInstance().getPushMessageManager().enablePush();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                callbackContext.success();
            }
        });
        return true;
    }

    private boolean handleGetSystemToken(final CallbackContext callbackContext) {
        final String systemToken;
        try {
            systemToken = MarketingCloudSdk.getInstance().getRegistrationManager().getSystemToken();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, systemToken));
            }
        });
        return true;
    }

    private boolean caughtException(final CallbackContext callbackContext, final Exception e) {
        Log.e(TAG, e.getMessage(), e);
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                callbackContext.error(e.getMessage());
            }
        });
        return false;
    }
}