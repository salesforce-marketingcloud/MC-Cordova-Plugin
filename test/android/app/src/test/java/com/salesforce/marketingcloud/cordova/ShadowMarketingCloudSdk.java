package com.salesforce.marketingcloud.cordova;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import com.salesforce.marketingcloud.MCLogListener;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;

//Approximate implementation of static MarketingCloudSdk methods
@Implements(MarketingCloudSdk.class) public class ShadowMarketingCloudSdk {

  private static final MCLogListener testLogListener = new MCLogListener() {
    @Override
    public void out(int i, @NonNull String s, @NonNull String s1, @Nullable Throwable throwable) {
    }
  };

  private static MarketingCloudSdk.WhenReadyListener recentSdkRequest = null;
  private static boolean initializing = false;
  private static boolean ready = false;
  private static MarketingCloudSdk instance;
  private static int logLevel = -1;
  private static MCLogListener currentLogListener = testLogListener;

  @Implementation public static MarketingCloudSdk getInstance() {
    return instance;
  }

  public static void setInstance(MarketingCloudSdk instance) {
    ShadowMarketingCloudSdk.instance = instance;
  }

  @Implementation public static boolean isInitializing() {
    return initializing;
  }

  public static void isInitializing(boolean initializing) {
    ShadowMarketingCloudSdk.initializing = initializing;
  }

  @Implementation public static boolean isReady() {
    return ready;
  }

  public static void isReady(boolean ready) {
    ShadowMarketingCloudSdk.ready = ready;
  }

  @Implementation public static void requestSdk(MarketingCloudSdk.WhenReadyListener listener) {
    recentSdkRequest = listener;
  }

  public static MarketingCloudSdk.WhenReadyListener getRecentSdkRequest() {
    return recentSdkRequest;
  }

  public static int getLogLevel() {
    return logLevel;
  }

  @Implementation public static void setLogLevel(int logLevel) {
    ShadowMarketingCloudSdk.logLevel = logLevel;
  }

  public static MCLogListener getLogListener() {
    return currentLogListener;
  }

  @Implementation public static void setLogListener(MCLogListener listener) {
    currentLogListener = listener;
  }

  public static void reset() {
    initializing = false;
    ready = false;
    instance = null;
    recentSdkRequest = null;
    logLevel = -1;
    currentLogListener = testLogListener;
  }
}
