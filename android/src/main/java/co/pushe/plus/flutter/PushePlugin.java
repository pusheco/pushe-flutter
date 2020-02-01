package co.pushe.plus.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import co.pushe.plus.Pushe;
import co.pushe.plus.notification.PusheNotification;
import co.pushe.plus.analytics.PusheAnalytics;
import co.pushe.plus.notification.UserNotification;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterMain;
import java.util.Map;
import java.util.List;



/**
 * PushePlugin
 *
 * @author Mahdi Malvandi
 * FIXME: Warnings will be repaired with the next release
 */
public class PushePlugin implements MethodCallHandler {

    private Context context;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "Pushe");
        channel.setMethodCallHandler(new PushePlugin(registrar));
    }

    private PushePlugin(Registrar registrar) {
        this.context = registrar.context();

        IntentFilter i = new IntentFilter();
        i.addAction(context.getPackageName() + ".nr"); // Receive
        i.addAction(context.getPackageName() + ".nc"); // Click
        i.addAction(context.getPackageName() + ".nbc"); // Button click
        i.addAction(context.getPackageName() + ".nd"); // Dismiss
        i.addAction(context.getPackageName() + ".nccr"); // CustomContent receive
        context.registerReceiver(new PusheNotificationReceiver(new MethodChannel(registrar.messenger(), "Pushe")), i);
    }

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        String methodName = call.method;
        switch (methodName) {
            case "Pushe.getAndroidId":
                result.success(Pushe.getAndroidId());
                break;

            case "Pushe.getGoogleAdvertisingId":
                result.success(Pushe.getGoogleAdvertisingId());
                break;

            case "Pushe.getCustomId":
                result.success(Pushe.getCustomId());
                break;

            case "Pushe.setCustomId":
                if (call.hasArgument("id")) {
                    String id = call.argument("id");
                    Pushe.setCustomId(id);
                    result.success("Will set custom id " + id);
                } else {
                    result.error("404", "Failed to set custom id. No id provided.", null);
                }
                break;

            case "Pushe.getUserEmail":
                result.success(Pushe.getUserEmail());
                break;

            case "Pushe.setUserEmail":
                if (call.hasArgument("email")) {
                    String email = call.argument("email");
                    Pushe.setUserEmail(email);
                    result.success("Will set user email to " + email);
                } else {
                    result.error("404", "Failed to set email. No email provided.", null);
                }
                break;

            case "Pushe.getUserPhoneNumber":
                result.success(Pushe.getUserPhoneNumber());
                break;

            case "Pushe.setUserPhoneNumber":
                if (call.hasArgument("phone")) {
                    String phone = call.argument("phone");
                    Pushe.setUserPhoneNumber(phone);
                    result.success("Will set user phone to " + phone);
                } else {
                    result.error("404", "Failed to set phone. No phone provided.", null);
                }
                break;

            case "Pushe.subscribe":
                if (call.hasArgument("topic")) {
                    final String topic = call.argument("topic");
                    Pushe.subscribeToTopic(topic, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });
                } else {
                    result.error("404", "Failed to subscribe. No topic argument is passed", null);
                }
                break;
            case "Pushe.unsubscribe":
                if (call.hasArgument("topic")) {
                    String topic = call.argument("topic");
                    Pushe.unsubscribeFromTopic( topic, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });

                } else {
                    result.error("404", "Failed to unsubscribe. No topic provided.", null);
                }
                break;
            case "Pushe.disableNotifications":
                Pushe.getPusheService(PusheNotification.class).disableNotifications();
                break;
            case "Pushe.enableNotifications":
                Pushe.getPusheService(PusheNotification.class).enableNotifications();
                break;
            case "Pushe.isNotificationEnable":
                result.success(Pushe.getPusheService(PusheNotification.class).isNotificationEnable());
                break;
            case "Pushe.isInitialized":
                result.success(Pushe.isInitialized());
                break;
            case "Pushe.isRegistered":
                result.success(Pushe.isRegistered());
                break;
            case "Pushe.sendNotificationToUser":
                if (call.hasArgument("androidId")
                        && call.hasArgument("title")
                        && call.hasArgument("content")) {
                    UserNotification userNotification = UserNotification.withAndroidId((String) call.argument("androidId"));
                    userNotification.setTitle((String) call.argument("title"));
                    userNotification.setContent((String) call.argument("content"));
                    Pushe.getPusheService(PusheNotification.class).sendNotificationToUser(userNotification);
                }
                break;

            case "Pushe.sendEvent":
                if (call.hasArgument("name")) {
                    String name = call.argument("name");
                    Pushe.getPusheService(PusheAnalytics.class).sendEvent(name);
                    result.success("Will send event " + name);
                } else {
                    result.error("404", "Failed to send event. No event name provided.", null);
                }
                break;
            case "Pushe.sendEcommerceData":
                if (call.hasArgument("name") && call.hasArgument("price")) {
                    String name = call.argument("name");
                    Double price = call.argument("price");
                    Pushe.getPusheService(PusheAnalytics.class).sendEcommerceData(name,price);
                    result.success("Will send ecommerce data " + name);
                } else {
                    result.error("404", "Failed to send ecommerce data. No event name and price provided.", null);
                }

                break;
            case "Pushe.initNotificationListenerManually":
                initNotificationListenerManually();
                break;

            case "Pushe.setRegistrationCompleteListener":

                Pushe.setRegistrationCompleteListener(new Pushe.Callback() {
                    @Override
                    public void onComplete() {
                        // Done
                        result.success(true);
                    }
                } );
                break;

            case "Pushe.setInitializationCompleteListener":
                Pushe.setInitializationCompleteListener(new Pushe.Callback() {
                    @Override
                    public void onComplete() {
                        // Done
                        result.success(true);
                    }
                } );
                break;

            case "Pushe.addTags":
                if (call.hasArgument("tags") && call.argument("tags") instanceof Map) {
                    Map tags = call.argument("tags");
                    Pushe.addTags( tags, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });

                } else {
                    result.error("404", "Failed to add tags. No tags provided.", null);
                }
                break;

            case "Pushe.removeTags":
                if (call.hasArgument("tags") && call.argument("tags") instanceof List) {
                    List tags = call.argument("tags");
                    Pushe.removeTags( tags, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });

                } else {
                    result.error("404", "Failed to remove tags. No tags provided.", null);
                }
                break;

            case "Pushe.getSubscribedTags":
                result.success(Pushe.getSubscribedTags());
                break;

            case "Pushe.getSubscribedTopics":
                result.success(Pushe.getSubscribedTopics());
                break;


            default:
                result.notImplemented();
                break;
        }
    }


    private void initNotificationListenerManually() {
        PusheApplication.initializeNotificationListeners(context.getApplicationContext());
    }

    public static class PusheNotificationReceiver extends BroadcastReceiver {
        private MethodChannel channel;

        public PusheNotificationReceiver(MethodChannel methodChannel) {
            channel = methodChannel;
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            FlutterMain.ensureInitializationComplete(context, null);
            String action = intent.getAction() == null ? "" : intent.getAction();

            if (action.isEmpty()) {
                return;
            }

            if (action.equals(context.getPackageName() + ".nr")) {
                channel.invokeMethod("Pushe.onNotificationReceived", getNotification(intent).toString());
            } else if (action.equals(context.getPackageName() + ".nc")) {
                channel.invokeMethod("Pushe.onNotificationClicked", getNotification(intent).toString());
            } else if (action.equals(context.getPackageName() + ".nbc")) {
                try {
                    JSONObject o = new JSONObject();
                    o.put("notification", getNotification(intent).toString());
                    o.put("button", getButton(intent).toString());
                    channel.invokeMethod("Pushe.onNotificationButtonClicked", o);
                } catch (JSONException e) {
                    Log.w("Pushe", "Failed to parse json", e);
                }
            } else if (action.equals(context.getPackageName() + ".nccr")) {
                channel.invokeMethod("Pushe.onCustomContentReceived", getJson(intent).toString());
            } else if (action.equals(context.getPackageName() + ".nd")) {
                channel.invokeMethod("Pushe.onNotificationDismissed", getNotification(intent).toString());
            }
        }

        public JSONObject getNotification(Intent intent) {
            JSONObject o = new JSONObject();
            try {
                String data = intent.getStringExtra("data");
                o.put("data", new JSONObject(data));
            } catch (JSONException e) {
                System.out.println("Pushe: Failed to parse notification");
            }
            return o;
        }

        public JSONObject getJson(Intent intent) {
            JSONObject o = new JSONObject();
            try {
                String data = intent.getStringExtra("json");
                o.put("json", new JSONObject(data));
            } catch (JSONException e) {
                System.out.println("Pushe: Failed to parse notification");
            }
            return o;
        }

        public JSONObject getButton(Intent intent) {
            JSONObject o = new JSONObject();
            try {
                String button = intent.getStringExtra("button");
                o.put("buttons", new JSONObject(button));
            } catch (JSONException e) {
               System.out.println("Pushe: Failed to parse notification button");
            }
            return o;
        }

        public JSONObject getNotificationAndButton(Intent intent) {
            JSONObject o = new JSONObject();
            try {
                o.put("notification", getNotification(intent));
                o.put("button", getButton(intent));
            } catch (JSONException ignored) {
            }
            return o;
        }
    }

}
