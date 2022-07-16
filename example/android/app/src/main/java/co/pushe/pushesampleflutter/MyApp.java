package co.pushe.pushesampleflutter;

import android.content.Context;
import androidx.multidex.MultiDex;
import co.pushe.plus.flutter.PusheFlutterPlugin;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;

import static co.pushe.plus.flutter.PusheFlutterPlugin.*;

public class MyApp extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        setDebugMode(true);
        initialize(this);
    }

    @Override
    public void registerWith(io.flutter.plugin.common.PluginRegistry registry) {
        PusheFlutterPlugin.registerWith(registry);
    }
}
