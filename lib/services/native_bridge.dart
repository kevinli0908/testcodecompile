// lib/native_communication.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bee_project/services/bluetooth/omni_ble.dart';
import 'package:flutter_bee_project/services/bluetooth/omni_gatt_manager.dart';

class NativeBridge {
  static const String TAG = "OMNI.BEE.NativeBridge";
  static const MethodChannel _channel = MethodChannel('com.omnidevices/native_channel');

  // 监听来自 Android 的调用
  static void init() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNativeEvent':
        // 接收 Android 传来的数据
          final state = call.arguments['state'];
          final message = call.arguments['message'];
          final timestamp = call.arguments['timestamp'];
          debugPrint("${NativeBridge.TAG} Received from Android: $state at $timestamp");

          // 处理业务逻辑
          await handleNativeEvent(state, message, timestamp);

          return 'Dart processed successfully';

        default:
          throw PlatformException(
            code: 'NOT_IMPLEMENTED',
            message: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  // Dart 调用 Android 端方法
  static Future<String> sendToNative(String data) async {
    try {
      final result = await _channel.invokeMethod('getDataFromDart', {
        'data': data,
      });
      return result.toString();
    } on PlatformException catch (e) {
      debugPrint("${NativeBridge.TAG} Error: ${e.message}");
      return 'Failed: ${e.message}';
    }
  }

  static Future<void> handleNativeEvent(int state, String message, int timestamp) async {
    // 在这里处理蓝牙重连逻辑
    debugPrint("${NativeBridge.TAG} handleNativeEvent = $state");
    OmniBle.instance.deviceConnectStatusChanged();
    OmniGattManager.instance.handleDeviceConnectionStateChanged(state);
    // 可以触发 UI 更新、重连操作等
  }
}