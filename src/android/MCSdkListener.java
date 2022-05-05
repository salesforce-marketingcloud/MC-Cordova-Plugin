package com.salesforce.marketingcloud.cordova;

import android.app.PendingIntent;
import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import android.util.Log;

import com.salesforce.marketingcloud.UrlHandler;

public enum MCSdkListener implements UrlHandler {
    INSTANCE;

    public UrlHandler urlHandler = null;

    @Nullable
    @Override
    public void handleUrl(@NonNull Context context, @NonNull String s, @NonNull String s1) {
        if (urlHandler != null) {
            urlHandler.handleUrl(context, s, s1);
        }
    }
}
