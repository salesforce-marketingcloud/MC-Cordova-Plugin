package com.salesforce.marketingcloud.cordovaplugin;

import android.app.Application;
import android.content.Context;
import android.support.annotation.CallSuper;
import android.util.Log;

import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.registration.RegistrationManager;

import java.util.Set;
import java.util.TreeSet;
import packagename.R;

public class MCCordovaPluginApplication extends Application {

    private static final String TAG = "~#MCSdkCordovaApp";
    private static Context context;

    public static Context getAppContext() {
        return context;
    }
    public static final String CURRENT_CORDOVA_VERSION_NAME = "MC_Cordova_v1.1.0";

    @Override
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();

        boolean etAnalyticsEnabled = "enabled".equalsIgnoreCase(getString(R.string.ETANALYTICS));

        MarketingCloudSdk.init(this, MarketingCloudConfig.builder()
                .setApplicationId(getString(R.string.APPID))
                .setAccessToken(getString(R.string.ACCESSTOKEN))
                .setGcmSenderId(getString(R.string.GCMSENDERID))
                .setAnalyticsEnabled(etAnalyticsEnabled)
                .setNotificationChannelName(String.valueOf(R.string.CHANNELNAME))
                .build(), new MarketingCloudSdk.InitializationListener() {
            @Override public void complete(InitializationStatus status) {

                if (status.isUsable()) {
                    RegistrationManager registrationManager = MarketingCloudSdk.getInstance().getRegistrationManager();
                    RegistrationManager.Editor registrationEditor = registrationManager.edit();
                    Set<String> tags = new TreeSet<>(registrationManager.getTags());
                    if (!tags.isEmpty()) {
                        for (String tag : tags) {
                            if (!tag.equals(CURRENT_CORDOVA_VERSION_NAME) && tag.startsWith("MC_Cordova_v")) {
                                registrationEditor.removeTags(tag);
                            }
                        }
                    }
                    registrationEditor.addTags(CURRENT_CORDOVA_VERSION_NAME).commit();
                }
            }
        });
    }
}
