package com.salesforce.marketingcloud.cordova

import com.google.common.truth.Truth.assertThat
import com.nhaarman.mockitokotlin2.any
import com.nhaarman.mockitokotlin2.argumentCaptor
import com.nhaarman.mockitokotlin2.inOrder
import com.nhaarman.mockitokotlin2.mock
import com.nhaarman.mockitokotlin2.verify
import com.nhaarman.mockitokotlin2.whenever
import com.salesforce.marketingcloud.MarketingCloudSdk
import com.salesforce.marketingcloud.messages.push.PushMessageManager
import com.salesforce.marketingcloud.registration.RegistrationManager
import org.apache.cordova.CallbackContext
import org.json.JSONArray
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class) @Config(shadows = [ShadowMarketingCloudSdk::class])
class MCCordovaPluginTest {

  val plugin = MCCordovaPlugin()
  val sdk = mock<MarketingCloudSdk>()
  val pushMessageManager = mock<PushMessageManager>()
  val registrationManager = mock<RegistrationManager>()
  val registrationEditor = mock<RegistrationManager.Editor>()
  val callbackContext = mock<CallbackContext>()

  @Before fun setup() {
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

  @After fun tearDown() {
    Mockito.reset(sdk, pushMessageManager, registrationEditor, registrationManager, callbackContext)
    ShadowMarketingCloudSdk.reset()
  }


  @Test fun execute_unknownAction_false() {
    assertThat(plugin.execute("unknown", JSONArray(), mock<CallbackContext>())).isFalse()
  }

  @Test fun execute_sdkInitializing_requestSdk() {
    ShadowMarketingCloudSdk.isInitializing(true)
    whenever(pushMessageManager.pushToken).thenReturn("testToken")

    assertThat(plugin.execute("getSystemToken", JSONArray(), callbackContext)).isTrue()

    assertThat(ShadowMarketingCloudSdk.getRecentSdkRequest()).isNotNull()
    ShadowMarketingCloudSdk.getRecentSdkRequest().ready(sdk)
    verify(callbackContext).success("testToken")
  }

  @Test fun execute_isPushEnabled_success() {
    ShadowMarketingCloudSdk.isReady(true)
    whenever(pushMessageManager.isPushEnabled).thenReturn(true)

    assertThat(plugin.execute("isPushEnabled", JSONArray(), callbackContext)).isTrue()

    verify(pushMessageManager).isPushEnabled
    verify(callbackContext).success(1)
  }

  @Test fun execute_enablePush_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(plugin.execute("enablePush", JSONArray(), callbackContext)).isTrue()

    verify(pushMessageManager).enablePush()
  }

  @Test fun execute_disablePush_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(plugin.execute("disablePush", JSONArray(), callbackContext)).isTrue()

    verify(pushMessageManager).disablePush()
  }

  @Test fun execute_getAttributes_success() {
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

  @Test fun execute_clearAttribute_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(
        plugin.execute("clearAttribute", JSONArray(listOf("attrKey")), callbackContext)).isTrue()

    inOrder(registrationEditor) {
      verify(registrationEditor).clearAttribute("attrKey")
      verify(registrationEditor).commit()
    }
  }

  @Test fun execute_setAttribute_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(
        plugin.execute("setAttribute", JSONArray(listOf("key1", "val1")), callbackContext)).isTrue()

    inOrder(registrationEditor) {
      verify(registrationEditor).setAttribute("key1", "val1")
      verify(registrationEditor).commit()
    }
  }

  @Test fun execute_getTags_success() {
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

  @Test fun execute_addTag_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(plugin.execute("addTag", JSONArray(listOf("tag1")), callbackContext)).isTrue()

    inOrder(registrationEditor) {
      verify(registrationEditor).addTag("tag1")
      verify(registrationEditor).commit()
    }
  }

  @Test fun execute_removeTag_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(plugin.execute("removeTag", JSONArray(listOf("tag1")), callbackContext)).isTrue()

    inOrder(registrationEditor) {
      verify(registrationEditor).removeTag("tag1")
      verify(registrationEditor).commit()
    }
  }

  @Test fun execute_getContactKey_success() {
    ShadowMarketingCloudSdk.isReady(true)
    whenever(registrationManager.contactKey).thenReturn("testContactKey")

    assertThat(plugin.execute("getContactKey", JSONArray(), callbackContext)).isTrue()

    verify(registrationManager).contactKey
    verify(callbackContext).success("testContactKey")
  }

  @Test fun execute_setContactKey_success() {
    ShadowMarketingCloudSdk.isReady(true)

    assertThat(plugin.execute("setContactKey", JSONArray(listOf("testContactKey")),
        callbackContext)).isTrue()

    inOrder(registrationEditor) {
      verify(registrationEditor).setContactKey("testContactKey")
      verify(registrationEditor).commit()
    }
  }
}