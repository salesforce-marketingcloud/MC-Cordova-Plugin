/**
 * Copyright 2018 Salesforce, Inc
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific prior written permission.
 *
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

import android.support.annotation.NonNull;
import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import java.util.Collection;
import java.util.Map;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MCCordovaPlugin extends CordovaPlugin {
  static final String TAG = "~!MCCordova";

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

  @Override public boolean execute(final String action, final JSONArray args,
      final CallbackContext callbackContext) throws JSONException {
    if (handleStaticAction(action, args, callbackContext)) {
      return true;
    }

    final ActionHandler handler = getActionHandler(action);

    if (handler == null) {
      return false;
    }

    cordova.getThreadPool().execute(new Runnable() {
      @Override public void run() {
        if (MarketingCloudSdk.isReady()) {
          handler.execute(MarketingCloudSdk.getInstance(), args, callbackContext);
        } else if (MarketingCloudSdk.isInitializing()) {
          MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
            @Override public void ready(@NonNull MarketingCloudSdk sdk) {
              handler.execute(sdk, args, callbackContext);
            }
          });
        } else {
          callbackContext.error("MarketingCloudSdk#init has not been called");
        }
      }
    });

    return true;
  }

  private boolean handleStaticAction(String action, JSONArray args,
      CallbackContext callbackContext) {
    switch (action) {
      case "enableVerboseLogging":
        MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE);
        MarketingCloudSdk.setLogListener(new MCLogListener.AndroidLogListener());
        callbackContext.success();
        return true;
      case "disableVerboseLogging":
        MarketingCloudSdk.setLogListener(null);
        callbackContext.success();
        return true;
      default:
        return false;
    }
  }

  private ActionHandler getActionHandler(String action) {
    switch (action) {
      case "getSystemToken":
        return getSystemToken();
      case "isPushEnabled":
        return isPushEnabled();
      case "enablePush":
        return enabledPush();
      case "disablePush":
        return disablePush();
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
      default:
        return null;
    }
  }

  private ActionHandler getContactKey() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        callbackContext.success(sdk.getRegistrationManager().getContactKey());
      }
    };
  }

  private ActionHandler setContactKey() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String contactKey = args.optString(0, null);
        boolean success = sdk.getRegistrationManager().edit().setContactKey(contactKey).commit();
        callbackContext.success(success ? 1 : 0);
      }
    };
  }

  private ActionHandler getTags() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        callbackContext.success(fromCollection(sdk.getRegistrationManager().getTags()));
      }
    };
  }

  private ActionHandler removeTag() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String tag = args.optString(0, null);
        boolean success = sdk.getRegistrationManager().edit().removeTag(tag).commit();
        callbackContext.success(success ? 1 : 0);
      }
    };
  }

  private ActionHandler addTag() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String tag = args.optString(0, null);
        boolean success = sdk.getRegistrationManager().edit().addTag(tag).commit();
        callbackContext.success(success ? 1 : 0);
      }
    };
  }

  private ActionHandler clearAttribute() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String key = args.optString(0, null);
        boolean success = sdk.getRegistrationManager().edit().clearAttribute(key).commit();
        callbackContext.success(success ? 1 : 0);
      }
    };
  }

  private ActionHandler setAttribute() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String key = args.optString(0, null);
        String value = args.optString(1);
        boolean success = sdk.getRegistrationManager().edit().setAttribute(key, value).commit();
        callbackContext.success(success ? 1 : 0);
      }
    };
  }

  private ActionHandler getAttributes() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        try {
          callbackContext.success(fromMap(sdk.getRegistrationManager().getAttributes()));
        } catch (JSONException e) {
          callbackContext.error(e.getMessage());
        }
      }
    };
  }

  private ActionHandler disablePush() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        sdk.getPushMessageManager().disablePush();
        callbackContext.success();
      }
    };
  }

  private ActionHandler enabledPush() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        sdk.getPushMessageManager().enablePush();
        callbackContext.success();
      }
    };
  }

  private ActionHandler isPushEnabled() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        callbackContext.success(sdk.getPushMessageManager().isPushEnabled() ? 1 : 0);
      }
    };
  }

  private ActionHandler getSystemToken() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        callbackContext.success(sdk.getPushMessageManager().getPushToken());
      }
    };
  }

  interface ActionHandler {
    void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext);
  }
}
