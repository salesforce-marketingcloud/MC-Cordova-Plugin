/**
 * Copyright 2018 Salesforce, Inc
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.salesforce.marketingcloud.cordova

import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import org.assertj.core.api.Java6Assertions.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.StringReader
import java.util.*

@RunWith(RobolectricTestRunner::class)
class MCSdkConfigTest {

    private val testAppId = UUID.randomUUID().toString()
    private val testAccessToken = "abcdefghi123456789abcdef"
    private val testNotificationSmallIconName = "ic_notification"
    private val testSenderId = "123456789876"

    @Test
    fun parseConfig_minimumInput_producesConfigWithDefaultValues() {
        // GIVEN
        val testTse = "https://example.com/"
        FirebaseApp.initializeApp(RuntimeEnvironment.application, with(FirebaseOptions.Builder()) {
            setApplicationId("1:$testSenderId:android:12b123ab12345678")
            setProjectId("test-app")
            setGcmSenderId(testSenderId)
            build()
        })
        val configParser = """
      <preference name="com.salesforce.marketingcloud.app_id" value="$testAppId" />
      <preference name="com.salesforce.marketingcloud.access_token" value="$testAccessToken" />
      <preference name="com.salesforce.marketingcloud.notification_small_icon" value="$testNotificationSmallIconName" />
      <preference name="com.salesforce.marketingcloud.tenant_specific_endpoint" value="$testTse" />
    """.trimIndent().toXmlParser()

        // WHEN
        val config = MCSdkConfig.parseConfig(RuntimeEnvironment.application, configParser).build(
                RuntimeEnvironment.application)

        // THEN
        assertThat(config.applicationId).isEqualTo(testAppId)
        assertThat(config.accessToken).isEqualTo(testAccessToken)
        assertThat(config.senderId).isEqualTo(testSenderId)
        assertThat(config.marketingCloudServerUrl).isEqualTo(testTse)
        assertThat(config.analyticsEnabled).isFalse()
        assertThat(config.delayRegistrationUntilContactKeyIsSet).isFalse()
        assertThat(config.geofencingEnabled).isFalse()
        assertThat(config.proximityEnabled).isFalse()
        assertThat(config.piAnalyticsEnabled).isFalse()

        FirebaseApp.getInstance()?.delete()
    }

    @Test
    fun parseConfig_allConfigValues_producesConfigWithDefaultValues() {
        // GIVEN
        val testTse = "https://example.com/"
        val configParser = """
      <preference name="com.salesforce.marketingcloud.app_id" value="$testAppId" />
      <preference name="com.salesforce.marketingcloud.access_token" value="$testAccessToken" />
      <preference name="com.salesforce.marketingcloud.sender_id" value="$testSenderId" />
      <preference name="com.salesforce.marketingcloud.notification_small_icon" value="$testNotificationSmallIconName" />
      <preference name="com.salesforce.marketingcloud.analytics" value="true" />
      <preference name="com.salesforce.marketingcloud.delay_registration_until_contact_key_is_set" value="true" />
      <preference name="com.salesforce.marketingcloud.tenant_specific_endpoint" value="$testTse" />
    """.trimIndent().toXmlParser()

        // WHEN
        val config = MCSdkConfig.parseConfig(RuntimeEnvironment.application, configParser).build(
                RuntimeEnvironment.application)

        // THEN
        assertThat(config.applicationId).isEqualTo(testAppId)
        assertThat(config.accessToken).isEqualTo(testAccessToken)
        assertThat(config.senderId).isEqualTo(testSenderId)
        assertThat(config.analyticsEnabled).isTrue()
        assertThat(config.delayRegistrationUntilContactKeyIsSet).isTrue()
        assertThat(config.marketingCloudServerUrl).isEqualTo(testTse)
    }


    private fun String.toXmlParser(): XmlPullParser {
        val factory = XmlPullParserFactory.newInstance()
        factory.isNamespaceAware = false
        val parser = factory.newPullParser()
        parser.setInput(StringReader(this))
        return parser
    }
}