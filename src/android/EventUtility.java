/**
 * Copyright 2018 Salesforce, Inc
 * <p>
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 * <p>
 * 1. Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 * <p>
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 * <p>
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific prior written permission.
 * <p>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.salesforce.marketingcloud.cordova;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import androidx.annotation.Nullable;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.salesforce.marketingcloud.sfmcsdk.components.events.CartEvent;
import com.salesforce.marketingcloud.sfmcsdk.components.events.CatalogEvent;
import com.salesforce.marketingcloud.sfmcsdk.components.events.CatalogObject;
import com.salesforce.marketingcloud.sfmcsdk.components.events.Event;
import com.salesforce.marketingcloud.sfmcsdk.components.events.EventManager;
import com.salesforce.marketingcloud.sfmcsdk.components.events.LineItem;
import com.salesforce.marketingcloud.sfmcsdk.components.events.Order;
import com.salesforce.marketingcloud.sfmcsdk.components.events.OrderEvent;


public class EventUtility {

    private static int MAX_LOG_LENGTH = 4000;

    static Event toEvent(JSONObject jsonObject){
        try {
            String objType = jsonObject.optString("objType");
            switch (objType) {
                case "CartEvent":
                    return createCartEvent(jsonObject);
                case "CustomEvent":
                    return EventManager.customEvent(jsonObject.optString("name"), toMap(jsonObject.optJSONObject("attributes")));
                case "OrderEvent":
                    return createOrderEvent(jsonObject);
                case "CatalogObjectEvent":
                    return createCatalogEvent(jsonObject);
                default:
                    return null;
                    // return checkForOtherEvents(jsonObject);
            }
        }catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    private static CartEvent createCartEvent(JSONObject jsonObject) {
        CartEvent cartEvent = null;
        final LineItem lineItem = getLineItem(jsonObject.optJSONObject("lineItem"));
        switch (jsonObject.optString("name")) {
            case "Add To Cart":
                cartEvent = CartEvent.add(lineItem);
                break;
            case "Remove From Cart":
                cartEvent = CartEvent.remove(lineItem);
                break;
            case "Replace Cart":
                cartEvent = CartEvent.replace(new ArrayList<LineItem>() {{
                    add(lineItem);
                }});
                break;
            default:
                break;
        }
        return cartEvent;
    }

    private static OrderEvent createOrderEvent(JSONObject jsonObject) {
        OrderEvent orderEvent = null;
        switch (jsonObject.optString("name")) {
            case "Purchase":
                orderEvent = OrderEvent.purchase(getOrder(jsonObject.optJSONObject("order")));
                break;
            case "Preorder":
                orderEvent = OrderEvent.preorder(getOrder(jsonObject.optJSONObject("order")));
                break;
            case "Cancel":
                orderEvent = OrderEvent.cancel(getOrder(jsonObject.optJSONObject("order")));
                break;
            case "Ship":
                orderEvent = OrderEvent.ship(getOrder(jsonObject.optJSONObject("order")));
                break;
            case "Deliver":
                orderEvent = OrderEvent.deliver(getOrder(jsonObject.optJSONObject("order")));
                break;
            case "Return":
                orderEvent = OrderEvent.returnOrder(getOrder(jsonObject.optJSONObject("order")));
                break;
            case "Exchange":
                orderEvent = OrderEvent.exchange(getOrder(jsonObject.optJSONObject("order")));
                break;
        }
        return orderEvent;
    }

    private static Event createCatalogEvent(JSONObject jsonObject) throws JSONException {
        String category = jsonObject.optString("name");
        switch (category) {
            case "Comment Catalog Object":
                return CatalogEvent.comment(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
            case "View Catalog Object":
                return CatalogEvent.view(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
            case "Quick View Catalog Object":
                return CatalogEvent.quickView(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
            case "View Catalog Object Detail":
                return CatalogEvent.viewDetail(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
            case "Favorite Catalog Object":
                return CatalogEvent.favorite(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
            case "Share Catalog Object":
                return CatalogEvent.share(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
            case "Review Catalog Object":
                return CatalogEvent.review(getCatalogObject(jsonObject.optJSONObject("catalogObject")));
        }
        return null;
    }

    private static Order getOrder(JSONObject order) {
        String id = order.optString("id");
        String currency = order.optString("currency");
        double totalValue = order.optDouble("totalValue");
        JSONArray lineItems = order.optJSONArray("lineItems");
        JSONObject attributes = order.optJSONObject("attributes");
        Map<String, Object> attributesMap = getAttributesMap(attributes);
        if (attributesMap == null) {
            return new Order(id, getLineItems(lineItems), totalValue, currency);
        } else {
            return new Order(id, getLineItems(lineItems), totalValue, currency, attributesMap);
        }
    }

    private static List<LineItem> getLineItems(JSONArray jsonArray) {
        List<LineItem> items = null;
        if (jsonArray != null && jsonArray.length() > 0) {
            items = new ArrayList<>();
            for (int i = 0; i < jsonArray.length(); i++) {
                try {
                    LineItem item = getLineItem(jsonArray.getJSONObject(i));
                    items.add(item);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
        return items;
    }

    private static LineItem getLineItem(JSONObject lineItem) {
        String catalogObjectType = lineItem.optString("catalogObjectType");
        String catalogObjectId = lineItem.optString("catalogObjectId");
        int quantity = lineItem.optInt("quantity");
        double price = lineItem.optDouble("price");
        String currency = lineItem.optString("currency");
        JSONObject attributes = lineItem.optJSONObject("attributes");
        Map<String, Object> attributesMap = getAttributesMap(attributes);
        if (attributesMap == null) {
            return new LineItem(catalogObjectType, catalogObjectId, quantity, price, currency);
        }
        return new LineItem(catalogObjectType, catalogObjectId, quantity, price, currency, attributesMap);
    }

    private static CatalogObject getCatalogObject(JSONObject catalogObject) throws JSONException {
        String type = catalogObject.optString("type");
        String id = catalogObject.optString("id");
        JSONObject attributes = catalogObject.optJSONObject("attributes");
        JSONObject relatedCatalogObjects = catalogObject.optJSONObject("relatedCatalogObjects");
        return new CatalogObject(type, id, toMap(attributes), getRelatedCatalogObjects(relatedCatalogObjects));
    }

    private static Map<String, List<String>> getRelatedCatalogObjects(JSONObject relatedCatalogObjects) {
        if (relatedCatalogObjects == null) {
            return null;
        }
        Map<String, List<String>> map = new HashMap<>();
        Iterator<String> iterator = relatedCatalogObjects.keys();

        while (iterator.hasNext()) {
            String key = iterator.next();
            Object value = relatedCatalogObjects.opt(key);
            if (value instanceof JSONArray) {
                map.put(key, toList((JSONArray) value));
            }
        }
        return map;
    }

    @Nullable
    private static Map<String, Object> getAttributesMap(JSONObject attributes) {
        Map<String, Object> attributesMap = null;
        try {
            attributesMap = toMap(attributes);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return attributesMap;
    }

    static JSONObject fromMap(Map<String, String> map) throws JSONException {
        JSONObject data = new JSONObject();
        if (map != null && !map.isEmpty()) {
            for (Map.Entry<String, String> entry : map.entrySet()) {
                data.put(entry.getKey(), entry.getValue());
            }
        }
        return data;
    }

    static JSONArray fromCollection(Collection<String> collection) {
        JSONArray data = new JSONArray();
        if (collection != null && !collection.isEmpty()) {
            for (String s : collection) {
                data.put(s);
            }
        }
        return data;
    }

    static Map<String, Object> toMap(JSONObject jsonobj)  throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();
        Iterator<String> keys = jsonobj.keys();
        while(keys.hasNext()) {
            String key = keys.next();
            Object value = jsonobj.get(key);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }   
            map.put(key, value);
        }   return map;
    }

    static List<String> toList(JSONArray jsonArray) {
        if (jsonArray == null || jsonArray.length() < 1) {
            return null;
        }
        List<String> objectIds = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            objectIds.add(jsonArray.optString(i));
        }
        return objectIds;
    }

    static void log(String tag, String msg) {
        for (int i = 0, length = msg.length(); i < length; i += MAX_LOG_LENGTH) {
            Log.println(Log.DEBUG, tag, msg.substring(i, Math.min(length, i + MAX_LOG_LENGTH)));
        }
    }
}
