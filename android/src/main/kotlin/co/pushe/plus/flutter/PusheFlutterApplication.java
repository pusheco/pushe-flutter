package co.pushe.plus.flutter;

import android.content.Context;

import androidx.multidex.MultiDex;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;

import static co.pushe.plus.flutter.PusheFlutterPlugin.initialize;

public class PusheFlutterApplication extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        PusheFlutterPlugin.setDebugMode(false);
        initialize(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        PusheFlutterPlugin.registerWith(registry);
    }
}
