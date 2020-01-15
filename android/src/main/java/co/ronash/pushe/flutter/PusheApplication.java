package co.ronash.pushe.flutter;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.util.Log;
import android.util.Pair;
import org.json.JSONObject;

import java.util.Map;

import co.pushe.plus.Pushe;
import co.pushe.plus.notification.NotificationButtonData;
import co.pushe.plus.notification.NotificationData;
import co.pushe.plus.notification.PusheNotification;
import co.pushe.plus.notification.PusheNotificationListener;
import io.flutter.app.FlutterApplication;
import io.flutter.view.FlutterMain;

public class PusheApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        initializeNotificationListeners(this);
    }

    public static void initializeNotificationListeners(final Context context) {
        final Context c = context.getApplicationContext();
        Pushe.getPusheService(PusheNotification.class).setNotificationListener(new PusheNotificationListener() {
            @Override
            public void onNotification(@NonNull NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".NOTIFICATION_RECEIVED",
                Pair.create("data", notificationData.toString()));
                Log.i("PusheApplication",notificationData.toString());
            }

            @Override
            public void onCustomContentNotification(@NonNull Map<String, Object> customContent) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".NOTIFICATION_CUSTOM_CONTENT_RECEIVED",
                Pair.create("json", customContent.toString()));
            }

            @Override
            public void onNotificationClick(@NonNull NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".NOTIFICATION_CLICKED",
                        Pair.create("data", notificationData.toString()));
            }

            @Override
            public void onNotificationDismiss(@NonNull NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".NOTIFICATION_DISMISSED",
                Pair.create("data", notificationData.toString()));
            }

            @Override
            public void onNotificationButtonClick(@NonNull NotificationButtonData notificationButtonData, @NonNull NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".NOTIFICATION_BUTTON_CLICKED",
                Pair.create("data", notificationData.toString()),
                Pair.create("button", notificationButtonData.toString()));
            }
        });
    }

    @SafeVarargs
    private static void sendBroadcastOnMainThread(final Context context, final String action, final Pair<String, String>... data) {
        final Handler main = new Handler(Looper.getMainLooper());
        main.post(new Runnable() {
            @Override
            public void run() {
                FlutterMain.ensureInitializationComplete(context, null);
                Intent i = new Intent(action);
                for (Pair<String, String> datum : data) {
                    i.putExtra(datum.first, datum.second);
                }
                context.sendBroadcast(i);
            }
        });
    }

}
