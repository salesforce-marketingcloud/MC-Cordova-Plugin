package com.salesforce.marketingcloud.cordova;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.support.annotation.NonNull;
import android.util.Log;
import com.google.firebase.FirebaseApp;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import java.io.IOException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import static com.salesforce.marketingcloud.cordova.MCCordovaPlugin.TAG;

public class MCSdkConfig {

  private static final String CONFIG_PREFIX = "com.salesforce.marketingcloud.";

  private MCSdkConfig() {
  }

  @NonNull public static MarketingCloudConfig.Builder prepareConfigBuilder(Context context) {
    return parseConfig(context, loadConfigsForXml(context));
  }

  static MarketingCloudConfig.Builder parseConfig(Context context, Map<String, String> config) {
    MarketingCloudConfig.Builder builder = MarketingCloudConfig.builder();
    boolean senderIdSet = false;

    for (Map.Entry<String, String> entry : config.entrySet()) {
      switch (entry.getKey()) {
        case CONFIG_PREFIX + "app_id":
          builder.setApplicationId(entry.getValue());
          break;
        case CONFIG_PREFIX + "access_token":
          builder.setAccessToken(entry.getValue());
          break;
        case CONFIG_PREFIX + "sender_id":
          builder.setSenderId(entry.getValue());
          senderIdSet = true;
          break;
        case CONFIG_PREFIX + "analytics":
          builder.setAnalyticsEnabled("true".equalsIgnoreCase(entry.getValue()));
          break;
        case CONFIG_PREFIX + "notification_channel_name":
          builder.setNotificationChannelName(entry.getValue());
          break;
        case CONFIG_PREFIX + "notification_small_icon":
          int notifId = context.getResources()
              .getIdentifier(entry.getValue(), "drawable", context.getPackageName());
          if (notifId != 0) {
            builder.setNotificationSmallIconResId(notifId);
          }
          break;
        case CONFIG_PREFIX + "tenant_specific_endpoint":
          builder.setMarketingCloudServerUrl(entry.getValue());
      }
    }

    if (!senderIdSet) {
      try {
        builder.setSenderId(FirebaseApp.getInstance().getOptions().getGcmSenderId());
      } catch (Exception e) {
        Log.e(TAG,
            "Unable to retrieve sender id.  Push messages will not work for Marketing Cloud.", e);
      }
    }

    return builder;
  }

  private static Map<String, String> loadConfigsForXml(Context context) {
    Map<String, String> configs = new HashMap<>();

    Resources res = context.getResources();
    int configId = res.getIdentifier("config", "xml", context.getPackageName());

    if (configId == 0) {
      return configs;
    }

    XmlResourceParser parser = res.getXml(configId);

    try {
      while (parser.next() != XmlPullParser.END_DOCUMENT) {
        if (parser.getEventType() != XmlPullParser.START_TAG || !"preference".equals(
            parser.getName())) {
          continue;
        }

        String key = parser.getAttributeValue(null, "name");
        String val = parser.getAttributeValue(null, "value");

        if (key != null && val != null) {
          key = key.toLowerCase(Locale.US);
          if (key.startsWith(CONFIG_PREFIX)) {
            configs.put(key, val);
          }
        }
      }
    } catch (XmlPullParserException e) {
      Log.e(TAG, "Unable to read config.xml.", e);
    } catch (IOException ioe) {
      Log.e(TAG, "Unable to open config.xml.", ioe);
    }

    return configs;
  }
}