package com.omnidevices.flutter_bee_project;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
    public static final String TAG = "BEE_MainActivity";
    private final static String ACTION_CONNECTION_STATE_CHANGED = "android.bluetooth.input.profile.action.CONNECTION_STATE_CHANGED";
    private static final String CHANNEL = "com.omnidevices/native_channel";
    private MethodChannel methodChannel;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate: ");

        IntentFilter intentFilter = new IntentFilter(ACTION_CONNECTION_STATE_CHANGED);
        registerReceiver(bleReceiver, intentFilter);
    }

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
        // 创建 MethodChannel
        methodChannel = new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                CHANNEL
        );

        // 设置方法调用处理器（接收来自 Dart 的调用）
        methodChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("getDataFromDart")) {
                // 接收 Dart 传来的数据
                String data = call.argument("data");
                Log.d(TAG, "Received from Dart: " + data);
                result.success("Native received: " + data);
            } else {
                result.notImplemented();
            }
        });
    }

    // Android 主动调用 Dart 端方法
    private void callDartMethod(int state) {
        Log.d(TAG, "callDart connect gatt: ");
        // 在合适的时机调用，比如收到广播后
        methodChannel.invokeMethod("onNativeEvent",
                java.util.Map.of(
                        "state", state,
                        "message", "device connect",
                        "timestamp", System.currentTimeMillis()
                ),
                new MethodChannel.Result() {
                    @Override
                    public void success(Object result) {
                        Log.d(TAG, "Dart call success: " + result);
                    }

                    @Override
                    public void error(String errorCode, String errorMessage, Object errorDetails) {
                        Log.e(TAG, "Dart call error: " + errorMessage);
                    }

                    @Override
                    public void notImplemented() {
                        Log.w(TAG, "Dart method no achieve");
                    }
                }
        );
    }

    public void onDetachedFromEngine() {
        Log.d(TAG, "Config change - skipping engine detach");
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "onDestroy");
        unregisterReceiver(bleReceiver);

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

        private BroadcastReceiver bleReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                assert intent.getAction() != null;

                int state;
                switch (intent.getAction()) {
                    case ACTION_CONNECTION_STATE_CHANGED:
                        state = intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1);
                        Log.d(TAG, "received broadcast ACTION_CONNECTION_STATE_CHANGED " + state);
                        //if (mCallback != null) mCallback.onDeviceConnectionStateChanged(device, state);
                        if (state == BluetoothProfile.STATE_CONNECTED) {
                            callDartMethod(state);
                        }
                        break;

                    default:
                        break;
                }
            }
        };
}
