package com.salesforce.etpush;

import android.os.Bundle;
import android.util.Log;
import org.json.JSONObject;
import org.json.JSONException;
import android.support.v4.app.FragmentActivity;
import java.util.Set;

public class ETPushCordovaLandingPagePassthrough extends FragmentActivity {

	private static final String TAG = CONSTS.LOG_TAG;

  /**
   * When this activity is created by events happening in the ET SDK,
	 *   call the appropriate methods in the plugin for cloudPageReceived and openDirectRecieved
   */
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState); 

    Bundle extras = this.getIntent().getExtras();

    if (this.getIntent().getExtras().containsKey(CONSTS.KEY_CLOUD_PAGE)) {
    	//Cloud Page
      String webPageUrl = extras.getString(CONSTS.KEY_CLOUD_PAGE);
      try {
      	ETPushCordovaPlugin.cloudPageReceived(new JSONObject().put(CONSTS.KEY_WEB_PAGE_URL, webPageUrl));
      } catch (JSONException e) {
    		Log.e(TAG, e.getMessage(), e);
      }
    }

    if (this.getIntent().getExtras().containsKey(CONSTS.KEY_OPEN_DIRECT)) {
    	//Open Direct
      String webPageUrl = extras.getString(CONSTS.KEY_OPEN_DIRECT);
      try {
      	ETPushCordovaPlugin.openDirectReceived(new JSONObject().put(CONSTS.KEY_WEB_PAGE_URL, webPageUrl));
      } catch (JSONException e) {
    		Log.e(TAG, e.getMessage(), e);
      }      
    } 

		finish(); //call finish so this activity doesn't show in UI
  }
}
