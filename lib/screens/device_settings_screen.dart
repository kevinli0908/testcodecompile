import 'package:flutter/material.dart';
import 'package:flutter_bee_project/services/bluetooth/omni_gatt_manager.dart';
import '../models/device_model.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth/ota_manager.dart';
import '../services/storage/storage_service.dart';
import '../services/bluetooth/defines.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final DeviceModel device;
  final Function(DeviceModel) onUpdateDevice;
  final VoidCallback onBackToGesture;

  const DeviceSettingsScreen({
    super.key,
    required this.device,
    //required this.onSectionTap,
    required this.onUpdateDevice,
    required this.onBackToGesture,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen>  with AutomaticKeepAliveClientMixin
    implements OTACallback{
  final StorageService _storage = StorageService();
  late int _connectStatus;
  //bool _isConnecting = true;
  int _batteryPercentage = 0;
  String _currentVersion = "";
  String _newVersion = "";

  bool _isUpgrading = false;
  double _upgradeProgress = 0.0;

  final double _batteryWidth = 58;
  final double _batteryHeight = 30;

  @override
  bool get wantKeepAlive => true;  // 关键：保持页面状态不被销毁

  @override
  void onDeviceNotFound() {
    debugPrint("onDeviceNotFound:");
    if (mounted) {
      setState(() {
        _connectStatus = OmniGattManager.instance.getGattState();
        //_isConnected = false;
      });
    }
  }

  @override
  void onFirmwareAvailable(String rcuVer, String imgVer, bool upgrade) {
    debugPrint("onFirmwareAvailable: rcuVer=$rcuVer, imgVer=$imgVer, upgrade=$upgrade");
    if (mounted) {
      setState(() {
        //_isConnected = true;
        _connectStatus = OmniGattManager.instance.getGattState();
        _currentVersion = rcuVer;
        _newVersion = imgVer;
        _batteryPercentage = OmniGattManager.instance.getBatteryLevel();
        _saveDeviceStatus();
      });

    }
  }

  @override
  void onFirmwareUpToDate(String rcuVer) {
    debugPrint("onFirmwareUpToDate: rcuVer=$rcuVer");
  }

  @override
  void onFirmwareUpdateResult(String result) {
    debugPrint("onFirmwareUpdateResult: result=$result");
    // 升级完成，重置进度
    if (mounted) {
      setState(() {
        if(result == "ota completed successfully"){
            _currentVersion = _newVersion;
            _saveDeviceStatus();
        }
        _isUpgrading = false;
        _upgradeProgress = 0.0;
      });
    }
  }

  @override
  void onFirmwareUpdating(int current, int total, int repeatCount) {
    //debugPrint("onFirmwareUpdating: current=$current, total=$total, repeatCount=$repeatCount");
    // 更新进度
    if (mounted) {
      setState(() {
        _isUpgrading = true;
        _upgradeProgress = current / total;
      });
    }
  }

  @override
  void onGattConnectionStateChanged(int state) {
    if (mounted) {
      setState(() {
        _connectStatus = OmniGattManager.instance.getGattState();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _connectStatus = OmniGattManager.instance.getGattState();
    _loadDeviceStatus();
    _connectBleDevice();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    OTAManager.instance.unregisterCallback();

  }

  void _loadDeviceStatus() async{
    setState(() {
      _batteryPercentage = _storage.getBatteryPercentage();
      _currentVersion = _storage.getCurrentVersion();
      _newVersion = _storage.getNewVersion();
      //_isConnected = _storage.getLastConnected();
    });
  }

  void _saveDeviceStatus() async{
    await _storage.saveBatteryPercentage(_batteryPercentage);
    await _storage.saveCurrentVersion(_currentVersion);
    await _storage.saveNewVersion(_newVersion);
    //await _storage.saveLastConnected(_isConnected);
  }

  void _connectBleDevice() async{
    OTAManager.instance.registerCallback(this);
    OTAManager.instance.connectOmniDevice();

    /*  await _bleManager.connectAndListen(
      onConnected: () {
         print('连接成功');
         //_otaManager.startOTA()
      },
      onDisconnected: () {
        print('断开连接');
      },
      onDataReceived: (data) {
        print('收到数据: $data');
    }
    );*/
  }

  String get _connectText {
    if (_connectStatus == Defines.STATE_GATT_CONNECTING || _connectStatus == Defines.STATE_GATT_MTU_EXCHANGE) {
      return 'Connecting';
    } else if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return 'Connected';
    } else {
      return 'Disconnected';
    }
  }

  Color get _connectColor {
    if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return AppTheme.ble_connect;
    } else {
      return AppTheme.ble_disconnect;
    }
  }

  Color get _connectBkColor {
    if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return AppTheme.ble_connect_bk;
    } else {
      return AppTheme.ble_disconnect_bk;
    }
  }

  IconData get _batteryIcon {
    if (_connectStatus == Defines.STATE_GATT_CONNECTING || _connectStatus == Defines.STATE_GATT_MTU_EXCHANGE) {
      return Icons.battery_0_bar;
    } else if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return Icons.battery_std;
    } else {
      return Icons.battery_0_bar;
    }
  }

  bool get _isConnected{
    if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return true;
    } else {
      return false;
    }
  }

  bool get _availableUpdate{
      if(_currentVersion == null || _currentVersion.isEmpty){
        return false;
      }

      if(_newVersion == null || _newVersion.isEmpty){
        return false;
      }

      if(_newVersion.compareTo(_currentVersion) > 0){
        return true;
      }

      return false;
  }

  bool get _isCanPressUpdate{
    if(_isConnected && _availableUpdate && !_isUpgrading){
      return true;
    }else{
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    // 确保 percent 在 0 ~ 100 范围内
    final clampedPercent = _batteryPercentage.clamp(0.0, 100.0);
    // 根据电量决定颜色
    final batteryFillColor = clampedPercent > 20 ? Colors.green : Colors.red;
    // 内部可用宽度 = 总宽 - 边框(3x2) - padding(4x2)
    final innerWidth = _batteryWidth - 14; // 58 - 6 - 8 = 44
    final fillWidth =  (innerWidth * (clampedPercent / 100));

    debugPrint("build: fillWidth=$fillWidth");

    return WillPopScope(
      onWillPop: () async {
        widget.onBackToGesture();
        return false;
      },
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              leading: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    widget.onBackToGesture();
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/icon_004.png'),
                    size: 20,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),


              title: const Text(
                'Device Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppTheme.background,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 12,
              automaticallyImplyLeading: false,
            ),
            const SizedBox(height: 20),

            // Device Status Card
            Card(
              color: Color.fromARGB(255,14,23,41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: AppTheme.cardPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Device',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _connectText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.device.isConnected
                                ? Colors.grey
                                : Colors.grey,
                          ),
                        ),

                        Text(
                          'Battery: $_batteryPercentage%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    //const SizedBox(width: 145),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(right: 0), // 🔑 距离右边缘 10px
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 电池主体
                          Container(
                            width: _batteryWidth,
                            height: _batteryHeight,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FractionallySizedBox(
                                widthFactor: clampedPercent / 100,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: batteryFillColor,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: batteryFillColor.withOpacity(0.38),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 正极凸起
                          Container(
                            width: 5,
                            height: 12,
                            margin: const EdgeInsets.only(left: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),

                   /* Icon(
                      _batteryIcon,
                      color: _getBatteryColor(widget.device.batteryPercentage),
                    ),*/
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Firmware Version update
            Card(
              color: Color.fromARGB(255,14,23,41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: AppTheme.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firmware Update',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      color: _connectBkColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _connectColor,
                          width: 0.2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _connectColor,
                                  width: 0.2,
                                ),
                              ),
                              child: ImageIcon(
                                AssetImage('assets/images/icon_007.png'),
                                size: 20,
                                color: _connectColor,
                              ),
                            ),
                            SizedBox(width: 12),

                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _connectColor,
                                shape: BoxShape.circle,
                              ),
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bluetooth connection',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _connectText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Current version: $_currentVersion',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'New version: $_newVersion available',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Updates require an active Bluetooth connection',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),

                    if (_isUpgrading) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _upgradeProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_upgradeProgress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCanPressUpdate
                            ? () {
                          // 点击升级逻辑
                          OTAManager.instance.startOTA();
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCanPressUpdate ? Colors.blue : Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Upgrade Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _isCanPressUpdate ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Firmware Version Card
            Card(
              color: Color.fromARGB(255,14,23,41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: AppTheme.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firmware Version',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                     Text(
                        _currentVersion,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBatteryColor(int percentage) {
    if (percentage >= 70) return AppTheme.successGreen;
    if (percentage >= 30) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

}