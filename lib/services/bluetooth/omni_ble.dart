// lib/services/bluetooth/omni_ble.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'defines.dart';

/// OmniBle 回调接口
abstract class OmniBleCallback {
  void onDeviceNotFound();
  void onDeviceBondStateChanged(BluetoothDevice device, int state);
  void onDeviceConnectionStateChanged(BluetoothDevice device, int state);
  void onGattConnectionStateChanged(BluetoothDevice device, int state);
  void onCharacteristicWrite(OmniBluetoothGattCharacteristic characteristic);
  void onCharacteristicRead(OmniBluetoothGattCharacteristic characteristic);
  void onCharacteristicChanged(OmniBluetoothGattCharacteristic  characteristic);
}

/// 蓝牙 GATT 特征值封装类
class OmniBluetoothGattCharacteristic {
  final String uuid;
  final List<int> value;

  OmniBluetoothGattCharacteristic({required this.uuid, required this.value});

  String getUuid() => uuid;
  List<int> getValue() => value;
}

/// OmniBle - 蓝牙管理类
class OmniBle {
  static const String TAG = "OMNI.OTA.OmniBle";

  // 回调
  OmniBleCallback? _callback;

  // 状态
  List<BluetoothDevice> _connectedDeviceList = [];
  BluetoothDevice? _currentDevice;
  BluetoothCharacteristic? _otaCommandChar;
  BluetoothCharacteristic? _otaBlockChar;
  BluetoothCharacteristic? _batteryChar;
  int _batteryLevel = 0;
  int _gattState = Defines.STATE_GATT_DISCONNECTED;

  // 查找设备相关
  bool _findDeviceByName = true;
  // hp 连接速度慢，传输数据多 128 根据mtu来
  // claro 连接速度快，传输 16 根据mtu来
  String _targetDeviceName = "HP_RC4111801";
  //String _targetDeviceName = "RC_OMNICLAROBR";
  //String _targetDeviceName = "StarHub RC396";

  // 通知特征值列表
  final List<String> _notifyList = [];

  // 流订阅
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _commandNotificationSubscription;
  StreamSubscription<List<int>>? _blockNotificationSubscription;

  static final OmniBle _instance = OmniBle._internal();

  /// 获取单例实例
  static OmniBle get instance => _instance;

  /// 私有构造函数
  OmniBle._internal() {
    _init();
  }

  /// 工厂构造函数，返回单例
  factory OmniBle() {
    return _instance;
  }

  void _init() {
    // 监听蓝牙适配器状态
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      debugPrint("$TAG adapterState: $state");
    });

    startCharacteristicWirteListening();
  }

  void release() {
    _adapterStateSubscription?.cancel();
    _connectionSubscription?.cancel();
    _commandNotificationSubscription?.cancel();
    _blockNotificationSubscription?.cancel();
    disconnectGatt();
  }

  void registerCallback(OmniBleCallback callback) {
    _callback = callback;
  }

  void unregisterCallback() {
    _callback = null;
  }

  /// 查找 Omni 遥控器设备
  Future<void> findOmniRemote() async {
    debugPrint("$TAG findOmniRemote");

    // 获取已配对的设备
    _connectedDeviceList = await FlutterBluePlus.connectedSystemDevices;
    await _connectDevice();
  }

  /// 按名称查找 Omni 遥控器设备
  Future<void> findOmniRemoteByName(String name) async {
    debugPrint("$TAG findOmniRemoteByName: name=$name");
    _findDeviceByName = true;
    _targetDeviceName = name;
    await findOmniRemote();
  }

  /// 断开 GATT 连接
  void disconnectGatt() {
    debugPrint("$TAG disconnectGatt");
    if (_gattState != Defines.STATE_GATT_DISCONNECTED &&
        _currentDevice != null) {
      _currentDevice!.disconnect();
    }
    _gattState = Defines.STATE_GATT_DISCONNECTED;
    _currentDevice = null;
    _otaCommandChar = null;
    _otaBlockChar = null;
  }

  // 在 initState 或合适的地方开始监听
  void startCharacteristicWirteListening() {
    FlutterBluePlus.events.onCharacteristicWritten.listen((event) {
      //debugPrint("$TAG CharacteristicWirte success!");
      _callback?.onCharacteristicWrite(
          OmniBluetoothGattCharacteristic(uuid: event.characteristic.uuid.toString(), value: event.value),
      );

    });
  }

  /// 写入数据
  Future<bool> writeData(
    String uuidServ,
    String uuidChar,
    List<int> data,
  ) async {
    if (_gattState != Defines.STATE_GATT_CONNECTED) {
      debugPrint("$TAG writeData: gatt not connected! state=$_gattState");
      return false;
    }

    if (_currentDevice == null) {
      debugPrint("$TAG writeData: device not connected!");
      return false;
    }

    try {
      BluetoothCharacteristic? characteristic;

      if (uuidChar.toLowerCase() == Defines.UUID_OTA_COMMAND.toLowerCase()) {
        characteristic = _otaCommandChar;
      } else if (uuidChar.toLowerCase() ==
          Defines.UUID_OTA_BLOCK.toLowerCase()) {
        characteristic = _otaBlockChar;
      }

      if (characteristic == null) {
        debugPrint("$TAG writeData: characteristic not found!");
        return false;
      }

      // data,withoutResponse: true must
      if (_targetDeviceName == "RC_OMNICLAROBR") {
        if (uuidChar.toLowerCase() == Defines.UUID_OTA_COMMAND.toLowerCase()) {
          await characteristic.write(data);
        } else {
          await characteristic.write(data, withoutResponse: true);
        }
      } else {
        await characteristic.write(data, withoutResponse: true);
      }

     /* _callback?.onCharacteristicWrite(
        BluetoothGattCharacteristic(uuid: uuidChar, value: data),
      );*/

      return true;
    } catch (e) {
      debugPrint("$TAG writeData: write failed - $e");
      return false;
    }
  }

  // ==================== 私有方法 ====================

  /// 连接设备
  Future<void> _connectDevice() async {
    debugPrint("$TAG connectDevice: gattState=$_gattState");

    if (_gattState == Defines.STATE_GATT_CONNECTING) {
      if (_currentDevice != null && _callback != null) {
        _callback!.onGattConnectionStateChanged(_currentDevice!, _gattState);
      }
      return;
    }

    if (_connectedDeviceList.isEmpty) {
      if (_callback != null) {
        _callback!.onDeviceNotFound();
      }
      return;
    }

    // 按名称筛选设备
    BluetoothDevice? targetDevice;
    if (_findDeviceByName && _targetDeviceName.isNotEmpty) {
      for (var device in _connectedDeviceList) {
        if (device.platformName == _targetDeviceName) {
          targetDevice = device;
          break;
        }
      }
      if (targetDevice == null) {
        debugPrint(
          "$TAG connectDevice: device with name $_targetDeviceName not found",
        );
        if (_callback != null) {
          _callback!.onDeviceNotFound();
        }
        return;
      }
      _currentDevice = targetDevice;
    } else {
      _currentDevice = _connectedDeviceList[0];
    }

    _gattState = Defines.STATE_GATT_CONNECTING;
    if (_callback != null) {
      _callback!.onGattConnectionStateChanged(_currentDevice!, _gattState);
    }

    // 建立 GATT 连接
    await _connectGatt(_currentDevice!);
  }

  /// 建立 GATT 连接
  Future<void> _connectGatt(BluetoothDevice device) async {
    debugPrint("$TAG _connectGatt: device=${device.platformName}");

    // 发起连接
    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 30),
      autoConnect: false,
    );

    // 监听连接状态
    _connectionSubscription = device.connectionState.listen((state) {
      debugPrint("$TAG onConnectionStateChange: state=$state");

      if (state == BluetoothConnectionState.connected) {
        debugPrint("$TAG GATT connected");
        _gattState = Defines.STATE_GATT_CONNECTING;
        _discoverServices(device);
      } else if (state == BluetoothConnectionState.disconnected) {
        debugPrint("$TAG GATT disconnected");
        _gattState = Defines.STATE_GATT_DISCONNECTED;
        if (_callback != null) {
          _callback!.onGattConnectionStateChanged(device, _gattState);
        }
        _currentDevice = null;
        _otaCommandChar = null;
        _otaBlockChar = null;
        _connectionSubscription?.cancel();
        _connectionSubscription = null;
      }
    });
  }

  /// 发现服务
  Future<void> _discoverServices(BluetoothDevice device) async {
    debugPrint("$TAG discoverServices: device=${device.platformName}");

    try {
      final services = await device.discoverServices();

      BluetoothService? otaService;
      BluetoothService? batteryService;
      for (var service in services) {
        debugPrint(
          "$TAG discoverServices service UUID:${service.uuid.toString()}",
        );
        if (service.uuid.toString().toLowerCase() ==
            Defines.UUID_OTA_SERV.toLowerCase()) {
          otaService = service;
          //break;
        }

        if (service.uuid.toString().toLowerCase() ==
            Defines.UUID_BATTERY_SERV.toLowerCase()) {
          batteryService = service;
          //break;
        }

        if (otaService != null && batteryService != null) {
          break;
        }
      }

      if (otaService == null) {
        debugPrint("$TAG discoverServices: OTA UUID not found!");
        _gattState = Defines.STATE_GATT_DISCONNECTING;
        await device.disconnect();
        // 连接下一个设备
        if (_connectedDeviceList.isNotEmpty) {
          _connectedDeviceList.remove(device);
          await _connectDevice();
        }
        return;
      }

      if (batteryService == null) {
        debugPrint("$TAG discoverServices: Battery UUID not found!");
        return;
      }

      // 查找 OTA Command 和 OTA Block 特征值
      for (var characteristic in otaService.characteristics) {
        final uuidStr = characteristic.uuid.toString().toLowerCase();
        if (uuidStr == Defines.UUID_OTA_COMMAND.toLowerCase()) {
          _otaCommandChar = characteristic;
          _notifyList.add(Defines.UUID_OTA_COMMAND);
        } else if (uuidStr == Defines.UUID_OTA_BLOCK.toLowerCase()) {
          _otaBlockChar = characteristic;
          _notifyList.add(Defines.UUID_OTA_BLOCK);
        }
      }

      for (var characteristic in batteryService.characteristics) {
        final uuidStr = characteristic.uuid.toString().toLowerCase();
        if (uuidStr == Defines.UUID_BATTERY_CHAR.toLowerCase()) {
          _batteryChar = characteristic;
          readBatteryLevel();
        }
      }

      if (_notifyList.isNotEmpty) {
        await _setNotify(_otaCommandChar!);
      }
    } catch (e) {
      debugPrint("$TAG discoverServices: error - $e");
      _gattState = Defines.STATE_GATT_DISCONNECTING;
      await device.disconnect();
      if (_connectedDeviceList.isNotEmpty) {
        _connectedDeviceList.remove(device);
        await _connectDevice();
      }
    }
  }

  /// 设置通知
  Future<bool> _setNotify(BluetoothCharacteristic characteristic) async {
    debugPrint("$TAG setNotify: uuid=${characteristic.uuid}");

    if (_currentDevice == null) {
      debugPrint("$TAG setNotify: device not connected");
      return false;
    }

    try {
      // 启用通知
      await characteristic.setNotifyValue(true);

      // 监听特征值变化
      final uuidStr = characteristic.uuid.toString().toLowerCase();
      if (uuidStr == Defines.UUID_OTA_COMMAND.toLowerCase()) {
        _commandNotificationSubscription = characteristic.onValueReceived
            .listen((value) {
              _onCharacteristicChanged(characteristic, value);
            });
      } else if (uuidStr == Defines.UUID_OTA_BLOCK.toLowerCase()) {
        _blockNotificationSubscription = characteristic.onValueReceived.listen((
          value,
        ) {
          _onCharacteristicChanged(characteristic, value);
        });
      }

      // 移除已设置的通知特征值
      if (_notifyList.isNotEmpty) {
        _notifyList.removeAt(0);

        if (_notifyList.isNotEmpty) {
          final nextUuid = _notifyList[0];
          if (nextUuid == Defines.UUID_OTA_COMMAND && _otaCommandChar != null) {
            await _setNotify(_otaCommandChar!);
          } else if (nextUuid == Defines.UUID_OTA_BLOCK &&
              _otaBlockChar != null) {
            await _setNotify(_otaBlockChar!);
          }
        } else {
          // MTU 交换
          _gattState = Defines.STATE_GATT_MTU_EXCHANGE;
          if (_callback != null) {
            _callback!.onGattConnectionStateChanged(
              _currentDevice!,
              _gattState,
            );
          }
          await _requestMtu(247);
        }
      }

      return true;
    } catch (e) {
      debugPrint("$TAG setNotify: failed - $e");
      return false;
    }
  }

  /// 请求 MTU
  Future<bool> _requestMtu(int mtu) async {
    debugPrint("$TAG requestMtu: mtu=$mtu");

    if (_currentDevice == null) {
      return false;
    }

    try {
      // flutter_blue_plus 的 requestMtu
      await _currentDevice!.requestMtu(mtu);

      _gattState = Defines.STATE_GATT_CONNECTED;
      if (_callback != null) {
        _callback!.onGattConnectionStateChanged(_currentDevice!, _gattState);
      }
      return true;
    } catch (e) {
      debugPrint("$TAG requestMtu: failed - $e");
      _gattState = Defines.STATE_GATT_CONNECTED;
      if (_callback != null) {
        _callback!.onGattConnectionStateChanged(_currentDevice!, _gattState);
      }
      return false;
    }
  }

  // ==================== 回调方法 ====================

  void _onCharacteristicChanged(
    BluetoothCharacteristic characteristic,
    List<int> value,
  ) {
    final uuidStr = characteristic.uuid.toString().toLowerCase();

    if (uuidStr == Defines.UUID_OTA_COMMAND.toLowerCase()) {
      _callback?.onCharacteristicChanged(
        OmniBluetoothGattCharacteristic(
          uuid: Defines.UUID_OTA_COMMAND,
          value: value,
        ),
      );
    } else if (uuidStr == Defines.UUID_OTA_BLOCK.toLowerCase()) {
      _callback?.onCharacteristicChanged(
        OmniBluetoothGattCharacteristic(uuid: Defines.UUID_OTA_BLOCK, value: value),
      );
    }
  }

  // ==================== 辅助方法 ====================

  int getGattState() => _gattState;

  int getBatteryLevel() => _batteryLevel;

  Future<void> readBatteryLevel() async {
    if (_batteryChar == null) {
      debugPrint("$TAG battery level _batteryChar is null");
    } else {
      final value = await _batteryChar!.read();
      if (value.isNotEmpty) {
        _batteryLevel = value[0];
        debugPrint("$TAG battery level: $_batteryLevel%");
      } else {
        debugPrint("$TAG battery level value is null");
      }
    }
  }

  String _dump(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
