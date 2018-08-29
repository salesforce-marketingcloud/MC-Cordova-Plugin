package com.salesforce.marketingcloud.cordova;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.registration.RegistrationManager;
import java.util.Set;

public class MCInitProvider extends ContentProvider
    implements MarketingCloudSdk.InitializationListener {

  private static final String TAG_PREFIX = "MC_Cordova_v";

  private static String versionMetaData(Context context) {
    try {
      ApplicationInfo ai = context.getPackageManager()
          .getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      Bundle bundle = ai.metaData;
      return bundle.getString("com.salesforce.marketingcloud.cordova.VERSION", "");
    } catch (Exception e) {
      Log.e(MCCordovaPlugin.TAG, "Failed to read cordova plugin version from manifest.", e);
    }

    return "";
  }

  @Override public boolean onCreate() {
    Context ctx = getContext();
    if (ctx != null) {
      MarketingCloudConfig.Builder builder = MCSdkConfig.prepareConfigBuilder(ctx);
      if (builder != null) {
        MarketingCloudSdk.init(ctx, builder.build(ctx), this);
      }
    }
    return false;
  }

  @Nullable @Override
  public Cursor query(@NonNull Uri uri, @Nullable String[] projection, @Nullable String selection,
      @Nullable String[] selectionArgs, @Nullable String sortOrder) {
    return null;
  }

  @Nullable @Override public String getType(@NonNull Uri uri) {
    return null;
  }

  @Nullable @Override public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
    return null;
  }

  @Override public int delete(@NonNull Uri uri, @Nullable String selection,
      @Nullable String[] selectionArgs) {
    return 0;
  }

  @Override
  public int update(@NonNull Uri uri, @Nullable ContentValues values, @Nullable String selection,
      @Nullable String[] selectionArgs) {
    return 0;
  }

  @Override public void complete(@NonNull InitializationStatus status) {
    if (status.isUsable()) {
      MarketingCloudSdk.requestSdk(new MarketingCloudSdk.WhenReadyListener() {
        @Override public void ready(@NonNull MarketingCloudSdk marketingCloudSdk) {
          RegistrationManager registrationManager = marketingCloudSdk.getRegistrationManager();
          Set<String> tags = registrationManager.getTags();
          if (!tags.isEmpty()) {
            for (String tag : tags) {
              if (tag.startsWith(TAG_PREFIX)) {
                String versionTag = TAG_PREFIX + versionMetaData(getContext());
                registrationManager.edit().removeTag(tag).addTag(versionTag).commit();
                break;
              }
            }
          } else {
            registrationManager.edit().addTag(TAG_PREFIX + versionMetaData(getContext())).commit();
          }
        }
      });
    }
  }
}
