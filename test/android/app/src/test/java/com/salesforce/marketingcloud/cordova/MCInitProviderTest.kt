package com.salesforce.marketingcloud.cordova

import com.google.common.truth.Truth.assertThat
import com.salesforce.marketingcloud.MarketingCloudSdk
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment

@RunWith(RobolectricTestRunner::class) class MCInitProviderTest {

  @Test fun provider_onCreate_initializesMarketingCloudSdk() {
    MCInitProvider().attachInfo(RuntimeEnvironment.application, null)

    assertThat(MarketingCloudSdk.isReady() || MarketingCloudSdk.isInitializing()).isTrue()
  }
}