package co.pushe.pushesampleflutter;

import android.os.Bundle;

import co.pushe.plus.flutter.PushePlugin;
import io.flutter.app.FlutterActivity;

public class EmbeddingV1Activity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PushePlugin.registerWith(registrarFor("co.pushe.plus.flutter.PushePlugin"));
    }
}