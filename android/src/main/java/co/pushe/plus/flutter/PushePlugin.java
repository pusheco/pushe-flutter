package co.pushe.plus.flutter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * PushePlugin
 *
 * @author Mahdi Malvandi
 */
public class PushePlugin implements FlutterPlugin, ActivityAware {

    private static final String TAG = "Pushe";

    public static void registerWith(Registrar registrar) {
        lg("Plugin registered using 'registerWith' static method");
        setUpChannel(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        lg("Plugin registered by v2 embedding engine");
        setUpChannel(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        lg("Plugin has detached from engine");
    }


    ///// Activity aware functions

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        lg("Plugin has been attached to Activity");
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        lg("Plugin has been detached from Activity");
    }


    ////// Util methods

    private static void lg(String message) {
        Log.d(TAG, message);
    }

    private static void setUpChannel(Context context, BinaryMessenger messenger) {
        final MethodChannel channel = new MethodChannel(messenger, "plus.pushe.co/pushe_flutter");
        channel.setMethodCallHandler(new PusheChannelHandler(context, messenger));

        final MethodChannel backgroundChannel = new MethodChannel(messenger, "plus.pushe.co/pushe_flutter_background");
        backgroundChannel.setMethodCallHandler(new PusheBackgroundChannelHandler());
    }

}
