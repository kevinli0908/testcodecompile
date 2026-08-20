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

/// OTA 回调接口
abstract class OTACallback {
  void onDeviceNotFound();

  /// @param rcuVer RCU版本
  /// @param imgVer 镜像版本
  /// @param upgrade true:升级, false:降级
  void onFirmwareAvailable(String rcuVer, String imgVer, bool upgrade);

  void onFirmwareUpToDate(String rcuVer);
  void onFirmwareUpdating(int current, int total, int repeatCount);
  void onFirmwareUpdateResult(String result);
  void onGattConnectionStateChanged(int state);
}

/// OTA 管理器
class OTAManager {
  static const String TAG = "OMNI.BEE.OTAManager";

  static final OTAManager _instance = OTAManager._internal();
  static OTAManager get instance => _instance;

  late final ImageManager _imageManager;

  OTACallback? _callback;

  // 状态
  int _gattStatus = Defines.STATE_GATT_DISCONNECTED;
  bool _otaInProgress = false;
  bool _ssuStarted = false;
  int _retryTimes = Defines.MAX_RETRY_TIMES;

  // 数据
  final Uint8List _rcuVersion = Uint8List(2); // [0]:versionMinor, [1]:versionMajor
  String _imageName = "";
  int _maxTransactionSize = Defines.DEFAULT_MAX_TRANSACTION_SIZE;
  int _packageNum = 0;
  int _packageCount = 0;
  int _subPackageCount = 0;

  // 定时器
  Timer? _reconnectTimer;

  // 静态标志
  static bool activityStarted = false;

  // ==================== 回调实现 ====================

  late ImageCallback _imageCallback;

  late _OmniGattCallbackImpl _omniBleCallback;

  // 私有构造函数
  OTAManager._internal() {
    _init();
  }

  // 防止外部实例化
  factory OTAManager() {
    return _instance;
  }

  void _init() {
    _imageManager = ImageManager();
    _imageCallback = _ImageCallbackImpl(this);
    _omniBleCallback = _OmniGattCallbackImpl(this);
    _imageManager.registerCallback(_imageCallback);
    OmniGattManager.instance.registerOTACallback(_omniBleCallback);
  }

  void release() {
    _reconnectTimer?.cancel();
    _imageManager.unregisterCallback();
    _imageManager.release();
    OmniGattManager.instance.unregisterOTACallback();
  }

  void registerCallback(OTACallback callback) {
    _callback = callback;
  }

  void unregisterCallback() {
    _callback = null;
  }

  void connectOmniDevice() {
    debugPrint("$TAG connectOmniDevice");
    if (_gattStatus == Defines.STATE_GATT_CONNECTED) {
        _callback?.onGattConnectionStateChanged(_gattStatus);
        _getRcuInfo();
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

  void startOTA() {
    debugPrint("$TAG startOTA");
    final bytes = Uint8List.fromList([
      Defines.CMD_HEADER,
      Defines.CMD_HOST_START_IMAGE_TRANSFER,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ]);
    _writeData(Defines.UUID_OTA_COMMAND, bytes);
  }

  void stopOTA() {
    debugPrint("$TAG stopOTA");
    final bytes = Uint8List.fromList([
      Defines.CMD_HEADER,
      Defines.CMD_HOST_STOP_REMOTE,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ]);
    _writeData(Defines.UUID_OTA_COMMAND, bytes);
  }

  /// 发送 SSU 命令
  void sendSsuCommand(int command) {
    debugPrint("$TAG sendSsuCommand: command=$command");
    if (command == 1) {
      _ssuStarted = true;
      stopOTA();
    } else if (command == 2) {
      _ssuStarted = false;
      if (_otaInProgress) {
        _getRcuInfo();
      }
    }
  }

  // ==================== 私有方法 ====================

  void _getRcuInfo() {
    debugPrint("$TAG _getRcuInfo");
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
      case Defines.CMD_RCU_RETURN_REMOTE_INFO:
        _handleReturnRemoteInfo(bytes);
        break;

      case Defines.CMD_RCU_GET_IMAGE_INFO:
        _handleGetImageInfo();
        break;

      case Defines.CMD_RCU_RETURN_UPGRADE_RESULT:
        _handleReturnUpgradeResult(bytes);
        break;

      case Defines.CMD_RCU_SET_MAX_TRANSACTION_SIZE:
        _handleSetMaxTransactionSize(bytes);
        break;

      case Defines.CMD_RCU_READY_FOR_RESUME:
      case Defines.CMD_RESTART_OTA:
        _getRcuInfo();
        break;

      default:
        break;
    }
  }

  void _handleBlock(Uint8List bytes) {
    _otaInProgress = true;
    _packageNum = Defines.bytesToInt(bytes, 1, 3, true);
    int blockSize = Defines.bytesToInt(bytes, 5, 2, true);
    _subPackageCount = (blockSize ~/ _maxTransactionSize) +
        ((blockSize % _maxTransactionSize) > 0 ? 1 : 0);

    //debugPrint("$TAG handleBlock: packageNum=$_packageNum, blockSize=$blockSize, subPackageCount=$_subPackageCount");
    _sendImageBlock(_packageNum);
  }

  void _sendImageBlock(int blockNum) {
    //debugPrint("$TAG sendImageBlock: blockNum=$blockNum");
    if (_ssuStarted) return;

    int position = (blockNum - 1) * _maxTransactionSize + Defines.IMAGE_HEADER_LENGTH;
    final blockData = _imageManager.getBlockData(_imageName, position, _maxTransactionSize);

    if (blockData == null) {
      debugPrint("$TAG sendImageBlock: get block data failed!");
      return;
    }

    final bytes = Uint8List(blockData.length + 4);
    bytes[0] = Defines.CMD_HEADER;
    bytes[1] = (blockNum & 0x000000FF);
    bytes[2] = ((blockNum & 0x0000FF00) >> 8);
    bytes[3] = ((blockNum & 0x00FF0000) >> 16);

    for (int i = 0; i < blockData.length; i++) {
      bytes[i + 4] = blockData[i];
    }

    _writeData(Defines.UUID_OTA_BLOCK, bytes);

    if (_callback != null) {
      if (_packageCount == 0) {
        _packageCount = _imageManager.getBlockCount(_imageName, _maxTransactionSize);
      }
      _callback!.onFirmwareUpdating(blockNum, _packageCount, 0);
    }
  }

  void _handleReturnRemoteInfo(Uint8List bytes) {
    _rcuVersion[0] = bytes[2];
    _rcuVersion[1] = bytes[3];

    String strRcuVersion = Defines.getVersionString(_rcuVersion);
    int rcuId = Defines.bytesToInt(bytes, 4, 2, true);

    debugPrint("$TAG handleReturnRemoteInfo: RCU ID=$rcuId, RCU Version=$strRcuVersion");

    _packageCount = 0;
    _imageManager.findImage(rcuId, _rcuVersion);
  }

  void _handleGetImageInfo() {
    final imageHeader = _imageManager.getImageHeader(_imageName);
    if (imageHeader == null) {
      debugPrint("$TAG handleGetImageInfo: get Image Header failed! image=$_imageName");
      return;
    }

    final bytes = Uint8List(2 + imageHeader.length);
    bytes[0] = Defines.CMD_HEADER;
    bytes[1] = Defines.CMD_HOST_RETURN_IMAGE_INFO;
    for (int i = 0; i < imageHeader.length; i++) {
      bytes[i + 2] = imageHeader[i];
    }
    _writeData(Defines.UUID_OTA_COMMAND, bytes);
  }

  void _handleReturnUpgradeResult(Uint8List bytes) {
    int result = bytes[2];
    debugPrint("$TAG handleReturnUpgradeResult: result=${Defines.getResultName(result)}");

    switch (result) {
      case Defines.RESULT_RCU_BATTERY_LOW:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_OTA_ONGOING:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_INVALID_IMAGE:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_OTA_COMPLETED_SUCCESSFULLY:
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_IMAGE_SIZE_LIMIT_EXCEEDED:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_CRC_ERROR:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_RCU_ABORTED_OTA:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_NO_OTA_ONGOING:
        disconnectGatt();
        _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        break;

      case Defines.RESULT_TIME_OUT:
        if (_ssuStarted) return;
        if (_retryTimes > 0) {
          _retryTimes--;
          _reconnectTimer = Timer(const Duration(seconds: 1), () {
            _getRcuInfo();
          });
        } else {
          disconnectGatt();
          _callback?.onFirmwareUpdateResult(Defines.getResultName(result));
        }
        break;

      default:
        break;
    }
  }

  void _handleSetMaxTransactionSize(Uint8List bytes) {
    _maxTransactionSize = Defines.bytesToInt(bytes, 2, 2, true);
    debugPrint("$TAG handleSetMaxTransactionSize: maxTransactionSize=$_maxTransactionSize");

    // 返回最大传输大小
    final command = Uint8List.fromList([
      Defines.CMD_HEADER,
      Defines.CMD_HOST_RETURN_MAX_TRANSACTION_SIZE,
      bytes[2], bytes[3],
      0x00, 0x00, 0x00, 0x00
    ]);
    _writeData(Defines.UUID_OTA_COMMAND, command);
  }

  Future<bool> _writeData(String uuid, Uint8List bytes) async {
    return await  OmniGattManager.instance.writeData(Defines.UUID_OTA_SERV, uuid, bytes);
  }

  String _dump(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }


}

/// 图像回调实现
class _ImageCallbackImpl implements ImageCallback {
  static const String TAG = "_ImageCallbackImpl";
  final OTAManager _manager;

  _ImageCallbackImpl(this._manager);

  @override
  void onImageNotFound(int softwareID) {
    debugPrint("$TAG onImageNotFound: softwareID=$softwareID");
    _manager._handleImageNotFound(softwareID);
  }

  @override
  void onImageInfo(String imageName, int imageID, Uint8List imageVersion, int imageSize) {
    debugPrint("$TAG onImageInfo: imageName=$imageName, imageID=$imageID, imageVersion=$imageVersion, imageSize=$imageSize");
    _manager._handleImageInfo(imageName, imageID, imageVersion, imageSize);
  }
}

/// OmniBle 回调实现
class _OmniGattCallbackImpl implements OmniGattCallback {
  final OTAManager _manager;

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

// 扩展 OTAManager 的回调处理方法
extension OTAManagerHandlers on OTAManager {
  void _handleImageNotFound(int softwareID) {
    disconnectGatt();
    if (_callback != null) {
      String strRcuVersion = Defines.getVersionString(_rcuVersion);
      _callback!.onFirmwareUpToDate(strRcuVersion);
    }
  }

  void _handleImageInfo(String imageName, int imageID, Uint8List imageVersion, int imageSize) {
    String strImageVersion = Defines.getVersionString(imageVersion);
    debugPrint("$OTAManager.TAG onImageInfo: imageName=$imageName, imageId=$imageID, imageVersion=$strImageVersion, imageSize=$imageSize");

    _imageName = imageName;
    String strRcuVersion = Defines.getVersionString(_rcuVersion);

    int intRcuVersion = Defines.bytesToInt(_rcuVersion, 0, 2, true);
    int intImageVersion = Defines.bytesToInt(imageVersion, 0, 2, true);

    _callback?.onFirmwareAvailable(strRcuVersion, strImageVersion, true);

    /*if (intImageVersion == intRcuVersion) {
      // 无需升级
      disconnectGatt();
      _callback?.onFirmwareUpToDate(strRcuVersion);
    } else if (intImageVersion > intRcuVersion) {
      // 升级（镜像版本 > RCU版本）
      _callback?.onFirmwareAvailable(strRcuVersion, strImageVersion, true);
    } else {
      // 降级（镜像版本 < RCU版本），留给UI决定
      _callback?.onFirmwareAvailable(strRcuVersion, strImageVersion, false);
    }*/
  }

  void _handleDeviceNotFound() {
    _callback?.onDeviceNotFound();
  }

  void _handleDeviceConnectionStateChanged(int state) {
   /* if (state == 2 && _gattStatus == Defines.STATE_GATT_DISCONNECTED) {
      connectOmniDevice();
    }*/
  }

  void _handleGattConnectionStateChanged(int state) {
    debugPrint("$OTAManager.TAG _handleGattConnectionStateChanged = $state");
    _gattStatus = state;
    if (state == Defines.STATE_GATT_CONNECTED) {
      _retryTimes = Defines.MAX_RETRY_TIMES;
      Future.delayed(const Duration(seconds: 1), () {
        _getRcuInfo();
      });
    } else if (state == Defines.STATE_GATT_DISCONNECTED) {
      _otaInProgress = false;
    }

    _callback?.onGattConnectionStateChanged(state);
  }

  void _handleCharacteristicWrite(OmniBluetoothGattCharacteristic characteristic) {
    if (characteristic.getUuid().toLowerCase() == Defines.UUID_OTA_BLOCK.toLowerCase()) {
      //debugPrint("_handleCharacteristicWrite _subPackageCount = $_subPackageCount");
      if (_subPackageCount > 1) {
        _subPackageCount--;
        _packageNum = Defines.bytesToInt(characteristic.getValue(), 1, 3, true);

        Future.microtask(() {
          _sendImageBlock(_packageNum + 1);
        });
      }
    }
  }

  void _handleCharacteristicChanged(OmniBluetoothGattCharacteristic characteristic) {
    final value = characteristic.getValue();
    if (value.isEmpty || value[0] != Defines.CMD_HEADER) return;

    final uuid = characteristic.getUuid().toLowerCase();
    final bytes = Uint8List.fromList(value);

    if (uuid == Defines.UUID_OTA_COMMAND.toLowerCase()) {
      _handleCommand(bytes);
    } else if (uuid == Defines.UUID_OTA_BLOCK.toLowerCase()) {
      _handleBlock(bytes);
    }
  }
}