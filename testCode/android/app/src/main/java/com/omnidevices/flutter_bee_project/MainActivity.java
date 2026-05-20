package com.omnidevices.flutter_bee_project;

import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    public static final String TAG = "BEE_MainActivity";


    //gatt disconnect will changingConfig = 112, so must config three into androidmanifest.xml,else activity will be kill restart
    //ActivityInfo.CONFIG_KEYBOARD 16
    //ActivityInfo.CONFIG_KEYBOARD_HIDDEN 32
    //ActivityInfo.CONFIG_NAVIGATION  64
    public void onConfigurationChanged(Configuration newConfig) {
        Log.d(TAG, "Config change");
        super.onConfigurationChanged(newConfig);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        Log.d(TAG, "configureFlutterEngine ");
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }

    public void onDetachedFromEngine() {
        Log.d(TAG, "Config change - skipping engine detach");
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "onDestroy");
        int changingConfig = getChangingConfigurations();

        Log.d(TAG, "onDestroy changingConfig = " + changingConfig);

        if ((changingConfig & ActivityInfo.CONFIG_MCC) != 0)
            Log.d("Config", "CONFIG_MCC (1)");
        if ((changingConfig & ActivityInfo.CONFIG_MNC) != 0)
            Log.d("Config", "CONFIG_MNC (2)");
        if ((changingConfig & ActivityInfo.CONFIG_LOCALE) != 0)
            Log.d("Config", "CONFIG_LOCALE (4)");
        if ((changingConfig & ActivityInfo.CONFIG_TOUCHSCREEN) != 0)
            Log.d("Config", "CONFIG_TOUCHSCREEN (8)");
        if ((changingConfig & ActivityInfo.CONFIG_SCREEN_SIZE) != 0)
            Log.d("Config", "CONFIG_SCREEN_SIZE (16)");
        if ((changingConfig & ActivityInfo.CONFIG_SCREEN_LAYOUT) != 0)
            Log.d("Config", "CONFIG_SCREEN_LAYOUT (32)");
        if ((changingConfig & ActivityInfo.CONFIG_UI_MODE) != 0)
            Log.d("Config", "CONFIG_UI_MODE (64)");
        if ((changingConfig & ActivityInfo.CONFIG_ORIENTATION) != 0)
            Log.d("Config", "CONFIG_ORIENTATION (128)");
            /*if ((changingConfig & ActivityInfo.CONFIG_SCREEN_LAYOUT_SIZE) != 0)
                Log.d("Config", "CONFIG_SCREEN_LAYOUT_SIZE (256)");*/
        if ((changingConfig & ActivityInfo.CONFIG_SMALLEST_SCREEN_SIZE) != 0)
            Log.d("Config", "CONFIG_SMALLEST_SCREEN_SIZE (512)");
        if ((changingConfig & ActivityInfo.CONFIG_DENSITY) != 0)
            Log.d("Config", "CONFIG_DENSITY (1024)");
        if ((changingConfig & ActivityInfo.CONFIG_LAYOUT_DIRECTION) != 0)
            Log.d("Config", "CONFIG_LAYOUT_DIRECTION (2048)");
        if ((changingConfig & ActivityInfo.CONFIG_FONT_SCALE) != 0)
            Log.d("Config", "CONFIG_FONT_SCALE (4096)");
            /*if ((changingConfig & ActivityInfo.CONFIG_HARD_KEYBOARD_HIDDEN) != 0)
                Log.d("Config", "CONFIG_HARD_KEYBOARD_HIDDEN (8192)");*/
        if ((changingConfig & ActivityInfo.CONFIG_KEYBOARD) != 0)
            Log.d("Config", "CONFIG_KEYBOARD (16384)");
        if ((changingConfig & ActivityInfo.CONFIG_KEYBOARD_HIDDEN) != 0)
            Log.d("Config", "CONFIG_KEYBOARD_HIDDEN (32768)");
        if ((changingConfig & ActivityInfo.CONFIG_NAVIGATION) != 0)
            Log.d("Config", "CONFIG_NAVIGATION (65536)");
            /*if ((changingConfig & ActivityInfo.CONFIG_COLOR_MODE) != 0)
                Log.d("Config", "CONFIG_COLOR_MODE (131072)");*/

        if (isFinishing()) {
            Log.d(TAG, "User finished the activity");
        } else if (isChangingConfigurations()) {
            Log.d(TAG, "Recreating due to config change");
        } else {
            Log.d(TAG, "System is destroying activity");
        }
        super.onDestroy();
    }
}
