package com.salesforce.etpush;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.os.AsyncTask;
import android.app.ActivityManager;
import android.util.Log;

import java.util.LinkedHashSet;
import java.util.List;
import java.lang.Exception;



import com.exacttarget.etpushsdk.ETNotificationBuilder;
import com.exacttarget.etpushsdk.ETNotifications;

/**
 * Created by nnarahari on 3/9/17.
 */

public class ETNotificationsCordova implements ETNotificationBuilder{

    private static final String TAG = CONSTS.LOG_TAG;

    @Override
    public NotificationCompat.Builder setupNotificationBuilder(Context context, Bundle payload) {

        // Add additional capabilities to the notification such as displaying buttons based on the category sent
        String alert = payload.getString("alert");
        String title = payload.getString("title");
        try {
            boolean foreground = new ForegroundCheckTask().execute(context).get();
            Log.d(TAG, "Notification have been received with foreground check status:"+foreground);
            if(!foreground) {
                NotificationCompat.Builder builder = ETNotifications.setupNotificationBuilder(context, payload);
                builder.setContentTitle(title);
                builder.setContentText(alert);
                return builder;
            }
        }catch(Exception ie) {
            Log.e(TAG,"Caught InterruptedException:"+ie.getMessage());
        }
        return null;
        
    }



    class ForegroundCheckTask extends AsyncTask<Context, Void, Boolean> {

        @Override
        protected Boolean doInBackground(Context... params) {
            final Context context = params[0].getApplicationContext();
            return isAppOnForeground(context);
        }

        private boolean isAppOnForeground(Context context) {
            ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
            if (appProcesses == null) {
                return false;
            }
            final String packageName = context.getPackageName();
            for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
                if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName.equals(packageName)) {
                    return true;
                }
            }
            return false;
        }
    }
}