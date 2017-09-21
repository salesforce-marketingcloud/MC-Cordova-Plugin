package com.salesforce.marketingcloud.cordovaplugin;

import android.text.TextUtils;
import android.support.v4.util.ArraySet;
import android.util.Log;

import com.salesforce.marketingcloud.MCLogListener.AndroidLogListener;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.MCLogListener;
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
import java.util.Set;

@SuppressWarnings("ConstantConditions")
public class MCCordovaPlugin extends CordovaPlugin {
    private static final String TAG = "~#MCSdkCordovaPlugin";
    private static final String ACTION_GET_SYSTEM_TOKEN = "getSystemToken";
    private static final String ACTION_ENABLE_PUSH = "enablePush";
    private static final String ACTION_DISABLE_PUSH = "disablePush";
    private static final String ACTION_IS_PUSH_ENABLED = "isPushEnabled";
    private static final String ACTION_SET_ATTRIBUTE = "setAttribute";
    private static final String ACTION_CLEAR_ATTRIBUTE = "clearAttribute";
    private static final String ACTION_GET_ATTRIBUTES = "getAttributes";
    private static final String ACTION_SET_CONTACTKEY = "setContactKey";
    private static final String ACTION_GET_CONTACTKEY = "getContactKey";
    private static final String ACTION_ADD_TAG = "addTag";
    private static final String ACTION_REMOVE_TAG = "removeTag";
    private static final String ACTION_GET_TAGS = "getTags";
    private static final String ACTION_ENABLE_VERBOSE_LOGGING = "enableVerboseLogging";
    private static final String ACTION_DISABLE_VERBOSE_LOGGING = "disableVerboseLogging";

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
            case ACTION_SET_CONTACTKEY:
                return handleSetContactKey(callbackContext, args);
            case ACTION_GET_CONTACTKEY:
                return handleGetContactKey(callbackContext);
            case ACTION_ADD_TAG:
                return handleAddTag(callbackContext, args);
            case ACTION_REMOVE_TAG:
                return handleRemoveTag(callbackContext, args);
            case ACTION_GET_TAGS:
                return handleGetTags(callbackContext);
            case ACTION_ENABLE_VERBOSE_LOGGING:
                return handleEnableVerboseLogging(callbackContext);
            case ACTION_DISABLE_VERBOSE_LOGGING:
                return handleDisableVerboseLogging(callbackContext);
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

    private boolean handleSetAttribute(final CallbackContext callbackContext, final JSONArray args) throws JSONException {
        // Ensure args are valid
        if (args == null || args.length() < 2) {
            return caughtException(callbackContext, "Attribute arguments may not be null and must contain at least 2 values.");
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
            return caughtException(callbackContext, "Attribute arguments may not be null and must contain a value."); //TODO
        }

        final String key = args.optString(0);
        if (TextUtils.isEmpty(key.trim())) {
            return caughtException(callbackContext, "Attribute must have a valid key.");
        }

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

    private boolean handleSetContactKey(final CallbackContext callbackContext, JSONArray args) throws JSONException {
        if (args == null || args.length() < 1) {
            return caughtException(callbackContext, "ContactKey arguments may not be null and must contain a value.");
        }

        final String contactKey = args.optString(0);
        if (TextUtils.isEmpty(contactKey.trim())) {
            return caughtException(callbackContext, "ContactKey must not be null or empty.");
        }
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    marketingCloudSdk.getRegistrationManager().edit()
                            .setContactKey(contactKey.trim())
                            .commit();
                    callbackContext.success();
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleGetContactKey(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, marketingCloudSdk.getRegistrationManager().getContactKey()));
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleAddTag(final CallbackContext callbackContext, final JSONArray args) throws JSONException {
        // Ensure args are valid
        if (args == null || args.length() < 1) {
            return caughtException(callbackContext, "Tag argument may not be null and must contain a value.");
        }

        final String tag = args.optString(0);
        if (TextUtils.isEmpty(tag.trim())) {
            return caughtException(callbackContext, "Tag must not be null or empty.");
        }
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    marketingCloudSdk.getRegistrationManager().edit()
                            .addTags(tag.trim())
                            .commit();
                    callbackContext.success();
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleRemoveTag(final CallbackContext callbackContext, JSONArray args) throws JSONException {
        if (args == null || args.length() < 1) {
            return caughtException(callbackContext, "Tag argument may not be null and must contain a value."); //TODO
        }

        final String tag = args.optString(0);
        if (TextUtils.isEmpty(tag.trim())) {
            return caughtException(callbackContext, "Tag must not be null or empty.");
        }

        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    marketingCloudSdk.getRegistrationManager().edit()
                            .removeTags(tag)
                            .commit();
                    callbackContext.success();
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleGetTags(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    RegistrationManager registrationManager = marketingCloudSdk.getRegistrationManager();
                    final Set<String> tags = new ArraySet<>(registrationManager.getTags());
                    final JSONArray tagArray = new JSONArray();
                    if (!tags.isEmpty()) {
                        for (String tag : tags) {
                            if (!TextUtils.isEmpty(tag)) {
                                tagArray.put(tag);
                            }
                        }
                    }
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, tagArray));
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleEnableVerboseLogging(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                      MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE);
                      MarketingCloudSdk.setLogListener(new AndroidLogListener());
                      callbackContext.success();
                }
            });
        } catch (Exception e) {
            return caughtException(callbackContext, e);
        }
        return true;
    }

    private boolean handleDisableVerboseLogging(final CallbackContext callbackContext) {
        try {
            MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
                @Override
                public void ready(MarketingCloudSdk marketingCloudSdk) {
                    MarketingCloudSdk.setLogListener(null);
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
