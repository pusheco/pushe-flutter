package co.ronash.pushe_example;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.support.annotation.NonNull;

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
        FlutterMain.startInitialization(this);
        initializeNotificationListeners(PusheApplication.this);

    }

    private static void initializeNotificationListeners(final Context context) {
        System.out.println("In initializeNotificationListeners");
        Pushe.setNotificationListener(new Pushe.NotificationListener() {


            @Override
            public void onNotificationReceived(@NonNull final NotificationData notificationData) {
                System.out.println("in onNotificationReceived");

                context.sendBroadcast(
                        new Intent().setPackage(context.getPackageName())
                                .setAction(context.getPackageName() + ".NOTIFICATION_RECEIVED")
                                .putExtra("data", notificationData.toString())
                );

                Handler a = new Handler(context.getMainLooper());
                a.post(new Runnable() {
                    @Override
                    public void run() {
                        System.out.println("In handler");
                        FlutterMain.ensureInitializationCompleteAsync(context, null, a, new Runnable() {
                            @Override
                            public void run() {
                                System.out.println("in completeInit");
                                context.sendBroadcast(
                                        new Intent().setPackage(context.getPackageName())
                                                .setAction(context.getPackageName() + ".NOTIFICATION_RECEIVED")
                                                .putExtra("data", notificationData.toString())
                                );
                            }
                        });
                    }
                });


            }

            @Override
            public void onNotificationClicked(@NonNull final NotificationData notificationData) {
                FlutterMain.ensureInitializationCompleteAsync(context, null, new Handler(), new Runnable() {
                    @Override
                    public void run() {
                        context.sendBroadcast(
                                new Intent().setPackage(context.getPackageName())
                                        .setAction(context.getPackageName() + ".NOTIFICATION_CLICKED")
                                        .putExtra("data", notificationData.toString())
                        );
                    }
                });
            }

            @Override
            public void onNotificationButtonClicked(@NonNull final NotificationData notificationData, @NonNull final NotificationButtonData notificationButtonData) {
                FlutterMain.ensureInitializationCompleteAsync(context, null, new Handler(), new Runnable() {
                    @Override
                    public void run() {
                        context.sendBroadcast(
                                new Intent().setPackage(context.getPackageName())
                                        .setAction(context.getPackageName() + ".NOTIFICATION_BUTTON_CLICKED")
                                        .putExtra("data", notificationData.toString())
                                        .putExtra("button", notificationButtonData.toString())
                        );
                    }
                });
            }

            @Override
            public void onCustomContentReceived(@NonNull final JSONObject jsonObject) {
                FlutterMain.ensureInitializationCompleteAsync(context, null, new Handler(), new Runnable() {
                    @Override
                    public void run() {
                        context.sendBroadcast(
                                new Intent().setPackage(context.getPackageName())
                                        .setAction(context.getPackageName() + ".NOTIFICATION_CUSTOM_CONTENT_RECEIVED")
                                        .putExtra("json", jsonObject.toString())
                        );
                    }
                });
            }

            @Override
            public void onNotificationDismissed(@NonNull final NotificationData notificationData) {
                FlutterMain.ensureInitializationCompleteAsync(context, null, new Handler(), new Runnable() {
                    @Override
                    public void run() {
                        context.sendBroadcast(
                                new Intent().setPackage(context.getPackageName())
                                        .setAction(context.getPackageName() + ".NOTIFICATION_DISMISSED")
                                        .putExtra("data", notificationData.toString())
                        );
                    }
                });
            }
        });
    }
}
