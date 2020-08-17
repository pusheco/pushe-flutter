package co.pushe.pushesampleflutter;

import android.content.Context;
import androidx.multidex.MultiDex;
import co.pushe.plus.flutter.PusheFlutterApplication;
import co.pushe.plus.flutter.PushePlugin;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MyApp extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        PushePlugin.setDebugMode(true);
        PushePlugin.initialize(this);
    }

    @Override
    public void registerWith(io.flutter.plugin.common.PluginRegistry registry) {
        PushePlugin.registerWith(registry);
    }
}
