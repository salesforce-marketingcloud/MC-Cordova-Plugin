package com.salesforce.marketingcloud.cordova;

import com.salesforce.marketingcloud.MarketingCloudSdk;
import org.robolectric.annotation.Implementation;
import org.robolectric.annotation.Implements;

//Approximate implementation of static MarketingCloudSdk methods
@Implements(MarketingCloudSdk.class) public class ShadowMarketingCloudSdk {

  private static MarketingCloudSdk.WhenReadyListener recentSdkRequest = null;
  private static boolean initializing = false;
  private static boolean ready = false;
  private static MarketingCloudSdk instance;

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

  public static void reset() {
    initializing = false;
    ready = false;
    instance = null;
    recentSdkRequest = null;
  }
}
