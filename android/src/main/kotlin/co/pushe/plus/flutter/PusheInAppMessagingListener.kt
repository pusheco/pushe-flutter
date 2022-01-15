package co.pushe.plus.flutter

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import co.pushe.plus.Pushe
import co.pushe.plus.flutter.InAppUtils.getInAppMessage
import co.pushe.plus.flutter.Utils.lg
import co.pushe.plus.inappmessaging.InAppMessage
import co.pushe.plus.inappmessaging.PusheInAppMessaging
import co.pushe.plus.inappmessaging.PusheInAppMessagingListener
import io.flutter.view.FlutterMain

object PusheInAppMessagingListener {

    fun setListeners(context: Context) {

        try {
            Pushe.getPusheService(PusheInAppMessaging::class.java)
        } catch (e: NoClassDefFoundError) {
            lg("""
                PusheInAppMessaging class does not exist in the classPath.
                Make sure you add the library since its existence is optional
                In you android/build.gradle add:
                implementation("co.pushe.plus:inappmessaging:$\\latest
            """.trimIndent())
        }

        val packageName = context.packageName
        val inAppMessaging = Pushe.getPusheService(PusheInAppMessaging::class.java)
        inAppMessaging?.setInAppMessagingListener(object : PusheInAppMessagingListener {
            override fun onInAppMessageReceived(inAppMessage: InAppMessage) {
                val message = getInAppMessage(inAppMessage)
                handleForegroundMessage(context, "$packageName.ir", "piam" to message.toString())
            }

            override fun onInAppMessageTriggered(inAppMessage: InAppMessage) {
                val message = getInAppMessage(inAppMessage)
                handleForegroundMessage(context, "$packageName.it", "piam" to message.toString())
            }

            override fun onInAppMessageDismissed(inAppMessage: InAppMessage) {
                val message = getInAppMessage(inAppMessage)
                handleForegroundMessage(context, "$packageName.id", "piam" to message.toString())
            }

            override fun onInAppMessageButtonClicked(inAppMessage: InAppMessage, index: Int) {
                val message = getInAppMessage(inAppMessage)
                handleForegroundMessage(context, "$packageName.ibc",
                        "piam" to message.toString(),
                        "index" to index.toString()
                )
            }

            override fun onInAppMessageClicked(inAppMessage: InAppMessage) {
                val message = getInAppMessage(inAppMessage)
                handleForegroundMessage(context, "$packageName.ic", "piam" to message.toString())
            }

        })
    }

    /**
     * If native callbacks were called when app is on the foreground, this function will handle the sending.
     * The method will broadcase an intent to throughout the app and the receiver (PusheFlutterPlugin itself)
     *    will receive it and send it to the dart side for execution.
     */
    private fun handleForegroundMessage(context: Context, action: String, vararg data: Pair<String?, String?>) {
        val main = Handler(Looper.getMainLooper())
        main.post {
            FlutterMain.ensureInitializationComplete(context, null)
            val i = Intent(action)
            i.setPackage(context.packageName)
            for (datum in data) {
                i.putExtra(datum.first, datum.second)
            }
            context.sendBroadcast(i)
        }
    }
}