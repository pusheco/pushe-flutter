package co.pushe.plus.flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import co.pushe.plus.Pushe
import co.pushe.plus.analytics.PusheAnalytics
import co.pushe.plus.analytics.event.Ecommerce
import co.pushe.plus.analytics.event.Event
import co.pushe.plus.analytics.event.EventAction
import co.pushe.plus.fcm.PusheFCM
import co.pushe.plus.flutter.HandleStorage.saveMessageHandle
import co.pushe.plus.flutter.HandleStorage.saveSetupHandle
import co.pushe.plus.flutter.Pack.getCustomContentFromIntent
import co.pushe.plus.flutter.Pack.getNotificationJsonFromIntent
import co.pushe.plus.flutter.Utils.lg
import co.pushe.plus.notification.PusheNotification
import co.pushe.plus.notification.UserNotification
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/**
 * PusheChandler
 *
 * @author Mahdi Malvandi
 */
@Suppress("SpellCheckingInspection")
internal class PusheChandler(private val context: Context,
                             private val messenger: BinaryMessenger) : BroadcastReceiver(), MethodCallHandler {

    /**
     * Register a receiver to get Pushe foreground callbacks
     * See `onReceive` at the end of the file
     */
    init {
        val i = IntentFilter()
        val packageName = context.packageName
        i.addAction("$packageName.nr") // Receive
        i.addAction("$packageName.nc") // Click
        i.addAction("$packageName.nbc") // Button click
        i.addAction("$packageName.nd") // Dismiss
        i.addAction("$packageName.nccr") // CustomContent receive
        context.registerReceiver(this, i)
    }

    private val notificationTypes = listOf("IdType.DeviceId", "IdType.AdvertisingId", "IdType.CustomId")

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val methodName = call.method
        val notificationModule = Pushe.getPusheService(PusheNotification::class.java)
        val analyticsModule = Pushe.getPusheService(PusheAnalytics::class.java)
        val fcmModule = Pushe.getPusheService(PusheFCM::class.java)

        when (methodName) {
            "Pushe.initialize" -> Pushe.initialize()
            "Pushe.setUserConsentGiven" -> setUserConsentGiven(call, result)
            "Pushe.getUserConsentStatus" -> result.success(Pushe.getUserConsentStatus())
            "Pushe.getDeviceId" -> result.success(Pushe.getDeviceId())
            "Pushe.getAndroidId" -> result.success(Pushe.getAndroidId())
            "Pushe.getGoogleAdvertisingId" -> result.success(Pushe.getGoogleAdvertisingId())
            "Pushe.getAdvertisingId" -> result.success(Pushe.getAdvertisingId())
            "Pushe.getCustomId" -> result.success(Pushe.getCustomId())
            "Pushe.setCustomId" -> setCustomId(call, result)
            "Pushe.getUserEmail" -> result.success(Pushe.getUserEmail())
            "Pushe.setUserEmail" -> setUserEmail(call, result)
            "Pushe.getUserPhoneNumber" -> result.success(Pushe.getUserPhoneNumber())
            "Pushe.setUserPhoneNumber" -> setUserPhoneNumber(call, result)
            "Pushe.subscribe" -> subscribeToTopic(call, result)
            "Pushe.unsubscribe" -> unsubscribeFromTopic(call, result)
            "Pushe.enableNotifications" -> setNotificationEnabled(true, result, notificationModule)
            "Pushe.disableNotifications" -> setNotificationEnabled(false, result, notificationModule)
            "Pushe.enableCustomSound" -> setCustomSoundEnabled(true, result, notificationModule)
            "Pushe.disableCustomSound" -> setCustomSoundEnabled(false, result, notificationModule)
            "Pushe.isNotificationEnable" -> isNotificationEnabled(result, notificationModule)
            "Pushe.isCustomSoundEnabled" -> isCustomSoundEnabled(result, notificationModule)
            "Pushe.createNotificationChannel" -> createNotificationChannel(call, result, notificationModule)
            "Pushe.removeNotificationChannel" -> removeNotificationChannel(call, result, notificationModule)
            "Pushe.isInitialized" -> result.success(Pushe.isInitialized())
            "Pushe.isRegistered" -> result.success(Pushe.isRegistered())
            "Pushe.sendUserNotification" -> sendUserNotification(call, result, notificationModule)
            "Pushe.sendAdvancedUserNotification" -> sendAdvancedNotification(call, result, notificationModule)
            "Pushe.sendEvent" -> sendEvent(call, result, analyticsModule)
            "Pushe.sendEcommerceData" -> sendEcommerceData(call, result, analyticsModule)
            "Pushe.initNotificationListenerManually" -> initializeForegroundNotifications()
            "Pushe.setRegistrationCompleteListener" -> Pushe.setRegistrationCompleteListener {
                result.success(true)
            }
            "Pushe.setInitializationCompleteListener" -> Pushe.setInitializationCompleteListener {
                result.success(true)
            }
            "Pushe.addTags" -> addTag(call, result)
            "Pushe.removeTags" -> removeTags(call, result)
            "Pushe.getSubscribedTags" -> result.success(Pushe.getSubscribedTags())
            "Pushe.getSubscribedTopics" -> result.success(Pushe.getSubscribedTopics())
            "Pushe.notificationListener" -> setNotificationListeners(call, result)
            // Background init
            "Pushe.platformInitialized" -> initializeListenerPlatform(result)
            "Pushe.getActiveCourier" -> getActiveService(result)
            "Pushe.getFcmToken" -> getFcmTokenOrEmpty(result, fcmModule)
            "Pushe.getHmsToken" -> getHmsTokenOrEmpty(result)
            "Pushe.enableForceForegroundAware" -> enableForceForegroundAware(true, result, notificationModule)
            "Pushe.disableForceForegroundAware" -> enableForceForegroundAware(false, result, notificationModule)
            "Pushe.isForceForegroundAware" -> result.success(notificationModule?.isForegroundAwareByForce())
            else -> result.notImplemented()
        }
    }

    ///// Do stuff when a method was called

    private fun setUserConsentGiven(call: MethodCall, result: MethodChannel.Result) {
        try {
            Pushe.setUserConsentGiven(call.argument<Boolean>("enabled") ?: true)
            result.success(true)
        } catch (e: java.lang.Exception) {
            result.error("022", "Error occorred when parsing `enabled` argument. Must be of type bool", e.message)
        }
    }

    private fun setCustomId(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("id")) {
            Pushe.setCustomId(null)
            result.success(true)
            return
        }
        Pushe.setCustomId(call.argument("id"))
        result.success(true)
    }

    private fun setUserEmail(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("email")) {
            result.success(Pushe.setUserEmail(null))
            return
        }
        result.success(Pushe.setUserEmail(call.argument("email")))
    }

    private fun setUserPhoneNumber(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("phone")) {
            result.success(Pushe.setUserPhoneNumber(null))
            return
        }
        result.success(Pushe.setUserPhoneNumber(call.argument("phone")))
    }

    private fun subscribeToTopic(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("topic")) {
            result.error("004", "Call must contain 'topic'", null)
            return
        }
        try {
            Pushe.subscribeToTopic(call.argument("topic")) {
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("004", "Could not subscribe to topic ${e.message}", null)
        }
    }

    private fun unsubscribeFromTopic(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("topic")) {
            result.error("005", "Call must contain 'topic'", null)
            return
        }
        try {
            Pushe.unsubscribeFromTopic(call.argument("topic")) {
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("005", "Could not unsubscribe from topic ${e.message}", null)
        }
    }

    private fun setNotificationEnabled(enabled: Boolean, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("013", "Notification module is not ready. Notifications will not ba handled.", null)
            return
        }
        if (enabled) {
            notificationModule.enableNotifications()
        } else {
            notificationModule.disableNotifications()
        }
    }

    private fun isNotificationEnabled(result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("013", "Notification module is not ready. Notifications will not ba handled.", null)
            return
        }
        result.success(notificationModule.isNotificationEnable())
    }

    private fun sendUserNotification(call: MethodCall, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("006", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }

        if (!call.hasAll("type", "id", "title", "content")) {
            result.error("006", "Call must contain 'type', 'id', 'title' and 'content'", null)
            return
        }

        val type = call.argument<String>("type")
        lg("Type: $type")
        if (!notificationTypes.contains(type)) {
            result.error("006", "Type must be either 'DeviceId', 'GoogleAdvertisingId' or 'CustomId'", null)
            return
        }

        val id = call.argument<String>("id")
        if (id == null || id.isEmpty()) {
            result.error("006", "Id must not be null or empty", null)
            return
        }

        val notification = when (type) {
            "IdType.DeviceId" -> UserNotification.withDeviceId(id)
            "IdType.AdvertisingId" -> UserNotification.withAdvertisementId(id)
            "IdType.CustomId" -> UserNotification.withCustomId(id)
            else -> {
                result.error("006", "Type must be either 'DeviceId', 'GoogleAdvertisingId' or 'CustomId'", null)
                return
            }
        }

        val title = call.argument<String>("title")
        val content = call.argument<String>("content")
        val bigTitle = call.argument<String>("bigTitle")
        val bigContent = call.argument<String>("bigContent")
        val imageUrl = call.argument<String>("imageUrl")
        val iconUrl = call.argument<String>("iconUrl")
        val notifIcon = call.argument<String>("notifIcon")
        val customContent = call.argument<String>("customContent")
        notification?.setTitle(title)
          ?.setContent(content)
          ?.setBigTitle(bigTitle)
          ?.setBigContent(bigContent)
          ?.setImageUrl(imageUrl)
          ?.setIconUrl(iconUrl)
          ?.setNotifIcon(notifIcon)
          ?.setCustomContent(customContent)
        if (notification != null) {
            notificationModule.sendNotificationToUser(notification)
            result.success(true)
        } else {
            result.error("006", "There was a problem building notification for sending. Make sure data is provided correctly", null)
        }
    }

    private fun sendAdvancedNotification(call: MethodCall, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("020", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }
        if (!call.hasAll("type", "id", "advancedJson")) {
            result.error("020", "Call must contain 'type', 'id' and 'advancedJson' (Use jsonEncode for advancedJson)", null)
            return
        }

        val type = call.argument<String>("type")
        if (!notificationTypes.contains(type)) {
            result.error("020", "Type must be either 'DeviceId', 'GoogleAdvertisingId' or 'CustomId'", null)
            return
        }

        val id = call.argument<String>("id")
        if (id == null || id.isEmpty()) {
            result.error("020", "Id must not be null or empty", null)
            return
        }
        val notification = when (type) {
            "IdType.DeviceId" -> UserNotification.withDeviceId(id)
            "IdType.AdvertisingId" -> UserNotification.withAdvertisementId(id)
            "IdType.CustomId" -> UserNotification.withCustomId(id)
            else -> {
                result.error("006", "Type must be either 'DeviceId', 'GoogleAdvertisingId' or 'CustomId'", null)
                return
            }
        }
        val advancedJson = call.argument<String>("advancedJson")
        notification.setAdvancedNotification(advancedJson)
        notificationModule.sendNotificationToUser(notification)

    }

    private fun sendEvent(call: MethodCall, result: MethodChannel.Result, analyticsModule: PusheAnalytics?) {
        if (analyticsModule == null) {
            result.error("016", "Analytics module is not ready. Analytics APIs will not ba handled.", null)
            return
        }
        if (!call.hasArgument("name")) {
            result.error("016", "Call must contain 'name', only data and action are optional", null)
            return
        }
        val name = call.argument<String>("name")
        if (name == null || name.isEmpty()) {
            result.error("016", "Call must contain 'name', only data and action are optional", null)
            return
        }
        val action = call.argument<String>("action")

        val actualAction = when (action?.removePrefix("EventAction.")) {
            "custom" -> EventAction.CUSTOM
            "sign_up" -> EventAction.SIGN_UP
            "login" -> EventAction.LOGIN
            "purchase" -> EventAction.PURCHASE
            "achievement" -> EventAction.ACHIEVEMENT
            "level" -> EventAction.LEVEL
            else -> EventAction.CUSTOM
        }

        val eventBuilder = Event.Builder(name)
        eventBuilder.setAction(actualAction)
        call.argument<Map<String, Any>>("data")?.let {
            eventBuilder.setData(it)
        }
        analyticsModule.sendEvent(eventBuilder.build())
        result.success(true)
    }

    private fun sendEcommerceData(call: MethodCall, result: MethodChannel.Result, analyticsModule: PusheAnalytics?) {
        if (analyticsModule == null) {
            result.error("018", "Analytics module is not ready. Analytics APIs will not ba handled.", null)
            return
        }

        if (!call.hasAll("name", "price")) {
            result.error("018", "Call must contain 'name' and 'price'", null)
            return
        }
        val name = call.argument<String>("name")
        val price = call.argument<Double>("price")

        if (name == null || price == null) {
            result.error("018", "'name' and 'price' can not be null", null)
            return
        }

        val ecommerceBuilder = Ecommerce.Builder(name, price)
        if (call.hasArgument("category") && call.argument<String>("category")?.isNotBlank() == true) {
            ecommerceBuilder.setCategory(call.argument("category"))
        }
        if (call.hasArgument("quantity") && call.argument<Long>("quantity") != null) {
            ecommerceBuilder.setQuantity(call.argument("category"))
        }

        analyticsModule.sendEcommerceData(ecommerceBuilder.build())
        result.success(true)
    }

    private fun initializeListenerPlatform(result: MethodChannel.Result) {
        PusheNotificationListener.onInitialized(context)
        result.success(true)
    }

    private fun addTag(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("tags") || call.argument<Any>("tags") == null || call.argument<Any>("tags") !is Map<*, *>) {
            result.error("012", "Failed to add tags. No valid tags provided.", null)
            return
        }
        val tags: Map<String, String>? = call.argument<Map<String, String>>("tags")
        Pushe.addTags(tags) {
            result.success(true)
            return@addTags
        }
    }

    private fun removeTags(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("tags") && call.argument<Any>("tags") !is List<*>) {
            result.error("012", "Failed to remove tags. No tags provided.", null)
            return
        }
        val tags = call.argument<List<String>>("tags")!!
        Pushe.removeTags(tags) {
            result.success(true)
        }
    }

    private fun setCustomSoundEnabled(enabled: Boolean, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("017", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }
        if (enabled) {
            notificationModule.enableCustomSound()
        } else {
            notificationModule.disableCustomSound()
        }
        result.success(true)
    }

    private fun isCustomSoundEnabled(result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("017", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }
        result.success(notificationModule.isCustomSoundEnable())
    }

    private fun createNotificationChannel(call: MethodCall, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("019", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }

        if (!call.hasAll("channelId", "channelName")) {
            result.error("019", "Call must contain 'channelId' and 'channelName'", null)
            return
        }

        try {
            val channelId: String = call.argument<String>("channelId") ?: ""
            val channelName: String = call.argument<String>("channelName") ?: ""
            val description: String? = call.argument<String>("description")
            val importance: Int = call.argument<Int>("importance") ?: -1
            val enableLight: Boolean = call.argument<Boolean>("enableLight") ?: false
            val enableVibration: Boolean = call.argument<Boolean>("enableVibration") ?: false
            val showBadge: Boolean = call.argument<Boolean>("showBadge") ?: false
            val ledColor: Int = call.argument<Int>("ledColor") ?: 0
            val vibrationPattern: LongArray? = call.argument<LongArray>("vibrationPattern")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                notificationModule.createNotificationChannel(channelId, channelName, description, importance, enableLight, enableVibration, showBadge, ledColor, vibrationPattern)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("019", "Could not create notification channel.\n ${e.message}", null)
        }
    }

    private fun removeNotificationChannel(call: MethodCall, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("021", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }
        if (!call.hasArgument("channelId") || call.argument<String>("channelId") == null) {
            result.error("021", "Call must contain 'channelId' which is not null.", null)
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationModule.removeNotificationChannel(call.argument<Any>("channelId") as String)
        }
        result.success(true)
    }

    private fun setNotificationListeners(call: MethodCall, result: MethodChannel.Result) {
        var setupCallbackHandle: Long = 0
        var backgroundMessageHandle: Long = 0
        try {
            val setup = call.argument<Any>("setupHandle")
            val background = call.argument<Any>("backgroundHandle")
            setupCallbackHandle = if (setup is Int) {
                setup.toLong()
            } else {
                setup as Long
            }
            backgroundMessageHandle = if (background is Int) {
                background.toLong()
            } else {
                background as Long
            }
        } catch (e: Exception) {
            lg("There was an exception when getting callback handle from Dart side")
            e.printStackTrace()
        }
        saveSetupHandle(context, setupCallbackHandle)
        PusheNotificationListener.startBackgroundIsolate(context, setupCallbackHandle)
        saveMessageHandle(context, backgroundMessageHandle)
        result.success(true)
    }

    private fun enableForceForegroundAware(enabled: Boolean, result: MethodChannel.Result, notificationModule: PusheNotification?) {
        if (notificationModule == null) {
            result.error("030", "Notification module is not ready. Notification APIs will not ba handled.", null)
            return
        }
        if (enabled) {
            notificationModule.enableNotificationForceForegroundAware()
            result.success(true)
        } else {
            notificationModule.disableNotificationForceForegroundAware()
            result.success(true)
        }
    }

    // region Fcm and Hms

    private fun getActiveService(result: MethodChannel.Result) {
        Pushe.setInitializationCompleteListener {
            result.success(Pushe.getActiveCourier() ?: "")
        }
    }

    private fun getFcmTokenOrEmpty(result: MethodChannel.Result, fcmModule: PusheFCM?) {
        try {
            result.success(fcmModule?.getToken() ?: "")
        } catch (e: java.lang.Exception) {
            result.error("028", "Failed to fetch token", null)
            lg("Failed to fetch for Fcm Token")
        }
    }

    private fun getHmsTokenOrEmpty(result: MethodChannel.Result) {
        try {
            val hmsModule = Pushe.getPusheService(co.pushe.plus.hms.PusheHMS::class.java)
            result.success(hmsModule?.getToken() ?: "")
        } catch (e: NoClassDefFoundError) {
            result.error("029", """
                PusheHMS module is not added into the classPath. 
                Since it's optional make sure you add 
                implementation("co.pushe.plus:hms:${'$'}latest")
                in android/build.gradle in dependencies {}
            """.trimIndent(), null)
        } catch (e: java.lang.Exception) {
            result.error("029", "Failed to fetch token", null)
            lg("Failed to fetch for Hms Token")
        }
    }

    // endregion

    private fun initializeForegroundNotifications() {
        PusheNotificationListener.setNotificationCallbacks(context.applicationContext)
    }

    ///// Do stuff when a callback was received

    /**
     * Handle foreground notification callbacks
     * Callback are broadcasted, so this will receive the broadcast and send the parsed intent data as json to the dart side.
     */
    override fun onReceive(context: Context, intent: Intent) {
        val channel = MethodChannel(messenger, "plus.pushe.co/pushe_flutter")
        val packageName = context.packageName
        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(context.applicationContext, null)
        val action = if (intent.action == null) "" else intent.action
        if (action?.isEmpty() == true) {
            return
        }

        when (action) {
            "$packageName.nr" -> {
                channel.invokeMethod("Pushe.onNotificationReceived", getNotificationJsonFromIntent(intent).toString())
            }
            "$packageName.nc" -> {
                channel.invokeMethod("Pushe.onNotificationClicked", getNotificationJsonFromIntent(intent).toString())
            }
            "$packageName.nbc" -> {
                channel.invokeMethod("Pushe.onNotificationButtonClicked", getNotificationJsonFromIntent(intent).toString())
            }
            "$packageName.nccr" -> {
                channel.invokeMethod("Pushe.onCustomContentReceived", getCustomContentFromIntent(intent).toString())
            }
            "$packageName.nd" -> {
                channel.invokeMethod("Pushe.onNotificationDismissed", getNotificationJsonFromIntent(intent).toString())
            }
        }
    }

    ///// Utils

    /**
     * Check that if the the MethodCall which was received from dart side, contains all the keys in the arguement.
     */
    private fun MethodCall.hasAll(vararg keys: String): Boolean {
        var hasAll = true
        keys.forEach {
            if (!hasArgument(it)) {
                hasAll = false
                return@forEach
            }
        }
        return hasAll
    }


}