package co.ronash.pushe.flutter;

import android.content.Context;
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
 * #author Mahdi Malvandi
 */
public class PushePlugin implements MethodCallHandler {

    private Context context;
    private Registrar registrar;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "Pushe");
        channel.setMethodCallHandler(new PushePlugin(registrar));
    }

    private PushePlugin(Registrar registrar) {
        this.registrar = registrar;
        this.context = registrar.context();
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
                initializePusheListeners(new MethodChannel(registrar.messenger(), "Pushe"));
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void initializePusheListeners(final MethodChannel channel) {
        Pushe.setNotificationListener(new Pushe.NotificationListener() {
            @Override
            public void onNotificationReceived(@NonNull final NotificationData notificationData) {
                System.out.println("NOTIFICATION_RECEIVED");
                registrar.activity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        System.out.println("NOTIFICATION_RECEIVED on uiThread");
                        channel.invokeMethod("Pushe#onNotificationReceived", notificationData.toString());
                    }
                });
            }

            @Override
            public void onNotificationClicked(@NonNull NotificationData notificationData) {
                channel.invokeMethod("Pushe#onNotificationClicked", notificationData.toString());
            }

            @Override
            public void onNotificationButtonClicked(@NonNull NotificationData notificationData,
                                                    @NonNull NotificationButtonData notificationButtonData) {
                channel.invokeMethod("Pushe#onNotificationButtonClicked",
                        new String[] {notificationData.toString(), notificationButtonData.toString()});
            }

            @Override
            public void onCustomContentReceived(@NonNull JSONObject jsonObject) {
                channel.invokeMethod("Pushe#onCustomContentReceived", jsonObject.toString());
            }

            @Override
            public void onNotificationDismissed(@NonNull NotificationData notificationData) {
                channel.invokeMethod("Pushe#onNotificationDismissed", notificationData.toString());
            }
        });
    }
}
