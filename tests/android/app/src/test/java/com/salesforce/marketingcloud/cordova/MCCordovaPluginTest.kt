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

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.nhaarman.mockitokotlin2.*
import com.salesforce.marketingcloud.MCLogListener
import com.salesforce.marketingcloud.MarketingCloudSdk
import com.salesforce.marketingcloud.messages.push.PushMessageManager
import com.salesforce.marketingcloud.notifications.NotificationMessage
import com.salesforce.marketingcloud.registration.RegistrationManager
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaWebView
import org.apache.cordova.PluginResult
import org.assertj.core.api.Java6Assertions.assertThat
import org.json.JSONArray
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLog
import java.util.concurrent.ExecutorService

@RunWith(RobolectricTestRunner::class)
@Config(shadows = [ShadowMarketingCloudSdk::class, ShadowNotificationManager::class])
class MCCordovaPluginTest {

    val plugin = MCCordovaPlugin()
    val testExecutorService = mock<ExecutorService> {
        on { execute(any()) } doAnswer { (it.arguments[0] as? Runnable)?.run() }
    }
    val sdk = mock<MarketingCloudSdk>()
    val pushMessageManager = mock<PushMessageManager>()
    val registrationManager = mock<RegistrationManager>()
    val registrationEditor = mock<RegistrationManager.Editor>()
    val callbackContext = mock<CallbackContext>()

    @Before
    fun setup() {
        plugin.cordova = mock<CordovaInterface> {
            on { threadPool } doReturn testExecutorService
        }
        whenever(registrationEditor.addTag(any())).thenReturn(registrationEditor)
        whenever(registrationEditor.removeTag(any())).thenReturn(registrationEditor)
        whenever(registrationEditor.setAttribute(any(), any())).thenReturn(registrationEditor)
        whenever(registrationEditor.clearAttribute(any())).thenReturn(registrationEditor)
        whenever(registrationEditor.setContactKey(any())).thenReturn(registrationEditor)

        whenever(registrationManager.edit()).thenReturn(registrationEditor)

        whenever(sdk.pushMessageManager).thenReturn(pushMessageManager)
        whenever(sdk.registrationManager).thenReturn(registrationManager)

        ShadowMarketingCloudSdk.setInstance(sdk)
    }

    @After
    fun tearDown() {
        Mockito.reset(sdk, pushMessageManager, registrationEditor, registrationManager, callbackContext)
        ShadowNotificationManager.reset()
        ShadowMarketingCloudSdk.reset()
    }


    @Test
    fun execute_unknownAction_false() {
        assertThat(plugin.execute("unknown", JSONArray(), mock<CallbackContext>())).isFalse()
    }

    @Test
    fun execute_sdkInitializing_requestSdk() {
        ShadowMarketingCloudSdk.isInitializing(true)
        whenever(pushMessageManager.pushToken).thenReturn("testToken")

        assertThat(plugin.execute("getSystemToken", JSONArray(), callbackContext)).isTrue()

        assertThat(ShadowMarketingCloudSdk.getRecentSdkRequest()).isNotNull()
        ShadowMarketingCloudSdk.getRecentSdkRequest().ready(sdk)
        verify(callbackContext).success("testToken")
    }

    @Test
    fun execute_isPushEnabled_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(pushMessageManager.isPushEnabled).thenReturn(true)

        assertThat(plugin.execute("isPushEnabled", JSONArray(), callbackContext)).isTrue()

        verify(pushMessageManager).isPushEnabled
        verify(callbackContext).success(1)
    }

    @Test
    fun execute_enablePush_success() {
        ShadowMarketingCloudSdk.isReady(true)

        assertThat(plugin.execute("enablePush", JSONArray(), callbackContext)).isTrue()

        verify(pushMessageManager).enablePush()
    }

    @Test
    fun execute_disablePush_success() {
        ShadowMarketingCloudSdk.isReady(true)

        assertThat(plugin.execute("disablePush", JSONArray(), callbackContext)).isTrue()

        verify(pushMessageManager).disablePush()
    }

    @Test
    fun execute_getAttributes_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationManager.attributes).thenReturn(mapOf("key1" to "val1", "key2" to "val2"))

        assertThat(plugin.execute("getAttributes", JSONArray(), callbackContext)).isTrue()

        argumentCaptor<JSONObject>().apply {
            verify(callbackContext).success(capture())
        }.firstValue.run {
            assertThat(getString("key1")).isEqualTo("val1")
            assertThat(getString("key2")).isEqualTo("val2")
        }
    }

    @Test
    fun execute_clearAttribute_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(true)

        assertThat(
                plugin.execute("clearAttribute", JSONArray(listOf("attrKey")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).clearAttribute("attrKey")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(1)
    }

    @Test
    fun execute_clearAttribute_error() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(false)

        assertThat(
                plugin.execute("clearAttribute", JSONArray(listOf("attrKey")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).clearAttribute("attrKey")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(0)
    }

    @Test
    fun execute_setAttribute_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(true)

        assertThat(
                plugin.execute("setAttribute", JSONArray(listOf("key1", "val1")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).setAttribute("key1", "val1")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(1)
    }

    @Test
    fun execute_setAttribute_error() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(false)

        assertThat(
                plugin.execute("setAttribute", JSONArray(listOf("key1", "val1")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).setAttribute("key1", "val1")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(0)
    }

    @Test
    fun execute_getTags_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationManager.tags).thenReturn(setOf("tag1"))

        assertThat(plugin.execute("getTags", JSONArray(), callbackContext)).isTrue()

        verify(registrationManager).tags
        argumentCaptor<JSONArray>().apply {
            verify(callbackContext).success(capture())
        }.firstValue.run {
            assertThat(getString(0)).isEqualTo("tag1")
        }
    }

    @Test
    fun execute_addTag_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(true)

        assertThat(plugin.execute("addTag", JSONArray(listOf("tag1")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).addTag("tag1")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(1)
    }

    @Test
    fun execute_addTag_error() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(false)

        assertThat(plugin.execute("addTag", JSONArray(listOf("tag1")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).addTag("tag1")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(0)
    }

    @Test
    fun execute_removeTag_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(true)

        assertThat(plugin.execute("removeTag", JSONArray(listOf("tag1")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).removeTag("tag1")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(1)
    }

    @Test
    fun execute_removeTag_error() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(false)

        assertThat(plugin.execute("removeTag", JSONArray(listOf("tag1")), callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).removeTag("tag1")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(0)
    }

    @Test
    fun execute_getContactKey_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationManager.contactKey).thenReturn("testContactKey")

        assertThat(plugin.execute("getContactKey", JSONArray(), callbackContext)).isTrue()

        verify(registrationManager).contactKey
        verify(callbackContext).success("testContactKey")
    }

    @Test
    fun execute_setContactKey_success() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(true)

        assertThat(plugin.execute("setContactKey", JSONArray(listOf("testContactKey")),
                callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).setContactKey("testContactKey")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(1)
    }

    @Test
    fun execute_setContactKey_error() {
        ShadowMarketingCloudSdk.isReady(true)
        whenever(registrationEditor.commit()).thenReturn(false)

        assertThat(plugin.execute("setContactKey", JSONArray(listOf("testContactKey")),
                callbackContext)).isTrue()

        inOrder(registrationEditor) {
            verify(registrationEditor).setContactKey("testContactKey")
            verify(registrationEditor).commit()
        }

        verify(callbackContext).success(0)
    }

    @Test
    fun execute_enableVerboseLogging_success() {
        assertThat(plugin.execute("enableVerboseLogging", JSONArray(), callbackContext)).isTrue()

        assertThat(ShadowMarketingCloudSdk.getLogLevel()).isEqualTo(MCLogListener.VERBOSE)
        assertThat(ShadowMarketingCloudSdk.getLogListener()).isInstanceOf(
                MCLogListener.AndroidLogListener::class.java)
    }


    @Test
    fun execute_disableVerboseLogging_success() {
        assertThat(plugin.execute("disableVerboseLogging", JSONArray(), callbackContext)).isTrue()

        assertThat(ShadowMarketingCloudSdk.getLogListener()).isNull()
    }

    @Test
    fun pushReceived_callbackRegister_pushOpenedNotSubscribed_doesNotDeliverPushToCallback() {
        // GIVEN
        assertThat(plugin.execute("registerEventsChannel", JSONArray(), callbackContext)).isTrue()

        // WHEN
        plugin.onNewIntent(intentWithMessage(createMockNotificationMessage()))

        // THEN
        verifyNoMoreInteractions(callbackContext)
    }

    @Test
    fun pushOpenedSubscribed_afterOnNewIntent_sendsCachedPush() {
        // GIVEN
        assertThat(plugin.execute("registerEventsChannel", JSONArray(), callbackContext)).isTrue()
        val notificationMessage = createMockNotificationMessage(openDirectUrl = "https://salesforce.com")
        val intentWithMessage = intentWithMessage(notificationMessage)
        ShadowNotificationManager.expectedMessage = notificationMessage
        plugin.onNewIntent(intentWithMessage)

        // WHEN
        plugin.execute("subscribe", JSONArray().apply { put("notificationOpened") }, mock<CallbackContext>())

        // THEN
        argumentCaptor<PluginResult>().apply {
            verify(callbackContext).sendPluginResult(capture())
        }.firstValue.run {
            assertThat(keepCallback).isTrue()
            assertThat(status).isEqualTo(PluginResult.Status.OK.ordinal)
            assertThat(message).isNotNull()
            JSONObject(message).run {
                assertThat(get("timeStamp")).isNotNull().isInstanceOf(java.lang.Long::class.java)
                assertThat(getString("type")).isEqualTo("notificationOpened")
                JSONObject(getString("values")).run {
                    assertThat(getString("url")).isEqualTo("https://salesforce.com")
                    assertThat(getString("type")).isEqualTo("openDirect")
                    assertThat(optString("alert", null)).isNotNull()
                    assertThat(optString("_sid", null)).isNotNull()
                    assertThat(optString("_m", null)).isNotNull()
                }
            }
        }
    }

    @Test
    fun pushOpenedSubscribed_beforeOnNewIntent_sendsPushWhenReceived() {
        // GIVEN
        assertThat(plugin.execute("registerEventsChannel", JSONArray(), callbackContext)).isTrue()
        plugin.execute("subscribe", JSONArray().apply { put("notificationOpened") }, mock<CallbackContext>())
        val notificationMessage = createMockNotificationMessage(cloudPageUrl = "https://salesforce.com")
        val intentWithMessage = intentWithMessage(notificationMessage)
        ShadowNotificationManager.expectedMessage = notificationMessage

        // WHEN
        plugin.onNewIntent(intentWithMessage)

        // THEN
        argumentCaptor<PluginResult>().apply {
            verify(callbackContext).sendPluginResult(capture())
        }.firstValue.run {
            assertThat(keepCallback).isTrue()
            assertThat(status).isEqualTo(PluginResult.Status.OK.ordinal)
            assertThat(message).isNotNull()
            JSONObject(message).run {
                assertThat(get("timeStamp")).isNotNull().isInstanceOf(java.lang.Long::class.java)
                assertThat(getString("type")).isEqualTo("notificationOpened")
                JSONObject(getString("values")).run {
                    assertThat(getString("url")).isEqualTo("https://salesforce.com")
                    assertThat(getString("type")).isEqualTo("cloudPage")
                    assertThat(optString("alert", null)).isNotNull()
                    assertThat(optString("_sid", null)).isNotNull()
                    assertThat(optString("_m", null)).isNotNull()
                }
            }
        }
    }

    @Test
    fun pushOpenedSubscribed_afterInitializaWithPush_sendsCachedPush() {
        // GIVEN
        assertThat(plugin.execute("registerEventsChannel", JSONArray(), callbackContext)).isTrue()
        val notificationMessage = createMockNotificationMessage()
        val intentWithMessage = intentWithMessage(notificationMessage)
        ShadowNotificationManager.expectedMessage = notificationMessage
        val cordovaActivity = mock<Activity> {
            on { intent } doReturn intentWithMessage
        }
        val cordovaInterface = mock<CordovaInterface> {
            on { activity } doReturn cordovaActivity
        }
        plugin.initialize(cordovaInterface, mock<CordovaWebView>())

        // WHEN
        plugin.execute("subscribe", JSONArray().apply { put("notificationOpened") }, mock<CallbackContext>())

        // THEN
        argumentCaptor<PluginResult>().apply {
            verify(callbackContext).sendPluginResult(capture())
        }.firstValue.run {
            assertThat(keepCallback).isTrue()
            assertThat(status).isEqualTo(PluginResult.Status.OK.ordinal)
            assertThat(message).isNotNull()
            JSONObject(message).run {
                assertThat(get("timeStamp")).isNotNull().isInstanceOf(java.lang.Long::class.java)
                assertThat(getString("type")).isEqualTo("notificationOpened")
                JSONObject(getString("values")).run {
                    assertThat(getString("type")).isEqualTo("other")
                    assertThat(optString("alert", null)).isNotNull()
                    assertThat(optString("_sid", null)).isNotNull()
                    assertThat(optString("_m", null)).isNotNull()
                }
            }
        }
    }

    @Test
    fun urlAction_sendsUrlResult() {
        // GIVEN
        val url = "http://www.salesforce.com"
        assertThat(plugin.execute("registerEventsChannel", JSONArray(), callbackContext)).isTrue()
        plugin.execute("subscribe", JSONArray().apply { put("urlAction") }, mock<CallbackContext>())

        // WHEN
        //plugin.handleUrl(mock<Context>(), url, "webUrl")

        // THEN
        argumentCaptor<PluginResult>().apply {
            verify(callbackContext).sendPluginResult(capture())
        }.firstValue.run {
            assertThat(keepCallback).isTrue()
            assertThat(status).isEqualTo(PluginResult.Status.OK.ordinal)
            assertThat(message).isNotNull()
            JSONObject(message).run {
                assertThat(getString("type")).isEqualTo("urlAction")
                assertThat(getString("url")).isEqualTo(url)
            }
        }
    }

    @Test
    fun logSdkState_printsStateToLog() {
        // GIVEN
        ShadowMarketingCloudSdk.isReady(true)
        val testState = JSONObject().apply { put("state", "a".repeat(4000)) }
        given(sdk.sdkState).willReturn(testState)

        // WHEN
        val callSuccess = plugin.execute("logSdkState", JSONArray(), callbackContext)

        assertThat(callSuccess).isTrue()
        val stateLogs = ShadowLog.getLogsForTag("MCSDK STATE")
        assertThat(stateLogs).hasSize(2) // Should have split log into two calls given size of sdk state
        verify(callbackContext).success()
    }

    private fun intentWithMessage(message: NotificationMessage): Intent {
        return Intent().apply {
            putExtra("com.salesforce.marketingcloud.notifications.EXTRA_MESSAGE", message)
        }
    }

    private fun createMockNotificationMessage(messageId: String = "mId", alert: String = "Alert text",
        openDirectUrl: String? = null, cloudPageUrl: String? = null): NotificationMessage {
        val data = mutableMapOf("_sid" to "SFMC", "_m" to messageId, "alert" to alert).apply {
            if (openDirectUrl != null) {
                put("_od", openDirectUrl)
            } else if (cloudPageUrl != null) {
                put("_x", cloudPageUrl)
            }
        }
        val notificationMessage = mock<NotificationMessage>()
        whenever(notificationMessage.id).thenReturn(messageId)
        whenever(notificationMessage.alert).thenReturn(alert)
        whenever(notificationMessage.sound).thenReturn(NotificationMessage.Sound.DEFAULT)
        whenever(notificationMessage.url).thenReturn(cloudPageUrl ?: openDirectUrl)
        whenever(notificationMessage.type).thenReturn(
            if (cloudPageUrl != null) { NotificationMessage.Type.CLOUD_PAGE }
            else if (openDirectUrl != null) { NotificationMessage.Type.OPEN_DIRECT }
            else { NotificationMessage.Type.OTHER}
        )
        whenever(notificationMessage.trigger).thenReturn(NotificationMessage.Trigger.PUSH)
        whenever(notificationMessage.customKeys).thenReturn(emptyMap())
        whenever(notificationMessage.payload).thenReturn(data)
        return notificationMessage
    }
}
