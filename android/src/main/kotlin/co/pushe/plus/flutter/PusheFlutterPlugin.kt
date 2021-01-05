package co.pushe.plus.flutter

import android.content.Context
import android.util.Log
import co.pushe.plus.flutter.Utils.lg
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * PusheFlutterPlugin
 * Main class that the developer who uses this plugin interacts with.
 * Class handles all configuration stuff which developer will do.
 * Mainly used functions are:
 *  [PusheFlutterPlugin.initialize]
 *  [PusheFlutterPlugin.debugMode]
 *  [PusheFlutterPlugin.registerWith] // both types
 * @author Mahdi Malvandi
 */
@Suppress("SpellCheckingInspection")
class PusheFlutterPlugin : FlutterPlugin, ActivityAware {

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        setUpChannel(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        PusheLifeCycle.isForeground = false
    }

    ///// Activity aware functions

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        PusheLifeCycle.isForeground = true
    }

    override fun onDetachedFromActivityForConfigChanges() {
        PusheLifeCycle.isForeground = false
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        PusheLifeCycle.isForeground = true
    }

    override fun onDetachedFromActivity() {
        PusheLifeCycle.isForeground = false
    }

    companion object {

        /**
         * In order to be able to use the library callbacks, you need to override the application class and make a custom one.
         * 1. Create a class called `App` in the root of `android/app/packageName`,
         * extend [io.flutter.app.FlutterApplication] and implement [io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback].
         * 2. Introduce it to the `AndroidManifest.xml` located at, `android/app/src/main/` as `android:name=".App" (or the full packageName of the class)
         * 3. Add [PusheFlutterPlugin.initialize] in `onCreate` method of the app class (override it if it does not exist).
         * 4. Add [PusheFlutterPlugin.registerWith] and pass the registry in the `registerWith` method (override it if it does not exist).
         * @param initializer is the instance of your app which follows the extending and implementing rule above.
         * @param <T> forces the instance to firstly, extend the FlutterApplication (Context) and secondly, implement PluginRegistrantCallback
         * 5. You're good at native side, you may follow the rest according to https://docs.pushe.co
         * -- Why is it here? -- To make usage more simple, this class will handle all the stuff and user does not need to know about any other classes.
        </T> */
        @JvmStatic
        fun <T> initialize(initializer: T) where T : Context, T : PluginRegistrantCallback {
            PusheNotificationListener.initialize(initializer)
        }

        /**
         * Registration for v1 embedded flutter projects
         * Might cause issue with proguard, so you better exclude it in the rules by adding
         * ```
         * -keep co.pushe.plus.flutter.** { *; }
         * ```
         */
        @JvmStatic
        fun registerWith(registry: PluginRegistry) {
            registerWith(registry.registrarFor("co.pushe.plus.flutter.PusheFlutterPlugin"))
        }

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            lg("Plugin registered using 'registerWith' static method")
            setUpChannel(registrar.context(), registrar.messenger())
        }

        @JvmStatic
        internal fun setUpChannel(context: Context?, messenger: BinaryMessenger?) {
            if (context == null || messenger == null) {
                Log.e("Pushe", "Unhandled exception occurred.\n" +
                        "Either BinaryMessenger or Android Context is null. So plugin can not set MessageHandlers")
                return
            }
            // Main Method handler
            val channel = MethodChannel(messenger, "plus.pushe.co/pushe_flutter")
            val callHandler = PusheChandler(context, messenger)
            channel.setMethodCallHandler(callHandler)

            // When background was applied
            val backgroundChannel = MethodChannel(messenger, "plus.pushe.co/pushe_flutter_background")
            backgroundChannel.setMethodCallHandler(callHandler)
            PusheNotificationListener.setBackgroundChannel(backgroundChannel)
        }

        /**
         * If set to true,
         * verbose logs will be printed to logcat,
         * so each step can be tracked and observed.
         */
        @JvmStatic
        var debugMode = false

        @JvmStatic
        fun appOnForeground(foreground: Boolean) {
            PusheLifeCycle.isForeground = foreground
        }
    }
}