package com.adeccoglobal.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.cordova.MCSdkConfig;
import com.salesforce.marketingcloud.registration.RegistrationManager;
import de.appplant.cordova.plugin.badge.BadgeImpl;

public class NotificationBroadcastReceiver extends BroadcastReceiver {

  @Override
  public void onReceive(Context context, Intent intent) {
    BadgeImpl badgeImpl = new BadgeImpl(context);
    Log.println(
      Log.DEBUG,
      "NotificationBuilder",
      "NotificationBroadcastReceiver.onReceive"
    );
    String action = intent.getAction();
    if (action.equals("notification_cancelled")) {
      RegistrationManager registrationManager = MarketingCloudSdk
        .getInstance()
        .getRegistrationManager();
      MCSdkConfig.updateMessageCountCount(
        registrationManager,
        MCSdkConfig.PUSH_MESSAGES_COUNT_ATTRIBUTE,
        -1
      );
      if (badgeImpl.isSupported()) {
        badgeImpl.setBadge(MCSdkConfig.getMessageCount(registrationManager));
      }
      Log.println(
        Log.DEBUG,
        "NotificationBuilder",
        "count=" + MCSdkConfig.getMessageCount(registrationManager)
      );
    }
  }
}
