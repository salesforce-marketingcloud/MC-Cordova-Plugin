package com.salesforce.marketingcloudsdk;

import android.app.Application;
import android.content.Context;
import android.support.annotation.CallSuper;

import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;

public class MarketingCloudSdkCordovaApplication extends Application {

    private static final String TAG = "~#MarketingCloudSdkCordovaApp";

    private static Context context;

    public static Context getAppContext() {
        return context;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();

        MarketingCloudSdk.init(this, MarketingCloudConfig.builder()
                .setApplicationId(getString(R.string.APPID))
                .setAccessToken(getString(R.string.ACCESSTOKEN))
                .setGcmSenderId(getString(R.string.GCMSENDERID))
                .build(), new MarketingCloudSdk.InitializationListener() {
            @Override
            public void complete(InitializationStatus status) {
                if (!status.isUsable()) {
                    // failed log
                }
            }
        });
    }
}