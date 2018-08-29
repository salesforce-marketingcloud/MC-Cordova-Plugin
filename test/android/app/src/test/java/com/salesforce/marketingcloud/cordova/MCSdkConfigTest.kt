package com.salesforce.marketingcloud.cordova

import com.google.common.truth.Truth.assertThat
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.StringReader
import java.util.UUID

@RunWith(RobolectricTestRunner::class) class MCSdkConfigTest {

  private val testAppId = UUID.randomUUID().toString()
  private val testAccessToken = "abcdefghi123456789abcdef"
  private val testNotificationChannelName = "Marketing"
  private val testNotificationSmallIconName = "ic_notification"
  private val testSenderId = "123456789876"

  @Test fun parseConfig_minimumInput_producesConfigWithDefaultValues() {
    // GIVEN
    FirebaseApp.initializeApp(RuntimeEnvironment.application, with(FirebaseOptions.Builder()) {
      setApplicationId("1:$testSenderId:android:12b123ab12345678")
      setProjectId("test-app")
      setGcmSenderId(testSenderId)
      build()
    })
    val configParser = """
      <preference name="com.salesforce.marketingcloud.app_id" value="$testAppId" />
      <preference name="com.salesforce.marketingcloud.access_token" value="$testAccessToken" />
      <preference name="com.salesforce.marketingcloud.notification_channel_name" value="$testNotificationChannelName" />
      <preference name="com.salesforce.marketingcloud.notification_small_icon" value="$testNotificationSmallIconName" />
    """.trimIndent().toXmlParser()

    // WHEN
    val config = MCSdkConfig.parseConfig(RuntimeEnvironment.application, configParser).build(
        RuntimeEnvironment.application)

    // THEN
    assertThat(config.applicationId()).isEqualTo(testAppId)
    assertThat(config.accessToken()).isEqualTo(testAccessToken)
    assertThat(config.senderId()).isEqualTo(testSenderId)
    assertThat(config.notificationChannelName()).isEqualTo(testNotificationChannelName)
    val iconName = RuntimeEnvironment.application.resources.getResourceEntryName(
        config.notificationSmallIconResId())
    assertThat(iconName).isEqualTo(testNotificationSmallIconName)
    assertThat(config.notificationSmallIconResId()).isNotEqualTo(0)
    assertThat(config.analyticsEnabled()).isFalse()
    assertThat(config.geofencingEnabled()).isFalse()
    assertThat(config.proximityEnabled()).isFalse()
    assertThat(config.piAnalyticsEnabled()).isFalse()

    FirebaseApp.getInstance()?.delete()
  }

  @Test fun parseConfig_allConfigValues_producesConfigWithDefaultValues() {
    // GIVEN
    val testTse = "https://example.com/"
    val configParser = """
      <preference name="com.salesforce.marketingcloud.app_id" value="$testAppId" />
      <preference name="com.salesforce.marketingcloud.access_token" value="$testAccessToken" />
      <preference name="com.salesforce.marketingcloud.sender_id" value="$testSenderId" />
      <preference name="com.salesforce.marketingcloud.notification_channel_name" value="$testNotificationChannelName" />
      <preference name="com.salesforce.marketingcloud.notification_small_icon" value="$testNotificationSmallIconName" />
      <preference name="com.salesforce.marketingcloud.analytics" value="true" />
      <preference name="com.salesforce.marketingcloud.tenant_specific_endpoint" value="$testTse" />
    """.trimIndent().toXmlParser()

    // WHEN
    val config = MCSdkConfig.parseConfig(RuntimeEnvironment.application, configParser).build(
        RuntimeEnvironment.application)

    // THEN
    assertThat(config.applicationId()).isEqualTo(testAppId)
    assertThat(config.accessToken()).isEqualTo(testAccessToken)
    assertThat(config.senderId()).isEqualTo(testSenderId)
    assertThat(config.notificationChannelName()).isEqualTo(testNotificationChannelName)
    val iconName = RuntimeEnvironment.application.resources.getResourceEntryName(
        config.notificationSmallIconResId())
    assertThat(iconName).isEqualTo(testNotificationSmallIconName)
    assertThat(config.notificationSmallIconResId()).isNotEqualTo(0)
    assertThat(config.analyticsEnabled()).isTrue()
    assertThat(config.marketingCloudServerUrl()).isEqualTo(testTse)
  }


  private fun String.toXmlParser(): XmlPullParser {
    val factory = XmlPullParserFactory.newInstance()
    factory.isNamespaceAware = false
    val parser = factory.newPullParser()
    parser.setInput(StringReader(this))
    return parser
  }
}