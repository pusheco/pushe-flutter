package co.ronash.pushe.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import co.ronash.pushe.NotificationButtonData;
import co.ronash.pushe.NotificationData;
import co.ronash.pushe.Pushe;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PushePlugin
 *
 * #author Mahdi Malvandi
 */
public class PushePlugin implements MethodCallHandler {

    private Context context;
    private static boolean isNotificationListenersEnabled = false;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "Pushe");
        channel.setMethodCallHandler(new PushePlugin(registrar));
    }

    private PushePlugin(Registrar registrar) {
        this.context = registrar.context();

        IntentFilter i = new IntentFilter();
        i.addAction(context.getPackageName() + ".NOTIFICATION_RECEIVED");

        context.registerReceiver(new PusheNotificationReceiver(new MethodChannel(registrar.messenger(), "Pushe")), i);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String methodName = call.method;
        switch (methodName) {
            case "Pushe#initialize":
                Boolean dialog = null;
                if (call.hasArgument("showDialog")) {
                    dialog = call.argument("showDialog");
                }
                if (dialog == null) dialog = true;
                Pushe.initialize(context, dialog);
                System.out.println("[Plugin] Trying to initialize Pushe");
                Pushe.initialize(context, true); // TODO: Take the true as optional from user
                break;
            case "Pushe#getPusheId":
                result.success(Pushe.getPusheId(context));
                break;
            case "Pushe#subscribe":
                if (call.hasArgument("topic")) {
                    String topic = call.argument("topic");
                    Pushe.subscribe(context, topic);
                    result.success("Will subscribe to topic " + topic);
                } else {
                    result.error("Failed to subscribe to topic", null, null);
                }
                break;
            case "Pushe#unsubscribe":
                if (call.hasArgument("topic")) {
                    String topic = call.argument("topic");
                    Pushe.unsubscribe(context, topic);
                    result.success("Will unsubscribe from topic " + topic);
                } else {
                    result.error("Failed to unsubscribe from topic", null, null); // TODO: What are these nulls
                }
                break;
            case "Pushe#setNotificationOff":
                Pushe.setNotificationOff(context);
                break;
            case "Pushe#setNotificationOn":
                Pushe.setNotificationOn(context);
                break;
            case "Pushe#isPusheInitialized":
                result.success(Pushe.isPusheInitialized(context));
                break;
            case "Pushe#sendSimpleNotifToUser":
                if (call.hasArgument("pusheId")
                        && call.hasArgument("title")
                        && call.hasArgument("content")) {
                    Pushe.sendSimpleNotifToUser(context,
                            (String) call.argument("pusheId"),
                            (String) call.argument("title"),
                            (String) call.argument("content"));
                }
                break;
            case "Pushe#sendAdvancedNotifToUser":
                if (call.hasArgument("pusheId")
                        && call.hasArgument("json")) {
                    try {
                        Pushe.sendAdvancedNotifToUser(context,
                                (String) call.argument("pusheId"),
                                (String) call.argument("json"));
                        result.success("Will send advanced notification");
                    } catch (JSONException e) {
                        result.error("Invalid json entered", null, null);
                    } catch (Exception c) {
                        result.error("Something bad happened.", null, null);
                    }
                }
                break;
            case "Pushe#initializeNotificationListeners":
                if (call.hasArgument("enabled")) {
                    Boolean b = call.argument("enabled");
                    if (b != null) {
                        initializePusheListeners(b);
                    }
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void initializePusheListeners(boolean enabled) {
        isNotificationListenersEnabled = enabled;
    }



    public static class PusheNotificationReceiver extends BroadcastReceiver {
        private MethodChannel channel;

        public PusheNotificationReceiver(MethodChannel methodChannel) {
            channel = methodChannel;
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            System.out.println("In onReceive");
            if (!isNotificationListenersEnabled) return;
            String action = intent.getAction() == null ? "" : intent.getAction();
            if (action.equals(context.getPackageName() + ".NOTIFICATION_RECEIVED")) {
                System.out.println("NOTIFICATION_RECEIVED on uiThread");
                String data = intent.getStringExtra("data");
                channel.invokeMethod("Pushe#onNotificationReceived", data);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_CLICKED")) {
                System.out.println("NOTIFICATION_CLICKED on uiThread");
                String data = intent.getStringExtra("data");
                channel.invokeMethod("Pushe#onNotificationClicked", data);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_BUTTON_CLICKED")) {
                System.out.println("NOTIFICATION_BUTTON_CLICKED on uiThread");
                String data = intent.getStringExtra("data");
                String button = intent.getStringExtra("button");
                channel.invokeMethod("Pushe#onNotificationButtonClicked", new String[] {data, button});
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_CUSTOM_CONTENT_RECEIVED")) {
                System.out.println("NOTIFICATION_CUSTOM_CONTENT_RECEIVED on uiThread");
                String data = intent.getStringExtra("json");
                channel.invokeMethod("Pushe#onCustomContentReceived", data);
            } else if (action.equals(context.getPackageName() + ".NOTIFICATION_DISMISSED")) {
                System.out.println("NOTIFICATION_DISMISSED on uiThread");
                String data = intent.getStringExtra("data");
                channel.invokeMethod("Pushe#onNotificationDismissed", data);
            }
        }
    }

}
