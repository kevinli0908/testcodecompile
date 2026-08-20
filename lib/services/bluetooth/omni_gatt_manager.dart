// lib/services/ota/ota_manager.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../bluetooth/omni_ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'defines.dart';


/// Omni gatt 回调接口
abstract class OmniGattCallback {
  void onDeviceNotFound();
  void onDeviceBondStateChanged(int state);
  void onDeviceConnectionStateChanged(int state);
  void onGattConnectionStateChanged(int state);
  void onCharacteristicWrite(OmniBluetoothGattCharacteristic characteristic);
  void onCharacteristicRead(OmniBluetoothGattCharacteristic characteristic);
  void onCharacteristicChanged(OmniBluetoothGattCharacteristic  characteristic);
}

/// Omni gatt 管理器
class OmniGattManager {
  static const String TAG = "OMNI.BEE.OmniGattManager";
  // 单例实例
  static OmniGattManager? _instance;

  late final OmniBle _omniBle;
  OmniGattCallback? _omniGattOTACallback;
  OmniGattCallback? _omniGattDeviceControlCallback;

  late OmniBleCallback _omniBleCallback;
  int _gattStatus = Defines.STATE_GATT_DISCONNECTED;

  // 私有构造函数
  OmniGattManager._internal() {
    _omniBleCallback = _OmniBleCallbackImpl(this);
    _omniBle = OmniBle();
    _omniBle.registerCallback(_omniBleCallback);
  }

  /// 获取单例实例
  static OmniGattManager get instance {
    _instance ??= OmniGattManager._internal();
    return _instance!;
  }

  void release() {
    _omniBle.unregisterCallback();
    _omniBle.disconnectGatt();
  }

  void registerOTACallback(OmniGattCallback callback) {
    _omniGattOTACallback = callback;
  }

  void unregisterOTACallback() {
    _omniGattOTACallback = null;
  }

  void registerDeviceControlCallback(OmniGattCallback callback) {
    _omniGattDeviceControlCallback = callback;
  }

  void unregisterDeviceControlCallback() {
    _omniGattDeviceControlCallback = null;
  }

  void connectOmniDevice() {
    debugPrint("$TAG connectOmniDevice");
    //if (_gattStatus == Defines.STATE_GATT_CONNECTED) return;
    _omniBle.findOmniRemote();
  }

  void connectOmniDeviceByName(String name) {
    debugPrint("$TAG connectOmniDeviceByName: name=$name");
    _omniBle.findOmniRemoteByName(name);
  }

  void disconnectGatt() {
    debugPrint("$TAG disconnectGatt");
    _omniBle.disconnectGatt();
  }

  void handleDeviceConnectionStateChanged(int state) {
    debugPrint("${OmniGattManager.TAG} _handleDeviceConnectionStateChanged = $state");
     if (state == 2 && _gattStatus == Defines.STATE_GATT_DISCONNECTED) {
      connectOmniDevice();
    }
  }

  void handleGattConnectionStateChanged(int state) {
    debugPrint("${OmniGattManager.TAG} _handleGattConnectionStateChanged = $state");
    _gattStatus = state;

    _omniGattOTACallback?.onGattConnectionStateChanged(state);
    _omniGattDeviceControlCallback?.onGattConnectionStateChanged(state);
  }

  Future<bool> writeData(String uuidServ, String uuidChar, List<int> data,) async{
    return await _omniBle.writeData(uuidServ, uuidChar, data);
  }

  int getGattState() {
    return _omniBle.getGattState();
  }

  int getBatteryLevel() {
    return _omniBle.getBatteryLevel();
  }

  void openRing(int value){
    _omniBle.openRing(value);
  }

  Future<List<int>?> getRing() async {
      return  await _omniBle.getRing();
  }

  void closeRing(){
    _omniBle.closeRing();
  }
}

/// OmniBle 回调实现
class _OmniBleCallbackImpl implements OmniBleCallback {
  final OmniGattManager _omniGattManager;

  _OmniBleCallbackImpl(this._omniGattManager);

  @override
  void onDeviceNotFound() {
      _omniGattManager._omniGattOTACallback?.onDeviceNotFound();
      _omniGattManager._omniGattDeviceControlCallback?.onDeviceNotFound();
  }

  @override
  void onDeviceBondStateChanged(BluetoothDevice device, int state) {
    _omniGattManager._omniGattOTACallback?.onDeviceBondStateChanged(state);
    _omniGattManager._omniGattDeviceControlCallback?.onDeviceBondStateChanged(state);
  }

  @override
  void onDeviceConnectionStateChanged(BluetoothDevice device, int state) {
    _omniGattManager.handleDeviceConnectionStateChanged(state);
   /* _omniGattManager._omniGattOTACallback?.onDeviceConnectionStateChanged(state);
    _omniGattManager._omniGattDeviceControlCallback?.onDeviceConnectionStateChanged(state);*/
  }

  @override
  void onGattConnectionStateChanged(BluetoothDevice device, int state) {
    _omniGattManager.handleGattConnectionStateChanged(state);
  }

  @override
  void onCharacteristicWrite(OmniBluetoothGattCharacteristic characteristic) {
    if (characteristic.uuid.toLowerCase() == Defines.UUID_OTA_COMMAND.toLowerCase()
    || characteristic.uuid.toLowerCase() == Defines.UUID_OTA_BLOCK.toLowerCase()) {
      _omniGattManager._omniGattOTACallback?.onCharacteristicWrite(characteristic);
    } else {
      _omniGattManager._omniGattDeviceControlCallback?.onCharacteristicWrite(characteristic);
    }
  }

  @override
  void onCharacteristicRead(OmniBluetoothGattCharacteristic characteristic) {
    if (characteristic.uuid.toLowerCase() == Defines.UUID_OTA_COMMAND.toLowerCase()
        || characteristic.uuid.toLowerCase() == Defines.UUID_OTA_BLOCK.toLowerCase()) {
      _omniGattManager._omniGattOTACallback?.onCharacteristicRead(characteristic);
    } else {
      _omniGattManager._omniGattDeviceControlCallback?.onCharacteristicRead(characteristic);
    }
  }

  @override
  void onCharacteristicChanged(OmniBluetoothGattCharacteristic characteristic) {
    if (characteristic.uuid.toLowerCase() == Defines.UUID_OTA_COMMAND.toLowerCase()
        || characteristic.uuid.toLowerCase() == Defines.UUID_OTA_BLOCK.toLowerCase()) {
      _omniGattManager._omniGattOTACallback?.onCharacteristicChanged(characteristic);
    } else {
      _omniGattManager._omniGattDeviceControlCallback?.onCharacteristicChanged(characteristic);
    }
  }
}
