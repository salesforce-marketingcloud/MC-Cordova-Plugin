package com.salesforce.cordova.dev;

import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;

import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.registration.Attribute;
import com.salesforce.marketingcloud.registration.RegistrationManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@SuppressWarnings("ConstantConditions")
public class MarketingCloudSdkCordovaPlugin extends CordovaPlugin {
    private static final String TAG = "~#MCSdkCordovaPlugin";
    private static final String ACTION_GET_SYSTEM_TOKEN = "getSystemToken";
    private static final String ACTION_ENABLE_PUSH = "enablePush";
    private static final String ACTION_DISABLE_PUSH = "disablePush";
    private static final String ACTION_IS_PUSH_ENABLED = "isPushEnabled";
    private static final String ACTION_SET_ATTRIBUTE = "setAttribute";
    private static final String ACTION_CLEAR_ATTRIBUTE = "clearAttribute";
    private static final String ACTION_GET_ATTRIBUTES = "getAttributes";

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
            case ACTION_SET_ATTRIBUTE:
                return handleSetAttribute(callbackContext, args);
            case ACTION_CLEAR_ATTRIBUTE:
                return handleClearAttribute(callbackContext, args);
            case ACTION_GET_ATTRIBUTES:
                return handleGetAttributes(callbackContext);
            default:
                callbackContext.error("Invalid action");
                return false;
        }
    }

    private boolean handleIsPushEnabled(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, marketingCloudSdk.getPushMessageManager().isPushEnabled()));
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleDisablePush(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    marketingCloudSdk.getPushMessageManager().disablePush();
                    callbackContext.success(); // TODO sendPluginResult w/isPushEnabled like handleIsPushEnabled() and update UI
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleEnablePush(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    marketingCloudSdk.getPushMessageManager().enablePush();
                    callbackContext.success(); // TODO sendPluginResult w/isPushEnabled like handleIsPushEnabled() and update UI
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleGetSystemToken(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, marketingCloudSdk.getRegistrationManager().getSystemToken()));
                }
            });
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
        return true;
    }

    private boolean handleSetAttribute(final CallbackContext callbackContext, @NonNull final JSONArray args) throws JSONException {
        // Ensure args are valid
        if (args == null || args.length() < 2) {
            return caughtException(callbackContext, "handleSetAttribute arguments may not be null and must contain at least 2 values.");
        }

        final String key = args.optString(0);
        final String value = args.optString(1);
        if (TextUtils.isEmpty(key) || value == null) {
            return caughtException(callbackContext, "Attribute must have a valid key and value pair.");
        }

        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    marketingCloudSdk.getRegistrationManager().edit().setAttribute(key, value).commit();
                    callbackContext.success();
                }
            });
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
        return true;
    }

    private boolean handleClearAttribute(final CallbackContext callbackContext, JSONArray args) throws JSONException {
        if (args == null || args.length() < 1) {
            return caughtException(callbackContext, "fix me"); //TODO
        }

        final String key = args.optString(0);
        if (TextUtils.isEmpty(key)) {
            return caughtException(callbackContext, "Attribute must have a valid key.");
        }

        if (key != null && !key.isEmpty()) {
            try {
                MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                    @Override
                    public void ready(MarketingCloudSdk marketingCloudSdk) {
                        marketingCloudSdk.getRegistrationManager().edit()
                                .clearAttributes(key)
                                .commit();
                        callbackContext.success();
                    }
                });
            } catch (Exception e) {
                return caughtException(callbackContext, e);
            }
        }
        return true;
    }

    private boolean handleGetAttributes(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    RegistrationManager registrationManager = marketingCloudSdk.getRegistrationManager();
                    final List<Attribute> attributes = new ArrayList<>(registrationManager.getAttributes());
                    final JSONObject attributeObject = new JSONObject();
                    if (!attributes.isEmpty()) {
                        for (Attribute attribute : attributes) {
                            if (attribute != null && !TextUtils.isEmpty(attribute.key())) {
                                try {
                                    attributeObject.put(attribute.key(), attribute.value());
                                } catch (JSONException e) {
                                    Log.e(TAG, String.format(Locale.ENGLISH, "Failed to get attribute: %s", attribute.key()));
                                }
                            }
                        }
                    }
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, attributeObject));
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }


    private boolean caughtException(final CallbackContext callbackContext, final String e) {
        callbackContext.error(e);
        return false;
    }

    private boolean caughtException(final CallbackContext callbackContext, final Exception e) {
        return caughtException(callbackContext, e.getMessage());
    }
}