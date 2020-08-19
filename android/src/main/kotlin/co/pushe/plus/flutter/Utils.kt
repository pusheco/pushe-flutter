package co.pushe.plus.flutter

import android.content.Intent
import android.util.Log
import co.pushe.plus.flutter.Utils.lg
import co.pushe.plus.inappmessaging.InAppMessage
import co.pushe.plus.notification.NotificationButtonData
import co.pushe.plus.notification.NotificationData
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/**
 * This static class will do all tasks related to parsing and packing.
 */
internal object Pack {

    @JvmStatic
    fun getNotificationJsonObject(data: NotificationData?, clickedButtonData: NotificationButtonData? = null): JSONObject? {
        if (data == null) {
            return null
        }
        val notificationObject = JSONObject()
        return try {
            notificationObject.apply {
                put("title", data.title)
                put("content", data.content)
                put("bigTitle", data.bigTitle)
                put("bigContent", data.bigContent)
                put("imageUrl", data.imageUrl)
                put("summary", data.summary)
                put("iconUrl", data.iconUrl)

                if (clickedButtonData != null) {
                    try {
                        put("clickedButton", getButtonJsonObject(clickedButtonData))
                    } catch (e: Exception) {
                        lg("[Parsing notification] Failed to add button to the notification data")
                    }
                }
                try {
                    put("json", JSONObject(data.customContent))
                } catch (e: Exception) {
                    lg("[Parsing notification] No json to put as customContent field")
                }
                try {
                    put("buttons", getButtonsJsonArray(data.buttons))
                } catch (e: Exception) {
                    lg("[Parsing notification] No buttons to put as customContent field")
                }
            }
            notificationObject
        } catch (e: JSONException) {
            Log.w("Pushe", "Failed to parse notification and convert it to Json.")
            null
        }
    }

    @JvmStatic
    fun getButtonJsonObject(buttonData: NotificationButtonData?): JSONObject? {
        if (buttonData == null) {
            return null
        }
        val o = JSONObject()
        return try {
            o.run {
                put("title", buttonData.text)
                put("icon", buttonData.icon)
            }
        } catch (e: JSONException) {
            Log.w("Pushe", "Failed to parse notification and convert it to Json.")
            null
        }
    }

    @JvmStatic
    fun getButtonsJsonArray(buttons: List<NotificationButtonData>): JSONArray? {
        val jA = JSONArray()
        for (i in buttons) {
            jA.put(getButtonJsonObject(i))
        }
        return jA
    }

    ///// Background extensions

    @JvmStatic
    fun getBackgroundNotificationObject(data: NotificationData, type: String, clickedButtonData: NotificationButtonData? = null): JSONObject? {
        val finalObject = JSONObject()
        val notificationObject = getNotificationJsonObject(data, clickedButtonData)
        if (notificationObject == null) {
            lg("Failed to get notification object")
            return null
        }

        finalObject.put("data", notificationObject)

        finalObject.put("type", type)

        return finalObject
    }

    @JvmStatic
    fun getCustomContent(json: Map<String, Any>): JSONObject {
        val customContent = JSONObject()
        customContent.put("json", JSONObject(json))
        customContent.put("type", Constants.CUSTOM_CONTENT)
        return customContent
    }

    @JvmStatic
    fun getNotificationJsonFromIntent(intent: Intent): JSONObject {
        val o = JSONObject()
        try {
            val data = intent.getStringExtra("data")
            o.put("data", JSONObject(data))
        } catch (e: JSONException) {
            lg("Failed to parse notification")
        }
        return o
    }

    @JvmStatic
    fun getCustomContentFromIntent(intent: Intent): JSONObject {
        val o = JSONObject()
        try {
            val data = intent.getStringExtra("json")
            o.put("json", JSONObject(data))
        } catch (e: JSONException) {
            lg("Failed to parse notification")
        }
        return o
    }

    @JvmStatic
    fun getButtonJsonFromIntent(intent: Intent): JSONObject? {
        var o: JSONObject? = JSONObject()
        try {
            val button = intent.getStringExtra("button")
            o = JSONObject(button)
        } catch (e: JSONException) {
            lg("Failed to parse notification button")
        }
        return o
    }

    @JvmStatic
    fun getNotificationAndButtonFromIntent(intent: Intent): JSONObject {
        val o = JSONObject()
        try {
            o.put("notification", getNotificationJsonFromIntent(intent))
            o.put("button", getButtonJsonFromIntent(intent))
        } catch (ignored: JSONException) {
        }
        return o
    }
}

object InAppUtils {
    @JvmStatic
    fun getInAppMessage(inAppMessage: InAppMessage): JSONObject {
        val o = JSONObject()
        try {
            o.put("title", inAppMessage.title)
            o.put("content", inAppMessage.content)
            val buttons = JSONArray()
            inAppMessage.buttons?.forEach { button ->
                val btnObject = JSONObject()
                btnObject.put("text", button.text)
                buttons.put(btnObject)
            }
            o.put("buttons", buttons)
        } catch (ignored: java.lang.Exception) {
            lg("Failed to parse InAppMessage")
        }
        return o
    }

    fun getInAppMessageFromIntent(intent: Intent): JSONObject? {
        val o = JSONObject()
        try {
            val data = intent.getStringExtra("piam")
            o.put("piam", JSONObject(data))
        } catch (ignored: java.lang.Exception) {
            lg("Failed to retrieve message from broadcast.")
        }
        return o
    }

    @JvmStatic
    fun getInAppMessageAndButtonFromIntent(intent: Intent): JSONObject {
        val o = JSONObject()
        try {
            o.put("message", getInAppMessageFromIntent(intent))
            o.put("index", intent.getStringExtra("index"))
        } catch (ignored: JSONException) {
        }
        return o
    }

}

/**
 * Normal util class
 *
 */
object Utils {

    /**
     * Specifies whether the app is in the background or foreground.
     */
    fun isAppOnForeground()= PusheLifeCycle.isForeground
    

    /**
     * Verbose logger. At first it is not enabled and it will be enabled using `PushePlugin.setDebugMode(true)`
     */
    @JvmStatic
    fun lg(message: String) {
        if (PushePlugin.debugMode) {
            Log.d("Pushe", message)
        }
    }
}

/**
 * Holding a static variable initialized in all lifecycle methods.
 * If the activity comes up means the user is using and the app is in foreground, otherwise any method calling is happening in the background. 
 */
internal object PusheLifeCycle {
    var isForeground: Boolean = false
}