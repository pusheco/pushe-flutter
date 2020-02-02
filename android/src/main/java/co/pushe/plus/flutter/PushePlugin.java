package co.pushe.plus.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import co.pushe.plus.Pushe;
import co.pushe.plus.analytics.PusheAnalytics;
import co.pushe.plus.notification.PusheNotification;
import co.pushe.plus.notification.UserNotification;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterMain;


/**
 * PushePlugin
 *
 * @author Mahdi Malvandi
 * FIXME: Warnings will be repaired with the next release
 */
@SuppressWarnings("NullableProblems")
public class PushePlugin implements MethodCallHandler {

    private Context context;
    private final List<String> NOTIF_TYPES = Arrays.asList("IdType.AndroidId", "IdType.GoogleAdvertisingId", "IdType.CustomId");

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

    // TODO: Fix long method issue
    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        String methodName = call.method;
        PusheNotification notificationModule = Pushe.getPusheService(PusheNotification.class);
        PusheAnalytics analyticsModule = Pushe.getPusheService(PusheAnalytics.class);

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
                    result.error("001", "Failed to set custom id. No id provided.", null);
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
                    result.error("002", "Failed to set email. No email provided.", null);
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
                    result.error("003", "Failed to set phone. No phone provided.", null);
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
                    result.error("004", "Failed to subscribe. No topic argument is passed", null);
                }
                break;
            case "Pushe.unsubscribe":
                if (call.hasArgument("topic")) {
                    String topic = call.argument("topic");
                    Pushe.unsubscribeFromTopic(topic, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });

                } else {
                    result.error("005", "Failed to unsubscribe. No topic provided.", null);
                }
                break;
            case "Pushe.disableNotifications":
                if (notificationModule == null) {
                    result.error("013", "Failed to interact with notification module", null);
                    return;
                }
                notificationModule.disableNotifications();
                break;
            case "Pushe.enableNotifications":
                if (notificationModule == null) {
                    result.error("014", "Failed to interact with notification module", null);
                    return;
                }
                notificationModule.enableNotifications();
                break;
            case "Pushe.isNotificationEnable":
                if (notificationModule == null) {
                    result.error("015", "Failed to interact with notification module", null);
                    return;
                }
                result.success(notificationModule.isNotificationEnable());
                break;
            case "Pushe.isInitialized":
                result.success(Pushe.isInitialized());
                break;
            case "Pushe.isRegistered":
                result.success(Pushe.isRegistered());
                break;

            case "Pushe.sendUserNotification":
                //noinspection RedundantCast
                if (call.hasArgument("type") && NOTIF_TYPES.contains((String) call.argument("type")) &&
                        call.hasArgument("id") &&
                        call.hasArgument("title") && call.hasArgument("content")) {
                    String type = call.argument("type");
                    String id = call.argument("id");
                    if (id == null || type == null) {
                        result.error("006", "The keys type and id must exist", null);
                        return;
                    }
                    if (notificationModule == null) {
                        result.error("007", "Failed to interact with notification module", null);
                        return;
                    }
                    UserNotification notification = null;
                    switch (type) {
                        case "IdType.AndroidId":
                            notification = UserNotification.withAndroidId(id);
                            break;
                        case "IdType.GoogleAdvertisingId":
                            notification = UserNotification.withAdvertisementId(id);
                            break;
                        case "IdType.CustomId":
                            notification = UserNotification.withCustomId(id);
                            break;
                        default:
                            break;
                    }

                    if (notification == null) {
                        result.error("008", "Type must be either 'AndroidId', 'GoogleAdvertisingId' or 'CustomId'", null);
                        return;
                    }

                    String title = call.argument("title");
                    String content = call.argument("content");
                    String bigTitle = call.argument("bigTitle");
                    String bigContent = call.argument("bigContent");
                    String imageUrl = call.argument("imageUrl");
                    String iconUrl = call.argument("iconUrl");
                    String notifIcon = call.argument("notifIcon");
                    String customContent = call.argument("customContent");

                    notification.setTitle(title)
                            .setContent(content)
                            .setBigTitle(bigTitle)
                            .setBigContent(bigContent)
                            .setImageUrl(imageUrl)
                            .setIconUrl(iconUrl)
                            .setNotifIcon(notifIcon)
                            .setCustomContent(customContent);

                    notificationModule.sendNotificationToUser(notification);

                } else {
                    result.error("009", "Failed to send notification", null); // TODO: better crash
                }
                break;
            case "Pushe.sendAdvancedUserNotification":
                //noinspection RedundantCast
                if (call.hasArgument("type") && NOTIF_TYPES.contains((String) call.argument("type")) &&
                        call.hasArgument("id") &&
                        call.hasArgument("advancedJson")) {
                    String type = call.argument("type");
                    String id = call.argument("id");
                    if (id == null || type == null) {
                        result.error("020", "The keys 'type' and 'id' must exist", null);
                        return;
                    }
                    if (notificationModule == null) {
                        result.error("021", "Failed to interact with notification module", null);
                        return;
                    }
                    UserNotification notification = null;
                    switch (type) {
                        case "IdType.AndroidId":
                            notification = UserNotification.withAndroidId(id);
                            break;
                        case "IdType.GoogleAdvertisingId":
                            notification = UserNotification.withAdvertisementId(id);
                            break;
                        case "IdType.CustomId":
                            notification = UserNotification.withCustomId(id);
                            break;
                        default:
                            break;
                    }

                    if (notification == null) {
                        result.error("008", "Type must be either 'AndroidId', 'GoogleAdvertisingId' or 'CustomId'", null);
                        return;
                    }

                    String advancedJson = call.argument("advancedJson");

                    notification.setAdvancedNotification(advancedJson);

                    notificationModule.sendNotificationToUser(notification);

                } else {
                    result.error("009", "Failed to send notification", null); // TODO: better crash
                }
                break;
            case "Pushe.sendEvent":
                if (call.hasArgument("name")) {
                    String name = call.argument("name");
                    if (name == null) {
                        result.error("016", "'name' can not be null", null);
                        return;
                    }
                    if (analyticsModule == null) {
                        result.error("017", "Failed to interact with analytics module", null);
                        return;
                    }
                    analyticsModule.sendEvent(name);
                    result.success("Will send event " + name);
                } else {
                    result.error("010", "Failed to send event. No event name provided.", null);
                }
                break;
            case "Pushe.sendEcommerceData":
                if (call.hasArgument("name") && call.hasArgument("price")) {
                    String name = call.argument("name");
                    Double price = call.argument("price");
                    if (name == null || price == null) {
                        result.error("019", "'name' and 'price' can not be null", null);
                        return;
                    }
                    if (analyticsModule == null) {
                        result.error("018", "Failed to interact with analytics module", null);
                        return;
                    }
                    analyticsModule.sendEcommerceData(name, price);
                    result.success("Will send ecommerce data " + name);
                } else {
                    result.error("011", "Failed to send ecommerce data. No event name and price provided.", null);
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
                });
                break;

            case "Pushe.setInitializationCompleteListener":
                Pushe.setInitializationCompleteListener(new Pushe.Callback() {
                    @Override
                    public void onComplete() {
                        // Done
                        result.success(true);
                    }
                });
                break;

            case "Pushe.addTags":
                if (call.hasArgument("tags") && call.argument("tags") instanceof Map) {
                    Map<String, String> tags = call.argument("tags");
                    Pushe.addTags(tags, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });

                } else {
                    result.error("012", "Failed to add tags. No tags provided.", null);
                }
                break;

            case "Pushe.removeTags":
                if (call.hasArgument("tags") && call.argument("tags") instanceof List) {
                    List<String> tags = call.argument("tags");
                    Pushe.removeTags(tags, new Pushe.Callback() {
                        @Override
                        public void onComplete() {
                            // Done
                            result.success(true);
                        }
                    });

                } else {
                    result.error("012", "Failed to remove tags. No tags provided.", null);
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
                channel.invokeMethod("Pushe.onNotificationButtonClicked", getNotificationAndButton(intent).toString());
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
                o = new JSONObject(button);
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
