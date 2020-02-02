package co.pushe.plus.flutter;

import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.util.Pair;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
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
        PusheNotification pusheNotification = Pushe.getPusheService(PusheNotification.class);
        if (pusheNotification == null) {
            Log.e("Pushe", "Pushe notification module is not found");
            return;
        }
        pusheNotification.setNotificationListener(new PusheNotificationListener() {
            @Override
            public void onNotification(NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".nr",
                Pair.create("data", notificationDataJson(notificationData).toString()));
            }

            @Override
            public void onCustomContentNotification(Map<String, Object> customContent) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".nccr",
                Pair.create("json", new JSONObject(customContent).toString()));
            }

            @Override
            public void onNotificationClick(NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                        c.getPackageName() + ".nc",
                        Pair.create("data", notificationDataJson(notificationData).toString()));
            }

            @Override
            public void onNotificationDismiss(NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".nd",
                        Pair.create("data", notificationDataJson(notificationData).toString()));
            }

            @Override
            public void onNotificationButtonClick(NotificationButtonData notificationButtonData, NotificationData notificationData) {
                sendBroadcastOnMainThread(c,
                c.getPackageName() + ".nbc",
                        Pair.create("data", notificationDataJson(notificationData).toString()),
                    Pair.create("button", notificationButtonDataJson(notificationButtonData).toString()));
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

    public static JSONObject notificationDataJson(NotificationData data) {
        if (data == null) {
            return null;
        }
        JSONObject o = new JSONObject();
        try {
            o.put("title", data.getTitle());
            o.put("content", data.getContent());
            o.put("bigTitle", data.getBigTitle());
            o.put("bigContent", data.getBigContent());
            o.put("imageUrl", data.getImageUrl());
            o.put("summary", data.getSummary());
            o.put("iconUrl", data.getIconUrl());
            try {
                o.put("json", new JSONObject(data.getCustomContent()));
            } catch (Exception e) {
                Log.d("Pushe", "Failed to add customContent to notification content", e);
            }
            try {
                o.put("buttons", notificationButtonDataList(data.getButtons()));
            } catch (Exception e) {
                Log.w("Pushe", "Failed to parse notification buttons");
            }
            return o;
        } catch (JSONException e) {
            Log.w("Pushe", "Failed to parse notification and convert it to Json.", e);
            return null;
        }
    }

    public static JSONObject notificationButtonDataJson(NotificationButtonData buttonData) {
        if (buttonData == null) {
            return null;
        }
        JSONObject o = new JSONObject();
        try {
            o.put("title", buttonData.getText());
            o.put("icon", buttonData.getIcon());
            return o;
        } catch (JSONException e) {
            Log.w("Pushe", "Failed to parse notification and convert it to Json.", e);
            return null;
        }
    }

    public static JSONArray notificationButtonDataList(List<NotificationButtonData> buttons) {
        JSONArray jA = new JSONArray();
        for (NotificationButtonData i : buttons) {
            jA.put(notificationButtonDataJson(i));
        }
        return jA;
    }

}
