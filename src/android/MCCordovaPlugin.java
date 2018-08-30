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

/**
 * This class echoes a string called from JavaScript.
 */
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
        String tag = args.optString(0, null);
        if (tag != null) {
          sdk.getRegistrationManager().edit().setContactKey(tag).commit();
          callbackContext.success();
        } else {
          callbackContext.error("Valid contactKey not provided.");
        }
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
        if (tag != null) {
          sdk.getRegistrationManager().edit().removeTag(tag).commit();
          callbackContext.success();
        } else {
          callbackContext.error("Valid tag not provided.");
        }
      }
    };
  }

  private ActionHandler addTag() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String tag = args.optString(0, null);
        if (tag != null) {
          sdk.getRegistrationManager().edit().addTag(tag).commit();
          callbackContext.success();
        } else {
          callbackContext.error("Valid tag not provided.");
        }
      }
    };
  }

  private ActionHandler clearAttribute() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String key = args.optString(0, null);
        if (key != null) {
          sdk.getRegistrationManager().edit().clearAttribute(key).commit();
          callbackContext.success();
        } else {
          callbackContext.error("Valid attribute key not provided.");
        }
      }
    };
  }

  private ActionHandler setAttribute() {
    return new ActionHandler() {
      @Override
      public void execute(MarketingCloudSdk sdk, JSONArray args, CallbackContext callbackContext) {
        String key = args.optString(0, null);
        String value = args.optString(1);
        if (key != null) {
          sdk.getRegistrationManager().edit().setAttribute(key, value).commit();
        } else {
          callbackContext.error("Valid attribute key/value not provided.");
        }
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
