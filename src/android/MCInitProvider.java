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

import android.app.ActivityManager;
import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.notifications.NotificationManager;
import com.salesforce.marketingcloud.notifications.NotificationMessage;
import com.salesforce.marketingcloud.registration.RegistrationManager;
import de.appplant.cordova.plugin.badge.BadgeImpl;
import java.util.List;
import org.json.JSONObject;

public class MCInitProvider
  extends ContentProvider
  implements MarketingCloudSdk.InitializationListener {

  static final String MESSAGES_COUNT_ATTRIBUTE = "MessagesCount";
  private static BadgeImpl badgeImpl;

  @Override
  public boolean onCreate() {
    Context ctx = getContext();
    if (ctx != null) {
      MarketingCloudConfig.Builder builder = MCSdkConfig.prepareConfigBuilder(
        ctx
      );
      if (builder != null) {
        builder.setUrlHandler(MCSdkListener.INSTANCE);
        MarketingCloudSdk.init(ctx, builder.build(ctx), this);
      }
      Log.println(Log.DEBUG, "NotificationBuilder", "done");
    }
    return false;
  }

  @Nullable
  @Override
  public Cursor query(
    @NonNull Uri uri,
    @Nullable String[] projection,
    @Nullable String selection,
    @Nullable String[] selectionArgs,
    @Nullable String sortOrder
  ) {
    return null;
  }

  @Nullable
  @Override
  public String getType(@NonNull Uri uri) {
    return null;
  }

  @Nullable
  @Override
  public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
    return null;
  }

  @Override
  public int delete(
    @NonNull Uri uri,
    @Nullable String selection,
    @Nullable String[] selectionArgs
  ) {
    return 0;
  }

  @Override
  public int update(
    @NonNull Uri uri,
    @Nullable ContentValues values,
    @Nullable String selection,
    @Nullable String[] selectionArgs
  ) {
    return 0;
  }

@Override
  public void complete(@NonNull InitializationStatus status) {
    if (status.isUsable()) {
      MarketingCloudSdk.requestSdk(
        new MarketingCloudSdk.WhenReadyListener() {
          @Override
          public void ready(@NonNull MarketingCloudSdk marketingCloudSdk) {
            RegistrationManager registrationManager = marketingCloudSdk.getRegistrationManager();
            registrationManager.edit().addTag("Cordova").commit();
            NotificationManager.ShouldShowNotificationListener listener = new NotificationManager.ShouldShowNotificationListener() {
              @Override
              public boolean shouldShowNotification(@NonNull NotificationMessage notificationMessage) {
                if(isAppOnForeground(getContext())) {
                  JSONObject data = new JSONObject(notificationMessage.payload());
                  MCCordovaPlugin.sendMessage(data.toString());

                  return false;
                }
                String count = notificationMessage.customKeys().get("badge").toString();

                updateMessageCountCount(registrationManager, "PushMessagesCount", count);
                return true;
              }
            };
            marketingCloudSdk.getNotificationManager().setShouldShowNotificationListener(
                    listener
            );
          }
        }
      );
    }
  }

  public static void updateMessageCountCount(
          RegistrationManager registrationManager,
          String type,
          String count
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
                    count
            )
            .commit();

    if (badgeImpl.isSupported()) {
      badgeImpl.setBadge(Integer.parseInt(count));
    }
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