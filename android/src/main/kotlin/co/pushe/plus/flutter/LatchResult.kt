package co.pushe.plus.flutter

import co.pushe.plus.flutter.Utils.lg
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch

/**
 * A concurrent handler of the Flutter background isolate.
 */
internal class LatchResult(latch: CountDownLatch) {
    val result: MethodChannel.Result

    init {
        result = object : MethodChannel.Result {
            override fun success(result: Any?) {
                lg("MethodChannel result, success")
                latch.countDown()
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                lg("MethodChannel result, error")
                latch.countDown()
            }

            override fun notImplemented() {
                lg("MethodChannel result, notImplemented")
                latch.countDown()
            }
        }
    }
}