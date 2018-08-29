package com.salesforce.marketingcloud.cordova;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import com.salesforce.marketingcloud.InitializationStatus;
import com.salesforce.marketingcloud.MarketingCloudConfig;
import com.salesforce.marketingcloud.MarketingCloudSdk;
import com.salesforce.marketingcloud.registration.RegistrationManager;
import java.util.Set;

public class MCInitProvider extends ContentProvider
    implements MarketingCloudSdk.InitializationListener {

  private static final String CURRENT_CORDOVA_VERSION_NAME = "MC_Cordova_v1.1.0";

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
          RegistrationManager.Editor registrationEditor = registrationManager.edit();
          Set<String> tags = registrationManager.getTags();
          if (!tags.isEmpty()) {
            for (String tag : tags) {
              if (!tag.equals(CURRENT_CORDOVA_VERSION_NAME) && tag.startsWith("MC_Cordova_v")) {
                registrationEditor.removeTags(tag);
              }
            }
          }
          registrationEditor.addTags(CURRENT_CORDOVA_VERSION_NAME).commit();
        }
      });
    }
  }
}
