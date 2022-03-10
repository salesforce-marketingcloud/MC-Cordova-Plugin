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

import static com.salesforce.marketingcloud.cordova.MCCordovaPlugin.TAG;

import android.app.ActivityManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import com.adeccoglobal.app.MainActivity;
import com.adeccoglobal.app.NotificationBroadcastReceiver;
import com.google.firebase.FirebaseApp;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions;
import com.salesforce.marketingcloud.notifications.NotificationManager;
import com.salesforce.marketingcloud.notifications.NotificationMessage;
import com.salesforce.marketingcloud.registration.RegistrationManager;
import de.appplant.cordova.plugin.badge.BadgeImpl;
import java.io.IOException;
import java.util.List;
import java.util.Locale;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

public class MCSdkConfig {

  private static final String CONFIG_PREFIX = "com.salesforce.marketingcloud.";
  public static final String PUSH_MESSAGES_COUNT_ATTRIBUTE =
    "PushMessagesCount";
  public static final String SSE_MESSAGES_COUNT_ATTRIBUTE = "SseMessagesCount";

  private static BadgeImpl badgeImpl;

  private MCSdkConfig() {}

  @Nullable
  public static MarketingCloudConfig.Builder prepareConfigBuilder(
    Context context
  ) {
    Resources res = context.getResources();
    int configId = res.getIdentifier("config", "xml", context.getPackageName());
    badgeImpl = new BadgeImpl(context);

    if (configId == 0) {
      return null;
    }

    XmlResourceParser parser = res.getXml(configId);
    return parseConfig(context, parser);
  }

  static MarketingCloudConfig.Builder parseConfig(
    Context context,
    XmlPullParser parser
  ) {
    MarketingCloudConfig.Builder builder = MarketingCloudConfig.builder();
    boolean senderIdSet = false;
    int iconId = 0;
    try {
      while (parser.next() != XmlPullParser.END_DOCUMENT) {
        if (
          parser.getEventType() != XmlPullParser.START_TAG ||
          !"preference".equals(parser.getName())
        ) {
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
              int notifId = context
                .getResources()
                .getIdentifier(val, "drawable", context.getPackageName());
              iconId = notifId;
              if (notifId != 0) {
                builder.setNotificationCustomizationOptions(
                  NotificationCustomizationOptions.create(notifId)
                );
              }
              break;
            case CONFIG_PREFIX + "tenant_specific_endpoint":
              builder.setMarketingCloudServerUrl(val);
              break;
            case CONFIG_PREFIX + "delay_registration_until_contact_key_is_set":
              builder.setDelayRegistrationUntilContactKeyIsSet(
                "true".equalsIgnoreCase(val)
              );
              break;
          }
        }
      }

      int finalIconId = iconId;
      Log.println(Log.DEBUG, "NotificationBuilder", "" + iconId);

      builder.setNotificationCustomizationOptions(
        NotificationCustomizationOptions.create(
          new NotificationManager.NotificationBuilder() {
            @NonNull
            @Override
            public NotificationCompat.Builder setupNotificationBuilder(
              @NonNull Context context,
              @NonNull NotificationMessage notificationMessage
            ) {
              try {
                Log.println(
                  Log.DEBUG,
                  "NotificationBuilder",
                  notificationMessage.toString()
                );

                RegistrationManager registrationManager = MarketingCloudSdk
                  .getInstance()
                  .getRegistrationManager();
                NotificationCompat.Builder b = NotificationManager.getDefaultNotificationBuilder(
                  context,
                  notificationMessage,
                  NotificationManager.createDefaultNotificationChannel(context),
                  finalIconId
                );
                b
                  .setContentIntent(
                    onReceiveMessage(
                      registrationManager,
                      context,
                      notificationMessage
                    )
                  )
                  .setDeleteIntent(
                    onDeleteMessage(
                      registrationManager,
                      context,
                      notificationMessage
                    )
                  )
                  .setAutoCancel(true);

                return b;
              } catch (Exception e) {
                Log.println(Log.DEBUG, "NotificationBuilder", e.getMessage());

                return null;
              }
            }
          }
        )
      );
    } catch (XmlPullParserException e) {
      Log.e(TAG, "Unable to read config.xml.", e);
    } catch (IOException ioe) {
      Log.e(TAG, "Unable to open config.xml.", ioe);
    }

    if (!senderIdSet) {
      try {
        builder.setSenderId(
          FirebaseApp.getInstance().getOptions().getGcmSenderId()
        );
      } catch (Exception e) {
        Log.e(
          TAG,
          "Unable to retrieve sender id. Push messages will not work for Marketing Cloud.",
          e
        );
      }
    }

    return builder;
  }

  public static void updateMessageCountCount(
    RegistrationManager registrationManager,
    String type,
    int count
  ) {
    String messageCountCountAttr = registrationManager
      .getAttributes()
      .get(type);
    Log.println(
      Log.DEBUG,
      "NotificationBuilder",
      "updateMessageCountCount:" + messageCountCountAttr + ",count:" + count
    );
    registrationManager
      .edit()
      .setAttribute(
        type,
        Integer.toString(
          messageCountCountAttr == null
            ? count
            : count + Integer.parseInt(messageCountCountAttr)
        )
      )
      .commit();
  }

  public static int getMessageCount(RegistrationManager registrationManager) {
    String pushMessageCountCountAttr = registrationManager
      .getAttributes()
      .get(PUSH_MESSAGES_COUNT_ATTRIBUTE);
    String sseMessageCountCountAttr = registrationManager
      .getAttributes()
      .get(SSE_MESSAGES_COUNT_ATTRIBUTE);
    int pushMessageCountCount = pushMessageCountCountAttr == null
      ? 0
      : Integer.parseInt(pushMessageCountCountAttr);
    int sseMessageCountCount = sseMessageCountCountAttr == null
      ? 0
      : Integer.parseInt(sseMessageCountCountAttr);

    Log.println(
      Log.DEBUG,
      "NotificationBuilder",
      "getMessageCount:" + (pushMessageCountCount + sseMessageCountCount)
    );
    return pushMessageCountCount + sseMessageCountCount;
  }

  private static PendingIntent onReceiveMessage(
    @NonNull RegistrationManager registrationManager,
    @NonNull Context context,
    @NonNull NotificationMessage notificationMessage
  ) {
    Log.println(Log.DEBUG, "NotificationBuilder", "onReceiveMessage");

    updateMessageCountCount(
      registrationManager,
      PUSH_MESSAGES_COUNT_ATTRIBUTE,
      1
    );
    if (badgeImpl.isSupported()) {
      badgeImpl.setBadge(getMessageCount(registrationManager));
    }

    Log.println(
      Log.DEBUG,
      "NotificationBuilder",
      "count=" + getMessageCount(registrationManager)
    );

    return NotificationManager.redirectIntentForAnalytics(
      context,
      PendingIntent.getBroadcast(
        context,
        0,
        new Intent(context, MainActivity.class),
        PendingIntent.FLAG_UPDATE_CURRENT
      ),
      notificationMessage,
      true
    );
  }

  private static PendingIntent onDeleteMessage(
    @NonNull RegistrationManager registrationManager,
    @NonNull Context context,
    @NonNull NotificationMessage notificationMessage
  ) {
    Log.println(Log.DEBUG, "NotificationBuilder", "onDeleteMessage");

    // updateMessageCountCount(registrationManager,PUSH_MESSAGES_COUNT_ATTRIBUTE,-1);
    // if(badgeImpl.isSupported()) {
    // badgeImpl.setBadge(getMessageCount(registrationManager));
    // }
    // Log.println(Log.DEBUG, "NotificationBuilder", "count="+getMessageCount(registrationManager));
    Intent intent = new Intent(context, NotificationBroadcastReceiver.class);
    intent.setAction("notification_cancelled");
    return NotificationManager.redirectIntentForAnalytics(
      context,
      PendingIntent.getBroadcast(
        context,
        0,
        intent,
        PendingIntent.FLAG_CANCEL_CURRENT
      ),
      notificationMessage,
      true
    );
  }

  private static boolean isAppOnForeground(Context context) {
    ActivityManager activityManager = (ActivityManager) context.getSystemService(
      Context.ACTIVITY_SERVICE
    );
    List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
    if (appProcesses == null) {
      return false;
    }
    final String packageName = context.getPackageName();
    for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
      if (
        appProcess.importance ==
        ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND &&
        appProcess.processName.equals(packageName)
      ) {
        return true;
      }
    }
    return false;
  }
}
