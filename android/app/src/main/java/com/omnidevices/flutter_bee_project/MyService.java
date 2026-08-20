package com.omnidevices.flutter_bee_project;
import android.Manifest;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.IBinder;
import android.util.Log;
import io.flutter.plugin.common.MethodChannel;



public class MyService extends Service {
    private static final String TAG = "OMNI.OTA." + MyService.class.getSimpleName();
    private final static String ACTION_CONNECTION_STATE_CHANGED = "android.bluetooth.input.profile.action.CONNECTION_STATE_CHANGED";
    private static final String CHANNEL_NAME = "com.omnidevices/bluetooth_hid";

    private MethodChannel methodChannel;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "onCreate: ");

        IntentFilter intentFilter = new IntentFilter(ACTION_CONNECTION_STATE_CHANGED);
        registerReceiver(bleReceiver, intentFilter);
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.d(TAG, "onBind: ");
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand: ");
/*        String NOTIFICATION_CHANNEL_ID = "com.omni.ble.notificationchannel";
        String channelName = "bleservice";
        NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE);
        chan.setLightColor(Color.BLUE);
        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        assert manager != null;
        manager.createNotificationChannel(chan);

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID);
        Notification notification = notificationBuilder.setOngoing(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("ble is running in background")
                .setPriority(NotificationManager.IMPORTANCE_NONE)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build();
        startForeground(2, notification);*/
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy: ");
        unregisterReceiver(bleReceiver);
    }

    private BroadcastReceiver bleReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            assert intent.getAction() != null;

            BluetoothDevice device;
            int state;
            switch (intent.getAction()) {
                case ACTION_CONNECTION_STATE_CHANGED:
                    device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                    state = intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1);
                    //if (mCallback != null) mCallback.onDeviceConnectionStateChanged(device, state);
                    break;

                default:
                    break;
            }
        }
    };

}

