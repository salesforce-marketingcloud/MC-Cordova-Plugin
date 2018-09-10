package com.salesforce.marketingcloud.cordova;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.support.annotation.Nullable;
import android.util.Log;
import com.google.firebase.FirebaseApp;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import java.io.IOException;
import java.util.Locale;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import static com.salesforce.marketingcloud.cordova.MCCordovaPlugin.TAG;

public class MCSdkConfig {

  private static final String CONFIG_PREFIX = "com.salesforce.marketingcloud.";

  private MCSdkConfig() {
  }

  @Nullable public static MarketingCloudConfig.Builder prepareConfigBuilder(Context context) {
    Resources res = context.getResources();
    int configId = res.getIdentifier("config", "xml", context.getPackageName());

    if (configId == 0) {
      return null;
    }

    XmlResourceParser parser = res.getXml(configId);

    return parseConfig(context, parser);
  }

  static MarketingCloudConfig.Builder parseConfig(Context context, XmlPullParser parser) {
    MarketingCloudConfig.Builder builder = MarketingCloudConfig.builder();
    boolean senderIdSet = false;
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

          switch (key) {
            case CONFIG_PREFIX + "app_id":
              builder.setApplicationId(val);
              break;
            case CONFIG_PREFIX + "access_token":
              builder.setAccessToken(val);
              break;
            case CONFIG_PREFIX + "sender_id":
              builder.setSenderId(val);
              senderIdSet = true;
              break;
            case CONFIG_PREFIX + "analytics":
              builder.setAnalyticsEnabled("true".equalsIgnoreCase(val));
              break;
            case CONFIG_PREFIX + "notification_small_icon":
              int notifId =
                  context.getResources().getIdentifier(val, "drawable", context.getPackageName());
              if (notifId != 0) {
                builder.setNotificationSmallIconResId(notifId);
              }
              break;
            case CONFIG_PREFIX + "tenant_specific_endpoint":
              builder.setMarketingCloudServerUrl(val);
              break;
          }
        }
      }
    } catch (XmlPullParserException e) {
      Log.e(TAG, "Unable to read config.xml.", e);
    } catch (IOException ioe) {
      Log.e(TAG, "Unable to open config.xml.", ioe);
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
}