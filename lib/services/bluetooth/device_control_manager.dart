// lib/services/ota/ota_manager.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bee_project/services/bluetooth/omni_gatt_manager.dart';
import 'defines.dart';
import 'image_manager.dart';
import '../bluetooth/omni_ble.dart';
import 'defines.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'omni_gatt_manager.dart';
import '../../models/GestureMapping.dart';

/// 设备控制 回调接口
abstract class DeviceControlCallback {
  void onDeviceNotFound();
  void onGattConnectionStateChanged(int state);
  void onSetGestureStatus(bool status);
  void onGetGestureValue(int group, int value);
}

/// OTA 管理器
class DeviceControlManager {
  static const String TAG = "OMNI.BEE.DeviceControlManager";
  static final DeviceControlManager _instance = DeviceControlManager._internal();
  static DeviceControlManager get instance => _instance;

  DeviceControlCallback? _callback;

  int _gestuteIndex = 0;

  // 状态
  int _gattStatus = Defines.STATE_GATT_DISCONNECTED;

  // 数据
  final Uint8List _rcuVersion = Uint8List(2); // [0]:versionMinor, [1]:versionMajor

  // ==================== 回调实现 ====================

  late _OmniGattCallbackImpl _omniBleCallback;

  // 私有构造函数
  DeviceControlManager._internal() {
    _init();
  }

  // 防止外部实例化
  factory DeviceControlManager() {
    return _instance;
  }

  void _init() {
    _omniBleCallback = _OmniGattCallbackImpl(this);
    OmniGattManager.instance.registerDeviceControlCallback(_omniBleCallback);
  }

  void release() {
    OmniGattManager.instance.unregisterDeviceControlCallback();
  }

  void registerCallback(DeviceControlCallback callback) {
    _callback = callback;
  }

  void unregisterCallback() {
    _callback = null;
  }

  void connectOmniDevice() {
    debugPrint("$TAG connectOmniDevice");
    if (_gattStatus == Defines.STATE_GATT_CONNECTED) {
      _callback?.onGattConnectionStateChanged(_gattStatus);
      return;
    }

    if (_gattStatus == Defines.STATE_GATT_DISCONNECTED) {
      OmniGattManager.instance.connectOmniDevice();
    }
  }

  void connectOmniDeviceByName(String name) {
    debugPrint("$TAG connectOmniDeviceByName: name=$name");
    OmniGattManager.instance.connectOmniDeviceByName(name);
  }

  void disconnectGatt() {
    debugPrint("$TAG disconnectGatt");
    OmniGattManager.instance.disconnectGatt();
  }

  void getFirstGestureAction() {
    debugPrint("$TAG getAllGesture");
    _gestuteIndex = 0;
    List<int> keyList = GestureMapping.getAllGesturesKey();
      final bytes = Uint8List.fromList([
        Defines.CMD_DEVICE_HEADER,
        Defines.CMD_HOST_GET_GESTURE,
        keyList[_gestuteIndex]
      ]);
      _writeData(Defines.UUID_SSU_CHAR, bytes);
    debugPrint("$TAG getFirstGestureAction action: ${_dump(bytes)}");
  }

  void getNextGestureAction() {
    debugPrint("$TAG getNextGesture");

    List<int> keyList = GestureMapping.getAllGesturesKey();
    _gestuteIndex ++;
    if(_gestuteIndex >= keyList.length){
         return;
    }
    final bytes = Uint8List.fromList([
      Defines.CMD_DEVICE_HEADER,
      Defines.CMD_HOST_GET_GESTURE,
      keyList[_gestuteIndex]
    ]);
    _writeData(Defines.UUID_SSU_CHAR, bytes);
    debugPrint("$TAG getNextGestureAction action: ${_dump(bytes)}");
  }

  void setGestureAction(int group, int value) {
    debugPrint("$TAG setGesture");
    final bytes = Uint8List.fromList([
      Defines.CMD_DEVICE_HEADER,
      Defines.CMD_HOST_SET_GESTURE,
      0x00,0x02,group,value
    ]);
    _writeData(Defines.UUID_SSU_CHAR, bytes);
    debugPrint("$TAG setGestureAction action: ${_dump(bytes)}");
  }

  // ==================== 私有方法 ====================

  void _getRcuInfo() {
    final bytes = Uint8List.fromList([
      Defines.CMD_HEADER,
      Defines.CMD_HOST_GET_REMOTE_INFO,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ]);
    _writeData(Defines.UUID_OTA_COMMAND, bytes);
  }

  void _handleCommand(Uint8List bytes) {
    final cmd = bytes[1];
    debugPrint("$TAG handleCommand: cmd=${Defines.getCommandName(cmd)}");

    switch (cmd) {
      case Defines.CMD_RCU_RETURN_PING:
        int totalLength = (bytes[2] << 8) | bytes[3];
        if(totalLength == 1 && bytes[4] == 0x2F){
          _callback?.onSetGestureStatus(true);
        }
        break;

      case Defines.CMD_RCU_RETURN_GET_GESTURE:
        int totalLength = (bytes[2] << 8) | bytes[3];
        if(totalLength == 2){
          _callback?.onGetGestureValue(bytes[4], bytes[5]);
        }
        break;
      default:
        break;
    }
  }


  Future<bool> _writeData(String uuid, Uint8List bytes) async {
    return await  OmniGattManager.instance.writeData(Defines.UUID_SSU_SERV, uuid, bytes);
  }

  String _dump(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

}

/// OmniBle 回调实现
class _OmniGattCallbackImpl implements OmniGattCallback {
  final DeviceControlManager _manager;

  _OmniGattCallbackImpl(this._manager);

  @override
  void onDeviceNotFound() {
    _manager._handleDeviceNotFound();
  }

  @override
  void onDeviceBondStateChanged(int state) {}

  @override
  void onDeviceConnectionStateChanged( int state) {
    //_manager._handleDeviceConnectionStateChanged(state);
  }

  @override
  void onGattConnectionStateChanged(int state) {
    _manager._handleGattConnectionStateChanged(state);
  }

  @override
  void onCharacteristicWrite(OmniBluetoothGattCharacteristic characteristic) {
    _manager._handleCharacteristicWrite(characteristic);
  }

  @override
  void onCharacteristicRead(OmniBluetoothGattCharacteristic characteristic) {}

  @override
  void onCharacteristicChanged(OmniBluetoothGattCharacteristic characteristic) {
    _manager._handleCharacteristicChanged(characteristic);
  }
}

extension DeviceControlHandlers on DeviceControlManager {

  void _handleDeviceNotFound() {
    _callback?.onDeviceNotFound();
  }

  void _handleDeviceConnectionStateChanged(int state) {
   /* if (state == 2 && _gattStatus == Defines.STATE_GATT_DISCONNECTED) {
      connectOmniDevice();
    }*/
  }

  void _handleGattConnectionStateChanged(int state) {
    _gattStatus = state;
    _callback?.onGattConnectionStateChanged(state);
    /*if (state == Defines.STATE_GATT_CONNECTED) {
      _retryTimes = Defines.MAX_RETRY_TIMES;
      Future.delayed(const Duration(seconds: 1), () {
        _getRcuInfo();
      });
    } else if (state == Defines.STATE_GATT_DISCONNECTED) {
      _otaInProgress = false;
    }*/
  }

  void _handleCharacteristicWrite(OmniBluetoothGattCharacteristic characteristic) {
    if (characteristic.getUuid().toLowerCase() == Defines.UUID_SSU_CHAR.toLowerCase()) {
        getNextGestureAction();
    }
  }

  void _handleCharacteristicChanged(OmniBluetoothGattCharacteristic characteristic) {
    final value = characteristic.getValue();
    if (value.isEmpty || value[0] != Defines.CMD_DEVICE_HEADER) return;

    final uuid = characteristic.getUuid().toLowerCase();
    final bytes = Uint8List.fromList(value);

    if (uuid == Defines.UUID_SSU_CHAR.toLowerCase()) {
        _handleCommand(bytes);
    }
  }
}