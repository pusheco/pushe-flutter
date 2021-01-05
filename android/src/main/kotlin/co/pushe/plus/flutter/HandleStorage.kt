package co.pushe.plus.flutter

import android.content.Context

/**
 * This object is mainly used to save and retrieve callback handles of dart side callback methods.
 * One is the setup which will be called when the plugin was initialized on app startup.
 * The other one is the callback which developer defines it as a static method or top level function and passes it to Plugin.
 * 
 * SetupHandle: Is a top level method which that handles waking the channel and initializing for telling the plugin that the isolate is running
 *    and plugin can call the background stuff and send them through channel to dart.
 *    
 * MessageHandle: Is the top level or static method that the user defines and passes to the `Pushe.setNotificationListener`.
 */
internal object HandleStorage {
    private const val SHARED_PREFERENCES_KEY = "pushe_storage"
    private const val BACKGROUND_SETUP_CALLBACK_HANDLE_KEY = "pushe_background_setup_handle"
    private const val BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY = "pushe_background_message_handle"

    @JvmStatic
    fun saveSetupHandle(context: Context, setupHandle: Long) {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0x0000)
        preferences.edit().putLong(BACKGROUND_SETUP_CALLBACK_HANDLE_KEY, setupHandle).apply()
    }

    @JvmStatic
    fun saveMessageHandle(context: Context, messageHandle: Long) {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0x0000)
        preferences.edit().putLong(BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY, messageHandle).apply()
    }

    @JvmStatic
    fun getSetupHandle(context: Context): Long {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0x0000)
        return preferences.getLong(BACKGROUND_SETUP_CALLBACK_HANDLE_KEY, 0)
    }

    @JvmStatic
    fun getMessageHandle(context: Context): Long {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0x0000)
        return preferences.getLong(BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY, 0)
    }

    @JvmStatic
    fun hasSetupHandle(context: Context): Boolean {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0x0000)
        return preferences.contains(BACKGROUND_SETUP_CALLBACK_HANDLE_KEY)
    }

    @JvmStatic
    fun hasMessageHandle(context: Context): Boolean {
        val preferences = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0x0000)
        return preferences.contains(BACKGROUND_MESSAGE_CALLBACK_HANDLE_KEY)
    }
}