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
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
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
import com.salesforce.marketingcloud.sfmcsdk.modules.push.PushModuleInterface;
import com.salesforce.marketingcloud.sfmcsdk.modules.push.PushModuleReadyListener;
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkReadyListener;

public class MCCordovaPlugin extends CordovaPlugin implements UrlHandler {
    static final String TAG = "~!MCCordova";
    private static final String EXTRA_MESSAGE =
        "com.salesforce.marketingcloud.notifications.EXTRA_MESSAGE";
    private CallbackContext eventsChannel = null;
    private PluginResult cachedNotificationOpenedResult = null;
    private boolean notificationOpenedSubscribed = false;

    private static JSONObject fromMap(Map<String, String> map) throws JSONException {
        JSONObject data = new JSONObject();
        if (map != null && !map.isEmpty()) {
            for (Map.Entry<String, String> entry : map.entrySet()) {
                data.put(entry.getKey(), entry.getValue());
            }
        }
        return data;
    }

    private static JSONArray fromCollection(Collection<String> collection) {
        JSONArray data = new JSONArray();
        if (collection != null && !collection.isEmpty()) {
            for (String s : collection) {
                data.put(s);
            }
        }
        return data;
    }

    private static Map<String, Object> toMap(JSONObject jsonobj)  throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();
        Iterator<String> keys = jsonobj.keys();
        while(keys.hasNext()) {
            String key = keys.next();
            Object value = jsonobj.get(key);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }   
            map.put(key, value);
        }   return map;
    }

    private static List<Object> toList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();
        for(int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            }
            else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            list.add(value);
        }   return list;
    }

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
                log("MCSDK STATE", sdk.getSdkState().toString());
                callbackContext.success();
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

    private static int MAX_LOG_LENGTH = 4000;

    private static void log(String tag, String msg) {
        for (int i = 0, length = msg.length(); i < length; i += MAX_LOG_LENGTH) {
            Log.println(Log.DEBUG, tag, msg.substring(i, Math.min(length, i + MAX_LOG_LENGTH)));
        }
    }
}
