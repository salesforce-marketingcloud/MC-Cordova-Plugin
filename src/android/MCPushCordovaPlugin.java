package com.salesforce.mcpush;
import android.support.v4.app.NotificationManagerCompat;
import android.util.Log;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import java.util.Locale;

public class MCPushCordovaPlugin extends CordovaPlugin {
    private static final String TAG = "~#MCPushCordovaPlugin";
    private static final String ACTION_GET_SDK_VERSION_NAME = "getSdkVersionName";
    private static final String ACTION_GET_SYSTEM_TOKEN = "getSystemToken";
    private static final String ACTION_ENABLE_PUSH = "enablePush";
    private static final String ACTION_DISABLE_PUSH = "disablePush";
    private static final String ACTION_IS_PUSH_ENABLED = "isPushEnabled";
    private static final String ACTION_IS_NOTIFICATION_ENABLED = "isNotificationEnabled";
    private static final String ACTION_SET_NOTIFICATION_HANDLER = "setNotificationHandler";
    private static CallbackContext notificationCallback;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.v(TAG, String.format(Locale.ENGLISH, "EXECUTING ACTION: %s", action));
        switch (action) {
            case ACTION_GET_SDK_VERSION_NAME:
                return handleGetSdkVersionName(callbackContext);
            case ACTION_GET_SYSTEM_TOKEN:
                return handleGetSystemToken(callbackContext);
            case ACTION_IS_NOTIFICATION_ENABLED:
                return handleIsNotificationEnabled(callbackContext);
            case ACTION_ENABLE_PUSH:
                return handleEnablePush(callbackContext);
            case ACTION_DISABLE_PUSH:
                return handleDisablePush(callbackContext);
            case ACTION_IS_PUSH_ENABLED:
                return handleIsPushEnabled(callbackContext);
            case ACTION_SET_NOTIFICATION_HANDLER:
                return handleSetNotificationHandler(callbackContext);
            default:
                callbackContext.error("Invalid action");
                return false;
        }
    }

    private boolean handleSetNotificationHandler(CallbackContext callbackContext) {
        if (notificationCallback != null) {
            callbackContext.error("Notification handler already running.");
            return true;
        }
        notificationCallback = callbackContext;
        Log.d(TAG, "EXECUTING ACTION_SET_NOTIFICATION_HANDLER");
        // Don't return any result now, since status results will be sent when events come in from broadcast receiver
        PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
        return true;
    }

    private boolean handleIsPushEnabled(CallbackContext callbackContext) {
        Boolean isPushEnabled;
        try {
            isPushEnabled = MarketingCloudSdk.getInstance().getPushMessageManager().isPushEnabled();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, isPushEnabled));
        return true;
    }

    private boolean handleDisablePush(CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.getInstance().getPushMessageManager().disablePush();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        callbackContext.success();
        return true;
    }

    private boolean handleEnablePush(CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.getInstance().getPushMessageManager().enablePush();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        callbackContext.success();
        return true;
    }

    private boolean handleIsNotificationEnabled(CallbackContext callbackContext) {
        boolean notificationStatus;
        try {
            notificationStatus = NotificationManagerCompat.from(MCPushCordovaApplication.getAppContext()).areNotificationsEnabled();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, notificationStatus));
        return true;
    }

    private boolean handleGetSystemToken(CallbackContext callbackContext) {
        String systemToken;
        try {
            systemToken = MarketingCloudSdk.getInstance().getRegistrationManager().getSystemToken();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, systemToken));
        return true;
    }

    private boolean handleGetSdkVersionName(CallbackContext callbackContext) {
        String versionName;
        try {
            versionName = MarketingCloudSdk.getSdkVersionName();
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, versionName));
        return true;
    }

    private boolean caughtException(CallbackContext callbackContext, Exception e) {
        Log.e(TAG, e.getMessage(), e);
        callbackContext.error(e.getMessage());
        return false;
    }
}