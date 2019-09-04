package co.ronash.pushe.flutter;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.util.Pair;
import org.json.JSONObject;
import co.ronash.pushe.NotificationButtonData;
import co.ronash.pushe.NotificationData;
import co.ronash.pushe.Pushe;
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
        Pushe.setNotificationListener(new Pushe.NotificationListener() {
            @Override
            public void onNotificationReceived(@NonNull final NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".NOTIFICATION_RECEIVED",
                        Pair.create("data", notificationData.toString()));
            }

            @Override
            public void onNotificationClicked(@NonNull final NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".NOTIFICATION_CLICKED",
                        Pair.create("data", notificationData.toString()));
            }

            @Override
            public void onNotificationButtonClicked(@NonNull final NotificationData notificationData,
                                                    @NonNull final NotificationButtonData notificationButtonData) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".NOTIFICATION_BUTTON_CLICKED",
                        Pair.create("data", notificationData.toString()),
                        Pair.create("button", notificationButtonData.toString()));
            }

            @Override
            public void onCustomContentReceived(@NonNull final JSONObject jsonObject) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".NOTIFICATION_CUSTOM_CONTENT_RECEIVED",
                        Pair.create("json", jsonObject.toString()));
            }

            @Override
            public void onNotificationDismissed(@NonNull final NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".NOTIFICATION_DISMISSED",
                        Pair.create("data", notificationData.toString()));
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
