/**
 * Copyright 2018 Salesforce, Inc
 * <p>
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 * <p>
 * 1. Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 * <p>
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 * <p>
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific prior written permission.
 * <p>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.salesforce.marketingcloud.cordova;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.UrlHandler;
import com.salesforce.marketingcloud.events.EventManager;
import com.salesforce.marketingcloud.notifications.NotificationManager;
import com.salesforce.marketingcloud.notifications.NotificationMessage;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdk;
import com.salesforce.marketingcloud.sfmcsdk.components.logging.LogLevel;
import com.salesforce.marketingcloud.sfmcsdk.components.logging.LogListener;
import com.salesforce.marketingcloud.sfmcsdk.components.identity.Identity;
import com.salesforce.marketingcloud.sfmcsdk.modules.push.PushModuleInterface;
import com.salesforce.marketingcloud.sfmcsdk.modules.push.PushModuleReadyListener;
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkReadyListener;
import com.salesforce.marketingcloud.cordova.EventUtility;

public class MCCordovaPlugin extends CordovaPlugin implements UrlHandler {
    static final String TAG = "~!MCCordova";
    private static final String EXTRA_MESSAGE =
        "com.salesforce.marketingcloud.notifications.EXTRA_MESSAGE";
    private CallbackContext eventsChannel = null;
    private PluginResult cachedNotificationOpenedResult = null;
    private boolean notificationOpenedSubscribed = false;

    @Nullable
    @Override
    public PendingIntent handleUrl(
        @NonNull Context context, @NonNull String url, @NonNull String urlType) {
        if (eventsChannel != null) {
            try {
                JSONObject eventArgs = new JSONObject();
                eventArgs.put("type", "urlAction");
                eventArgs.put("url", url);
                PluginResult result = new PluginResult(PluginResult.Status.OK, eventArgs);
                result.setKeepCallback(true);

                eventsChannel.sendPluginResult(result);
            } catch (Exception e) {
                // NO_OP
            }
        }
        return null;
    }

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        MCSdkListener.INSTANCE.urlHandler = this;

        Intent intent = cordova.getActivity().getIntent();
        if (intent != null && intent.hasExtra(EXTRA_MESSAGE)) {
            handleNotificationMessage(NotificationManager.extractMessage(intent));
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        if (intent != null && intent.hasExtra(EXTRA_MESSAGE)) {
            handleNotificationMessage(NotificationManager.extractMessage(intent));
        }
    }

    private void handleNotificationMessage(@Nullable NotificationMessage message) {
        if (message != null) {
            // Open from push
            PluginResult result;

            try {
                JSONObject eventArgs = new JSONObject();
                eventArgs.put("timeStamp", System.currentTimeMillis());
                JSONObject values = new JSONObject(message.payload());
                if (message.url() != null) {
                    values.put("url", message.url());
                }
                switch (message.type()) {
                    case OTHER:
                        values.put("type", "other");
                        break;
                    case CLOUD_PAGE:
                        values.put("type", "cloudPage");
                        break;
                    case OPEN_DIRECT:
                        values.put("type", "openDirect");
                        break;
                }
                eventArgs.put("values", values);
                eventArgs.put("type", "notificationOpened");

                result = new PluginResult(PluginResult.Status.OK, eventArgs);
                result.setKeepCallback(true);

                if (eventsChannel != null && notificationOpenedSubscribed) {
                    eventsChannel.sendPluginResult(result);
                } else {
                    cachedNotificationOpenedResult = result;
                }
            } catch (Exception e) {
                // NO_OP
            }
        }
    }

    @Override
    public boolean execute(final String action, final JSONArray args,
        final CallbackContext callbackContext) throws JSONException {
        if (handleStaticAction(action, args, callbackContext)) {
            return true;
        }

        final ActionHandler handler = getActionHandler(action);

        if (handler == null) {
            return false;
        }

        cordova.getThreadPool().execute(new Runnable() {
            @Override
            public void run() {

                SFMCSdk.requestSdk(new SFMCSdkReadyListener() {
                    @Override
                    public void ready(@NonNull SFMCSdk sfmcSdk) {
                        if(handler instanceof  SFMCActionHandler){
                            ((SFMCActionHandler)handler).execute(sfmcSdk, args, callbackContext);
                        }else if(handler instanceof PushSDKActionHandler){
                            sfmcSdk.mp(new PushModuleReadyListener() {
                                @Override
                                public void ready(@NonNull PushModuleInterface pushModuleInterface) {
                                    ((PushSDKActionHandler)handler).execute(pushModuleInterface, args, callbackContext);
                                }
                            });
                        } else if (handler instanceof IdentityActionHandler) {
                            ((IdentityActionHandler) handler).execute(sfmcSdk.identity, args, callbackContext);
                        } else {
                            callbackContext.error("Marcketing Cloud SDK - Cordova Plugin: Unknown handler reference");
                        }
                        
                    }
                });
            }
        });

        return true;
    }

    private boolean handleStaticAction(
        String action, JSONArray args, CallbackContext callbackContext) {
        switch (action) {
            case "enableLogging":
                SFMCSdk.Companion.setLogging(LogLevel.DEBUG, new LogListener.AndroidLogger());
                MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE);
                MarketingCloudSdk.setLogListener(new MCLogListener.AndroidLogListener());
                callbackContext.success();
                return true;
            case "disableLogging":
                SFMCSdk.Companion.setLogging(LogLevel.NONE, null);
                MarketingCloudSdk.setLogListener(null);
                callbackContext.success();
                return true;
            case "registerEventsChannel":
                registerEventsChannel(callbackContext);
                return true;
            case "subscribe":
                subscribe(args, callbackContext);
                return true;
            default:
                return false;
        }
    }

    private void registerEventsChannel(CallbackContext callbackContext) {
        this.eventsChannel = callbackContext;
        if (notificationOpenedSubscribed) {
            sendCachedPushEvent(eventsChannel);
        }
    }

    private void subscribe(JSONArray args, CallbackContext context) {
        switch (args.optString(0, null)) {
            case "notificationOpened":
                notificationOpenedSubscribed = true;
                if (eventsChannel != null) {
                    sendCachedPushEvent(eventsChannel);
                }
                break;
            case "urlAction":
                // NO_OP
                // Always send urlAction events to the JS plugin.  It will manager the listener
                // registration.
                break;
            default:
                // NO_OP
        }
    }

    private void sendCachedPushEvent(CallbackContext callbackContext) {
        if (cachedNotificationOpenedResult != null) {
            callbackContext.sendPluginResult(cachedNotificationOpenedResult);
            cachedNotificationOpenedResult = null;
        }
    }

    private ActionHandler getActionHandler(String action) {
        switch (action) {
            case "getSystemToken":
                return getSystemToken();
            case "logSdkState":
                return logSdkState();
            case "isPushEnabled":
                return isPushEnabled();
            case "enablePush":
                return enabledPush();
            case "disablePush":
                return disablePush();
            case "getDeviceId":
                return getDeviceId();
            case "getAttributes":
                return getAttributes();
            case "setAttribute":
                return setAttribute();
            case "clearAttribute":
                return clearAttribute();
            case "addTag":
                return addTag();
            case "removeTag":
                return removeTag();
            case "getTags":
                return getTags();
            case "setContactKey":
                return setContactKey();
            case "getContactKey":
                return getContactKey();
            case "track":
                return track();
            case "setAnalyticsEnabled":
                return setAnalyticsEnabled();
            case "isAnalyticsEnabled":
                return isAnalyticsEnabled();
            case "setPiAnalyticsEnabled":
                return setPiAnalyticsEnabled();
            case "isPiAnalyticsEnabled":
                return isPiAnalyticsEnabled();
            default:
                return null;
        }
    }

    private ActionHandler getSystemToken() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(sdk.getPushMessageManager().getPushToken());
            }
        };
    }

    private ActionHandler logSdkState() {
        return new SFMCActionHandler() {
            @Override
            public void execute(
                SFMCSdk sdk, JSONArray args, CallbackContext callbackContext) {
                EventUtility.log("MCSDK STATE", sdk.getSdkState().toString());
                callbackContext.success();
            }
        };
    }

    private ActionHandler isPushEnabled() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(sdk.getPushMessageManager().isPushEnabled() ? 1 : 0);
            }
        };
    }

    private ActionHandler disablePush() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                sdk.getPushMessageManager().disablePush();
                callbackContext.success();
            }
        };
    }

    private ActionHandler enabledPush() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                sdk.getPushMessageManager().enablePush();
                callbackContext.success();
            }
        };
    }

    private ActionHandler getDeviceId() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(sdk.getRegistrationManager().getDeviceId());
            }
        };
    }

    private ActionHandler getAttributes() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                try {
                    callbackContext.success(EventUtility.fromMap(sdk.getRegistrationManager().getAttributes()));
                } catch (JSONException e) {
                    callbackContext.error(e.getMessage());
                }
            }
        };
    }

    private ActionHandler setAttribute() {
        return new IdentityActionHandler() {
            @Override
            public void execute(
                Identity identity, JSONArray args, CallbackContext callbackContext) {
                String key = args.optString(0, null);
                String value = args.optString(1);
                identity.setProfileAttribute(key, value);
                callbackContext.success();
            }
        };
    }

    private ActionHandler clearAttribute() {
        return new IdentityActionHandler() {
            @Override
            public void execute(
                Identity identity, JSONArray args, CallbackContext callbackContext) {
                String key = args.optString(0, null);
                identity.clearProfileAttribute(key);
                callbackContext.success();
            }
        };
    }

    private ActionHandler addTag() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                String tag = args.optString(0, null);
                boolean success = sdk.getRegistrationManager().edit().addTag(tag).commit();
                callbackContext.success(success ? 1 : 0);
            }
        };
    }

    private ActionHandler removeTag() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                String tag = args.optString(0, null);
                boolean success = sdk.getRegistrationManager().edit().removeTag(tag).commit();
                callbackContext.success(success ? 1 : 0);
            }
        };
    }

    private ActionHandler getTags() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(EventUtility.fromCollection(sdk.getRegistrationManager().getTags()));
            }
        };
    }

    private ActionHandler getContactKey() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(sdk.getRegistrationManager().getContactKey());
            }
        };
    }

    private ActionHandler setContactKey() {
        return new IdentityActionHandler() {
            @Override
            public void execute(
                Identity identity, JSONArray args, CallbackContext callbackContext) {
                String contactKey = args.optString(0, null);
                identity.setProfileId(contactKey);
                callbackContext.success();
            }
        };
    }

    private ActionHandler track() {
        return new SFMCActionHandler() {
            @Override
            public void execute(
                SFMCSdk sfmcSdk, JSONArray args, CallbackContext callbackContext) {
                try {
                    sfmcSdk.track(EventUtility.toEvent(args.getJSONObject(0)));
                    callbackContext.success();
                } catch (Exception e) {
                    // NO-OP
                    callbackContext.error(e.getMessage());
                }
            }
        };
    }
    
    private ActionHandler setAnalyticsEnabled() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                boolean enable = args.optBoolean(0, true);
                if (enable) {
                    sdk.getAnalyticsManager().enableAnalytics();
                } else {
                    sdk.getAnalyticsManager().disableAnalytics();
                }

                callbackContext.success();
            }
        };
    }

    private ActionHandler isAnalyticsEnabled() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(sdk.getAnalyticsManager().areAnalyticsEnabled() ? 1 : 0);
            }
        };
    }

     private ActionHandler setPiAnalyticsEnabled() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                boolean enable = args.optBoolean(0, true);
                if (enable) {
                    sdk.getAnalyticsManager().enablePiAnalytics();
                } else {
                    sdk.getAnalyticsManager().disablePiAnalytics();
                }

                callbackContext.success();
            }
        };
    }

    private ActionHandler isPiAnalyticsEnabled() {
        return new PushSDKActionHandler() {
            @Override
            public void execute(
                    PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext) {
                callbackContext.success(sdk.getAnalyticsManager().arePiAnalyticsEnabled() ? 1 : 0);
            }
        };
    }

    interface ActionHandler {
        
    }

    interface SFMCActionHandler extends ActionHandler {
        void execute(SFMCSdk sfmcSdk, JSONArray args, CallbackContext callbackContext);
    }

    interface PushSDKActionHandler extends ActionHandler{
        void execute(PushModuleInterface sdk, JSONArray args, CallbackContext callbackContext);
    }

    interface IdentityActionHandler extends ActionHandler {
        void execute(Identity identity, JSONArray args, CallbackContext callbackContext);
    }

}
